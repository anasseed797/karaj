import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:karaj/bindings/widgets.dart';

class SelectLocationScreen extends StatefulWidget {
  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen>  {
  LatLng _userLocation = LatLng(21.567948, 39.208358);

  GoogleMapController mapController;

  Set<Marker> _markers = {};

  LatLng _center = const LatLng(21.567948, 39.208358);

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  @override
  void initState() {
    super.initState();
    _markers.add(Marker(
        markerId: MarkerId('userLocation'),
        position: _center,
        icon: BitmapDescriptor.defaultMarker));
    _getUserLocationGps();
  }

  _getUserLocationGps() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) {
      setState(() {
        _userLocation = LatLng(value.latitude, value.longitude);
        _center = LatLng(value.latitude, value.longitude);
        mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: _center,
          zoom: 10.0,
        )));
        _onCamMove();
      });
      return value;
    }).catchError((e) {
      print(e);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'تحديد الموقع'),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 15.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            markers: _markers,
            onCameraMove: (location) {
              setState(() {
                _userLocation = location.target;
              });
              _onCamMove();
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
          child: FlatButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            padding: const EdgeInsets.all(8.0),
            child:
            Text('متابعة', style: TextStyle(fontWeight: FontWeight.normal)),
            onPressed: () {
              _getAddress();
            },
          ),
        ),
      ),
    );
  }

  void _onCamMove() async {
    if (_markers.isNotEmpty) {
      _markers.clear();
    }
    var newMarker = Marker(
      markerId: MarkerId('userLocation'),
      position: _userLocation,
      icon: BitmapDescriptor.defaultMarker,
    );
    _markers.add(newMarker);
  }

  _getAddress() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController _addressController = TextEditingController();
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('يرجى ادخال عنوان بالتفصيل',
                    style: TextStyle(fontSize: 13.0)),
                TextFormField(
                  controller: _addressController,
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('الغاء'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('تاكيد'),
                onPressed: () async {
                  Map<String, dynamic> locationData = {};
                  locationData['latlng'] = "${_userLocation.latitude},${_userLocation.longitude}";
                  locationData['lat'] = _userLocation.latitude;
                  locationData['lng'] = _userLocation.longitude;
                  locationData['address'] = _addressController.text;
                  Navigator.pop(context);
                  Navigator.pop(context, locationData);
                },
              )
            ],
          );
        });
  }
}