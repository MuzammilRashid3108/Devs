import 'package:cloud_firestore/cloud_firestore.dart';
import '../../profile/data/user-service.dart';
import '../domain/progress_model.dart';
import '../domain/level_model.dart';

class ProgressService {
  final _db          = FirebaseFirestore.instance;
  final _userService = UserService();

  // ── Path helper ───────────────────────────────────────────────────────────
  CollectionReference _progress(String uid) =>
      _db.collection('users').doc(uid).collection('progress');

  // ── Load all progress for a user ──────────────────────────────────────────
  Future<Map<String, UserProgress>> getUserProgress(String uid) async {
    try {
      final snap = await _progress(uid).get();
      return {
        for (final doc in snap.docs)
          doc.id: UserProgress.fromMap(doc.id, doc.data() as Map<String, dynamic>)
      };
    } catch (e) {
      print('getUserProgress error: $e');
      return {};
    }
  }

  // ── Stream progress (real-time map updates) ───────────────────────────────
  Stream<Map<String, UserProgress>> streamUserProgress(String uid) {
    return _progress(uid).snapshots().map((snap) => {
      for (final doc in snap.docs)
        doc.id: UserProgress.fromMap(doc.id, doc.data() as Map<String, dynamic>)
    });
  }

  // ── Initialise progress for a new user (call after signup) ───────────────
  // Sets level 1 as active, everything else locked.
  Future<void> initProgress(String uid, List<Level> levels) async {
    final existing = await _progress(uid).limit(1).get();
    if (existing.docs.isNotEmpty) return; // already initialised

    final batch = _db.batch();
    for (var i = 0; i < levels.length; i++) {
      final level = levels[i];
      final ref   = _progress(uid).doc(level.id);
      batch.set(ref, UserProgress(
        levelId:  level.id,
        // ✅ First level is active, all others locked
        status:   i == 0 ? LevelStatus.active : LevelStatus.locked,
        stars:    0,
        attempts: 0,
      ).toMap());
    }
    await batch.commit();
  }

  // ── Force a specific level to 'active' ────────────────────────────────────
  // Used as a recovery mechanism when a user has all levels locked
  // (e.g. progress was never initialised, Firestore write failed, etc.).
  Future<void> forceActivate(String uid, String levelId) async {
    try {
      await _progress(uid).doc(levelId).set(
        UserProgress(
          levelId:  levelId,
          status:   LevelStatus.active,
          stars:    0,
          attempts: 0,
        ).toMap(),
        // Merge so we don't blow away attempts/completedAt if the doc exists
        SetOptions(merge: true),
      );
    } catch (e) {
      print('forceActivate error: $e');
      // Non-fatal: the UI will just show everything locked still
      rethrow;
    }
  }

  // ── Mark a level as complete ──────────────────────────────────────────────
  Future<void> completeLevel({
    required String uid,
    required String levelId,
    required String? nextLevelId,
    required int    stars,
    required int    xpReward,
  }) async {
    final batch = _db.batch();

    // 1. Mark this level done
    batch.update(_progress(uid).doc(levelId), {
      'status':      'done',
      'stars':       stars,
      'completedAt': Timestamp.now(),
      'attempts':    FieldValue.increment(1),
    });

    // 2. Unlock next level
    if (nextLevelId != null) {
      batch.update(_progress(uid).doc(nextLevelId), {
        'status': 'active',
      });
    }

    await batch.commit();

    // 3. Award XP (outside batch since it hits leaderboard too)
    await _userService.addXP(uid, xpReward);
    await _userService.incrementStreak(uid);
  }

  // ── Increment attempt count (track failed submissions) ────────────────────
  Future<void> recordAttempt(String uid, String levelId) async {
    await _progress(uid).doc(levelId).update({
      'attempts': FieldValue.increment(1),
    });
  }

  // ── Calculate stars based on time taken ───────────────────────────────────
  static int calculateStars({
    required int timeTaken,  // seconds
    required int attempts,
  }) {
    if (attempts > 5 || timeTaken > 600) return 1;  // >10 min or >5 tries
    if (attempts > 2 || timeTaken > 300) return 2;  // >5 min or >2 tries
    return 3;                                        // fast + clean
  }

  // ── Merge levels with user progress for the map screen ───────────────────
  static List<LevelWithProgress> mergeLevelsWithProgress({
    required List<Level>               levels,
    required Map<String, UserProgress> progressMap,
  }) {
    return levels.map((level) {
      final progress = progressMap[level.id] ?? UserProgress.locked(level.id);
      return LevelWithProgress(level: level, progress: progress);
    }).toList();
  }
}

// ── Combined model used by home_screen ───────────────────────────────────────
class LevelWithProgress {
  final Level        level;
  final UserProgress progress;
  const LevelWithProgress({required this.level, required this.progress});

  bool get isDone   => progress.status == LevelStatus.done;
  bool get isActive => progress.status == LevelStatus.active;
  bool get isLocked => progress.status == LevelStatus.locked;
}