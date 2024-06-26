import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventhandler/eventhandler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Apis/delete_account_request_api.dart';
import 'package:upaychat/Apis/network_utils.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/imagepicker.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/cupertino_date.dart';
import 'package:upaychat/CustomWidgets/custom_images.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Events/balanceevent.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/globals.dart';
import 'package:image_cropper/image_cropper.dart';
class DeleteAccountFile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DeleteAccountFileState();
  }
}

class DeleteAccountFileState extends State<DeleteAccountFile>{

  TextEditingController passwordController = TextEditingController();
  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        title: new Text(
          'Delete Account',
          style: TextStyle(
            fontFamily: 'Doomsday',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Container(
        color: MyColors.base_green_color_20,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(20),
        child: _body(context),
      ),
    );
  }

  _body(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child:  Text('Before you request to delete your account consider contacting our support team via support@upaychat.com', style: TextStyle(fontSize: 18, fontFamily: 'Doomsday', color: MyColors.grey_color),),
          ),
          SizedBox(height: 15,),
          Container(
            width: double.infinity,
            child:  Text('To confirm account deletion, enter your password below:', style: TextStyle(fontSize: 18, fontFamily: 'Doomsday', color: MyColors.grey_color),),
          ),
          SizedBox(height: 5,),
          Container(
            color: Colors.white,
            child: TextField(
              obscureText: true,
              controller: passwordController,
              style: TextStyle(
                fontFamily: 'Doomsday',
                fontSize: 18,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: MyColors.base_green_color, width: 2.0)),
                hintText: 'Enter Password',
              ),
            ),
          ),
          SizedBox(height: 15,),
          Container(
            height: 50,
            // color: MyColors.base_green_color,
            width: double.infinity,
            child: TextButton(
              onPressed: () async{
                DeleteAccountRequestApi reqApi = DeleteAccountRequestApi();
                context.loaderOverlay.show();
                try{
                  CommonModel apiResponse = await reqApi.sendRequest(passwordController.text);
                  if(apiResponse.status == "true"){
                    context.loaderOverlay.hide();
                    CommonUtils.successToast(context, apiResponse.message);
                    PreferencesManager.setString('loginID', '');
                    CommonUtils.logout(context);
                  }
                  else{
                    context.loaderOverlay.hide();
                    CommonUtils.errorToast(context, apiResponse.message);
                  }
                }
                catch(e){
                  context.loaderOverlay.hide();
                  CommonUtils.errorToast(context, e.toString());
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    MyColors.base_green_color),
              ),
              child: Text(
                'Delete Password',
                style: TextStyle(
                  fontFamily: 'Doomsday',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
