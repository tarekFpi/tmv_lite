import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tmv_lite/core/network/dio_client.dart';
import 'package:tmv_lite/features/vehicles/model/terminal.dart';
import 'package:tmv_lite/features/vehicles/model/terminal_response.dart';


class HomeController extends GetxController with StateMixin<List<Terminal>> {
  final dioClient = DioClient.instance;
  final terminals = RxList<Terminal>();
  final RxInt listLength = 0.obs;
  final storage = GetStorage();


  void filterTerminals(String? query) {
    if (query == null || query.isEmpty || query.toLowerCase().trim() == "r" || query.toLowerCase().trim() == "rm" || query.toLowerCase().trim() == "rml") {
      listLength(terminals.value.length);
      change(terminals.value, status: RxStatus.success());
    } else {
      try {

        final modifiedQuery = query.replaceAll("rml", "").replaceAll("RML", "");
        final list = terminals.value
            .where((element) =>
        element.terminalID!
            .toLowerCase()
            .contains(modifiedQuery.toLowerCase().trim()) ||
            element.terminalAssignmentCode!
                .toLowerCase()
                .contains(modifiedQuery.toLowerCase().trim()) ||
            element.carrierRegistrationNumber!
                .toLowerCase()
                .contains(modifiedQuery.toLowerCase().trim()))
            .toList();

        listLength(list.length);

        if (list.isEmpty) {
          change([], status: RxStatus.empty());
        } else {
          change(list, status: RxStatus.success());
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future<void> getTerminalList() async {
    try {
      change(null, status: RxStatus.loading());
      listLength(0);

      var formData = dio.FormData.fromMap({"_Script": "API/V1/Terminal/List", "Column" :  "TerminalID,TerminalDataLatitudeLast,TerminalDataLongitudeLast,TerminalAssignmentCode,CarrierRegistrationNumber,CarrierName" });

      final res = await dioClient.post("/",
          data: formData, options: Options(
            headers: {"Cookie": storage.read("user_cookie")},
          ));
      final vehicleResponse = TerminalResponse.fromJson(res.data);
      if (vehicleResponse.error?.code != 0) {
        change(null,
            status: RxStatus.error(vehicleResponse.error?.description));
        return;
      }
      final list = vehicleResponse.response?.terminal ?? [];

      //set vehicle list
      terminals(list);
      listLength(list.length);

      if (list.isEmpty) {
        change([], status: RxStatus.empty());
      } else {
        change(list, status: RxStatus.success());
      }
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }
}