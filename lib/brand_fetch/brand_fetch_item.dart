import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:website_info/brand_fetch/models/brand_fetch.dart';
import 'package:website_info/utils.dart';

class BrandFetchItem extends StatelessWidget {
  const BrandFetchItem({
    Key? key,
    required this.data,
  }) : super(key: key);

  final BrandFetch data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            DataTable(
              dataRowMaxHeight: double.infinity,
              columns: const [
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Name',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Domain',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Description',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ],
              rows: [
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text(data.name ?? '')),
                    DataCell(Text(data.domain ?? '')),
                    DataCell(SizedBox(
                        width: 300, child: Text(data.description ?? ''))),
                  ],
                ),
              ],
            ),
            ...(data.logos ?? [])
                .map((logo) => Column(
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          logo.type ?? '',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
                                  'Url',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  'Format',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  'Width',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  'Height',
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
                                  'Size',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                            ),
                          ],
                          rows: (logo.formats ?? [])
                              .map(
                                (e) => DataRow(
                                  cells: <DataCell>[
                                    DataCell(getIcon(
                                      e.src ?? '',
                                      svg: e.format == 'svg',
                                      theme: logo.theme,
                                    )),
                                    DataCell(getUrl(e.src ?? '')),
                                    DataCell(Text(e.format ?? '')),
                                    DataCell(Text(e.width?.toString() ?? '')),
                                    DataCell(Text(e.height?.toString() ?? '')),
                                    DataCell(Text(logo.type ?? '')),
                                    DataCell(Text(e.size?.toString() ?? '')),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ))
                .toList(),
            const SizedBox(height: 16),
            const Text(
              "Links",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DataTable(
              columns: const [
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Name',
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
              ],
              rows: (data.links ?? [])
                  .map(
                    (e) => DataRow(
                      cells: <DataCell>[
                        DataCell(Text(e.name ?? '')),
                        DataCell(getUrl(e.url ?? '')),
                      ],
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              "Colors",
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
                      'Hex code',
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
              ],
              rows: (data.colors ?? [])
                  .map(
                    (e) => DataRow(
                      cells: <DataCell>[
                        DataCell(Container(
                          width: 20,
                          height: 20,
                          color: colorFromHex(e.hex ?? ''),
                        )),
                        DataCell(Text(e.hex ?? '')),
                        DataCell(Text(e.type ?? '')),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget getUrl(String src) {
    return InkWell(
      child: Text(
        src,
        style: const TextStyle(decoration: TextDecoration.underline),
      ),
      onTap: () async {
        if (!await launchUrl(Uri.parse(src))) {
          throw Exception('Could not launch $src');
        }
      },
    );
  }

  Widget getIcon(String url, {bool svg = false, String? theme}) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: theme == "dark" ? null : Colors.black,
      width: 50,
      height: 50,
      child: svg
          ? SvgPicture.network(
              url,
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              width: 50,
              height: 50,
            )
          : CachedNetworkImage(
              imageUrl: url,
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              width: 50,
              height: 50,
              errorWidget: (BuildContext context, String url, Object error) {
                return Container();
              },
            ),
    );
  }
}
