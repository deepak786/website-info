import 'dart:convert';
import 'dart:typed_data';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:palette_generator/palette_generator.dart';
import 'package:website_info/manifest.dart';
import 'package:website_info/utils.dart';
import 'package:website_info/website_data.dart';
import 'package:website_info/website_info_item.dart';

class ExtractWebsiteInfo extends StatefulWidget {
  const ExtractWebsiteInfo({Key? key}) : super(key: key);

  @override
  State<ExtractWebsiteInfo> createState() => _ExtractWebsiteInfoState();
}

class _ExtractWebsiteInfoState extends State<ExtractWebsiteInfo> {
  final urlCtrl = TextEditingController();
  bool loadingData = false;
  WebsiteData? data;

  // default icons
  final iconPaths = [
    "/favicon.ico",
    "/apple-touch-icon.png",
    "/apple-touch-icon-precomposed.png",
  ];

  // link rel
  final iconTypes = [
    "shortcut icon",
    "icon",
    "apple-touch-icon",
    "apple-touch-icon-precomposed",
    "fluid-icon",
  ];

  // Signatures from https://en.wikipedia.org/wiki/List_of_file_signatures
  final icoSig = [0, 0, 1, 0];
  final pngSig = [137, 80, 78, 71, 13, 10, 26, 10];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (loadingData) ...[
            Container(
              width: double.maxFinite,
              height: double.maxFinite,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          ],
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: urlCtrl,
                decoration: const InputDecoration(
                  hintText: "Enter url",
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  String url = urlCtrl.text;
                  if (url.isEmpty) {
                    return;
                  }

                  // add http or https
                  if (!url.startsWith("http://") &&
                      !url.startsWith("https://")) {
                    url = "https://$url";
                  }

                  // load the data
                  setState(() {
                    loadingData = true;
                    data = null;
                  });

                  String? html = await loadHtml(url);
                  String title = "";
                  String name = "";
                  String themeColor = "";
                  List<Favicon> icons = [];
                  List<Color> paletteColors = [];

                  if (html != null) {
                    BeautifulSoup bs = BeautifulSoup(html);

                    var head = bs.head;
                    if (head != null) {
                      // title
                      title = head.title?.string ?? '';

                      // get the base url
                      var baseUrl = head.find("base")?.attributes['href'];
                      if (baseUrl == null || baseUrl.trim().isEmpty) {
                        baseUrl = url;
                      } else {
                        baseUrl = regenerateUrlWithBaseUrl(
                          baseUrl: url,
                          url: baseUrl,
                        );
                      }

                      // remove trailing slash from base url
                      if (baseUrl.endsWith('/')) {
                        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
                      }

                      // Check if there is manifest file
                      var manifestLink = head.find("link", attrs: {
                            "rel": "manifest",
                          })?.attributes['href'] ??
                          '';
                      if (manifestLink.isNotEmpty) {
                        manifestLink = regenerateUrlWithBaseUrl(
                          baseUrl: baseUrl,
                          url: manifestLink,
                        );

                        // get the data from manifest
                        var manifest = await loadManifest(manifestLink);
                        if (manifest != null) {
                          name = manifest.name;
                          themeColor = manifest.themeColor;
                          icons = manifest.icons
                              .map((e) => e.toFavicon(baseUrl!))
                              .toList()
                            ..sort();
                        }
                      }

                      // get the data by parsing the head element

                      // og:site_name
                      if (name.isEmpty) {
                        name = head.find("meta", attrs: {
                              "property": "og:site_name",
                            })?.attributes['content'] ??
                            '';
                      }

                      // theme-color
                      if (themeColor.isEmpty) {
                        themeColor = head.find("meta", attrs: {
                              "name": "theme-color",
                            })?.attributes['content'] ??
                            '';
                      }

                      // icons
                      if (icons.isEmpty) {
                        icons = await getIcons(baseUrl, head);
                      }

                      // palette color
                      paletteColors = await getPaletteColors(icons);
                    }
                  }

                  data = WebsiteData(
                    url: url,
                    title: title,
                    siteName: name,
                    themeColor: themeColor,
                    icons: icons,
                    paletteColors: paletteColors,
                  );
                  debugPrint(data.toString());

                  // hide the loader
                  setState(() {
                    loadingData = false;
                  });
                },
                child: const Text("Submit"),
              ),
              const SizedBox(height: 16),
              if (data != null) ...[
                WebsiteInfoItem(data: data!),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// get the icons
  Future<List<Favicon>> getIcons(String baseUrl, Bs4Element head) async {
    var icons = <String>{};

    // add default icons
    for (var iconPath in iconPaths) {
      icons.add("$baseUrl$iconPath");
    }

    // extract icons
    var links = head.findAll("link");
    for (var link in links) {
      var attributes = link.attributes;
      if (iconTypes.contains(attributes['rel'])) {
        // this link is of icon type
        // get the href attribute
        var href = attributes['href'];
        if (href != null && href.trim().isNotEmpty) {
          var iconUrl =
              regenerateUrlWithBaseUrl(baseUrl: baseUrl, url: href.trim());
          icons.add(iconUrl);
        }
      }
    }

    // verify icons
    var verifiedIcons = <Favicon>[];
    for (var icon in icons) {
      var favicon = await _verifyImage(icon);
      if (favicon != null) {
        // valid icon or image
        verifiedIcons.add(favicon);
      }
    }

    return verifiedIcons..sort();
  }

  Future<Favicon?> _verifyImage(String url) async {
    var response = await http.get(Uri.parse(getCorsUrl(url)));

    var contentType = response.headers['content-type'];
    if (contentType == null || !contentType.contains('image')) return null;

    // Take extra care with ico's since they might be constructed manually
    if (contentType == "image/x-icon") {
      if (response.bodyBytes.length < 4) return null;

      // Check if ico file contains a valid image signature
      if (!_verifySignature(response.bodyBytes, icoSig) &&
          !_verifySignature(response.bodyBytes, pngSig)) {
        return null;
      }
    }

    if (response.statusCode == 200 && (response.contentLength ?? 0) > 0) {
      int width = 0;
      int height = 0;

      if (contentType == "image/svg+xml") {
        // No need for size calculation on vector images
        // use default
        width = 100;
        height = 100;
      } else {
        try {
          var image = img.decodeImage(response.bodyBytes);
          if (image != null && image.isValid) {
            width = image.width;
            height = image.height;
          }
        } catch (e) {
          debugPrint(e.toString());
          return null;
        }
      }

      return Favicon(
        url: url,
        type: contentType,
        width: width,
        height: height,
      );
    }

    return null;
  }

  bool _verifySignature(Uint8List bodyBytes, List<int> signature) {
    var fileSignature = bodyBytes.sublist(0, signature.length);
    for (var i = 0; i < fileSignature.length; i++) {
      if (fileSignature[i] != signature[i]) return false;
    }
    return true;
  }

  /// Extract the color from icons
  Future<List<Color>> getPaletteColors(List<Favicon> icons) async {
    var colors = <Color>{};

    for (var icon in icons) {
      if (!icon.isSvg) {
        try {
          final paletteGenerator = await PaletteGenerator.fromImageProvider(
            CachedNetworkImageProvider(
              getCorsUrl(icon.url),
              errorListener: (e) => debugPrint(e.toString()),
            ),
            timeout: const Duration(seconds: 5),
            maximumColorCount: 3,
          );
          colors.addAll(paletteGenerator.colors);
          // var dominant = paletteGenerator.dominantColor?.color;
          // var vibrant = paletteGenerator.vibrantColor?.color;
          //
          // if (dominant != null) {
          //   colors.add(dominant);
          // }
          //
          // if (vibrant != null) {
          //   colors.add(vibrant);
          // }
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }

    return colors.toList();
  }

  /// Load url html
  Future<String?> loadHtml(String url) async {
    try {
      final response = await http.get(Uri.parse(getCorsUrl(url)));
      debugPrint('GET $url - ${response.statusCode}');

      return response.body;
    } catch (error) {
      debugPrint('GET $url - ${error.toString()}');
      return null;
    }
  }

  /// Load manifest
  Future<Manifest?> loadManifest(String url) async {
    try {
      final response = await http.get(Uri.parse(getCorsUrl(url)), headers: {
        'content-type': 'application/json',
      });
      debugPrint('GET $url - ${response.statusCode}');

      final data = json.decode(response.body);
      return Manifest.fromJson(data);
    } catch (error) {
      debugPrint('GET $url - ${error.toString()}');
      return null;
    }
  }
}
