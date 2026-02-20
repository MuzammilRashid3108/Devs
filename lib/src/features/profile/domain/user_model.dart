import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String username;
  final String email;
  final String avatar;
  final String bio;
  final String country;
  final int    xp;
  final int    streak;
  final int    mmr;
  final bool   profileComplete;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.username,
    required this.email,
    required this.avatar,
    required this.bio,
    required this.country,
    required this.xp,
    required this.streak,
    required this.mmr,
    required this.createdAt,
    this.profileComplete = false,
  });

  // ── Firestore → AppUser ───────────────────────────────────────────────────
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid:             map['uid']             as String,
      username:        map['username']        as String,
      email:           map['email']           as String,
      avatar:          map['avatar']          as String? ?? '🧑‍💻',
      bio:             map['bio']             as String? ?? '',
      country:         map['country']         as String? ?? '',
      xp:              map['xp']              as int?    ?? 0,
      streak:          map['streak']          as int?    ?? 0,
      mmr:             map['mmr']             as int?    ?? 1000,
      profileComplete: map['profileComplete'] as bool?   ?? false,
      createdAt:       (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // ── AppUser → Firestore ───────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'uid':             uid,
      'username':        username,
      'email':           email,
      'avatar':          avatar,
      'bio':             bio,
      'country':         country,
      'xp':              xp,
      'streak':          streak,
      'mmr':             mmr,
      'profileComplete': profileComplete,
      'createdAt':       Timestamp.fromDate(createdAt),
    };
  }

  // ── CopyWith for partial updates ──────────────────────────────────────────
  AppUser copyWith({
    String?   username,
    String?   avatar,
    String?   bio,
    String?   country,
    int?      xp,
    int?      streak,
    int?      mmr,
    bool?     profileComplete,
  }) {
    return AppUser(
      uid:             uid,
      email:           email,
      createdAt:       createdAt,
      username:        username        ?? this.username,
      avatar:          avatar          ?? this.avatar,
      bio:             bio             ?? this.bio,
      country:         country         ?? this.country,
      xp:              xp              ?? this.xp,
      streak:          streak          ?? this.streak,
      mmr:             mmr             ?? this.mmr,
      profileComplete: profileComplete ?? this.profileComplete,
    );
  }

  // ── Rank title based on MMR ───────────────────────────────────────────────
  String get rankTitle {
    if (mmr >= 2400) return 'Grandmaster';
    if (mmr >= 2000) return 'Master';
    if (mmr >= 1800) return 'Diamond';
    if (mmr >= 1600) return 'Platinum';
    if (mmr >= 1400) return 'Gold';
    if (mmr >= 1200) return 'Silver';
    return 'Bronze';
  }

  String get rankEmoji {
    if (mmr >= 2400) return '👑';
    if (mmr >= 2000) return '💜';
    if (mmr >= 1800) return '💎';
    if (mmr >= 1600) return '🔷';
    if (mmr >= 1400) return '🥇';
    if (mmr >= 1200) return '🥈';
    return '🥉';
  }
}