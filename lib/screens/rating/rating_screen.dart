import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/models/user.dart';
import 'package:karaj/services/database.dart';

class RatingScreen extends StatefulWidget {

  final String type;
  final String type2;
  final UserModel user;
  final UserModel voter;
  final String userID;
  final String orderID;

  const RatingScreen({Key key, this.type, this.type2, this.user, this.voter, this.userID, this.orderID}) : super(key: key);

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {


  bool onLoading = true;
  UserModel user;


  int uVoters;
  double uAllStars;
  double uStars;
  int stars = 0;



  @override
  void initState() {
    _fetchAsyncData();
    super.initState();
  }

  Future<void> _fetchAsyncData() async {
    if(widget.user == null && widget.userID != null) {
      user = await Database().getUser(widget.userID);
      uStars = user.stars;
      uVoters = user.voters;
      uAllStars = user.allStars;
      setState(() {
        onLoading = false;
      });
    } else {
      user = widget.user;
      uStars = user.stars;
      uVoters = user.voters;
      uAllStars = user.allStars;

      setState(() {
        onLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return onLoading || user == null ? LoadingScreen(true) : Scaffold(
      appBar: appBar(title: ''),
      backgroundColor: Get.theme.backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child: Container(
          width: Get.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("rating${widget.type.toUpperCase()}".tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 31.0)),
              SizedBox(height: 15.0),
              circleAvatarNetwork(
                src: user.avatar,
                radius: 47
              ),
              SizedBox(height: 15.0),
              Text(widget.type == "shop" ? user.personalData["commercialName"] : user.firstName ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21.0)),
              Container(
                margin: EdgeInsets.only(bottom: 15.0, top: 15.0),
                child: Column(
                  children: [
                    StarDisplay(value: uStars.toInt()),
                    Text('($uVoters ${"reviews".tr})')
                  ],
                ),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("تقيمك :"),
                  StarDisplayVote(
                    onChanged: (s) {
                      setState(() {
                        uVoters = user.voters + 1;
                        uAllStars = user.allStars + s;
                        uStars = (user.allStars + s) / uVoters;
                        stars = s;
                      });
                    },
                    value: stars,
                  )
                ],
              ),
              SizedBox(height: 15.0),
              Container(
                width: 157.0,
                child: normalFlatButtonWidget(
                  context: context,
                  text: "btnRating".tr,
                  padding: EdgeInsets.symmetric(vertical: 7.0),
                  callFunction: () async {
                    setState(() {
                      onLoading = true;
                    });
                    Map<String, dynamic> data = {
                      "allStars": uAllStars,
                      "stars": uStars,
                      "voters": uVoters,
                    };
                    Map<String, dynamic> orderData = {};
                    if(widget.type2 == 'spares') {
                      orderData = {
                        "shopVoted": true,
                        "shopStar": stars,
                      };

                      if(widget.type == "user") {
                        orderData = {
                          "clientRated": true,
                          "clientStars": stars,
                        };
                      }
                    } else {
                      orderData = {
                        "rated": true,
                        "stars": stars,
                      };

                      if(widget.type == "user") {
                        orderData = {
                          "clientRated": true,
                          "clientStars": stars,
                        };
                      }
                    }

                    await Database().updateDocument(docID: widget.orderID, docName: widget.type2 == "order" ? "orders" : "spares", donTShowLoading: true, data: orderData);
                    await Database().updateDocument(docID: user.id, docName: "users", donTShowLoading: true, data: data);
                    Get.back(result: "voted");
                  }
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


}
