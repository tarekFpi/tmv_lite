import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmv_lite/features/auth/auth_controller.dart';
import 'package:tmv_lite/features/nav/profile/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final profileController = Get.put(ProfileController());
  final authController = Get.find<AuthController>();



  @override
  Widget build(BuildContext context) {

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
              onPressed: (){
                authController.logoutDialog(context);
              },
              child: const Text("Logout"),
            ),
            const SizedBox(
              height: 16,
            ),
            Obx(() => Text("${profileController.appVersion}",style: textTheme.caption, ))
          ],
        ),
      ),
    );
  }
}
