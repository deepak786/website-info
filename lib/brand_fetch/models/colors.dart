class Colors {
  String? hex;
  String? type;
  int? brightness;

  Colors({this.hex, this.type, this.brightness});

  Colors.fromJson(Map<String, dynamic> json) {
    hex = json['hex'];
    type = json['type'];
    brightness = json['brightness'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hex'] = hex;
    data['type'] = type;
    data['brightness'] = brightness;
    return data;
  }
}
