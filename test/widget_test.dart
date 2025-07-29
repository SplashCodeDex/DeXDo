// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dexdo/main.dart';
import 'package:dexdo/screens/home_screen.dart';

void main() {
  group('DeXDo App Tests', () {
    testWidgets('App loads and shows empty state', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const DeXDo());

      // Wait for any async operations to complete
      await tester.pumpAndSettle();

      // Verify that the app title is displayed
      expect(find.text('DeXDo'), findsOneWidget);

      // Verify that the empty state is shown when no tasks exist
      expect(find.text('No tasks yet'), findsOneWidget);
      expect(find.text('Tap the + button to add your first task!'), findsOneWidget);

      // Verify that the floating action button is present
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Can navigate to add task screen', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const DeXDo());
      await tester.pumpAndSettle();

      // Tap the '+' icon to add a new task.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify that we navigated to the add task screen
      expect(find.text('Add New Task'), findsOneWidget);
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Description (Optional)'), findsOneWidget);
    });

    testWidgets('HomePage widget loads correctly', (WidgetTester tester) async {
      // Build just the HomePage widget
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Verify that the page loads without errors
      expect(find.byType(HomePage), findsOneWidget);

      // Should show loading state initially, then empty state
      // The loading state might be very brief, so we check for the final state
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Error state displays correctly', (WidgetTester tester) async {
      // This test would require mocking the repository to return an error
      // For now, we'll just verify the widget can be built
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Verify the widget builds without throwing
      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('Widget Integration Tests', () {
    testWidgets('App theme and styling', (WidgetTester tester) async {
      await tester.pumpWidget(const DeXDo());
      await tester.pumpAndSettle();

      // Verify app uses Material Design
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verify scaffold is present
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify gradient background container
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Accessibility features', (WidgetTester tester) async {
      await tester.pumpWidget(const DeXDo());
      await tester.pumpAndSettle();

      // Verify semantic labels are present (this would need actual tasks to test fully)
      expect(find.byType(Semantics), findsWidgets);
    });
  });
}
