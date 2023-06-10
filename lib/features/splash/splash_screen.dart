import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmv_lite/features/auth/auth_controller.dart';
import 'package:tmv_lite/features/auth/login_screen.dart';
import 'package:tmv_lite/features/nav/nav_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final authController = Get.find<AuthController>();

  @override
  void initState() {

    checkAuthState();

    super.initState();
  }

  void checkAuthState() async {
    await Future.delayed(Duration(seconds: 2));
    if(authController.isLoggedIn()){
      Get.offAll(() => NavScreen());
    }else{
      Get.offAll(() => LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("assets/images/runner_logo.png", width: 220,),
      ),
    );
  }
}
