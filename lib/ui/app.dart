import 'package:cvut_study_manager/ui/router/app_router.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      
      theme: ThemeData.dark(
        useMaterial3: true
      ),
      initialRoute: AppRouter.initRoute,
      onGenerateRoute: AppRouter.generate,
    );
  }
}