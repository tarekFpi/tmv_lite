import 'package:dio/dio.dart' as Dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tmv_lite/core/network/dio_client.dart';
import 'package:tmv_lite/features/auth/login_screen.dart';
import 'package:tmv_lite/features/auth/model/login_response.dart';
import 'package:tmv_lite/features/nav/home/home_controller.dart';
import 'package:tmv_lite/utils/toast.dart';

class AuthController extends GetxController {

  final dioClient = DioClient.instance;
  final storage = GetStorage();


  Future<bool> login(username, password) async {


    EasyLoading.show(dismissOnTap: true, maskType: EasyLoadingMaskType.custom);
    try {
      var formData = Dio.FormData.fromMap({
        "_Script": "API/V1/User/SignIn",
        "UserSignInName": username,
        "UserEmail": username,
        "UserPassword": password
      });


      final res = await dioClient.post("/", data: formData);
      final loginResponse = LoginResponse.fromJson(res.data);
      if(loginResponse.error?.code != 0){
        Toast.errorToast("${loginResponse.error?.description}", "Error Occur");

        EasyLoading.dismiss();
        return false;
      }else{

        final cookie = res.headers["Set-Cookie"].toString().split(";").first.replaceAll("[", "");
        final user = res.data["Response"]["User"];

        //save cookie to local storage
        storage.remove("user_cookie");
        storage.remove("user_info");

        saveCookie(cookie);
        saveUser(user);

        EasyLoading.dismiss();
        return true;
      }

    } catch (e) {
      debugPrint(e.toString());
      Toast.errorToast(e.toString(), "Error occur");
      EasyLoading.dismiss();
      return false;
    }
  }

  void logoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () => logout(context: context),
          ),
        ],
      ),
    );
  }

  void logout({BuildContext? context}) async {
    if(context != null) Navigator.of(context).pop();
    try {
      storage.remove("user_cookie");
      storage.remove("user_info");
    } catch (e) {
      storage.remove("user_cookie");
      storage.remove("user_info");
    }
    Get.delete<HomeController>();
    Get.offAll(()=> const LoginScreen());
  }


  void saveCookie(cookie){
    storage.write("user_cookie", cookie);
  }

  void saveUser(user){
    storage.write("user_info", user);
  }

  bool isLoggedIn(){
    if(storage.read("user_cookie") != null) return true;
    return false;
  }
}
