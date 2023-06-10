import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tmv_lite/features/auth/auth_controller.dart';
import 'package:tmv_lite/features/nav/home/home_controller.dart';
import 'package:tmv_lite/features/vehicles/model/terminal.dart';
import 'package:tmv_lite/features/vehicles/ui/details/vehicle_details_screen.dart';
import 'package:tmv_lite/utils/hexcolor.dart';
import 'package:tmv_lite/widgets/custom_error_widget.dart';
import 'package:tmv_lite/widgets/custom_list_loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final queryEditingController = TextEditingController();
  final homeController = Get.find<HomeController>();
  final authController = Get.find<AuthController>();
  final storage = GetStorage();
  String query = "";

  @override
  void initState() {
    homeController.getTerminalList();
    super.initState();
  }

  void moveToTerminalDetails(Terminal terminal){
    FocusScope.of(context).unfocus();
    final CameraPosition cameraPosition = CameraPosition(
      target: LatLng(double.parse(terminal.terminalDataLatitudeLast!),
          double.parse(terminal.terminalDataLongitudeLast!)),
      zoom: 15,
    );
    Get.to(() => VehicleDetailsScreen(
      vehicle: terminal,
      initialCameraPosition: cameraPosition,
    ));
  }

  void loginInAgain(BuildContext context) async {

    final username = storage.read("username");
    final password = storage.read("password");

    if(username == null || password == null){
      authController.logout(context: context);
    }else{
      final result = await authController.login(username, password);
      if(result == true){
        homeController.getTerminalList();
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16, top: 16),
              child: TextField(
                style: textTheme.bodyMedium,
                controller: queryEditingController,
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                  homeController.filterTerminals(value);
                },
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    hintText: "Search for vehicle",
                    hintStyle: textTheme.bodyMedium
                        ?.copyWith(color: HexColor("#BCC2EB")),
                    suffixIcon: query.isBlank == true || query.isEmpty
                        ? Icon(
                            FluentIcons.search_24_regular,
                            color: HexColor("#BCC2EB"),
                          )
                        : IconButton(
                            icon: Icon(Icons.close, color: HexColor("#BCC2EB")),
                            onPressed: () {
                              //clear query
                              setState(() {
                                query = "";
                              });
                              queryEditingController.clear();
                              FocusScope.of(context).unfocus();
                              homeController.filterTerminals(null);
                            })),
              ),
            ),
            Obx(() => Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 8),
                  child: Text(
                    "Vehicle List(${homeController.listLength})",
                    style: textTheme.labelMedium
                        ?.copyWith(color: HexColor("#5C5D72")),
                  ),
                )),
            Expanded(
              child: homeController.obx(
                  (state) => RefreshIndicator(
                      onRefresh: homeController.getTerminalList,
                      child: ListView.builder(
                        itemBuilder: (ctx, index) {
                          final item = state![index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            color: HexColor("#F9FAFF"),
                            elevation: 0,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: (){
                                moveToTerminalDetails(item);
                              },
                              child: ListTile(
                                dense:true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 6),
                                leading: Image.asset(
                                  "assets/images/car.png",
                                  width: 45,
                                  height: 45,
                                ),
                                title: Text(
                                  "${item.carrierRegistrationNumber}, ${item.carrierName}",
                                  style: textTheme.labelLarge
                                      ?.copyWith(color: HexColor("#303192")),
                                ),
                                subtitle: Text(
                                  "RML ${item.terminalAssignmentCode}",
                                  style: textTheme.bodySmall
                                      ?.copyWith(color: HexColor("#303192")),
                                ),
                                trailing: Card(
                                  elevation: 0,
                                  color: HexColor("#F5F6FC"),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: state?.length ?? 0,
                      )),
                  onLoading: CustomListLoadingWidget(), onError: (msg) {
                if (msg == "Terminal not found") {
                  return CustomErrorWidget(
                      message: "Your login session has been expired",
                      onClick: () {
                        loginInAgain(context);
                      },
                      icon: const Icon(
                        FluentIcons.warning_28_filled,
                        color: Colors.orangeAccent,
                        size: 60,
                      ),
                      btnLevel: "Login");
                }
                return CustomErrorWidget(
                    icon: Icon(
                      msg == "No Internet." ? FluentIcons.wifi_off_24_regular : FluentIcons.error_circle_24_filled,
                      color: Colors.red,
                      size: 40,
                    ),
                    btnLevel: "Retry",
                    message: msg.toString(),
                    onClick: () {
                      homeController.getTerminalList();
                    });
              },
                  onEmpty: const Center(
                    child: Text("No Vehicle Found"),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
