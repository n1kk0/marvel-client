import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:image_test_utils/image_test_utils.dart';

import 'package:marvel_client/my_material_app.dart';

void main() {
  testWidgets('Marvel client UI init tests', (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      await tester.pumpWidget(
        MyMaterialApp(apiBaseUrl: 'https://proxy.marvel.techmeup.io', httpClient: MockClient((Request request) async {
          return Response(jsonEncode({
            "count": 1493,
            "characters": [
              {"id": 0, "name": "3-D Man", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784.jpg"},
              {"id": 1, "name": "A-Bomb (HAS)", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/3/20/5232158de5b16.jpg"},
              {"id": 2, "name": "A.I.M.", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/6/20/52602f21f29ec.jpg"},
              {"id": 3, "name": "Aaron Stack", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg"},
              {"id": 4, "name": "Abomination (Emil Blonsky)", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/9/50/4ce18691cbf04.jpg"},
              {"id": 5, "name": "Abomination (Ultimate)", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg"},
              {"id": 6, "name": "Absorbing Man", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/1/b0/5269678709fb7.jpg"},
              {"id": 7, "name": "Abyss", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/9/30/535feab462a64.jpg"},
              {"id": 8, "name": "Abyss (Age of Apocalypse)", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/3/80/4c00358ec7548.jpg"},
              {"id": 9, "name": "Adam Destine", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg"},
              {"id": 10, "name": "Adam Warlock", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/a/f0/5202887448860.jpg"},
              {"id": 11, "name": "Aegis (Trey Rollins)", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/5/e0/4c0035c9c425d.gif"},
              {"id": 12, "name": "Agent Brand", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/4/60/52695285d6e7e.jpg"},
              {"id": 13, "name": "Agent X (Nijo)", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg"},
              {"id": 14, "name": "Agent Zero", "thumbnail": "http://i.annihil.us/u/prod/marvel/i/mg/f/60/4c0042121d790.jpg"}
            ]
          }), 200);
        }),
      ));

      await tester.pump(Duration(seconds: 1));

      expect(find.text('Marvel API Client'), findsOneWidget);
//      expect(find.text('Adam Warlock'), findsOneWidget);
      expect(find.text('DC Characters'), findsNothing);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.text('Search by Comic Series Title'), findsOneWidget);
      expect(find.text('Marvel Characters'), findsNothing);
    });
  });
}
