import 'package:flutter/material.dart';

class WrapTextOptions extends StatelessWidget {
  final Widget child;

  const WrapTextOptions({@required this.child});
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 0.9),
      child: child,
    );
  }
}
