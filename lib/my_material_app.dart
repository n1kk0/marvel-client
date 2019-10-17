import 'package:flutter/material.dart';

import 'package:marvel_client/screens/marvel_screen.dart';

class MyMaterialApp extends StatelessWidget {
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
