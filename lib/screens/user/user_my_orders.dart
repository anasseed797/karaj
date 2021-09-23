import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/authController.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/models/spares.dart';
import 'package:karaj/screens/orders/list_order_widget.dart';
import 'package:karaj/screens/spares/list_spares_orders.dart';
import 'package:karaj/services/database.dart';

class UserMyOrders extends StatefulWidget {
  @override
  _UserMyOrdersState createState() => _UserMyOrdersState();
}

class _UserMyOrdersState extends State<UserMyOrders> {
  AuthController authCtrl = Get.find();
  UserController _userCtrl = Get.find();

  int selectedPage = 0;
  PageController _pageController;

  //List<SparesModel> _sparesOrders = <SparesModel>[];
  //Stream<List<OrderModel>> _stream;
  bool isDriver = false;
  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    fetchData();
    super.initState();
  }

  fetchData() {
    if(_userCtrl.user != null && _userCtrl.user.isDriver) {
      isDriver = true;
      setState(() {});
    } else {
      setState(() {});
    }

    /*  if(!_userCtrl.user.isDriver && !_userCtrl.user.isShop) {
      _sparesOrders = await Database().getSparesOrders(userId: authCtrl.user.uid);
      _sparesOrders.sort((a, b) => a.id.compareTo(b.id));
    }
*/



  }

  Map<Y, List<T>> groupBy<T, Y>(Iterable<T> itr, Y Function(T) fn) {
    return Map.fromIterable(itr.map(fn).toSet(),
        value: (i) => itr.where((v) => fn(v) == i).toList());
  }

  @override
  Widget build(BuildContext context) {
    print(_userCtrl.user.id);
    return Scaffold(
      appBar: appBar(title: 'طلباتي'),
      body: Column(
        children: [
          Container(
            width: Get.width,
            color: Get.theme.backgroundColor,
            child: Row(
              children: [
                tabWidget('جميع الطلبات', 0),
                tabWidget('طلبات منتهية', 1),
                tabWidget('طلبات قطع الغيار', 2),
              ],
            )
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Container(
                  child: StreamBuilder(
                    stream: isDriver ? Database().getDriverOrdersStream(userId: _userCtrl.user.id) : Database().getUserOrdersStream(userId: authCtrl.user.uid),
                    builder: (BuildContext context, AsyncSnapshot<List<OrderModel>> snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting) {
                        return Container(height: Get.height * 0.9, child: LoadingScreen(true));
                      } else {
                        if(snapshot.hasData && snapshot.data.length > 0) {
                          List<OrderModel> _orders = snapshot.data;
                          if(isDriver) {
                            _orders.sort((a, b) => a.id.compareTo(b.id));
                          } else {
                            _orders.sort((a, b) => b.id.compareTo(a.id));
                          }
                          _orders.removeWhere((element) => element.status == 97 || element.status == 9);


                          return ListOrderWidget(orders: _orders, displayScroll: true);
                        } else {
                          return EmptyScreen();
                        }
                      }
                    },
                  ),
                ),
                Container(
                  child: StreamBuilder(
                    stream: isDriver ? Database().getDriverOrdersStream(userId: _userCtrl.user.id) : Database().getUserOrdersStream(userId: authCtrl.user.uid),
                    builder: (BuildContext context, AsyncSnapshot<List<OrderModel>> snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting) {
                        return Container(height: Get.height * 0.9, child: LoadingScreen(true));
                      } else {
                        if(snapshot.hasData && snapshot.data.length > 0) {
                          List<OrderModel> _orders = snapshot.data;
                          _orders.sort((a, b) => b.id.compareTo(a.id));


                          _orders.removeWhere((element) => element.status < 9);
                          return ListOrderWidget(orders: _orders, displayScroll: true);
                        } else {
                          return EmptyScreen();
                        }
                      }
                    },
                  ),
                ),
                !_userCtrl.user.isDriver && !_userCtrl.user.isShop ? Container(child: StreamBuilder<List<SparesModel>>(
                  stream: Database().getSparesOrdersStream(userId: authCtrl.user.uid),
                  builder: (BuildContext context, AsyncSnapshot<List<SparesModel>> snapshot) {
                    if(snapshot.hasData) {
                      return ListSparesOrdersWidget(orders: snapshot.data, displayScroll: true);
                    }
                    return Container();
                  },
                )) : SizedBox.shrink(),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget tabWidget(String text, int index) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedPage = index;
          });
          _pageController.animateToPage(index, duration: Duration(milliseconds: 350), curve: Curves.linear);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child:  Center(child: Text(text, style: TextStyle(fontWeight: selectedPage == index ? FontWeight.bold : null))),

        ),
      ),
    );
  }


  Widget displayStreamContainer({Stream<List<OrderModel>> stream, String type}) {
    return StreamBuilder(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<List<OrderModel>> snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Container(height: Get.height * 0.9, child: LoadingScreen(true));
        } else {
          if(snapshot.hasData && snapshot.data.length > 0) {
            List<OrderModel> _orders = snapshot.data;
            print("================================ ${snapshot.data.length}");
            if(isDriver) {
              _orders.sort((a, b) => a.id.compareTo(b.id));
            } else {
              _orders.sort((a, b) => b.id.compareTo(a.id));
            }

            if(type == "waiting") {
              _orders.removeWhere((element) => element.status == 97 || element.status == 9);
            } else if (type == "completed") {
              _orders.removeWhere((element) => element.status < 9);
            }
            print("================================ ${snapshot.data.length}");

            return ListOrderWidget(orders: _orders);
          } else {
            return EmptyScreen();
          }
        }
      },
    );
  }
}
