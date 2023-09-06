import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

uint8ListToBase64(Uint8List data) {
  return base64.encode(data);
}

Uint8List base64ToUint8List(String base64String) {
  final decodedBytes = base64.decode(base64String);
  return Uint8List.fromList(decodedBytes);
}



