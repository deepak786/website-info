class Images {
  List<Formats>? formats;
  List<String>? tags;
  String? type;

  Images({this.formats, this.tags, this.type});

  Images.fromJson(Map<String, dynamic> json) {
    if (json['formats'] != null) {
      formats = <Formats>[];
      json['formats'].forEach((v) {
        formats!.add(Formats.fromJson(v));
      });
    }
    if (json['tags'] != null) {
      tags = <String>[];
      json['tags'].forEach((v) {
        tags!.add(v);
      });
    }
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (formats != null) {
      data['formats'] = formats!.map((v) => v.toJson()).toList();
    }
    if (tags != null) {
      data['tags'] = tags!.toList();
    }
    data['type'] = type;
    return data;
  }
}

class Formats {
  String? src;
  String? background;
  String? format;
  int? height;
  int? width;
  int? size;

  Formats({
    this.src,
    this.background,
    this.format,
    this.height,
    this.width,
    this.size,
  });

  Formats.fromJson(Map<String, dynamic> json) {
    src = json['src'];
    background = json['background'];
    format = json['format'];
    height = json['height'];
    width = json['width'];
    size = json['size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['src'] = src;
    data['background'] = background;
    data['format'] = format;
    data['height'] = height;
    data['width'] = width;
    data['size'] = size;
    return data;
  }
}
