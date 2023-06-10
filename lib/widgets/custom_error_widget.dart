import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onClick;
  final Icon icon;
  final String btnLevel;
  const CustomErrorWidget({Key? key, required this.message, required this.onClick, required this.icon, required this.btnLevel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          icon,
          const SizedBox(
            height: 24,
          ),
          Text(message, style: textTheme.bodyLarge,),
          const SizedBox(
            height: 24,
          ),
          ElevatedButton(style: ElevatedButton.styleFrom(
            foregroundColor:
            Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),onPressed: onClick, child: Text(btnLevel))
        ],
      ),
    );
  }
}