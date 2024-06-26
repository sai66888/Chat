import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CustomWidgets/custom_images.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Models/mytransactionmodel.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../CommonUtils/preferences_manager.dart';
import '../CommonUtils/string_files.dart';
class TransactionDetailForElectricity extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TransactionDetailForElectricityState();
  }
}

class TransactionDetailForElectricityState extends State<TransactionDetailForElectricity> {
  MyTransactionData? data;
  final _globalKey = GlobalKey();
  @override
  void initState() {
    super.initState();
   }
  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context)!.settings.arguments as MyTransactionData?;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        title: new Text(
          'Transaction Receipt',
          style: TextStyle(
            fontFamily: 'Doomsday',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: _captureImage,
          backgroundColor: MyColors.base_green_color,
          child: Icon(
            Icons.download,
          ),
        ),
      ),
      body: RepaintBoundary(
        key: _globalKey,
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Container(
                height: 150,
                width: MediaQuery.of(context).size.width,
                color: MyColors.base_green_color,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 35,),
                    Icon(Icons.check_circle, color: Colors.white,size: 40,),
                    SizedBox(height: 20,),
                    Text("Thanks for using Upaychat!", style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Doomsday',
                        color: Colors.white
                    )),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: SizedBox()),
                        Image.asset("assets/logo_white.png", width: 12,),
                        SizedBox(width: 5,),
                        Text("Upaychat", style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Doomsday',
                            color: Colors.white
                        )),
                        Expanded(child: SizedBox()),
                      ],
                    ),

                  ],

                ),

              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("TOKEN", style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Doomsday',
                        color: Colors.grey
                    )),
                    Text(CommonUtils.tokenFormat(data!.tran.token), style: TextStyle(
                      fontSize: 34,
                      fontFamily: 'Doomsday',
                      color: Colors.grey,

                    ), textAlign: TextAlign.center,),
                    SizedBox(height:20),
                    Row(
                      children: [
                        Text("Amount", style: TextStyle(
                            fontSize: 18,
                            // fontFamily: 'Doomsday',
                            color: Colors.black
                        )),
                        Expanded(child: SizedBox()),
                        Text(double.parse(data!.tran.amount.toString() ?? '').toStringAsFixed(2), style: TextStyle(
                            fontSize: 18,
                            // fontFamily: 'Doomsday',
                            color: Colors.black
                        )),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      children: [
                        Text("Date & Time", style: TextStyle(
                            fontSize: 18,
                            // fontFamily: 'Doomsday',
                            color: Colors.black
                        )),
                        Expanded(child: SizedBox()),
                        Text(data!.tran.created_at, style: TextStyle(
                            fontSize: 18,
                            // fontFamily: 'Doomsday',
                            color: Colors.black
                        )),
                      ],
                    ),
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 1.0, color: Colors.grey),
                          )
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Text("Transaction Type", style: TextStyle(
                            fontSize: 18,
                            // fontFamily: 'Doomsday',
                            color: Colors.black
                        )),
                        Expanded(child: SizedBox()),
                        Text("Electricity", style: TextStyle(
                            fontSize: 18,
                            // fontFamily: 'Doomsday',
                            color: Colors.black
                        )),
                      ],
                    ),
                    Container(
                      height: 15,
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 1.0, color: Colors.grey),
                          )
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Text("Reference", style: TextStyle(
                            fontSize: 18,
                            // fontFamily: 'Doomsday',
                            color: Colors.black
                        )),
                        Expanded(child: SizedBox()),
                        Text(data!.tran.touser_id, style: TextStyle(
                            fontSize: 18,
                            color: Colors.black
                        )),

                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Text("Name", style: TextStyle(
                            fontSize: 18,
                            // fontFamily: 'Doomsday',
                            color: Colors.black
                        )),
                        Expanded(child: SizedBox()),
                        Text(PreferencesManager.getString(StringMessage.username), style: TextStyle(
                            fontSize: 18,
                            // fontFamily: 'Doomsday',
                            color: Colors.black
                        )),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<PermissionStatus> getPermission() async {
    final PermissionStatus permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      final Map<Permission, PermissionStatus> permissionStatus =
      await [Permission.storage].request();
      return permissionStatus[Permission.storage] ??
          PermissionStatus.restricted;
    } else {
      return permission;
    }
  }
  bool isCapture = false;
  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
      SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
  _captureImage() async {
    final PermissionStatus permissionStatus = await getPermission();
    if (permissionStatus != PermissionStatus.granted) {
      _handleInvalidPermissions(permissionStatus);
      return;
    }
    context.loaderOverlay.show();
    setState(() {
      isCapture = true;
    });
    Future.delayed(Duration(milliseconds: 100), () async {
      try {
        var exported = await saveImage();
        if (exported) {
          CommonUtils.successToast(
              context, "Successfully Saved to your photos");
        } else {
          CommonUtils.successToast(
              context, "Can't save image, Please try again later");
        }
      } catch (e) {
        print(e);
        CommonUtils.successToast(context, "Export image error");
      }
      context.loaderOverlay.hide();
      setState(() {
        isCapture = false;
      });
    });
  }

  saveImage() async {
    final RenderRepaintBoundary boundary =
    _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    var directory = await getApplicationDocumentsDirectory();
    var exportPath =
        '${directory.path}/UpayChat-transaction#${data!.tran.id.toString()}.png';
    final file = File(exportPath);
    await file.writeAsBytes(pngBytes);
    var respath = await GallerySaver.saveImage(exportPath);
    return respath;
  }
}