// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:first_project/main.dart';

void main() {
  testWidgets('shows the PoskoSync login screen', (tester) async {
    await tester.pumpWidget(const PoskoSyncApp());

    expect(find.text('PoskoSync'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('logs in after required fields are filled', (tester) async {
    await tester.pumpWidget(const PoskoSyncApp());

    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Wajib diisi'), findsNWidgets(2));

    await tester.enterText(find.byType(TextFormField).at(0), 'posko-demo');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Input Kebutuhan Bantuan'), findsOneWidget);
    expect(find.text('Kirim'), findsOneWidget);
  });
}
