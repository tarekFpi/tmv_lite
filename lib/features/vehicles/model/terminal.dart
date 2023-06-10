class Terminal {
  Terminal({
    String? terminalID,
    String? terminalDataLatitudeLast,
    String? terminalDataLongitudeLast,
    String? terminalAssignmentCode,
    String? carrierRegistrationNumber, String? carrierName}){
    _terminalID = terminalID;
    _terminalDataLatitudeLast = terminalDataLatitudeLast;
    _terminalDataLongitudeLast = terminalDataLongitudeLast;
    _terminalAssignmentCode = terminalAssignmentCode;
    _carrierRegistrationNumber = carrierRegistrationNumber;
    _carrierName = carrierName;
  }

  Terminal.fromJson(dynamic json) {
    _terminalID = json['TerminalID'];
    _terminalDataLatitudeLast = json['TerminalDataLatitudeLast'];
    _terminalDataLongitudeLast = json['TerminalDataLongitudeLast'];
    _terminalAssignmentCode = json['TerminalAssignmentCode'];
    _carrierRegistrationNumber = json['CarrierRegistrationNumber'];
    _carrierName = json['CarrierName'];
  }
  String? _terminalID;
  String? _terminalDataLatitudeLast;
  String? _terminalDataLongitudeLast;
  String? _terminalAssignmentCode;
  String? _carrierRegistrationNumber;
  String? _carrierName;

  String? get terminalID => _terminalID;
  String? get terminalDataLatitudeLast => _terminalDataLatitudeLast;
  String? get terminalDataLongitudeLast => _terminalDataLongitudeLast;
  String? get terminalAssignmentCode => _terminalAssignmentCode;
  String? get carrierRegistrationNumber => _carrierRegistrationNumber;
  String? get carrierName => _carrierName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['TerminalID'] = _terminalID;
    map['TerminalDataLatitudeLast'] = _terminalDataLatitudeLast;
    map['TerminalDataLongitudeLast'] = _terminalDataLongitudeLast;
    map['TerminalAssignmentCode'] = _terminalAssignmentCode;
    map['CarrierRegistrationNumber'] = _carrierRegistrationNumber;
    map['CarrierName'] = _carrierName;
    return map;
  }

}