import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:marvel_client/my_material_app.dart';

void main() {
  runApp(MyMaterialApp(
    httpClient: Client(),
    apiBaseUrl: 'https://proxy.marvel.techmeup.io',
  ));
}
