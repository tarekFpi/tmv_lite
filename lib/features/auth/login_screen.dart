import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tmv_lite/features/auth/auth_controller.dart';
import 'package:tmv_lite/features/nav/nav_screen.dart';
import 'package:tmv_lite/utils/toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscureText = true;
  String? password;
  String? username;
  bool rememberPassword = false;

  // String? password = "01730405882";
  // String? username = "Runnermotors";

  final formKey = GlobalKey<FormState>();
  final authController = Get.find<AuthController>();
  final storage = GetStorage();

  // Toggles the password show status
  void togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  void attemptLogin() async {
    FocusScope.of(context).unfocus();
    if (formKey.currentState!.validate()) {
      //check if remember password tick
      if (rememberPassword == true) {
        storage.write("username", username?.trim());
        storage.write("password", password?.trim());
      } else {
        storage.remove("username");
        storage.remove("password");
      }

      //login to account
      final result =
          await authController.login(username?.trim(), password?.trim());
      if (result == true) {
        Get.offAll(() => const NavScreen());
        Toast.successToast("Login success", "Welcome back");
      }
    }
  }

  @override
  void initState() {
    checkRememberPassword();
    super.initState();
  }

  void checkRememberPassword() {
    final sUsername = storage.read("username");
    final sPassword = storage.read("password");

    setState(() {
      if (sUsername != null && sPassword != null) {
        username = sUsername;
        password = sPassword;
        rememberPassword = true;
      } else {
        rememberPassword = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          width: double.infinity,
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                Expanded(
                    child: Image.asset(
                      "assets/images/runner_logo.png",
                      width: 220,
                    )),
                TextFormField(
                  initialValue: username,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Enter valid username';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      username = value;
                    });
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      hintText: "Username"),
                ),
                const SizedBox(
                  height: 24,
                ),
                TextFormField(
                  initialValue: password,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Enter valid password';
                    }
                    return null;
                  },
                  enableSuggestions: false,
                  autocorrect: false,
                  obscureText: obscureText,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      hintText: "Password",
                      suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            obscureText ? Icons.visibility : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: togglePasswordVisibility)),
                ),
                const SizedBox(
                  height: 8,
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  onTap: () {
                    setState(() {
                      rememberPassword = !rememberPassword;
                    });
                  },
                  leading: Checkbox(
                    value: rememberPassword,
                    onChanged: (value) {
                      setState(() {
                        rememberPassword = !rememberPassword;
                      });
                    },
                  ),
                  title: const Text("Remember Password ?"),
                ),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                    onPressed: attemptLogin,
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "A Product of",
                        style: textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Image.asset(
                      "assets/images/bondstein_logo.png",
                      width: 110,
                    )
                  ],
                ),
                const SizedBox(
                  height: 24,
                )
              ],
            ),
          ),
        ));
  }
}
