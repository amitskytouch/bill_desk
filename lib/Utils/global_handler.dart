import 'package:flutter/material.dart';

void navigatorPush(BuildContext context, Widget child) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) {
      return child;
    }),
  );
}

void navigatorPushReplace(BuildContext context, Widget child) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) {
      return child;
    }),
  );
}

void navigatorRemove(BuildContext context, Widget child) {
  Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (context) => child), (route) => false);
}
