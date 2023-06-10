import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

// ignore: constant_identifier_names
// Request methods PUT, POST, PATCH, DELETE needs access token,
// which needs to be passed with "Authorization" header as Bearer token.
class AuthorizationInterceptor extends Interceptor {

  final _box = GetStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {

    final cookie = _box.read("user_cookie");
    debugPrint(cookie.toString());
    options.headers['Cookie'] = cookie;
    // continue with the request
    super.onRequest(options, handler);
  }
}