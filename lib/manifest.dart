import 'package:website_info/utils.dart';
import 'package:website_info/website_data.dart';

class Manifest {
  Manifest._({
    this.name = "",
    this.shortName = "",
    this.backgroundColor = "",
    this.themeColor = "",
    this.icons = const [],
  });

  /// Name
  final String name;

  /// Short name
  final String shortName;

  /// Background color
  final String backgroundColor;

  /// Theme color
  final String themeColor;

  /// Icons
  final List<ManifestIcon> icons;

  factory Manifest.fromJson(Map<String, dynamic> data) {
    return Manifest._(
      name: data['name'] as String? ?? '',
      shortName: data['short_name'] as String? ?? '',
      backgroundColor: data['background_color'] as String? ?? '',
      themeColor: data['theme_color'] as String? ?? '',
      icons: (data['icons'] as List<dynamic>?)
              ?.map((e) => ManifestIcon.fromJson((e as Map? ?? {}).map(
                    (k, e) => MapEntry(k as String, e),
                  )))
              .toList() ??
          [],
    );
  }
}

class ManifestIcon {
  ManifestIcon._({
    this.sizes = "",
    this.src = "",
    this.type = "",
  });

  /// Size of the icon. E.g: 512x512
  final String sizes;

  /// Icon url
  final String src;

  /// Icon type
  final String type;

  factory ManifestIcon.fromJson(Map<String, dynamic> data) {
    return ManifestIcon._(
      sizes: data['sizes'] as String? ?? '',
      src: data['src'] as String? ?? '',
      type: data['type'] as String? ?? '',
    );
  }

  Favicon toFavicon(String baseUrl) {
    var size = sizes.split("x");
    var width = size.isNotEmpty ? int.tryParse(size.first) ?? 0 : 0;
    var height = size.length >= 2 ? int.tryParse(size[1]) ?? 0 : 0;
    var contentType = type;
    if (contentType.isEmpty) {
      // Remove query strings
      var url = src.split('?').first;
      if (url.endsWith(".png")) {
        contentType = "image/png";
      } else if (url.endsWith(".ico")) {
        contentType = "image/x-icon";
      } else if (url.endsWith(".svg")) {
        contentType = "image/svg+xml";
      }
    }

    return Favicon(
      url: regenerateUrlWithBaseUrl(baseUrl: baseUrl, url: src),
      width: width,
      height: height,
      type: contentType,
    );
  }
}
