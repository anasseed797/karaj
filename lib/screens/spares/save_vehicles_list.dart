import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/controllers/sparesOrderingController.dart';
import 'package:karaj/models/spares.dart';
import 'package:karaj/screens/spares/shops_list_screen.dart';
import 'package:karaj/services/database.dart';

class SavedVehiclesSpares extends StatefulWidget {
  @override
  _SavedVehiclesSparesState createState() => _SavedVehiclesSparesState();
}

class _SavedVehiclesSparesState extends State<SavedVehiclesSpares> {

  SparesOrderingController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Database().getSavedVehicles(),
      builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Container();
            break;
          default:
            if(snapshot.hasError) {
              return Container();
            } else {
              List<DocumentSnapshot> list = snapshot.data;

              return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  primary: true,
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, index) {
                    Map<String, dynamic> vehicle = list[index].data();
                    return InkWell(
                      onTap: () {
                        SparesModel _o = controller.order;
                        _o.brand = vehicle["brand"];
                        _o.model = vehicle["model"];
                        _o.category = vehicle["category"];
                        _o.chassisNumber = vehicle["chassisNumber"];
                        controller.setOrder = _o;

                        Get.to(ShopsListScreen());
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 15.0),
                        decoration: BoxDecoration(
                            color: Get.theme.backgroundColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                              )
                            ]
                        ),
                        child: ListTile(
                          title: Text("${vehicle["brand"]} - ${vehicle["category"]} - ${vehicle["model"]} - ${vehicle["chassisNumber"]}"),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_forever, color: Get.theme.errorColor),
                            onPressed: () async {
                              await Database().deleteInsideDocument(colName: "users", colID: FirebaseAuth.instance.currentUser.uid, docName: "vehiclesSpares", docID: list[index].id);
                              setState(() {

                              });
                              },
                          ),
                        ),
                      ),
                    );
              });
            }
        }
    },
    );
  }
}
