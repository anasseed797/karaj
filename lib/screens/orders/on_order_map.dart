import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/screens/orders/order_details.dart';
import 'package:karaj/services/location_service.dart';
import 'package:karaj/ui_widgets/order_card_direction.dart';

class OnOrderMap extends StatefulWidget {


  final OrderModel order;
  final String orderID;

  const OnOrderMap({Key key, this.order, this.orderID}) : super(key: key);


  @override
  _OnOrderMapState createState() => _OnOrderMapState();
}

class _OnOrderMapState extends State<OnOrderMap>{

  bool onLoading = false;
  OrderModel order;

  BitmapDescriptor fromMarker;
  BitmapDescriptor toMarker;
  BitmapDescriptor driverMarker;

  static LatLng _center = LatLng(22.982674, 45.234597);
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController mapCtrl;
  CameraPosition _initCameraPosition = CameraPosition(
    target: _center,
    zoom: 14,
  );

  Set<Marker> _markers = Set<Marker>();
  Set<Circle> circleSet = Set<Circle>();
  Set<Polyline> polylineSet = Set<Polyline>();
  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(15, 15)), 'assets/images/car_ios.png').then((d) {
      if(mounted) {
        setState(() {
          driverMarker = d;
        });
      }
    });

    setUpMapData();


    super.initState();
  }

  Future<void> setUpMapData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("orders").doc(widget.orderID).get();
    if(doc.exists) {
      OrderModel _orderM = OrderModel.fromFirestore(doc);
      if(Get.find<UserController>().user.onOrderID == widget.orderID && Get.find<UserController>().user.id == _orderM.driverId) {
        MTLocationService.updateOrderDriverLocation(orderID: widget.orderID);
      }
      if(_orderM.polylineEndpoint != null) {
        List<LatLng> pLineCoordinates = await Helpers.decodeEndpointPolyline(_orderM.polylineEndpoint);
        print(pLineCoordinates.toString());
        setState(() {
          polylineSet.clear();
          Polyline polyline = Polyline(
            polylineId: PolylineId("pID"),
            color: Get.theme.primaryColor,
            jointType: JointType.round,
            points: pLineCoordinates,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            geodesic: true,
          );

          polylineSet.add(polyline);
        });
      }

      await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(35, 35)), 'assets/images/location.png')
          .then((d) {
        if(mounted) {
          setState(() {
            fromMarker = d;
            _markers.add(Marker(
              markerId: MarkerId("fromMarker"),
              position: LatLng(_orderM.fromLat, _orderM.fromLng),
              icon: fromMarker,
            ));
          });
        }
      });

      await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(35, 35)), 'assets/images/marker.png')
          .then((d) {
        if(mounted) {
          setState(() {
            toMarker = d;
            _markers.add(Marker(
              markerId: MarkerId("toMarker"),
              position: LatLng(_orderM.toLat, _orderM.toLng),
              icon: toMarker,
            ));
          });
        }
      });
    }
  }





  @override
  Widget build(BuildContext context) {
    return onLoading ? LoadingScreen(true) : Scaffold(
      appBar: appBar(title: widget.orderID),
      body: StreamBuilder<Object>(
        stream: FirebaseFirestore.instance.collection("orders").doc(widget.orderID).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            order = OrderModel.fromFirestore(snapshot.data);
            _center = LatLng(order.fromLat, order.fromLng);
            _initCameraPosition = CameraPosition(
              target: _center,
              zoom: 14,
            );
            if(order.driverLng != null && order.driverLat != null) {
              _markers.add(Marker(
                markerId: MarkerId("driverMarker"),
                position: LatLng(order.driverLat, order.driverLng),
                icon: driverMarker,
              ));
            }
            return Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    initialCameraPosition: _initCameraPosition,
                    markers: _markers,
                    circles: circleSet,
                    polylines: polylineSet,
                    onMapCreated: (GoogleMapController ctrl) {
                      _controllerGoogleMap.complete(ctrl);
                      mapCtrl = ctrl;
                    },
                    onCameraMove: (location) {
                      setState(() {
                        _center = location.target;
                      });
                    },
                  ),
                ),
                Container(
                  child: OrderCardDirection(orderModel: order),
                )
              ],
            );
          } else {
            return LoadingScreen(true);
          }
        }
      ),
      bottomNavigationBar: normalFlatButtonWidget(
        radius: 0,
        padding: EdgeInsets.all(13.0),
        context: context,
        text: 'عرض الطلب',
        callFunction: () => Get.to(OrderDetails(order: order))
      ),
    );
  }
}
