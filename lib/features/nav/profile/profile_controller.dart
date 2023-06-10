import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileController extends GetxController {

  RxString appVersion = "".obs;

  @override
  void onInit() {
    getAppVersion();
    super.onInit();
  }

  void getAppVersion() async {
    try{

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      appVersion("Version "+version);
    }catch(e){
      debugPrint(e.toString());
    }
  }
}