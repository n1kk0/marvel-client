import 'package:flutter/material.dart';

class MarvelHeroScreen extends StatelessWidget {
  final String _thumbnail;
  final String _name;
  final String _tag;

  MarvelHeroScreen(this._thumbnail, this._name, this._tag, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: _tag,
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width / 2.3,
                  backgroundImage: NetworkImage(_thumbnail),
                  backgroundColor: Colors.transparent,
                )
              ),
              Text(_name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      )
    );
  }
}
