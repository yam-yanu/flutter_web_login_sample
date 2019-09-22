import 'package:flutter/material.dart';
import 'package:flutter_web_login_sample/auth.dart';

class Provider extends InheritedWidget {
  final BaseAuth auth;

  Provider({
    Key key,
    Widget child,
    this.auth,
  }) : super(
    key: key,
    child: child,
  );

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static Provider of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(Provider) as Provider);
}
