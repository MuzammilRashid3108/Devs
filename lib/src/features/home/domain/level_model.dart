import 'package:cloud_firestore/cloud_firestore.dart';

enum LevelDifficulty { easy, medium, hard, boss }

class Level {
  final String id;
  final int    number;
  final String title;
  final String tag;
  final String emoji;
  final String description;
  final Map<String, String> starterCode; // { 'python': '...', 'dart': '...' }
  final List<TestCase> testCases;
  final int    xpReward;
  final int    order;

  const Level({
    required this.id,
    required this.number,
    required this.title,
    required this.tag,
    required this.emoji,
    required this.description,
    required this.starterCode,
    required this.testCases,
    required this.xpReward,
    required this.order,
  });

  factory Level.fromMap(String id, Map<String, dynamic> map) {
    return Level(
      id:          id,
      number:      map['number']   as int,
      title:       map['title']    as String,
      tag:         map['tag']      as String,
      emoji:       map['emoji']    as String,
      description: map['description'] as String? ?? '',
      starterCode: Map<String, String>.from(map['starterCode'] ?? {}),
      testCases:   (map['testCases'] as List<dynamic>? ?? [])
          .map((t) => TestCase.fromMap(t as Map<String, dynamic>))
          .toList(),
      xpReward:    map['xpReward'] as int? ?? 100,
      order:       map['order']    as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number':      number,
      'title':       title,
      'tag':         tag,
      'emoji':       emoji,
      'description': description,
      'starterCode': starterCode,
      'testCases':   testCases.map((t) => t.toMap()).toList(),
      'xpReward':    xpReward,
      'order':       order,
    };
  }

  LevelDifficulty get difficulty {
    switch (tag.toLowerCase()) {
      case 'easy':   return LevelDifficulty.easy;
      case 'medium': return LevelDifficulty.medium;
      case 'hard':   return LevelDifficulty.hard;
      default:       return LevelDifficulty.boss;
    }
  }
}

class TestCase {
  final String input;
  final String expectedOutput;
  final bool   isHidden; // hidden test cases not shown to user

  const TestCase({
    required this.input,
    required this.expectedOutput,
    this.isHidden = false,
  });

  factory TestCase.fromMap(Map<String, dynamic> map) {
    return TestCase(
      input:          map['input']          as String,
      expectedOutput: map['expectedOutput'] as String,
      isHidden:       map['isHidden']       as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'input':          input,
    'expectedOutput': expectedOutput,
    'isHidden':       isHidden,
  };
}