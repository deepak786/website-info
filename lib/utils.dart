import 'package:flutter/material.dart';

/// Get an Hexadecimal representation of this color
String toHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0')}'
      .toUpperCase()
      .replaceAll('#FF', '#');
}

/// Get the color from hex code such as "#ffffff".
Color colorFromHex(String hexCode) {
  // remove # from code
  hexCode = hexCode.replaceAll('#', '');
  if (hexCode.length == 6) {
    hexCode = "FF$hexCode";
  }

  return Color(int.parse(hexCode, radix: 16));
}

String regenerateUrlWithBaseUrl({
  required String baseUrl,
  required String url,
}) {
  var baseUri = Uri.parse(baseUrl);

  // Fix scheme relative URLs
  if (url.startsWith('//')) {
    url = '${baseUri.scheme}:$url';
  }

  // Fix relative URLs
  if (url.startsWith('/')) {
    url = '${baseUri.scheme}://${baseUri.host}$url';
  }

  // Fix naked URLs
  if (!url.startsWith('http')) {
    url = '${baseUri.scheme}://${baseUri.host}/$url';
  }

  return url;
}
