import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Apis/enter_refferal_code_api.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:share_plus/share_plus.dart';
import 'package:upaychat/Models/commonmodel.dart';

import '../CustomWidgets/my_colors.dart';
class ReferEarningsFile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ReferEarningsFileState();
  }
}

class ReferEarningsFileState  extends State<ReferEarningsFile>{
  TextEditingController refferCodeEditController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    String referrallCode = PreferencesManager.getString(StringMessage.username);
    referrallCode = base64.encode(utf8.encode(referrallCode));
    referrallCode = referrallCode.replaceAll("=", "");

    String referralText = "Join me on UpayChat. It's an app that you can use to send money, shop internationally, and we both earn ₦500 bonus! rewards\n\nhttps://upaychat.app.link\n\nUse ${referrallCode} as referral code.";
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: IconButton(
                icon: const Icon(size: 30, Icons.chevron_left),
                onPressed: () { Navigator.pop(context); },
              ),
            );
          },
        ),
        leadingWidth: 40,
        title: Row(
          children: const [
            Spacer(),
            Text(
              'Refer & Earn',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Spacer(),
            SizedBox(width: 40),
          ],
        ),
        backgroundColor: MyColors.base_green_color,
      ),
    body: Container(
      color: MyColors.base_green_color_20,
      height: double.infinity,
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              // color: MyColors.base_green_color,
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: MyColors.base_green_dark_color
              ),
              child: Column(
                children: [
                  Text("Invite a new user", style: TextStyle(color: Colors.white, fontSize: 16),),
                  SizedBox(height: 5,),
                  Text("Earn ${StringMessage.naira}500 each", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
                  SizedBox(height: 5,),
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.white
                    ),
                    child: Center(child:Text("Get ${StringMessage.naira}500", textAlign: TextAlign.center, style: TextStyle(color: MyColors.base_green_dark_color, fontSize: 16) )),
                  ),
                  SizedBox(height: 5,),
                  Text("*Your friends can get ${StringMessage.naira}500 bonus", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),

            SizedBox(height: 10,),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Icon(Icons.check_box, color: MyColors.base_green_dark_color,),
                  SizedBox(width: 5,),
                  Expanded(child: Text("Get ₦500 when your friend funds their UpayChat account with ₦1,000 or more", style: TextStyle(fontWeight: FontWeight.w400),))
                ],
              ),
            ),
            SizedBox(height: 10,),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text("How it works", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),))
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Container(width: 30, height: 30, decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(50)), color: MyColors.base_green_dark_color),child: Center(child: Text("1", style: TextStyle(color: Colors.white),),),),
                      SizedBox(width: 10,),
                      Text("Invite your friend", style: TextStyle( fontSize: 14),),
                    ],
                  ),
                  Container(margin: EdgeInsets.only(left: 15),height: 15, decoration: BoxDecoration(border: Border(left: BorderSide(color: MyColors.base_green_dark_color, width: 1))),),
                  Row(
                    children: [
                      Container(width: 30, height: 30, decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(50)), color: MyColors.base_green_dark_color),child: Center(child: Text("2", style: TextStyle(color: Colors.white),),),),
                      SizedBox(width: 10,),
                      Text("Friends accept invite", style: TextStyle( fontSize: 14),),
                    ],
                  ),
                  Container(margin: EdgeInsets.only(left: 15),height: 15, decoration: BoxDecoration(border: Border(left: BorderSide(color: MyColors.base_green_dark_color, width: 1))),),
                  Row(
                    children: [
                      Container(width: 30, height: 30, decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(50)), color: MyColors.base_green_dark_color),child: Center(child: Text("3", style: TextStyle(color: Colors.white),),),),
                      SizedBox(width: 10,),
                      Text("Friends add money", style: TextStyle( fontSize: 14),),
                    ],
                  )
                ],
              ),
            ),

            SizedBox(height: 5,),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  TextButton(onPressed: ()async{

                    await Share.share(referralText,
                        subject: "Upaychat Referral Text");
                  }, child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: MyColors.base_green_dark_color
                    ),
                    child: Row(
                      children: [
                        Expanded(child: SizedBox()),
                        Icon(Icons.add, color: Colors.white,),
                        Text('Invite friends', style: TextStyle(color: Colors.white),),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  )),
                  TextButton(onPressed: ()async{

                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        // <-- for border radius
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                      ),
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: Container(
                                height: 200,
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const Text('Please enter a referral code.', style: TextStyle(fontSize: 16),),
                                      SizedBox(height: 5,),
                                      Container(height: 40, child: TextField(
                                        controller: refferCodeEditController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                                        ),
                                      ),),
                                      Container(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          child: const Text('Enter'),
                                          style:ElevatedButton.styleFrom(
                                              backgroundColor: MyColors.base_green_dark_color
                                          ),
                                          onPressed: ()async{
                                            context.loaderOverlay.show();
                                            try{
                                              EnterRefferalCodeApi enterRefferApi = EnterRefferalCodeApi();
                                              CommonModel response = await enterRefferApi.enterCode(refferCodeEditController.text);
                                              refferCodeEditController.text = "";
                                              if(response.status == "true"){
                                                CommonUtils.successToast(context, response.message);
                                                context.loaderOverlay.hide();
                                                Navigator.pop(context);
                                              }
                                              else{
                                                CommonUtils.errorToast(context, response.message);
                                                context.loaderOverlay.hide();
                                              }
                                              Navigator.pop(context);

                                            }
                                            catch(e){
                                              CommonUtils.errorToast(context, e.toString());
                                              context.loaderOverlay.hide();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ));
                      },
                    );
                  }, child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                      border: Border.all(color: MyColors.base_green_dark_color)
                    ),
                    child: Row(
                      children: [
                        Expanded(child: SizedBox()),
                        Text('Enter Referral Code', style: TextStyle(color: MyColors.base_green_dark_color),),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    )
    );
  }
}