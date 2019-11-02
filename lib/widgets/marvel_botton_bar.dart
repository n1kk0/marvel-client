import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:url_launcher/url_launcher.dart';

class MarvelBottomAppBar extends StatelessWidget {
  const MarvelBottomAppBar();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.red,
      child: GestureDetector(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text("Data provided by Marvel. © 2014 Marvel", textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).primaryTextTheme.body1.color, fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
        ),
        onTap: () async {
          if (kIsWeb) {
            uh.window.open('http://marvel.com', 'marvel');
          } else {
            await launch('http://marvel.com');
          }
        },
      ),
    );
  }
}
