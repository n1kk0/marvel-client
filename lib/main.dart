import 'package:flutter/material.dart';

import 'package:marvel_client/screens/marvel_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marvel Client',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'HelveticaNeue',
      ),
      home: MarvelScreen(),
    );
  }
}
