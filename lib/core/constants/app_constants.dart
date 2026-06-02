// ignore_for_file: non_constant_identifier_names

import 'dart:io';

const bool prod = true;

String _getBaseHost() {
  if (prod) return 'linkup.olildu.dpdns.org/api/v1';
  if (Platform.isAndroid) return '192.168.123.32:9002/api/v1';
  return 'localhost:9002/api/v1';
}

final String BASE_URL = 'http${prod ? "s" : ""}://${_getBaseHost()}';
final String WS_BASE_URL = 'ws${prod ? "s" : ""}://${_getBaseHost()}/ws';
