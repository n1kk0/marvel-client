// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:image_test_utils/image_test_utils.dart';

import 'package:marvel_client/tools/app_config.dart';
import 'package:marvel_client/my_material_app.dart';

void main() {
  testWidgets('Marvel client UI init tests', (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      await tester.pumpWidget(AppConfig(
        apiBaseUrl: 'https://proxy.marvel.techmeup.io',
        child: MyMaterialApp(MockClient((Request request) async {
          return Response(jsonEncode({
            "count": 1493,
            "characters": [
              {"name": "3-D Man", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784.jpg"},
              {"name": "A-Bomb (HAS)", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/3/20/5232158de5b16.jpg"},
              {"name": "A.I.M.", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/6/20/52602f21f29ec.jpg"},
              {"name": "Aaron Stack", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg"},
              {"name": "Abomination (Emil Blonsky)", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/9/50/4ce18691cbf04.jpg"},
              {"name": "Abomination (Ultimate)", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg"},
              {"name": "Absorbing Man", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/1/b0/5269678709fb7.jpg"},
              {"name": "Abyss", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/9/30/535feab462a64.jpg"},
              {"name": "Abyss (Age of Apocalypse)", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/3/80/4c00358ec7548.jpg"},
              {"name": "Adam Destine", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg"},
              {"name": "Adam Warlock", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/a/f0/5202887448860.jpg"},
              {"name": "Aegis (Trey Rollins)", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/5/e0/4c0035c9c425d.gif"},
              {"name": "Agent Brand", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/4/60/52695285d6e7e.jpg"},
              {"name": "Agent X (Nijo)", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg"},
              {"name": "Agent Zero", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/f/60/4c0042121d790.jpg"}
            ]
          }), 200);
        })),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Marvel Characters'), findsOneWidget);
//      expect(find.text('Adam Warlock'), findsOneWidget);
      expect(find.text('DC Characters'), findsNothing);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.text('Search by Comic Series Title'), findsOneWidget);
      expect(find.text('Marvel Characters'), findsNothing);
    });
  });
}
