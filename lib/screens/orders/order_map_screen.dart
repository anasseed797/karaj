import 'package:flutter/material.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/ui_widgets/draw_order_map.dart';

class OrderingMapScreen extends StatelessWidget {
  final OrderModel order;

  const OrderingMapScreen({Key key, this.order}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: order.id ?? ''),
      body: DrawOrderLocation(
        fullHeight: true,
        fromLat: order.fromLat,
        fromLng: order.fromLng,
        toLat: order.toLat,
        toLng: order.toLng,
        endpoint: order.polylineEndpoint,
      ),
    );
  }
}

