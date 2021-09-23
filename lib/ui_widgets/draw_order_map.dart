import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:karaj/helpers.dart';

class DrawOrderLocation extends StatefulWidget {

  final double fromLat, fromLng, toLat, toLng;
  final bool fullHeight;
  final String endpoint;

  const DrawOrderLocation({Key key, this.fromLat, this.fromLng, this.toLat, this.toLng, this.fullHeight = false, this.endpoint}) : super(key: key);

  @override
  _DrawOrderLocationState createState() => _DrawOrderLocationState();
}

class _DrawOrderLocationState extends State<DrawOrderLocation> {
  BitmapDescriptor fromMarker;
  BitmapDescriptor toMarker;
  Set<Marker> _markers = {};
  static LatLng _center = LatLng(22.982674, 45.234597);
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController mapCtrl;
  static final CameraPosition _initCameraPosition = CameraPosition(
    target: _center,
    zoom: 14,
  );

  Set<Polyline> polylineSet = {};


  @override
  void initState() {
    if(widget.fromLat != null && widget.fromLng != null) {
      _center = LatLng(widget.fromLat, widget.fromLng);
    }


    asyncFunction();
    super.initState();
  }

  void asyncFunction() async {
    if(widget.endpoint != null) {
      List<LatLng> pLineCoordinates = await Helpers.decodeEndpointPolyline(widget.endpoint);
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
            position: LatLng(widget.fromLat, widget.fromLng),
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
            position: LatLng(widget.toLat, widget.toLng),
            icon: toMarker,
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * (widget.fullHeight ? 1 : 0.3),
      child: GoogleMap(
        mapType: MapType.normal,
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: false,
        initialCameraPosition: _initCameraPosition,
        polylines: polylineSet,
        onMapCreated: (GoogleMapController ctrl) {
          _controllerGoogleMap.complete(ctrl);
          mapCtrl = ctrl;
        },
        markers: _markers,
        onCameraMove: (location) {
          setState(() {
            _center = location.target;
          });
        },
      ),
    );
  }
}
