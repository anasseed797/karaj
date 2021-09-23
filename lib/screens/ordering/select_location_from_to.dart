import 'dart:async';
import 'dart:convert';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/orderingController.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/screens/map/search_by_name.dart';
import 'package:karaj/screens/ordering/select_vehicle_from_panel.dart';
import 'package:karaj/screens/ordering/select_vehicle_type.dart';
import 'package:karaj/services/googleMapApiMethods.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SelectLocation extends StatefulWidget {

  final int orderType;
  final String orderTypeString;
  final bool isSpareOrder;
  final Map<String, dynamic> spare;
  const SelectLocation({Key key, this.orderType, this.orderTypeString, this.isSpareOrder = false, this.spare}) : super(key: key);

  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {

  OrderingController _orderCtrl = Get.find();
  PanelController _panelController = PanelController();
  BitmapDescriptor fromMarker;
  BitmapDescriptor toMarker;
  Set<Marker> _markers = {};

  Set<Polyline> polylineSet = {};

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController mapCtrl;
  static LatLng _center = LatLng(22.982674, 45.234597);
  static final CameraPosition _initCameraPosition = CameraPosition(
    target: _center,
    zoom: 5,
  );


  Position currentPosition;
  bool onPickSelected = true;


  @override
  void initState() {
    _orderCtrl.clear();

    if(widget.isSpareOrder) {
      _orderCtrl.order.isSpareOrder = true;
      _orderCtrl.order.spareID = widget.spare["id"];
      _orderCtrl.order.active = false;
      _orderCtrl.order.payed = 1;
      _orderCtrl.order.payCash = false;
      _orderCtrl.order.shopName = widget.spare["shopName"] ?? '';
      _orderCtrl.order.shopPhone = widget.spare["shopPhone"] ?? '';
    } else {
      _orderCtrl.order.orderType = widget.orderType ?? 1;
      _orderCtrl.order.orderTypeString = widget.orderTypeString ?? "";
    }

    _markers.add(Marker(
        markerId: MarkerId('userLocation'),
        position: _center,
        icon: BitmapDescriptor.defaultMarker));

    asyncFunction();
    super.initState();
  }

  void asyncFunction() async {
    await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(35, 35)), 'assets/images/location.png')
        .then((d) {
      fromMarker = d;
    });

    await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(35, 35)), 'assets/images/marker.png')
        .then((d) {
      toMarker = d;
    });
  }

  void getCurrentLocation() async {

    try {
      Position p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentPosition = p;
      LatLng latLngPosition = LatLng(p.latitude, p.longitude);
      CameraPosition cameraPosition = new CameraPosition(target: latLngPosition, zoom: 14);
      mapCtrl.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      if(!widget.isSpareOrder) {
        String address = await GoogleMapApiMethods.getFullAddress(p.latitude, p.longitude);
        OrderModel _o = _orderCtrl.order;
        _o.fromFullAddress = address;
        _orderCtrl.setOrder = _o;
      }

    } catch (e) {
      print("error on catching current location $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'selectLocation'.tr),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _initCameraPosition,
            polylines: polylineSet,
            onMapCreated: (GoogleMapController ctrl) async {
              _controllerGoogleMap.complete(ctrl);
              mapCtrl = ctrl;
              if(widget.isSpareOrder) {
                await updateFrom(lat: widget.spare["fromLat"],lng: widget.spare["fromLng"]);
                getCurrentLocation();
              } else {
                getCurrentLocation();
              }
            },
            markers: _markers,
            onCameraMove: (location) {
              setState(() {
                _center = location.target;
              });
              _onCamMove();
            },
          ),

          Obx(
              () => Positioned(
                top: 15.0,
                right: 0,
                left: 0,
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          var place = await Get.to(FindPlaceOnMap());
                          if(place != null) {
                            Map<String, dynamic> placeData = jsonDecode(place);
                            updateFrom(lng: placeData["lng"],lat: placeData["lat"]);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          margin: EdgeInsets.symmetric(vertical: 5.0),
                          decoration: BoxDecoration(
                              color: Colors.white
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_history, color: Color(0xffff5267)),
                              SizedBox(width: 5),
                              Text('pickupFrom'.tr, style: TextStyle(fontSize: 11.0, color: Colors.grey)),
                              SizedBox(width: 5),
                              _orderCtrl.onLoading && _orderCtrl.step == 0? Container(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(),
                              ) : Expanded(child: Text('${_orderCtrl.order.fromFullAddress} ', overflow: TextOverflow.ellipsis,)),

                            ],
                          ),
                        ),
                      ),

                      _orderCtrl.step > 0 ? GestureDetector(
                        onTap: () async {
                          var place = await Get.to(FindPlaceOnMap());
                          if(place != null) {
                            Map<String, dynamic> placeData = jsonDecode(place);
                            updateTo(lng: placeData["lng"],lat: placeData["lat"]);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          margin: EdgeInsets.symmetric(vertical: 5.0),
                          decoration: BoxDecoration(
                              color: Colors.white
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Color(0xff228cff)),
                              SizedBox(width: 5),
                              Text('pickupTo'.tr, style: TextStyle(fontSize: 11.0, color: Colors.grey)),
                              SizedBox(width: 5),
                              _orderCtrl.onLoading ? Container(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(),
                              ) : Expanded(child: Text('${_orderCtrl.order.toFullAddress}', overflow: TextOverflow.ellipsis,)),
                            ],
                          ),
                        ),
                      ) : SizedBox.shrink()
                    ],
                  ),
                ),
              )
          ),

          Positioned(
            bottom: 15.0,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: flatButtonWidget(
                context: context,
                callFunction: () => _doSomething(),
                text: _orderCtrl.step == 2 ? 'selectVan'.tr : _orderCtrl.step == 0 ? 'confirmPickupLocation'.tr : 'confirmDropOffLocation'.tr
              ),
            ),
          ),

          _orderCtrl.step >= 2 ? SlidingUpPanel(
            controller: _panelController,
            backdropEnabled: true,
            panel: SelectVehicleTypePanel(),
            borderRadius: BorderRadius.circular(15.0),
          ) : SizedBox.shrink(),
        ],
      ),
    );
  }

  void _onCamMove() async {
    if (_markers.isNotEmpty) {
      _markers.remove(_markers.firstWhere((Marker marker) => marker.markerId.value == "userLocation"));
    }
    var newMarker = Marker(
      markerId: MarkerId('userLocation'),
      position: _center,
      icon: BitmapDescriptor.defaultMarker,
    );
    _markers.add(newMarker);
  }

  void _doSomething() async {
   /* if (_orderCtrl.step == 2) {
      _markers.where((Marker marker) {
          if(marker.markerId.value == "userLocation") {
            _markers.remove(marker);
          }
          return;
      });
      Get.to(SelectVehicleType());
      return;
    }*/
    if(_orderCtrl.step == 0) {
      updateFrom(lat: _center.latitude, lng: _center.longitude);
    } else if(_orderCtrl.step >= 1) {
      await updateTo(lat: _center.latitude, lng: _center.longitude);
      print("============================ _panelController.isAttached : ${_panelController.isAttached}");
      if(_panelController.isAttached) {
        _panelController.open();
      } else {
        Future.delayed(Duration(seconds: 1), () {
          _panelController.open();
        });
      }
    }
  }

  Future<void> updateFrom({double lat, double lng}) async {
    _orderCtrl.setLoading = true;
    String address = await GoogleMapApiMethods.getFullAddress(lat, lng);
    OrderModel _o = _orderCtrl.order;
    _orderCtrl.setStep = 1;
    _o.fromFullAddress = address;
    _o.fromLat = lat;
    _o.fromLng = lng;
    _markers.add(Marker(
      markerId: MarkerId("fromMarker"),
      position: LatLng(lat, lng),
      icon: fromMarker,
    ));
    _orderCtrl.setOrder = _o;
    _orderCtrl.setLoading = false;
    moveMapCamera(lat,lng);
  }

  Future<void> updateTo({double lat, double lng}) async {
    _orderCtrl.setLoading = true;
    String address = await GoogleMapApiMethods.getFullAddress(lat, lng);
    OrderModel _o = _orderCtrl.order;
    _orderCtrl.setStep = 2;
    _o.toFullAddress = address;
    _o.toLat = lat;
    _o.toLng = lng;
    _markers.add(Marker(
      markerId: MarkerId("toMarker"),
      position: LatLng(lat, lng),
      icon: toMarker,
    ));
    drawPolyLine(LatLng(_o.fromLat, _o.fromLng), LatLng(lat, lng));
    _orderCtrl.setOrder = _o;
    _orderCtrl.setLoading = false;
    moveMapCamera(lat,lng);
  }

  void moveMapCamera(double lat, double lng) {
    LatLng latLngPosition = LatLng(lat, lng);
    CameraPosition cameraPosition = new CameraPosition(target: latLngPosition, zoom: 14);
    mapCtrl.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  drawPolyLine(LatLng from, LatLng to) async {
    Map<String, String> mapReturned = await GoogleMapApiMethods.getDirections(from, to);
    String polylineEndpoint = mapReturned["polylines"];
    String totalDuration = mapReturned["totalDuration"];
    List<LatLng> pLineCoordinates = await Helpers.decodeEndpointPolyline(polylineEndpoint);
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
    _orderCtrl.order.polylineEndpoint = polylineEndpoint;
    _orderCtrl.order.totalDuration = totalDuration;
    _orderCtrl.setOrder = _orderCtrl.order;
  }
}
