import 'package:tmv_lite/core/model/error.dart';
import 'package:tmv_lite/features/vehicles/model/terminal.dart';

class TerminalResponse {
  TerminalResponse({
      Error? error, 
      Response? response,}){
    _error = error;
    _response = response;
}

  TerminalResponse.fromJson(dynamic json) {
    _error = json['Error'] != null ? Error.fromJson(json['Error']) : null;
    _response = json['Response'] != null ? Response.fromJson(json['Response']) : null;
  }
  Error? _error;
  Response? _response;

  Error? get error => _error;
  Response? get response => _response;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_error != null) {
      map['Error'] = _error?.toJson();
    }
    if (_response != null) {
      map['Response'] = _response?.toJson();
    }
    return map;
  }

}

class Response {
  Response({
      List<Terminal>? terminal,}){
    _terminal = terminal;
}

  Response.fromJson(dynamic json) {
    if (json['Terminal'] != null) {
      _terminal = [];
      json['Terminal'].forEach((v) {
        _terminal?.add(Terminal.fromJson(v));
      });
    }
  }
  List<Terminal>? _terminal;

  List<Terminal>? get terminal => _terminal;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_terminal != null) {
      map['Terminal'] = _terminal?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}