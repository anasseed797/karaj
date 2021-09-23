import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:karaj/models/user.dart';
import 'package:karaj/services/categories_data.dart';
import 'package:karaj/services/database.dart';
import 'package:karaj/ui_widgets/animations/fade_animation.dart';

class MyProfileScreen extends StatefulWidget {
  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {


  UserController _userController = Get.find();

  File imagePath;
  bool onLoading = true;
  UserModel _user;
  List _userBrands = [];
  bool hasBeenEdit = false;

  @override
  void initState() {
    _fetchUser();
    super.initState();
  }

  Future<void> _fetchUser() async {
    if(_userController.user != null) {
      _user = _userController.user;
    } else {
      _user = await Database().getUser(FirebaseAuth.instance.currentUser.uid);
    }
    _userBrands = _user.personalData["brands"];
    setState(() {
      onLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_userBrands);
    return Scaffold(
      appBar: appBar(title: "myProfile".tr),
      body: onLoading ? LoadingScreen(true) : Container(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              FadeAnimation(
                delay: 1,
                child: InkWell(
                  onTap: () async {
                    PickedFile x = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 70);
                    imagePath = File(x.path);
                    if (!mounted) return;
                    setState(() {
                      hasBeenEdit = true;
                    });
                  },
                  child: Column(
                    children: [
                      imagePath != null ?
                      ClipRRect(
                        borderRadius: BorderRadius.circular(57.0),
                        child: Container(
                          width: 114.0,
                          height: 114.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle
                          ),
                          child: Image.file(imagePath, width: 114.0, fit: BoxFit.cover,),
                        ),
                      )
                          : circleAvatarNetwork(
                          src: _user.avatar,
                          radius: 57.0
                      ),
                      Text('changeAvatar'.tr, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 35.0),
              FadeAnimation(
                delay: 1.1,
                child: ContainerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("personalInformation".tr, style: Get.textTheme.headline5),
                      _inputFiled(keyName: "firstName", value: _user.firstName),
                      _inputFiled(keyName: "fatherName", value: _user.personalData["fatherName"], displayIt: _user.isDriver == true),
                      _inputFiled(keyName: "lastName", value: _user.lastName),
                      _inputFiled(keyName: "fullAddress", value: _user.fullAddress),
                      SizedBox(height: 15.0),
                      _user.isShop == true && 1 != 1 ? Text("يمكنك تعديل :") : Container(),
                      _user.isShop == true && 1 != 1 ? Container(
                        height: 50,
                        width: Get.width,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: Brands.brands.length,
                            itemBuilder: (BuildContext context, index) {
                              String brand = Brands.brands.keys.elementAt(index);
                              bool selected = false;
                              if(_userBrands.contains(brand)) {
                                selected = true;
                              }
                              return InkWell(
                                onTap: () {
                                 if(selected) {
                                   _userBrands.remove(brand);
                                 } else {
                                   _userBrands.add(brand);
                                 }

                                 setState(() {
                                   hasBeenEdit = true;
                                 });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0),
                                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                                  decoration: BoxDecoration(
                                      color: selected ? Get.theme.primaryColor : Get.theme.scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Center(child: Text(brand ?? '', style: TextStyle(color: !selected ? Colors.black : Colors.white))),
                                ),
                              );
                            }
                        ),
                      ) : SizedBox.shrink(),
                      SizedBox(height: 15.0),
                      hasBeenEdit ? Container(
                        width: Get.width,
                        child: normalFlatButtonWidget(
                          context: context,
                          text: 'btnSaveInfo'.tr,
                          padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                          radius: 5.0,
                          callFunction: () async {
                            setState(() {
                              onLoading = true;
                            });

                            if(imagePath != null) {
                              var imageChild = _user.id;
                              FirebaseStorage _storage = FirebaseStorage.instance;
                              Reference rf = _storage.ref().child('avatars').child(imageChild);
                              UploadTask uploadTask = rf.putFile(imagePath);
                              TaskSnapshot taskSnapshot = await uploadTask;
                              String imageUrl = await taskSnapshot.ref.getDownloadURL();
                              _user.avatar = imageUrl;
                            }
                            _user.personalData["brands"] = _userBrands;
                            _userController.setUser = _user;
                            setState(() {
                              hasBeenEdit = false;
                              onLoading = false;
                            });
                          },
                        ),
                      ) : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 35.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputFiled({String keyName, String value, bool displayIt = true}) {
    return !displayIt ? SizedBox.shrink() : Container(
      margin: EdgeInsets.only(top: 15.0),
      child: TextFormField(
        initialValue: value,
        decoration: inputDecorationUi(context, 'keyName'.tr, color: Get.theme.scaffoldBackgroundColor),
        keyboardType: TextInputType.text,
        enabled: false,
      ),
    );
  }
}
