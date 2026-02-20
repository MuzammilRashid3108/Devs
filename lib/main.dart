import 'package:devs/src/app.dart';
import 'package:devs/src/features/home/data/level_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //await LevelService().seedLevels();

  runApp(const DevsApp());
}