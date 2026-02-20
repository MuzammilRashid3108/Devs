import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/level_model.dart';

class LevelService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _levels => _db.collection('levels');

  // ── Fetch all levels ordered by level number ──────────────────────────────
  Future<List<Level>> getLevels() async {
    try {
      final snap = await _levels.orderBy('order').get();
      return snap.docs
          .map((d) => Level.fromMap(d.id, d.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('getLevels error: $e');
      return [];
    }
  }

  // ── Stream levels (real-time — useful if you add levels dynamically) ───────
  Stream<List<Level>> streamLevels() {
    return _levels.orderBy('order').snapshots().map((snap) =>
        snap.docs
            .map((d) => Level.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  // ── Fetch a single level ──────────────────────────────────────────────────
  Future<Level?> getLevel(String levelId) async {
    try {
      final snap = await _levels.doc(levelId).get();
      if (!snap.exists) return null;
      return Level.fromMap(snap.id, snap.data() as Map<String, dynamic>);
    } catch (e) {
      print('getLevel error: $e');
      return null;
    }
  }

  // ── Seed initial 12 levels into Firestore (run once from admin/dev) ────────
  // Call this from a one-time script or admin panel, NOT on every app launch
  Future<void> seedLevels() async {
    final snap = await _levels.limit(1).get();
    if (snap.docs.isNotEmpty) {
      print('Levels already seeded — skipping');
      return;
    }

    final levels = _initialLevels();
    final batch  = _db.batch();
    for (final level in levels) {
      final ref = _levels.doc();
      batch.set(ref, level.toMap());
    }
    await batch.commit();
    print('✅ Seeded ${levels.length} levels');
  }

  // ── Initial level data ────────────────────────────────────────────────────
  List<Level> _initialLevels() => [
    Level(
      id: '', number: 1, order: 1,
      title: 'Two Sum', tag: 'Easy', emoji: '🍎',
      xpReward: 100,
      description:
      'Given an array of integers nums and an integer target, '
          'return indices of the two numbers such that they add up to target.\n\n'
          'You may assume that each input would have exactly one solution.',
      starterCode: {
        'python': 'def two_sum(nums, target):\n    # your code here\n    pass',
        'javascript': 'function twoSum(nums, target) {\n    // your code here\n}',
      },
      testCases: [
        const TestCase(input: '[2,7,11,15], 9',  expectedOutput: '[0,1]'),
        const TestCase(input: '[3,2,4], 6',       expectedOutput: '[1,2]'),
        const TestCase(input: '[3,3], 6',          expectedOutput: '[0,1]'),
        const TestCase(input: '[1,2,3,4,5], 9',   expectedOutput: '[3,4]', isHidden: true),
      ],
    ),
    Level(
      id: '', number: 2, order: 2,
      title: 'Palindrome Check', tag: 'Easy', emoji: '🍊',
      xpReward: 100,
      description:
      'Given a string s, return true if it is a palindrome, '
          'or false otherwise. A palindrome reads the same forward and backward.',
      starterCode: {
        'python': 'def is_palindrome(s):\n    # your code here\n    pass',
        'javascript': 'function isPalindrome(s) {\n    // your code here\n}',
      },
      testCases: [
        const TestCase(input: '"racecar"', expectedOutput: 'true'),
        const TestCase(input: '"hello"',   expectedOutput: 'false'),
        const TestCase(input: '"A"',       expectedOutput: 'true'),
        const TestCase(input: '"abcba"',   expectedOutput: 'true', isHidden: true),
      ],
    ),
    Level(
      id: '', number: 3, order: 3,
      title: 'Linked List Cycle', tag: 'Easy', emoji: '🍋',
      xpReward: 150,
      description:
      'Given head, the head of a linked list, determine if the linked list has a cycle in it.\n\n'
          'Return true if there is a cycle in the linked list, otherwise return false.',
      starterCode: {
        'python': 'def has_cycle(head):\n    # your code here\n    pass',
        'javascript': 'function hasCycle(head) {\n    // your code here\n}',
      },
      testCases: [
        const TestCase(input: '[3,2,0,-4], pos=1', expectedOutput: 'true'),
        const TestCase(input: '[1,2], pos=0',       expectedOutput: 'true'),
        const TestCase(input: '[1], pos=-1',        expectedOutput: 'false'),
      ],
    ),
    Level(
      id: '', number: 4, order: 4,
      title: 'Binary Search', tag: 'Easy', emoji: '🍇',
      xpReward: 150,
      description:
      'Given an array of integers nums which is sorted in ascending order, '
          'and an integer target, write a function to search target in nums.\n\n'
          'If target exists, return its index. Otherwise, return -1.',
      starterCode: {
        'python': 'def binary_search(nums, target):\n    # your code here\n    pass',
        'javascript': 'function binarySearch(nums, target) {\n    // your code here\n}',
      },
      testCases: [
        const TestCase(input: '[-1,0,3,5,9,12], 9', expectedOutput: '4'),
        const TestCase(input: '[-1,0,3,5,9,12], 2', expectedOutput: '-1'),
        const TestCase(input: '[5], 5',              expectedOutput: '0'),
        const TestCase(input: '[1,2,3,4,5], 6',      expectedOutput: '-1', isHidden: true),
      ],
    ),
    Level(
      id: '', number: 5, order: 5,
      title: 'Stack Min', tag: 'Medium', emoji: '🫐',
      xpReward: 200,
      description:
      'Design a stack that supports push, pop, top, and retrieving the minimum element in constant time.\n\n'
          'Implement the MinStack class with push, pop, top, and getMin methods.',
      starterCode: {
        'python': 'class MinStack:\n    def __init__(self):\n        pass\n\n    def push(self, val):\n        pass\n\n    def pop(self):\n        pass\n\n    def top(self):\n        pass\n\n    def getMin(self):\n        pass',
        'javascript': 'class MinStack {\n    constructor() {}\n    push(val) {}\n    pop() {}\n    top() {}\n    getMin() {}\n}',
      },
      testCases: [
        const TestCase(input: 'push(-2),push(0),push(-3),getMin,pop,top,getMin', expectedOutput: '-3,0,-2'),
      ],
    ),
    Level(
      id: '', number: 6, order: 6,
      title: 'Merge Intervals', tag: 'Medium', emoji: '🍓',
      xpReward: 200,
      description:
      'Given an array of intervals where intervals[i] = [starti, endi], '
          'merge all overlapping intervals, and return an array of the non-overlapping intervals.',
      starterCode: {
        'python': 'def merge(intervals):\n    # your code here\n    pass',
        'javascript': 'function merge(intervals) {\n    // your code here\n}',
      },
      testCases: [
        const TestCase(input: '[[1,3],[2,6],[8,10],[15,18]]', expectedOutput: '[[1,6],[8,10],[15,18]]'),
        const TestCase(input: '[[1,4],[4,5]]',                expectedOutput: '[[1,5]]'),
      ],
    ),
    Level(
      id: '', number: 7, order: 7,
      title: 'BFS Shortest Path', tag: 'Medium', emoji: '🎃',
      xpReward: 250,
      description:
      'Given an n x n binary matrix grid, return the length of the shortest clear path in the matrix. '
          'A clear path goes from top-left to bottom-right through only 0s, moving 8-directionally.',
      starterCode: {
        'python': 'def shortest_path(grid):\n    # your code here\n    pass',
        'javascript': 'function shortestPath(grid) {\n    // your code here\n}',
      },
      testCases: [
        const TestCase(input: '[[0,1],[1,0]]', expectedOutput: '2'),
        const TestCase(input: '[[0,0,0],[1,1,0],[1,1,0]]', expectedOutput: '4'),
        const TestCase(input: '[[1,0,0],[1,1,0],[1,1,0]]', expectedOutput: '-1'),
      ],
    ),
    Level(
      id: '', number: 8, order: 8,
      title: 'LRU Cache', tag: 'Medium', emoji: '🔮',
      xpReward: 300,
      description:
      'Design a data structure that follows the constraints of a Least Recently Used (LRU) cache.\n\n'
          'Implement the LRUCache class with get(key) and put(key, value) methods, both O(1) time.',
      starterCode: {
        'python': 'class LRUCache:\n    def __init__(self, capacity):\n        pass\n\n    def get(self, key):\n        pass\n\n    def put(self, key, value):\n        pass',
        'javascript': 'class LRUCache {\n    constructor(capacity) {}\n    get(key) {}\n    put(key, value) {}\n}',
      },
      testCases: [
        const TestCase(input: 'capacity=2,put(1,1),put(2,2),get(1),put(3,3),get(2),put(4,4),get(1),get(3),get(4)', expectedOutput: '1,-1,1,-1,3,4'),
      ],
    ),
    Level(
      id: '', number: 9, order: 9,
      title: 'Trie Search', tag: 'Hard', emoji: '💀',
      xpReward: 400,
      description:
      'Implement a Trie (prefix tree) with insert, search, and startsWith methods.',
      starterCode: {
        'python': 'class Trie:\n    def __init__(self):\n        pass\n\n    def insert(self, word):\n        pass\n\n    def search(self, word):\n        pass\n\n    def starts_with(self, prefix):\n        pass',
        'javascript': 'class Trie {\n    constructor() {}\n    insert(word) {}\n    search(word) {}\n    startsWith(prefix) {}\n}',
      },
      testCases: [
        const TestCase(input: 'insert("apple"),search("apple"),search("app"),startsWith("app"),insert("app"),search("app")', expectedOutput: 'true,false,true,true'),
      ],
    ),
    Level(
      id: '', number: 10, order: 10,
      title: 'Segment Tree', tag: 'Hard', emoji: '🔥',
      xpReward: 450,
      description:
      'Implement a NumArray class that supports range sum queries and point updates in O(log n).',
      starterCode: {
        'python': 'class NumArray:\n    def __init__(self, nums):\n        pass\n\n    def update(self, index, val):\n        pass\n\n    def sum_range(self, left, right):\n        pass',
        'javascript': 'class NumArray {\n    constructor(nums) {}\n    update(index, val) {}\n    sumRange(left, right) {}\n}',
      },
      testCases: [
        const TestCase(input: '[1,3,5],sumRange(0,2),update(1,2),sumRange(0,2)', expectedOutput: '9,8'),
      ],
    ),
    Level(
      id: '', number: 11, order: 11,
      title: "Dijkstra's Algo", tag: 'Hard', emoji: '⚡',
      xpReward: 500,
      description:
      'Given a weighted directed graph, find the shortest path from source node 0 to all other nodes using Dijkstra\'s algorithm.',
      starterCode: {
        'python': 'def dijkstra(n, edges, src):\n    # your code here\n    pass',
        'javascript': 'function dijkstra(n, edges, src) {\n    // your code here\n}',
      },
      testCases: [
        const TestCase(input: 'n=5, edges=[[0,1,2],[0,2,4],[1,2,1],[1,3,7],[2,4,3]], src=0', expectedOutput: '[0,2,3,9,6]'),
      ],
    ),
    Level(
      id: '', number: 12, order: 12,
      title: 'BOSS: DP Marathon', tag: 'BOSS', emoji: '👑',
      xpReward: 1000,
      description:
      'The ultimate challenge. Solve a dynamic programming problem that combines multiple DP techniques. '
          'Given a grid, find the minimum cost path from top-left to bottom-right.',
      starterCode: {
        'python': 'def min_path_sum(grid):\n    # your code here\n    pass',
        'javascript': 'function minPathSum(grid) {\n    // your code here\n}',
      },
      testCases: [
        const TestCase(input: '[[1,3,1],[1,5,1],[4,2,1]]', expectedOutput: '7'),
        const TestCase(input: '[[1,2,3],[4,5,6]]',         expectedOutput: '12'),
        const TestCase(input: '[[1]]',                     expectedOutput: '1', isHidden: true),
      ],
    ),
  ];
}