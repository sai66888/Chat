import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/extension.dart';
import 'package:geocoding/geocoding.dart';
import 'package:upaychat/Apis/locationapi.dart';
import 'package:upaychat/Apis/poscashrequestapi.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/Models/locationmodel.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:upaychat/globals.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:math';
import 'package:upaychat/Models/requestmodel.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;


import 'package:flutter/services.dart';
import 'package:image/image.dart' as IMG;
import 'package:custom_marker/marker_icon.dart';

import 'Chat/ChatUserModel.dart';
import 'Chat/RequestChatScreen.dart';
import 'home_file.dart';

final _databaseRef = FirebaseDatabase.instance.ref("pos_cash_request");
class PosCashRequest extends StatefulWidget {
  String? posId = "";
  String? state = "";
  String? frId = "";
  bool? fromNotification  = false;
  bool isAccepted = false;
  PosCashRequest({super.key, required this.posId, this.fromNotification = false, this.isAccepted = false});

  @override
  State<StatefulWidget> createState() {
    return PosCashRequestState();
  }
}


// Starting point latitude
// PreferencesManager.setDouble(StringMessage.myCurrentLatitude, position.latitude);
double _originLatitude = PreferencesManager.getDouble(StringMessage.myCurrentLatitude);
double _originLongitude = PreferencesManager.getDouble(StringMessage.myCurrentLongitude);
// Starting point longitude
Map<MarkerId, Marker> markers = {};

PolylinePoints polylinePoints = PolylinePoints();
Map<PolylineId, Polyline> polylines = {};
double zoomValue = 14.0;


class PosCashRequestState extends State<PosCashRequest> with TickerProviderStateMixin{
  // ==================== My Info ========================================
  late final String myAvatar;
  late final String myFullname;
  late final double myLatitude;
  late final double myLongitude;
  late final String myAddress;
  // ---------------------------------------------------------------------

  // ==================== GOOGLE MAP =====================================
  Set<Marker> _markers = <Marker>{};
  final Completer<GoogleMapController> _controller = Completer();
  // Configure map position and zoom
  // _controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(carLat, carLon), 14));
  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(_originLatitude, _originLongitude),
    zoom: zoomValue,
  );
  bool isAcceptable = false;

  bool isConfirmable = false;
  String googleAPiKey = "AIzaSyCT68yhS_gvlHzW9VdqIg4mKsPNPVITgz4";
  late AnimationController progressBarAnimationController;
  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      width: 8,
      color: Colors.blueGrey
    );
    polylines[id] = polyline;
  }
  // -------------------- GOOGLE MAP ------------------------------------

  late String state = '';
  late String myImage = '';
  late BitmapDescriptor icon;
  late String myId;
  bool screenIsActive = false;

  PosCashRequestApi posCashRequestApi = PosCashRequestApi();
  List<RequestData> requestDataList = [];

  final PanelController _pc = PanelController();
  StreamSubscription<DatabaseEvent>? _requestStateSubscription;
  /* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
  void _getPosRequestData(posId) async {
    RequestModel result = await posCashRequestApi.getPosRequestData(posId);
    print("Check POS ID:${posId}");
    if(result.requestData != null && result.requestData?.isNotEmpty == true) {
      print("Is Delivery: ${result.requestData?[0].delivery}");
      setState(() {
        requestDataList = result.requestData ?? [];
        if(requestDataList.length > 0){
          state = requestDataList[0].state;
          isConfirmable = result.requestData?[0].delivery == "delivery";
        }
      });
      result.requestData?.map((res) async {
        // ================ google map icon & polyline =================

        if(myAvatar.isNotNullAndNotEmpty){
          _markers.add(
            Marker(
              markerId: MarkerId(myId),
              icon: await MarkerIcon.downloadResizePictureCircle(
                  myAvatar,
                  size: 150,
                  addBorder: true,
                  borderColor: MyColors.base_green_color,
                  borderSize: 15),
              position: LatLng(myLatitude, myLongitude),
            ),
          );
        }
        else{
          _markers.add(
            Marker(
              markerId: MarkerId(myId),
              icon: await MarkerIcon.circleCanvasWithText(size:const Size(150.0,150.0),text: CommonUtils.extractInitials(myAvatar),
                  fontColor: Colors.white,
                  circleColor: MyColors.base_green_color,
                  fontSize: 75),
              position: LatLng(myLatitude, myLongitude),
            ),
          );
        }


        setState(()  {
        });
        if(res.frAvatar.isNotNullAndNotEmpty){
          _markers.add(
            Marker(
              markerId: MarkerId('${res.frLatitude} + ${res.frLongitude}'),
              icon: await MarkerIcon.downloadResizePictureCircle(
                  res.frAvatar,
                  size: 120,
                  addBorder: true,
                  borderColor: Colors.grey,
                  borderSize: 15),
              position: LatLng(double.parse(res.frLatitude), double.parse(res.frLongitude)),
            ),
          );
        }
        else{
          _markers.add(
            Marker(
              markerId: MarkerId('${res.frLatitude} + ${res.frLongitude}'),
              icon: await MarkerIcon.circleCanvasWithText(size:const Size(150.0,150.0),text: CommonUtils.extractInitials(res.frUsername),
                  fontColor: Colors.white,
                  circleColor: MyColors.base_green_color,
                  fontSize: 75),
              position: LatLng(myLatitude, myLongitude),
            ),
          );
        }

        List<LatLng> polylineCoordinates = [];

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          "AIzaSyDM6KllO-RjTQyp_u4DhZ933R29t4b5Azw",
          PointLatLng(myLatitude, myLongitude),
          PointLatLng(double.parse(res.frLatitude), double.parse(res.frLongitude)),
          travelMode: TravelMode.driving,
        );

        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        } else {
          print(result.errorMessage);
        }

        _addPolyLine(polylineCoordinates);
      });
      setState(() {
        isAcceptable = true;
      });

      double calculateDistance(lat1, lon1, lat2, lon2){
        var p = 0.017453292519943295;
        var a = 0.5 - cos((lat2 - lat1) * p)/2 +
            cos(lat1 * p) * cos(lat2 * p) *
                (1 - cos((lon2 - lon1) * p))/2;
        return 12742 * asin(sqrt(a));
      }



      print("IsReceive:${requestDataList[0].receive}" );
      if(requestDataList[0].state == 'cancel'){
        PreferencesManager.setString(StringMessage.active_request, "");
        Globals.incoming_request =false;
        CommonUtils.errorToast(context, "This request has been canceled");
        goBack();
        return;


      }

      else if (requestDataList[0].state == "reject"){
        PreferencesManager.setString(StringMessage.active_request, "");
        Globals.incoming_request = false;
        CommonUtils.errorToast(context, "This request has been rejected");
        goBack();
        return;
      }
      else if (requestDataList[0].receive != null && requestDataList[0].receive != "null"){
        PreferencesManager.setString(StringMessage.active_request, "");
        Globals.incoming_request = false;
        CommonUtils.errorToast(context, "This request is no longer active.");
        goBack();
        return;
      }

      Timer(const Duration(seconds: 1), () {
        print("State: ${state}");
        if(state == "request"){
          print(requestDataList[0].elapsedTime);
          int timeDiffSeconds = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(int.parse(requestDataList[0].createdAt.toString()) * 1000, isUtc: true).toLocal()).inSeconds;
          print("TimeDiff: ${requestDataList[0].elapsedTime}");
          if(int.parse(requestDataList[0].elapsedTime) >= 90){
            CommonUtils.errorToast(context, "This request has been expired");
            goBack();
            return;
          }
          else{
            progressBarAnimationController.forward(from: (int.parse(requestDataList[0].elapsedTime)).toDouble() / 90);
            _pc.open();

          }

        }

        _requestStateSubscription = _databaseRef.child(widget.posId!).child("state").onValue.listen((event) {
          String newPosStatus = event.snapshot.value.toString();
          print("Status: ${newPosStatus} -- from firebase");
          print("CheckPoint: 0003");
          if(newPosStatus == "cancel" ||  newPosStatus  == "canceled"){
            _requestStateSubscription?.cancel();
            CommonUtils.errorToast(context, "This request has been canceled");

            PreferencesManager.setString(StringMessage.active_request, "");
            Globals.incoming_request = false;
            goBack();
          }
          else if (newPosStatus == "rejected"){
            _requestStateSubscription?.cancel();
            CommonUtils.errorToast(context, "This request has been rejected");
            PreferencesManager.setString(StringMessage.active_request, "");
            Globals.incoming_request = false;
            goBack();
          }
          else if (newPosStatus == "deliveried"){
            setState(() {
              isConfirmable = true;
            });
          }
          else if (newPosStatus == "completed"){
            CommonUtils.successToast(context, "This request has been completed");
            PreferencesManager.setString(StringMessage.active_request, "");
            Globals.incoming_request = false;
            goBack();
          }

        });
      });

    }
    else{
      PreferencesManager.setString(StringMessage.active_request, "");
      Globals.incoming_request = false;
      CommonUtils.errorToast(context, "This request is no longer active.");
      goBack();
      return;
    }
  }
  /* ------------------------------------------------------------------------ */

  @override
  void initState() {
    print("___________________________________");
    print("${widget.fromNotification}");
    print("___________________________________");
    screenIsActive = true;
    Globals.incoming_request =true ;
    myAvatar = PreferencesManager.getString(StringMessage.profileimage);
    myFullname = PreferencesManager.getString(StringMessage.username);
    myLatitude = PreferencesManager.getDouble(StringMessage.myCurrentLatitude);
    myLongitude = PreferencesManager.getDouble(StringMessage.myCurrentLongitude);
    myAddress = PreferencesManager.getString(StringMessage.myAddress);

    myId = PreferencesManager.getInt(StringMessage.id).toString();
    state = widget.state!;

    myImage = PreferencesManager.getString(StringMessage.profileimage);

    progressBarAnimationController = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 90),

    )..addListener(() {
      setState(() {

      });
    })..addStatusListener((status) {
      if(status.name == "completed"){
        goBack();
      }
    });
    progressBarAnimationController.repeat(reverse: false);
    progressBarAnimationController.stop();
    _getPosRequestData(widget.posId);
    super.initState();
  }
  goBack() async{
    _requestStateSubscription?.cancel();
    screenIsActive = false;
    if (widget.fromNotification == false) {
      print("Checkpoint: 011");
      if (Navigator.canPop(context)) {
        print('Navigator canPop is true: ${mounted}');
        if(mounted)
          Navigator.pop(context);
      } else {
        SystemNavigator.pop();
      }
    }
    else{
      print("Checkpoint: 012");
      // Navigator.pushReplacementNamed(context, '/home');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => HomeFile()), (route) => false);
    }
  }
  _posResponse(posId, state) async{
    return await posCashRequestApi.posResponse(posId, state);
  }
  _posResponseSuccess(posId, state) async{
    await posCashRequestApi.posResponseSuccess(posId, state);
  }

  _distance(String distance) {
    List<String> splitted = distance.split('.');
    int ddd = int.parse(splitted[0]);
    if(ddd < 1000) {
      return '${ddd}m from you.';
    } else {
      double dd = ddd / 100;
      int dddd = dd.toInt();
      return '${dddd/10}km from you';
    }
  }

  _showAcceptedRequestsModal() {
    if(requestDataList[0].frId == myId.toString() && requestDataList[0].state == 'accept') {
      // ============== A confirm money =============
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 17, right: 17, bottom: 6),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Your cash is on the way',
                    style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 3),),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: Image.network(
                          requestDataList[0].frAvatar,
                          width: 60,
                          height: 60,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.only(left: 15),
                          child: isConfirmable ? RichText(
                            text: TextSpan(
                                text: requestDataList[0].frUsername,
                                style: const TextStyle(
                                    fontFamily: 'Doomsday',
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                                children: const <TextSpan>[
                                  TextSpan(
                                    text:
                                    ' indicated that he gave you got the cash. Do you confirm this?',
                                    style: TextStyle(
                                        fontFamily: 'Doomsday',
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14),)]),) :  RichText(
                            text: TextSpan(
                                text: requestDataList[0].frUsername,
                                style: const TextStyle(
                                    fontFamily: 'Doomsday',
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                                children: const <TextSpan>[
                                  TextSpan(
                                    text:
                                    ' is on the way to you.',
                                    style: TextStyle(
                                        fontFamily: 'Doomsday',
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14),)]),)
                          ,),)],),
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 5),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.base_green_color,
                            elevation: 0.0,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          onPressed: () async{
                            context.loaderOverlay.show();
                            try{
                              await _posResponseSuccess(requestDataList[0].posId, 'receive');
                              context.loaderOverlay.hide();
                            }
                            catch(e){
                              if(screenIsActive)
                                context.loaderOverlay.hide();
                            }

                          } ,
                          child: const Text(
                            'I got the cash',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Ubuntu'),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: const EdgeInsets.only(top: 10, bottom: 5),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0.0,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          onPressed: () async {
                            if(isConfirmable){
                              Navigator.of(context).pushNamed("/contactus");
                            }
                            else{
                              context.loaderOverlay.show();
                              try{
                                await _posResponseSuccess(requestDataList[0].posId, 'noreceive');
                                context.loaderOverlay.hide();

                                Timer(const Duration(seconds: 1), () {
                                  goBack();
                                });
                              }
                              catch(e){
                                context.loaderOverlay.hide();

                                CommonUtils.errorToast(context, e.toString());
                              }

                            }

                          },
                          child: Text(
                            isConfirmable ? "Help" : "Cancel",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontFamily: 'Ubuntu'),),),),],),
                  Row(
                    children: [
                      Expanded(child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0.0,
                          ),
                          onPressed: () {
                            _openChat();
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.chat,
                                color: Colors.black87,
                              ),
                              Expanded(child: Container(
                                margin: const EdgeInsets.only(left: 10, right: 10),
                                child: const Text(
                                  'Chat',
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontFamily: 'Doomsday'),),)),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.black87,)],),),)),

                      const SizedBox(width: 20),

                      Expanded(child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0.0,),
                          onPressed: requestDataList[0].mobile == "" ? null : () async {
                            late String url = "tel:${requestDataList[0].mobile}";
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw "Error occured trying to call that number.";
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.call,
                                color: Colors.black87,),
                              Expanded(child: Container(
                                margin: const EdgeInsets.only(left: 12, right: 10),
                                child: const Text(
                                  'Call',
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontFamily: 'Doomsday'),),)),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.black87,)],),),)),],)],),),
            const Divider(
              color: Colors.grey, //color of divider
              height: 1, //height spacing of divider
              thickness: 0, //thickness of divier line
            ),
            Container(
              padding: const EdgeInsets.only(left: 17, right: 17, top: 3, bottom: 20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: const [
                      Text(
                        "Your address",
                        style: TextStyle(
                            fontFamily: 'Doomsday',
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1),
                        textAlign: TextAlign.start,)],),
                  Row(children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.only(right: 13.0),
                        child: Text(
                          myAddress,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 2,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontSize: 15,
                              fontFamily: 'Doomsday',
                              color: Colors.black87,
                              height: 1.6 ),),),) ],),
                  Row(
                    children: const [
                      Text(
                        'Amount',
                        style: TextStyle(
                            fontFamily: 'Doomsday',
                            fontSize: 14,
                            color: Colors.grey,
                            height: 2),
                        textAlign: TextAlign.start,)],),
                  Row(
                    children: [
                      Text(
                        StringMessage.naira + requestDataList[0].amount,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.start, )],),],),),],));
    } else {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 17, right: 17, bottom: 6),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Cash Request',
                    style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 3 // fix
                    ),
                  ),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(80.0),
                        child: Image.network(
                          requestDataList[0].frAvatar,
                          width: 60,
                          height: 60,
                        ),
                      ),
                      Flexible(
                        child: Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      requestDataList[0].frUsername,
                                      maxLines: 2,
                                      softWrap: true,
                                      overflow: TextOverflow.clip,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          height: 1.5), ), ], ),
                                Row(children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.only(right: 13.0),
                                      child: Text(
                                        '${requestDataList[0].frAddress}',
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        maxLines: 2,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'Doomsday',
                                            color: Colors.black87,
                                            height: 1.6 ),),),) ],),
                                Row(
                                  children: [
                                    Text(
                                      '${_distance(requestDataList[0].distance)}',
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.clip,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          height: 1.2),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: isConfirmable ? Container(
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.yellow,),
                          SizedBox(width: 10,),
                          Expanded(child: const Text("You will need to ask the client to confirm delivery and get funded before you leave."))
                        ],
                      )
                    ) : Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.red),
                              borderRadius: BorderRadius.circular(5)),
                          child: TextButton(
                            onPressed: () async{
                              context.loaderOverlay.show();
                              try{
                                await _posResponse(requestDataList[0].posId, 'cancel');
                                context.loaderOverlay.hide();
                              }
                              catch(e){

                                context.loaderOverlay.hide();
                                CommonUtils.errorToast(context, e.toString());
                              }
                              },
                            style: TextButton.styleFrom(
                              fixedSize: const Size(170, 48),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Doomsday',
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async{
                            context.loaderOverlay.show();
                            try{
                              await _posResponseSuccess(requestDataList[0].posId, 'delivery');
                              context.loaderOverlay.hide();
                              print("End api request for the delivery status: ${screenIsActive}");
                              print("CheckPoint: 0001");
                              // Timer(const Duration(seconds: 1), () {
                              //   goBack();
                              // });
                            }
                            catch(e){
                              context.loaderOverlay.hide();
                              CommonUtils.errorToast(context, e.toString());
                            }
                          },

                          style: TextButton.styleFrom(
                            fixedSize: const Size(170, 50),
                            backgroundColor: MyColors.base_green_color,
                          ),
                          child: const Text(
                            'Delivered',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Doomsday',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  isConfirmable ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: const EdgeInsets.only(top: 10, bottom: 5),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0.0,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () async {
                          Navigator.of(context).pushNamed("/contactus");
                      },
                      child: Text(
                        "Help",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontFamily: 'Ubuntu'),),),): SizedBox(),
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0.0,
                            ),
                            onPressed: () {
                              // _showNewRequestModal();
                              _openChat();
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.chat,
                                  color: Colors.black87,
                                ),
                                Container(
                                  margin:
                                  const EdgeInsets.only(left: 10, right: 42),
                                  child: const Text(
                                    'Chat',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontFamily: 'Doomsday'),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.black87,
                                )
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0.0,
                            ),
                            onPressed: requestDataList[0].mobile == "" ? null : () async {
                              late String url = "tel:${requestDataList[0].mobile}";
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw "Error occured trying to call that number.";
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.call,
                                  color: Colors.black87,
                                ),
                                Container(
                                  margin:
                                  const EdgeInsets.only(left: 12, right: 45),
                                  child: const Text(
                                    'Call',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontFamily: 'Doomsday'),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.black87,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                ],
              ),
            ),
            const Divider(
              color: Colors.grey, //color of divider
              height: 1, //height spacing of divider
              thickness: 0, //thickness of divier line
            ),
            Container(
              padding:
              const EdgeInsets.only(left: 17, right: 17, top: 3, bottom: 20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: const [
                      Text(
                        'Amount',
                        style: TextStyle(
                            fontFamily: 'Doomsday',
                            fontSize: 14,
                            color: Colors.grey,
                            height: 2),
                        textAlign: TextAlign.start,
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        StringMessage.naira + requestDataList[0].amount,
                        style: const TextStyle(
                          color: Colors.black87 ,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.start,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _showNewRequestModal() {
    return SafeArea(
      child: Wrap(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 17, right: 17),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Cash Delivery Request',
                  style: TextStyle(
                      fontFamily: 'Doomsday',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 3 // fix
                  ),
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(80.0),
                      child: Image.network(
                        requestDataList[0].frAvatar,
                        width: 60,
                        height: 60,
                      ),
                    ),
                    Flexible(
                      child: Container(
                          margin: const EdgeInsets.only(left: 15),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    requestDataList[0].frUsername,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.clip,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 1.5),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Flexible(child: Text(
                                    requestDataList[0].frAddress,
                                    maxLines: 2,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15, height: 1.3,
                                      fontFamily: 'Doomsday',
                                    ),
                                  )),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    _distance(requestDataList[0].distance),
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.clip,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      height: 1.5,
                                      fontFamily: 'Doomsday',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ),
                  ],
                ),




                LinearProgressIndicator(
                  value: progressBarAnimationController.value,
                  semanticsLabel: '',
                  color: MyColors.base_green_color,
                  backgroundColor: MyColors.base_green_color_20,

                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Row(
                    children: [
                      Expanded(child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.red),
                            borderRadius: BorderRadius.circular(5)),
                        child: TextButton(
                          onPressed: () async{
                            print("Reject");
                            progressBarAnimationController.stop();
                            try{
                              context.loaderOverlay.show();
                              await _posResponse(requestDataList[0].posId, 'reject');
                              context.loaderOverlay.hide();
                            }
                            catch(e){
                              context.loaderOverlay.hide();
                            }

                            // Navigator.pop(context);
                            // Timer(const Duration(seconds: 1), () {Navigator.pop(context);});
                            // goBack();
                          },
                          child: const Text(
                            'Decline',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Doomsday',
                              color: Colors.red,
                            ),
                          ),
                        ),
                      )),

                      const SizedBox(width: 10),

                      Expanded(child: TextButton(
                        onPressed: isAcceptable? ( )  async{
                          setState(() {
                            isAcceptable = false;
                          });
                          context.loaderOverlay.show();
                          _pc.close();
                          progressBarAnimationController.stop();
                          try{
                            CommonModel apiResponse = await _posResponse(requestDataList[0].posId, 'accept');
                            if(apiResponse.status == "true"){
                              context.loaderOverlay.hide();
                              setState(() {
                                state = 'accept';
                              });

                              Timer(const Duration(milliseconds: 500),() {_pc.open();});
                            }
                            else{

                              context.loaderOverlay.hide();
                              CommonUtils.errorToast(context, apiResponse.message);
                              if(apiResponse.data['willClose'] == true){
                                goBack();
                              }
                            }
                          }
                          catch(e){
                            setState(() {
                              isAcceptable = true;
                            });
                            context.loaderOverlay.hide();
                          }



                        }: null,
                        style: TextButton.styleFrom(
                            backgroundColor: MyColors.base_green_color,
                            padding: const EdgeInsets.only(top: 15, bottom: 15)
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Doomsday',
                            color: Colors.white,
                          ),
                        ),
                      )),
                    ],
                  ),
                )
              ],
            ),
          ),
          const Divider(
            color: Colors.grey, //color of divider
            height: 1, //height spacing of divider
            thickness: 0, //thickness of divier line
          ),
          Container(
            padding:
            const EdgeInsets.only(left: 17, right: 17, top: 3, bottom: 20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: const [
                    Text(
                      'Your address',
                      style: TextStyle(
                          fontFamily: 'Doomsday',
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1),
                      textAlign: TextAlign.start,
                    )
                  ],
                ),
                Row(children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(right: 13.0),
                      child: Text(
                        myAddress,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'Doomsday',
                            color: Colors.black87,
                            height: 1.5 ),),),) ],),
                Row(
                  children: const [
                    Text(
                      'Amount',
                      style: TextStyle(
                          fontFamily: 'Doomsday',
                          fontSize: 14,
                          color: Colors.grey,
                          height: 2),
                      textAlign: TextAlign.start, )],),
                Row(
                  children: [
                    Text(
                      StringMessage.naira + requestDataList[0].amount,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = const BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return  Scaffold(
      appBar: AppBar(
        toolbarHeight: 95,
        automaticallyImplyLeading: false, // Remove back button
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Available Balance',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Doomsday'
                ),
              ),
            ),
            Text(
              StringMessage.naira +
                  CommonUtils.toCurrency(Globals.walletbalance),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        backgroundColor: MyColors.base_green_color,
      ),
      body: WillPopScope(
        onWillPop: () async{
          return false;
        },
        child: requestDataList.isNotEmpty ? SlidingUpPanel(
          controller: _pc,
          panel: Center(
              child: state == 'accept'
                  ? _showAcceptedRequestsModal()
                  : _showNewRequestModal()
          ),
          borderRadius: radius,
          minHeight: 300,

          body: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            tiltGesturesEnabled: true,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            polylines: Set<Polyline>.of(polylines.values),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ) : CommonUtils.progressDialogBox(),
      ),
    );
  }
  _openChat() async{
    print("Hello world");
    // Navigator.of(context).push(
    //     MaterialPageRoute(
    //         builder: (context) => ChatsScreen(),
    //         fullscreenDialog: true)).then((value) {
    // });
    print(requestDataList[0].toId);
    String userId = requestDataList[0].frId == CommonUtils.getStrUserid() ? requestDataList[0].toId : requestDataList[0].frId;
    String userName = requestDataList[0].frUsername;
    String userAvatar = requestDataList[0].frAvatar;
    ChatUserModel chatUserModel = ChatUserModel(userId, userName, userAvatar);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RequestChatScreen(requestDataList[0].posId, chatUserModel)));
  }

  @override
  void dispose() {
    progressBarAnimationController.dispose();
    _requestStateSubscription?.cancel();
    Globals.incoming_request = false;
    screenIsActive = false;
    print("CheckPoint: 0002");
    super.dispose();
  }
}