import 'package:flutter/material.dart';

class WebsiteData {
  WebsiteData({
    required this.url,
    this.title = "",
    this.siteName = "",
    this.themeColor = "",
    this.icons = const [],
    this.paletteColors = const [],
  });

  /// Website url
  final String url;

  /// Title of the website
  final String title;

  /// Site name
  final String siteName;

  /// Theme color
  final String themeColor;

  /// Icons
  final List<Favicon> icons;

  /// Colors
  final List<Color> paletteColors;

  @override
  String toString() {
    return "{url: $url, title: $title, siteName: $siteName, icons: $icons, themeColor: $themeColor, paletteColors: $paletteColors}";
  }
}

class Favicon implements Comparable<Favicon> {
  Favicon({
    required this.url,
    this.type = "",
    this.width = 0,
    this.height = 0,
  });

  /// Icon url
  final String url;

  /// Icon type such as image/png, image/jpg, etc
  final String type;

  /// Icon width
  final int width;

  /// icon height
  final int height;

  bool get isSvg => type == "image/svg+xml";

  bool get isPng => type == "image/png";

  bool get isIco => type == "image/x-icon";

  @override
  int compareTo(Favicon other) {
    // If both are vector graphics, use URL length as tie-breaker
    // if (isSvg && other.isSvg) {
    //   return url.length < other.url.length ? -1 : 1;
    // }
    //
    // // Sort vector graphics before bitmaps
    // if (isSvg) return -1;
    // if (other.isSvg) return 1;

    // If bitmap size is the same, use URL length as tie-breaker
    if (width * height == other.width * other.height) {
      return url.length < other.url.length ? -1 : 1;
    }

    // Sort on bitmap size
    return (width * height > other.width * other.height) ? -1 : 1;
  }

  @override
  String toString() {
    return '{url: $url, type: $type, width: $width, height: $height}';
  }
}
