import 'package:cvut_study_manager/logic/hive/adapters/lesson.dart';
import 'package:cvut_study_manager/logic/hive/adapters_keys.dart';
import 'package:cvut_study_manager/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  Hive.registerAdapter(LinksAdapter());
  Hive.registerAdapter(LessonAdapter());
  
  await Hive.openBox<Lesson>(AdaptersKeys.lessons);
  
  runApp(const App());
}
