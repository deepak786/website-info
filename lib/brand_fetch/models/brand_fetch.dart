import 'package:website_info/brand_fetch/models/colors.dart';
import 'package:website_info/brand_fetch/models/fonts.dart';
import 'package:website_info/brand_fetch/models/images.dart';
import 'package:website_info/brand_fetch/models/links.dart';
import 'package:website_info/brand_fetch/models/logos.dart';

class BrandFetch {
  String? name;
  String? domain;
  bool? claimed;
  String? description;
  String? longDescription;
  List<Links>? links;
  List<Logos>? logos;
  List<Colors>? colors;
  List<Fonts>? fonts;
  List<Images>? images;

  BrandFetch({
    this.name,
    this.domain,
    this.claimed,
    this.description,
    this.longDescription,
    this.links,
    this.logos,
    this.colors,
    this.fonts,
    this.images,
  });

  BrandFetch.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    domain = json['domain'];
    claimed = json['claimed'];
    description = json['description'];
    longDescription = json['longDescription'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    if (json['logos'] != null) {
      logos = <Logos>[];
      json['logos'].forEach((v) {
        logos!.add(Logos.fromJson(v));
      });
    }
    if (json['colors'] != null) {
      colors = <Colors>[];
      json['colors'].forEach((v) {
        colors!.add(Colors.fromJson(v));
      });
    }
    if (json['fonts'] != null) {
      fonts = <Fonts>[];
      json['fonts'].forEach((v) {
        fonts!.add(Fonts.fromJson(v));
      });
    }
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['domain'] = domain;
    data['claimed'] = claimed;
    data['description'] = description;
    data['longDescription'] = longDescription;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    if (logos != null) {
      data['logos'] = logos!.map((v) => v.toJson()).toList();
    }
    if (colors != null) {
      data['colors'] = colors!.map((v) => v.toJson()).toList();
    }
    if (fonts != null) {
      data['fonts'] = fonts!.map((v) => v.toJson()).toList();
    }
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
