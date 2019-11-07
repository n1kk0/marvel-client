import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import 'package:marvel_client/data/providers/marvel_characters.dart';
import 'package:marvel_client/screens/marvel_screen.dart';

class MyMaterialApp extends StatelessWidget {
  final Client httpClient;
  final String apiBaseUrl;

  MyMaterialApp({this.httpClient, this.apiBaseUrl});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MarvelCharacters>(
      builder: (context) => MarvelCharacters(httpClient, apiBaseUrl),
      child: MaterialApp(
        title: 'Marvel API Client',
        theme: ThemeData(
          primarySwatch: Colors.red,
          fontFamily: 'HelveticaNeue',
        ),
        home: MarvelScreen(httpClient, apiBaseUrl),
      ),
    );
  }
}
