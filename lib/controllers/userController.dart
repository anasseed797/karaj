import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/models/user.dart';
import 'package:karaj/services/PushNotificationService.dart';
import 'package:karaj/services/database.dart';

class UserController extends GetxController {
  Rx<UserModel> _userModel = UserModel().obs;
  UserModel get user => _userModel.value;
  final _firestore = FirebaseFirestore.instance;

  set setUser(UserModel value) {
    print("================================== UserController set user data");
    this._userModel.value = value;
    updateUser(_userModel.value.toMap());
    update();
  }

  @override
  void onInit() {
    print("================================== Start binding UserController");
    getUserData(isOnInit: true);
    streamingUserData();
    super.onInit();
  }

  void streamingUserData() {
    print("================================== Start streaming user Data");

    if(FirebaseAuth.instance.currentUser != null && _userModel.value.id == FirebaseAuth.instance.currentUser?.uid) {
      _userModel.bindStream(Database().streamGetUser());
      print("================================== bindStream user Data has been started");
    }
  }

  void clear() {
    _userModel.value = UserModel();
  }



  Future<void> updateUser(Map<String, dynamic> updateData) async {
    if(_userModel.value != null) {
      Database().updateDocument(docID: _userModel.value.id, docName: "users", data: updateData, donTShowLoading: true);
    }
  }

  Future<void> getUserData({bool isOnInit = false}) async {
    if(FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser?.uid != null) {
      print("================================== Start getting UserData from userController");
      UserModel _user = await Database().getUser(FirebaseAuth.instance.currentUser.uid);
      if(isOnInit && _user.isDriver && !_user.isOnRide && !_user.isOnline) {
        this.setDriverOnline(true);
      } else {
        _userModel.value = _user;
      }
      streamingUserData();

    }
  }

  Future<void> setDriverOnline(bool val) async {
    print("================================== setDriverOnline()");


    if(val == true) {
      print("================================== setDriverOnline() => await Helpers.checkLocationPermission");
      if(await Helpers.checkLocationPermission()) {
        print("================================== setDriverOnline() => await Helpers.checkLocationPermission CHECKED TRUE");
        _userModel.value.isOnline = true;
        this.setUser = _userModel.value;
        final geo = Geoflutterfire();
        Position p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        GeoFirePoint myLocation = geo.point(latitude: p.latitude, longitude: p.longitude);
        bool vanCar = false;
        bool pickupCar = false;
        List vehicles = _userModel.value.personalData != null ? _userModel.value.personalData['vehicles'] ?? [] : [];
        if(vehicles.contains("van".tr)) {
          vanCar = true;
        }
        if(vehicles.contains("pickup".tr))  {
          pickupCar = true;
        }
        _firestore.collection('availableDrivers').doc(_userModel.value.id).set({'name': _userModel.value.firstName, 'uid': _userModel.value.id, 'vanCar': vanCar, 'pickupCar': pickupCar, 'token': _userModel.value.token, 'position': myLocation.data});
      } else {
        print("================================== setDriverOnline() => await Helpers.checkLocationPermission UNCHECKED FALSE");
        deleteAvailableDriver();
      }
    } else {
      deleteAvailableDriver();
    }
  }

  Future<void> deleteAvailableDriver() async {
    _userModel.value.isOnline = false;
    this.setUser = _userModel.value;
    _firestore.collection('availableDrivers').doc(_userModel.value.id).delete();
  }


  Future<void> submitOrder(OrderModel order) async {
    // Create a geoFirePoint
    await Database().updateDocument(docName: "users", docID: order.userId, data: {"isOnRide": true, "onOrderID": order.id});
    final geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: order.fromLat, longitude: order.fromLng);
    var collectionReference = _firestore.collection('availableDrivers');
    print("========================================================== collectionReference");
    double radius = 50;
    String field = 'position';
    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: radius, field: field);
    bool stopStreaming = false;
    List<String> tokensSended = [];
    stream.listen((List<DocumentSnapshot> documentList) {
      print("========================================================== streaming");
      print(stopStreaming);
      print(tokensSended);
      if(!stopStreaming) {
        documentList.forEach((element) {
          print("===========================================");
          if(!tokensSended.contains(element.data()['token'] ?? '')) {
            if (order.vehicleType == 1 && element["vanCar"] == false) {
            } else
            if (order.vehicleType == 2 && element["pickupCar"] == false) {
            } else {
              print("========================================================== started sending notification");

              PushNotificationService().sendNotification(
                  type: 'newOrder',
                  orderID: order.id,
                  title: 'طلب جديد',
                  body: 'هناك طلب جديد بالقرب منك.',
                  token: element.data()['token'] ?? ''
              );
            }
          }
          tokensSended.add(element.data()['token'] ?? '');
          if(tokensSended.length == documentList.length) {
            stopStreaming = true;
          }
        });
        print("===========================================");
      }



    });

  }
}
