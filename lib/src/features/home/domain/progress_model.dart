import 'package:cloud_firestore/cloud_firestore.dart';

enum LevelStatus { locked, active, done }

class UserProgress {
  final String      levelId;
  final LevelStatus status;
  final int         stars;       // 0-3
  final int         attempts;
  final DateTime?   completedAt;

  const UserProgress({
    required this.levelId,
    required this.status,
    required this.stars,
    required this.attempts,
    this.completedAt,
  });

  factory UserProgress.fromMap(String levelId, Map<String, dynamic> map) {
    return UserProgress(
      levelId:     levelId,
      status:      _statusFromString(map['status'] as String? ?? 'locked'),
      stars:       map['stars']    as int?  ?? 0,
      attempts:    map['attempts'] as int?  ?? 0,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status':      _statusToString(status),
      'stars':       stars,
      'attempts':    attempts,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  // ── Default for a locked level ────────────────────────────────────────────
  factory UserProgress.locked(String levelId) => UserProgress(
    levelId:  levelId,
    status:   LevelStatus.locked,
    stars:    0,
    attempts: 0,
  );

  UserProgress copyWith({
    LevelStatus? status,
    int?         stars,
    int?         attempts,
    DateTime?    completedAt,
  }) {
    return UserProgress(
      levelId:     levelId,
      status:      status      ?? this.status,
      stars:       stars       ?? this.stars,
      attempts:    attempts    ?? this.attempts,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  static LevelStatus _statusFromString(String s) {
    switch (s) {
      case 'done':   return LevelStatus.done;
      case 'active': return LevelStatus.active;
      default:       return LevelStatus.locked;
    }
  }

  static String _statusToString(LevelStatus s) {
    switch (s) {
      case LevelStatus.done:   return 'done';
      case LevelStatus.active: return 'active';
      case LevelStatus.locked: return 'locked';
    }
  }
}