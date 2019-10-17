// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marvel_client/my_material_app.dart';
import 'package:marvel_client/tools/app_config.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(AppConfig(
      apiBaseUrl: 'https://proxy.marvel.techmeup.io',
      child: MyMaterialApp(),
    ));

    expect(find.text('Marvel Characters'), findsOneWidget);
    expect(find.text('DC Client'), findsNothing);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    expect(find.text('Search by Comic Series Title'), findsNothing);
    expect(find.text(''), findsOneWidget);
  });
}
