import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:website_info/brand_fetch/brand_fetch_item.dart';
import 'package:website_info/brand_fetch/models/brand_fetch.dart';

class ExtractWebsiteInfo extends StatefulWidget {
  const ExtractWebsiteInfo({Key? key}) : super(key: key);

  @override
  State<ExtractWebsiteInfo> createState() => _ExtractWebsiteInfoState();
}

class _ExtractWebsiteInfoState extends State<ExtractWebsiteInfo> {
  final urlCtrl = TextEditingController();
  bool loadingData = false;
  BrandFetch? data;

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

                  data = await loadData(url);

                  // hide the loader
                  setState(() {
                    loadingData = false;
                  });
                },
                child: const Text("Submit"),
              ),
              const SizedBox(height: 16),
              if (data != null) ...[
                BrandFetchItem(data: data!),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Get the brand data from brand fetch API
  Future<BrandFetch?> loadData(String url) async {
    try {
      // remove https:// or http:// from url
      String domain = url.substring(url.indexOf("://") + 3);
      String apiUrl = 'https://api.brandfetch.io/v2/brands/$domain';
      debugPrint(apiUrl);
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer GUhPYn/6oW2PM6YHLA+QNmWGVyW85hoQl19DIawRkh4=',
        'Content-Type': 'application/json; charset=utf-8',
      });
      debugPrint('GET $url - ${response.statusCode}');

      return BrandFetch.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } catch (error) {
      debugPrint('GET $url - ${error.toString()}');
      return BrandFetch();
    }
  }
}
