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
import 'package:upaychat/Apis/network_utils.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/imagepicker.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/cupertino_date.dart';
import 'package:upaychat/CustomWidgets/custom_images.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Events/balanceevent.dart';
import 'package:upaychat/globals.dart';
import 'package:image_cropper/image_cropper.dart';

import '../Models/menu_item.dart';
class AccountManagementFile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AccountManagementFileState();
  }
}

class AccountManagementFileState extends State<AccountManagementFile>{

  List<MenuItem> menuList = [];
  @override
  void initState() {
    super.initState();
    menuList.add(MenuItem("Delete Account", "Find out how you can delete your Upaychat account.", 'deleteaccount'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        title: new Text(
          'Manage Account',
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
        child: _body(context),
      ),
    );
  }

  _body(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ListView.builder(itemCount: menuList.length, itemBuilder: (context, index){
        return InkWell(
          child: Container(
            child: Row(
              children: [
                Expanded(child: Column(
                  children: [
                    Container(child: Text(menuList[index].menuName, style: TextStyle(fontSize: 18, fontFamily: 'Doomsday'),),width: double.infinity,),
                    Container(child: Text(menuList[index].menuDescription, style: TextStyle(fontSize: 16, fontFamily: 'Doomsday', color: MyColors.grey_color),),width: double.infinity,),
                  ],
                )),
                Icon(Icons.arrow_forward_ios_rounded)
              ],
            ),
          ),
          onTap: (){
            Navigator.of(context).pushNamed('/${menuList[index].routeAction}');
          },
        );
      }),
    );
  }

}
