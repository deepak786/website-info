import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:website_info/website_data.dart';

class WebsiteInfoItem extends StatelessWidget {
  /// Display website info
  const WebsiteInfoItem({Key? key, required this.data}) : super(key: key);

  /// Data
  final WebsiteData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DataTable(
          columns: const [
            DataColumn(
              label: Expanded(
                child: Text(
                  'Url',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Title',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Site name',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
          rows: [
            DataRow(
              cells: <DataCell>[
                DataCell(Text(data.url)),
                DataCell(Text(data.title)),
                DataCell(Text(data.siteName)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "Icons",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DataTable(
          columns: const [
            DataColumn(
              label: Expanded(
                child: Text(
                  '',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Size',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Url',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Type',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Bytes',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
          rows: data.icons
              .map(
                (e) => DataRow(
                  cells: <DataCell>[
                    DataCell(getIcon(e)),
                    DataCell(Text("${e.width}x${e.height}")),
                    DataCell(
                      InkWell(
                        child: Text(
                          e.url,
                          style: const TextStyle(
                              decoration: TextDecoration.underline),
                        ),
                        onTap: () async {
                          if (!await launchUrl(Uri.parse(e.url))) {
                            throw Exception('Could not launch ${e.url}');
                          }
                        },
                      ),
                    ),
                    DataCell(Text(e.type)),
                    DataCell(Text(e.bytes.toString())),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget getIcon(Favicon icon) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: icon.isSvg
          ? SvgPicture.network(
              icon.url,
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              width: icon.width / 2,
              height: icon.height / 2,
            )
          : CachedNetworkImage(
              imageUrl: icon.url,
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              width: icon.width / 2,
              height: icon.height / 2,
              errorWidget: (BuildContext context, String url, Object error) {
                return Container();
              },
            ),
    );
  }
}
