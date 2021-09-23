import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/screens/map/search_by_name.dart';
import 'package:karaj/services/googleMapApiMethods.dart';

class SelectLocation extends StatefulWidget {
  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {

  Set<Marker> _markers = {};

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController mapCtrl;
  static LatLng _center = LatLng(22.982674, 45.234597);
  static final CameraPosition _initCameraPosition = CameraPosition(
    target: _center,
    zoom: 5,
  );
  Position currentPosition;

  String fullAddress;

  @override
  void initState() {
    _markers.add(Marker(
        markerId: MarkerId('userLocation'),
        position: _center,
        icon: BitmapDescriptor.defaultMarker));
    super.initState();
  }

  void getCurrentLocation() async {
    Position p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = p;
    LatLng latLngPosition = LatLng(p.latitude, p.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: latLngPosition, zoom: 14);
    mapCtrl.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String address = await GoogleMapApiMethods.getFullAddress(p.latitude, p.longitude);
    fullAddress = address;
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

  void moveMapCamera(double lat, double lng) {
    LatLng latLngPosition = LatLng(lat, lng);
    CameraPosition cameraPosition = new CameraPosition(target: latLngPosition, zoom: 14);
    mapCtrl.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
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
            onMapCreated: (GoogleMapController ctrl) {
              _controllerGoogleMap.complete(ctrl);
              mapCtrl = ctrl;
              getCurrentLocation();
            },
            markers: _markers,
            onCameraMove: (location) {
              setState(() {
                _center = location.target;
              });
              _onCamMove();
            },
          ),
          Positioned(
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
                        String address = await GoogleMapApiMethods.getFullAddress(placeData["lat"], placeData["lng"]);
                        setState(() {
                          fullAddress = address;
                        });
                        moveMapCamera(placeData["lat"], placeData["lng"]);
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
                          Text('location'.tr, style: TextStyle(fontSize: 11.0, color: Colors.grey)),
                          SizedBox(width: 5),
                          Expanded(child: Text('$fullAddress', overflow: TextOverflow.ellipsis,)),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 15.0,
            right: 0,
            left: 0,
            child: Container(
              width: Get.width,
              child: Column(
                children: [
                  Container(
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: flatButtonWidget(
                        context: context,
                        callFunction: () async {
                          String address = await GoogleMapApiMethods.getFullAddress(_center.latitude, _center.longitude);
                          setState(() {
                            fullAddress = address;
                          });
                        },
                        text: 'selectLocation'.tr
                    ),
                  ),

                  fullAddress != null && fullAddress.isNotEmpty ? Container(
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: flatButtonWidget(
                        context: context,
                        callFunction: () async {
                          Map<String, dynamic> locationData = {};
                          locationData['latlng'] = "${_center.latitude},${_center.longitude}";
                          locationData['lat'] = _center.latitude;
                          locationData['lng'] = _center.longitude;
                          locationData['address'] = fullAddress;
                          Navigator.pop(context, locationData);
                        },
                        text: 'btnContinue'.tr
                    ),
                  ) : SizedBox.shrink(),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
