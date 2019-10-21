import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:marvel_client/my_material_app.dart';

void main() {
  if (kIsWeb) {
    runApp(MyMaterialApp(
      httpClient: Client(),
      apiBaseUrl: 'http://127.0.0.1:8888',
    ));
  } else {
    runApp(MyMaterialApp(
      httpClient: Client(),
      // * IOS
      apiBaseUrl: 'http://127.0.0.1:8888',
      // * Android
      //apiBaseUrl: 'http://10.0.2.2:8888',
    ));
  }
}
