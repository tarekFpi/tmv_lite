class Error {
  Error({
    num? code,
    String? description,}){
    _code = code;
    _description = description;
  }

  Error.fromJson(dynamic json) {
    _code = json['Code'];
    _description = json['Description'];
  }
  num? _code;
  String? _description;

  num? get code => _code;
  String? get description => _description;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Code'] = _code;
    map['Description'] = _description;
    return map;
  }

}