import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Toast {
  static successToast(String title, String message) {
    Get.snackbar(title, message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        colorText: Colors.white);
  }

  static errorToast(String title, String message) {
    Get.snackbar(title, message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        colorText: Colors.white);
  }

  static warningToast(String title, String message, {int? second}) {
    Get.snackbar(title, message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.yellow,
        duration: second == null
            ? const Duration(seconds: 3)
            : Duration(seconds: second),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        colorText: Colors.black);
  }
}