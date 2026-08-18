import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/workout_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const FitProApp());
}

class FitProApp extends StatelessWidget {
  const FitProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkoutProvider(),
      child: MaterialApp(
        title: 'FitPro',
        theme: AppTheme.theme,
        home: const MainNavigationScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
