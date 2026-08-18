import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitpro/main.dart';

void main() {
  group('FitPro App Tests', () {
    testWidgets('App loads and shows Workouts screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FitProApp());

      expect(find.text('FitPro'), findsOneWidget);
      expect(find.text('Chest + Triceps'), findsOneWidget);
    });

    testWidgets('Bottom navigation works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FitProApp());

      expect(find.text('FitPro'), findsOneWidget);

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.text('Calendar'), findsWidgets);

      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();
      expect(find.text('Stats'), findsWidgets);
    });

    testWidgets('Workout card navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(const FitProApp());

      await tester.tap(find.text('Chest + Triceps'));
      await tester.pumpAndSettle();

      expect(find.text('Start workout'), findsOneWidget);
    });

    testWidgets('Workout provider initializes with sample data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FitProApp());

      expect(find.text('Chest + Triceps'), findsOneWidget);
      expect(find.text('190 lbs'), findsOneWidget);
      expect(find.text('Volume lifted'), findsOneWidget);
    });
  });
}
