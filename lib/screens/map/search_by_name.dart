import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/models/place.dart';
import 'package:karaj/services/googleMapApiMethods.dart';

class FindPlaceOnMap extends StatefulWidget {
  @override
  _FindPlaceOnMapState createState() => _FindPlaceOnMapState();
}

class _FindPlaceOnMapState extends State<FindPlaceOnMap> {

  TextEditingController _controllerTextEditing = TextEditingController();

  List<PlaceModel> placesList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: ''),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Get.theme.backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 7.0,
                              offset: Offset(0.0, 0.0),
                            )
                          ]
                      ),
                      child: TextFormField(
                        controller: _controllerTextEditing,
                        onChanged: (val) {
                          findThatPlace(val: val);
                        },
                        validator: (value) {
                          if (value != null) {
                            return "";
                          }
                          return null;
                        },
                        decoration: inputDecorationUi(context, 'placeName'.tr, color: Colors.transparent),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        autofocus: true,
                        autocorrect: true,
                      ),
                    ),
                  ),

                  SizedBox(width: 10.0),
                  InkWell(
                    onTap: () {
                      findThatPlace();
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Get.theme.backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 7.0,
                            offset: Offset(0.0, 0.0),
                          )
                        ]
                      ),
                      child: Icon(Icons.search),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                  itemBuilder: (BuildContext context, index) {
                    return PredictionTitle(place: placesList[index]);
                  },
                  separatorBuilder: (BuildContext context, int index) => Divider(),
                  itemCount: placesList.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void findThatPlace({String val}) async {
    String xPlace = val;
    if(xPlace == null ) {
      xPlace = _controllerTextEditing.text;
    }
    if(xPlace.trim().length > 0) {
      var res = await GoogleMapApiMethods.findPlaces(xPlace);
      if(res != null) {
        print(res["status"].toString().toUpperCase() );
        if(res["status"].toString().toUpperCase() == "OK") {
          var predictions = res["predictions"];
          var placesListX = (predictions as List).map((e) => PlaceModel.fromMap(e)).toList();
          setState(() {
            placesList = placesListX;
          });
        }
      }
    }
  }
}


class PredictionTitle extends StatelessWidget {

  final PlaceModel place;

  const PredictionTitle({Key key, this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.add_location),
      title: Text(place.mainText ?? "", overflow: TextOverflow.ellipsis),
      subtitle: Text(place.secondaryText ?? ""),
      onTap: () async {
        Map<String, dynamic> placeData = {};
        Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
        var res = await GoogleMapApiMethods.getPlaceDetails(place.placeId);
        if(res != null) {
          if(res["status"].toString().toUpperCase() == "OK") {
            placeData["address"] = res["result"]["name"];
            placeData["placeId"] = place.placeId;
            placeData["lat"] = res["result"]["geometry"]["location"]["lat"];
            placeData["lng"] = res["result"]["geometry"]["location"]["lng"];
            Get.back();
            Get.back(result: jsonEncode(placeData));
          }
        } else {
          Get.back();
        }
      },
    );
  }
}
