import 'package:tmv_lite/features/auth/model/user.dart';
import 'package:tmv_lite/core/model/error.dart';

class LoginResponse {
  LoginResponse({
      Error? error,
      Response? response,}){
    _error = error;
    _response = response;
}

  LoginResponse.fromJson(dynamic json) {
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
      User? user,}){
    _user = user;
}

  Response.fromJson(dynamic json) {
    _user = json['User'] != null ? User.fromJson(json['User']) : null;
  }
  User? _user;

  User? get user => _user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_user != null) {
      map['User'] = _user?.toJson();
    }
    return map;
  }

}