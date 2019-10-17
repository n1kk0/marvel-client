import 'package:flutter/material.dart';

import 'package:marvel_client/tools/app_config.dart';
import 'package:marvel_client/my_material_app.dart';

void main() {
  runApp(AppConfig(
    apiBaseUrl: 'https://proxy.marvel.techmeup.io',
    child: MyMaterialApp(),
  ));
}
