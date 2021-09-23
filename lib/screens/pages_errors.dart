import 'package:flutter/material.dart';
import 'package:karaj/bindings/widgets.dart';

class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: ''),
      body: SafeArea(
        child: NotFound(),
      ),
    );
  }
}
