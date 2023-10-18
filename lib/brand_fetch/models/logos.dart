class Logos {
  String? theme;
  List<Formats>? formats;
  List<String>? tags;
  String? type;

  Logos({this.theme, this.formats, this.tags, this.type});

  Logos.fromJson(Map<String, dynamic> json) {
    theme = json['theme'];
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
    data['theme'] = theme;
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
  int? size;
  int? height;
  int? width;

  Formats({
    this.src,
    this.background,
    this.format,
    this.size,
    this.height,
    this.width,
  });

  Formats.fromJson(Map<String, dynamic> json) {
    src = json['src'];
    background = json['background'];
    format = json['format'];
    size = json['size'];
    height = json['height'];
    width = json['width'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['src'] = src;
    data['background'] = background;
    data['format'] = format;
    data['size'] = size;
    data['height'] = height;
    data['width'] = width;
    return data;
  }


}
