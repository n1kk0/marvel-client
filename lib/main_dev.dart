import 'dart:io';

import 'package:flutter/material.dart';

import 'package:marvel_client/tools/app_config.dart';
import 'package:marvel_client/my_material_app.dart';

void main() {
  if (Platform.isAndroid) {
    runApp(AppConfig(
      apiBaseUrl: 'http://10.0.2.2:8888',
      child: MyMaterialApp(),
    ));
  } else if (Platform.isIOS) {
    runApp(AppConfig(
      apiBaseUrl: 'http://127.0.0.1:8888',
      child: MyMaterialApp(),
    ));
  }
}
