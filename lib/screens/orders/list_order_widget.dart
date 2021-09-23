import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/screens/orders/order_details.dart';
import 'package:karaj/ui_widgets/animations/fade_animation.dart';
import 'package:karaj/ui_widgets/order_card_direction.dart';

class ListOrderWidget extends StatelessWidget {
  final List<OrderModel> orders;
  final bool displayScroll;

  const ListOrderWidget({Key key, this.orders, this.displayScroll = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<OrderModel> ordersList = orders ?? [];
    return ListView.builder(
        physics: displayScroll ? null : NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        primary: true,
        itemCount: ordersList.length,
        itemBuilder: (BuildContext context, index) {
          OrderModel order = ordersList[index];
          return FadeAnimation(
            delay: index * 0.03,
            child: InkWell(
              onTap: () => Get.to(OrderDetails(order: order)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Stack(
                    children: [
                      OrderCardDirection(orderModel: order),
                      Positioned(
                        top: 15,
                        left: 15,
                        child: orderStatus(order.status),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}
