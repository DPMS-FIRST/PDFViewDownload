import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ValidateAlertComponent extends StatelessWidget {
  final String? message;
  final void Function()? onPressed;
  const ValidateAlertComponent({super.key, this.message, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Text(message ?? ""),
      actions: <Widget>[
        CupertinoDialogAction(
            child: Text(
              'OK',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: onPressed),
      ],
    );
  }
}
