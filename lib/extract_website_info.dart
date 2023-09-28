import 'dart:typed_data';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
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
                  String siteName = "";
                  List<Favicon> icons = [];

                  if (html != null) {
                    BeautifulSoup bs = BeautifulSoup(html);

                    var head = bs.head;
                    if (head != null) {
                      // title
                      title = head.title?.string ?? '';

                      // og:site_name
                      var ogSiteName = head.find("meta", attrs: {
                        "property": "og:site_name",
                      });
                      siteName = ogSiteName?.attributes['content'] ?? '';

                      // icons
                      icons = await getIcons(url, head);
                    }
                  }

                  data = WebsiteData(
                      url: url, title: title, siteName: siteName, icons: icons);
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
  Future<List<Favicon>> getIcons(String url, Bs4Element head) async {
    var icons = <String>{};

    // get the base url
    var baseUrl = head.find("base")?.attributes['href'];
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      baseUrl = url;
    }

    // remove trailing slash
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    // add default icons
    for (var iconPath in iconPaths) {
      icons.add("$baseUrl$iconPath");
    }

    var uri = Uri.parse(baseUrl);

    // extract icons
    var links = head.findAll("link");
    for (var link in links) {
      var attributes = link.attributes;
      if (iconTypes.contains(attributes['rel'])) {
        // this link is of icon type
        // get the href attribute
        var href = attributes['href'];
        if (href != null && href.trim().isNotEmpty) {
          var iconUrl = href.trim();

          // Fix scheme relative URLs
          if (iconUrl.startsWith('//')) {
            iconUrl = '${uri.scheme}:$iconUrl';
          }

          // Fix relative URLs
          if (iconUrl.startsWith('/')) {
            iconUrl = '${uri.scheme}://${uri.host}$iconUrl';
          }

          // Fix naked URLs
          if (!iconUrl.startsWith('http')) {
            iconUrl = '${uri.scheme}://${uri.host}/$iconUrl';
          }

          // // Remove query strings
          // iconUrl = iconUrl.split('?').first;

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
    var response = await http.get(Uri.parse(url));

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
        var image = decodeImage(response.bodyBytes);
        if (image != null && image.isValid) {
          width = image.width;
          height = image.height;
        }
      }

      return Favicon(
        url: url,
        type: contentType,
        bytes: response.contentLength!,
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

  /// Load url html
  Future<String?> loadHtml(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('GET $url - ${response.statusCode}');

      return response.body;
    } catch (error) {
      debugPrint('GET $url - ${error.toString()}');
      return null;
    }
  }
}
