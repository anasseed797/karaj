import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/sparesOrderingController.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/spares.dart';
import 'package:karaj/models/user.dart';
import 'package:karaj/screens/home_screen.dart';
import 'package:karaj/screens/spares/add_spares_form_screen.dart';

class SelectItemsScreen extends StatelessWidget {
  final UserModel shop;

  SelectItemsScreen({this.shop});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SparesOrderingController>(
        builder: (controller) => Scaffold(
          appBar: appBar(
              title:
              '${shop.firstName} ${shop.lastName} - ${controller.order.brand} ${controller.order.category} ${controller.order.model}'),
          body: Container(
            padding: EdgeInsets.only(bottom: 25.0),
            child: ListView.builder(
              //  physics: NeverScrollableScrollPhysics(),
                itemCount: controller.order.items?.length ?? 0,
                itemBuilder: (BuildContext context, index) {
                  Item item = controller.order.items[index];
                  return Container(
                    margin: EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(8.0),
                    color: Get.theme.backgroundColor,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          padding: EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(5)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(Icons.add, size: 20.0),
                                  ),
                                  onTap: () {
                                    controller.addQty(index, true);
                                  }),
                              Text(item.quantity.toString() ?? '', style: TextStyle(fontSize: 11.0),),
                              InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(Icons.remove, size: 20.0),
                                  ),
                                  onTap: () => {
                                    if (item.quantity > 1)
                                      {
                                        controller.addQty(index, false)
                                      }
                                  }),
                            ],
                          ),
                        ),
                        SizedBox(width: 15.0),
                        Expanded(
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[200],
                            ),
                            title: Text(item.name ?? ''),
                            subtitle: Text(item.number ?? ''),
                            trailing: IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: () {
                                controller.order.items.removeAt(index);
                                controller.setItems(controller.order.items);
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }),
          ),
          bottomNavigationBar: controller.order.items.length <= 0 ? Container(height: 0) : normalFlatButtonWidget(
            context: context,
            text: 'ارسال الطلب',
            callFunction: () async {
              Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
              await controller.submitOrder(shop: shop);
              Get.offAll(HomeScreen());
              Get.back();

              GetxWidgetHelpers.mSnackBar('spareSend'.tr, 'spareSendDsp'.tr);
            },
            radius: 0,
            padding: EdgeInsets.all(15.0),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.to(AddSpares());
            },
            child: Icon(Icons.add),
            backgroundColor: Get.theme.colorScheme.primaryVariant,
          ),
        )
    );
  }
}
