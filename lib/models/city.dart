class CityModel {
  String name;
  double lat;
  double lng;

  CityModel({this.name});

  factory CityModel.fromString(String city) => CityModel(
    name: city,
  );
}