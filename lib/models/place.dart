import 'dart:convert';

PlaceModel placeModelFromMap(String str) => PlaceModel.fromMap(json.decode(str));

String placeModelToMap(PlaceModel data) => json.encode(data.toMap());

class PlaceModel {
  PlaceModel({
    this.secondaryText,
    this.mainText,
    this.placeId,
  });

  String secondaryText;
  String mainText;
  String placeId;

  factory PlaceModel.fromMap(Map<String, dynamic> json) => PlaceModel(
    secondaryText: json["structured_formatting"]["secondary_text"] ?? "",
    mainText: json["structured_formatting"]["main_text"] ?? "",
    placeId: json["place_id"] ?? "",
  );

  Map<String, dynamic> toMap() => {
    "secondary_text": secondaryText,
    "main_text": mainText,
    "place_id": placeId,
  };
}
