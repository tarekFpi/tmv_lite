import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmv_lite/features/nav/home/home_controller.dart';
import 'package:tmv_lite/features/nav/home/home_screen.dart';
import 'package:tmv_lite/features/nav/profile/profile_screen.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({Key? key}) : super(key: key);

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {


  final homeController = Get.put(HomeController());

  final pages = [
    const HomeScreen(),
    ProfileScreen()
  ];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        centerTitle: true,
        surfaceTintColor: Colors.white,
        title: Image.asset(
          "assets/images/runner_logo.png",
          width: 180,
        ),
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => setState(() {
            selectedIndex = index;
          }),
          destinations: const <NavigationDestination>[
            NavigationDestination(
                icon: Icon(FluentIcons.home_24_regular),
                label: "Home",
                selectedIcon: Icon(
                  FluentIcons.home_24_filled,
                  color: Colors.white,
                )),
            NavigationDestination(
                icon: Icon(FluentIcons.person_24_regular),
                label: "Account",
                selectedIcon: Icon(
                  FluentIcons.person_24_filled,
                  color: Colors.white,
                )),
          ],
        ),
      ),
    );
  }
}
