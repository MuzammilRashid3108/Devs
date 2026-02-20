import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _users => _db.collection('users');

  // ── Create user doc (called once on signup) ───────────────────────────────
  Future<void> createUserDoc(AppUser user) async {
    final docRef = _users.doc(user.uid);
    final snap   = await docRef.get();

    // Don't overwrite if doc already exists (e.g. Google sign-in on existing account)
    if (!snap.exists) {
      await docRef.set(user.toMap());

      // Seed leaderboard entry
      await _db.collection('leaderboard').doc(user.uid).set({
        'uid':      user.uid,
        'username': user.username,
        'avatar':   user.avatar,
        'xp':       0,
        'mmr':      1000,
        'rank':     0,
      });
    }
  }

  // ── Fetch user doc once ───────────────────────────────────────────────────
  Future<AppUser?> getUser(String uid) async {
    try {
      final snap = await _users.doc(uid).get();
      if (!snap.exists) return null;
      return AppUser.fromMap(snap.data() as Map<String, dynamic>);
    } catch (e) {
      print('getUser error: $e');
      return null;
    }
  }

  // ── Stream user doc (real-time updates on profile page) ───────────────────
  Stream<AppUser?> streamUser(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return AppUser.fromMap(snap.data() as Map<String, dynamic>);
    });
  }

  // ── Update profile fields ─────────────────────────────────────────────────
  Future<void> updateProfile(String uid, {
    String? username,
    String? avatar,
    String? bio,
    String? country,
  }) async {
    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (avatar   != null) updates['avatar']   = avatar;
    if (bio      != null) updates['bio']       = bio;
    if (country  != null) updates['country']   = country;

    if (updates.isNotEmpty) {
      updates['profileComplete'] = true;
      await _users.doc(uid).update(updates);

      // Keep leaderboard username in sync
      if (username != null || avatar != null) {
        final lbUpdates = <String, dynamic>{};
        if (username != null) lbUpdates['username'] = username;
        if (avatar   != null) lbUpdates['avatar']   = avatar;
        await _db.collection('leaderboard').doc(uid).update(lbUpdates);
      }
    }
  }

  // ── Add XP + update MMR ───────────────────────────────────────────────────
  Future<void> addXP(String uid, int amount) async {
    await _users.doc(uid).update({
      'xp':  FieldValue.increment(amount),
    });
    await _db.collection('leaderboard').doc(uid).update({
      'xp':  FieldValue.increment(amount),
    });
  }

  // ── Update MMR (after battle) ─────────────────────────────────────────────
  Future<void> updateMMR(String uid, int newMmr) async {
    await _users.doc(uid).update({'mmr': newMmr});
    await _db.collection('leaderboard').doc(uid).update({'mmr': newMmr});
  }

  // ── Increment streak ──────────────────────────────────────────────────────
  Future<void> incrementStreak(String uid) async {
    await _users.doc(uid).update({
      'streak': FieldValue.increment(1),
    });
  }

  // ── Reset streak ──────────────────────────────────────────────────────────
  Future<void> resetStreak(String uid) async {
    await _users.doc(uid).update({'streak': 0});
  }

  // ── Check if username is taken ────────────────────────────────────────────
  Future<bool> isUsernameTaken(String username) async {
    final snap = await _users
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  // ── Delete account ────────────────────────────────────────────────────────
  Future<void> deleteUser(String uid) async {
    await _users.doc(uid).delete();
    await _db.collection('leaderboard').doc(uid).delete();
  }
}