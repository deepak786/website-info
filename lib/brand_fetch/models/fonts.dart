class Fonts {
  String? name;
  String? type;
  String? origin;
  String? originId;

  Fonts({this.name, this.type, this.origin, this.originId});

  Fonts.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    origin = json['origin'];
    originId = json['originId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['origin'] = origin;
    data['originId'] = originId;
    return data;
  }
}
