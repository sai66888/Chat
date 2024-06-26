import 'dart:async';
import 'dart:core';
import 'package:custom_marker/marker_icon.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/extension.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:upaychat/Apis/locationapi.dart';
import 'package:upaychat/Apis/poscashrequestapi.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/Models/locationmodel.dart';
import 'package:http/http.dart' as http;
import 'package:upaychat/Pages/pos_cash_request.dart';
import 'package:upaychat/globals.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:upaychat/main.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'Chat/ChatUserModel.dart';
import 'Chat/RequestChatScreen.dart';
import 'keys.dart';

import 'package:google_places_flutter/model/prediction.dart';

final _databaseRef = FirebaseDatabase.instance.ref("pos_cash_request");

class PosCashWithdrawal extends StatefulWidget {
  String? outGoingRequestId;
  LocationData? outgoingLocationData;
  String? elapsedTime;
  String? requestAmount;
  PosCashWithdrawal({Key? key, this.requestAmount, this.elapsedTime, this.outGoingRequestId, this.outgoingLocationData}) : super(key: key);

  static double myCurrentLatitude =
      PreferencesManager.getDouble(StringMessage.myCurrentLatitude);
  static double myCurrentLongitude =
      PreferencesManager.getDouble(StringMessage.myCurrentLongitude);

  static final kInitialPosition = LatLng(myCurrentLatitude, myCurrentLongitude);

  @override
  PosCashWithdrawalState createState() => PosCashWithdrawalState();
}

class PosCashWithdrawalState extends State<PosCashWithdrawal>
    with TickerProviderStateMixin , WidgetsBindingObserver{
  late final String myAvatar;
  late final String myFullname;
  late final double myLatitude;
  late final double myLongitude;
  late final String myAddress;
  bool isConfirmable = false;
  late String state = '';
  late String myImage = '';
  late BitmapDescriptor icon;
  late String myId;
  String currentPosRequestId = "";
  // Set<Marker> _markers = <Marker>{};
  List<Marker> _markers = <Marker>[];
  // PickResult? selectedPlace;

  bool isCancellable = true;
  bool isAccepted = false;
  late double seletedLocationLat = 0.0;
  late double seletedLocationLng = 0.0;

  TextEditingController controller = TextEditingController();

  String googleApikey = "AIzaSyCT68yhS_gvlHzW9VdqIg4mKsPNPVITgz4";
  GoogleMapController? mapController; //contrller for Google map
  CameraPosition? cameraPosition;
  // LatLng startLocation = LatLng(27.6602292, 85.308027);

  StreamSubscription<DatabaseEvent>? _requestStateSubscription;
  late AnimationController progressBarAnimationController;

  Set<Circle> circles = {
    const Circle(
        circleId: CircleId('id'),
        center: LatLng(0.0, 0.0),
        radius: 0,
        strokeWidth: 1,
        fillColor: Color.fromRGBO(138, 227, 177, 0.28),
        strokeColor: Colors.white10)
  };

  final TextEditingController needMoneyController = TextEditingController();
  final TextEditingController nearPerson = TextEditingController();

  String? _currentAddress;
  double amount = 0.00;
  Timer? _timer;
  late Timer _noRequestTimer;
  PersistentBottomSheetController? _persistentBottomSheetController;
  PersistentBottomSheetController? _persistentModalBottomSheetController;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  int i = 0;
  List<LocationData> locationList = [];
  late int _remainingTime = 0;
  PosCashRequestApi posCashRequestApi = PosCashRequestApi();
  _addMarker() async {
    MarkerId markerId = MarkerId(myId);
    if(myAvatar.isNotNullAndNotEmpty){
      _markers.add(
        Marker(
          markerId: markerId,
          icon: await MarkerIcon.downloadResizePictureCircle(myAvatar,
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
          markerId: markerId,
          icon: await MarkerIcon.circleCanvasWithText(size:const Size(150.0,150.0),text: CommonUtils.extractInitials(myFullname),
              fontColor: Colors.white,
              circleColor: MyColors.base_green_color,
              fontSize: 75),
          position: LatLng(myLatitude, myLongitude),
        ),
      );
    }


    setState(()  {
    });
  }
   @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      String messageCategory = message.data['category'].toString();
      if (messageCategory == 'accept') {
        _timer?.cancel();
        _noRequestTimer.cancel();
        _requestStateSubscription?.cancel();
        // Navigator.of(context).pushNamed('/requests');
      }
    });

    progressBarAnimationController = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 110),
    )..addListener(() {
        setState(() {});
        if (_persistentBottomSheetController != null) {
          _persistentBottomSheetController?.setState!(() {});
        }
      });
    progressBarAnimationController.repeat(reverse: false);
    myAvatar = PreferencesManager.getString(StringMessage.profileimage);
    myFullname = PreferencesManager.getString(StringMessage.username);
    seletedLocationLat =
        PreferencesManager.getDouble(StringMessage.myCurrentLatitude);
    seletedLocationLng =
        PreferencesManager.getDouble(StringMessage.myCurrentLongitude);
    myLatitude = PreferencesManager.getDouble(StringMessage.myCurrentLatitude);
    myLongitude =
        PreferencesManager.getDouble(StringMessage.myCurrentLongitude);
    _currentAddress = PreferencesManager.getString(StringMessage.myAddress);
    controller.text = _currentAddress.toString();
    myId = PreferencesManager.getInt(StringMessage.id).toString();

    _addMarker();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(widget.outGoingRequestId != null && widget.outgoingLocationData != null){
        setState(() {
          locationList.add(widget.outgoingLocationData!);
          needMoneyController.text = widget.requestAmount!;
          amount = double.parse(widget.requestAmount!.replaceAll(',', ''));
        });
        _showModal();
        progressBarAnimationController.stop();

        if(widget.outgoingLocationData!.avatar.isNotNullAndNotEmpty){
          _markers.add(
            Marker(
              markerId: MarkerId(widget.outgoingLocationData!.userId),
              icon: await MarkerIcon.downloadResizePictureCircle(widget.outgoingLocationData!.avatar,
                  size: 120,
                  addBorder: true,
                  borderColor: Colors.grey,
                  borderSize: 15),
              position: LatLng(
                  double.parse(widget.outgoingLocationData!.latitude), double.parse(widget.outgoingLocationData!.longitude)),
            ),
          );
        }
        else{
          _markers.add(
            Marker(
              markerId: MarkerId(widget.outgoingLocationData!.userId),
              icon: await MarkerIcon.circleCanvasWithText(size:const Size(150.0,150.0),text: CommonUtils.extractInitials("${widget.outgoingLocationData!.firstname} ${widget.outgoingLocationData!.lastname}"),
                  fontColor: Colors.white,
                  circleColor: MyColors.base_green_color,
                  fontSize: 75),
              position: LatLng(double.parse(widget.outgoingLocationData!.latitude), double.parse(widget.outgoingLocationData!.longitude)),
            ),
          );
        }
        setState(() {
          circles = {
            Circle(
                circleId: const CircleId('id'),
                center: LatLng(seletedLocationLat, seletedLocationLng),
                radius: 798.0 * 2,
                strokeWidth: 1,
                fillColor:
                const Color.fromRGBO(138, 227, 177, 0.28627450980392155),
                strokeColor: Colors.white10)
          };
        });
        progressBarAnimationController.forward(from: (int.parse(widget.elapsedTime!)).toDouble() / 100);
        print('Start ProgressBar');
        _persistentBottomSheetController?.setState!(() {});

        setState(() {
          currentPosRequestId = widget.outGoingRequestId!;
        });
        subscribePosRequest();
        _timer = Timer.periodic(Duration(seconds: 100 - int.parse(widget.elapsedTime!)), (timer) async{
          // currentPosRequestId
          _remainingTime++;
          timerCallBack(isFirst: false);
        });
      }
    });

    // progressBarAnimationController.stop();
  }

  @override
  void dispose() {
    progressBarAnimationController.dispose();
    Globals.incoming_request = false;
    
    _timer?.cancel();
    _requestStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        toolbarHeight: 95,
        leading: InkWell(
            onTap: isCancellable ? () {
                Navigator.of(context).pop();
            }: null,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: isCancellable ? () {
                    Navigator.of(context).pop();
                } : null,
                icon: const Icon(
                  Icons.chevron_left,
                  size: 35,
                ),
              ),
            )),
        leadingWidth: 40,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Available Balance',
                style: TextStyle(fontSize: 14, fontFamily: 'Doomsday'),
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
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: GoogleMap(
              //Map widget from google_maps_flutter package
              markers: Set<Marker>.of(_markers),
              zoomGesturesEnabled: true, //enable Zoom in, out on map
              initialCameraPosition: CameraPosition(
                //innital position in map
                target: PosCashWithdrawal.kInitialPosition, //initial position
                zoom: 14.0, //initial zoom level
              ),
              mapType: MapType.normal, //map type
              onMapCreated: (controller) {
                //method called when map is created
                setState(() {
                  mapController = controller;
                });
              },
              circles: circles,
            ),
          ),
          _showSheet(context),
        ]),
      ),
    );
  }

  _showSheet(context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.elliptical(100, 100),
            topRight: Radius.circular(10)),
      ),
      child: Center(
        child: Column(
          children: <Widget>[
            Row(
              children: const [
                Text(
                  'Delivery address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Doomsday',
                  ),
                ),
              ],
            ),
            GooglePlaceAutoCompleteTextField(
                textEditingController: controller,
                googleAPIKey: googleApikey,
                inputDecoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    prefixIcon: Icon(
                      Icons.location_pin,
                      color: MyColors.base_green_color,
                    ),
                    suffixIcon: InkWell(
                      onTap: (){
                        setState(() {
                          _currentAddress = '';
                          controller.text = '';
                        });
                      },
                      child: const Icon(Icons.close),
                    ),


                ),

                debounceTime: 800, // default 600 ms,
                countries: ["ng"], // optional by default null is set
                isLatLngRequired:
                    true, // if you required coordinates from place detail
                getPlaceDetailWithLatLng: (Prediction prediction) {
                  updateMyLocation(prediction);
                }, // this callback is called when isLatLngRequired is true
                itmClick: (Prediction prediction) {
                  updateMyLocation(prediction);
                }),
            Container(
              color: Colors.white,
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
              child: TextField(

                textAlign: TextAlign.start,
                controller: needMoneyController,

                style: const TextStyle(
                  fontFamily: 'Doomsday',
                  fontSize: 24,
                ),
                onChanged: (text) async {
                  if (text.isNotEmpty) {
                    text = text.replaceAll(RegExp(r'[^0-9.]'), '');
                    String prev = text;
                    text = text.replaceAll(',', '');
                    text = text.replaceAll('.', '');
                    if (text.length >= 10) text = text.substring(0, 9);
                    double value = int.parse(text).toDouble() / 100;
                    if (value > 3000000) {
                      text = text.substring(0, 8);
                      value = int.parse(text).toDouble() / 100;
                    }
                    text = CommonUtils.toCurrency(value);
                    if (prev != text) {
                      needMoneyController.text = text;
                      needMoneyController.selection =
                          TextSelection.collapsed(offset: text.length);
                    }

                    setState(() {
                      amount = double.parse(text.replaceAll(',', ''));
                    });
                  }
                },
                inputFormatters: [amountValidator!],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: MyColors.base_green_color, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  hintText: "0.00",
                ),
              ),
            ),
            amount >= 1000
                ? Container(
                    child: Row(
                      children: [
                        Text("Fee: ${checkFee(amount)}"),
                        Expanded(child: SizedBox())
                      ],
                    ),
                  )
                : SizedBox(),
            SizedBox(
              height: 5,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.base_green_color,
                minimumSize: const Size.fromHeight(50), // NEW
              ),
              onPressed: 1000.00 <= amount && amount < 500001
                  ? () {
                      if (amount + checkFee(amount) > Globals.walletbalance) {
                        CommonUtils.errorToast(
                            context, "Insufficient balance.");
                        return;
                      }
                      FocusManager.instance.primaryFocus?.unfocus();
                      // &&
                      setState(() {
                        _remainingTime = 0;
                      });
                      _showModal();
                      _sendRequest(2);
                    }
                  : null,
              child: const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Withdraw Cash',
                  style: TextStyle(fontSize: 18, fontFamily: 'Doomsday'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Looking option modal
  _showModal() {
    _persistentBottomSheetController = _key.currentState!.showBottomSheet(
      (BuildContext context) {
        return WillPopScope(child: BottomSheet(
            onClosing: () {
              print('OnCLosing');
              setState(() {
                _stopTimer();
              });
            }, builder: (context) {
          return Wrap(
            children: [
              Container(
                decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                      const EdgeInsets.only(left: 17, right: 17, bottom: 6),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 30,),
                          const Text(
                            'Connecting to an operator',
                            style: TextStyle(
                              fontFamily: 'Doomsday',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,),
                          ),
                          SizedBox(height: 20,),
                          locationList.isEmpty
                              ? Row(
                            children: [
                              const CircularProgressIndicator(
                                color: MyColors.base_green_color,
                              ),
                              Flexible(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 20),
                                  child: const Text(
                                    'We are connecting you to a nearby operator.\nPlease wait',
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              )
                            ],
                          )
                              : Container(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: SizedBox()),
                                    ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(80),
                                      child: Image.network(
                                        locationList[_remainingTime]
                                            .avatar,
                                        width: 80,
                                        height: 80,
                                      ),
                                    ),
                                    Expanded(child: SizedBox())
                                  ],
                                ),
                                Text(
                                  "${locationList[_remainingTime].firstname} ${locationList[_remainingTime].lastname}",
                                  style: TextStyle(
                                      fontFamily: 'Doomsday',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      height: 4),
                                ),
                                LinearProgressIndicator(
                                  value: progressBarAnimationController
                                      .value,
                                  semanticsLabel: '',
                                  color: MyColors.base_green_color,
                                  backgroundColor:
                                  MyColors.base_green_color_20,
                                ),
                              ],
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
                            margin: const EdgeInsets.only(top: 20, bottom: 10),
                            child: ElevatedButton(

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(50),
                                  elevation: 0.0,
                                  shadowColor: isCancellable ? Colors.red : MyColors.grey_color,
                                ),
                                onPressed: isCancellable ? () {
                                  print("Cancel Search");
                                  setState(() {
                                    _stopTimer();
                                  });
                                } :  null,
                                child:  Text(
                                  'Cancel search',
                                  style: TextStyle(
                                      color: isCancellable ? Colors.red : MyColors.grey_color,
                                      fontSize: 18,
                                      fontFamily: 'Doomsday'),
                                )),
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
                      padding: const EdgeInsets.only(
                          left: 17, right: 17, top: 3, bottom: 20),
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
                          Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.only(right: 13.0),
                                  child: Text(
                                    _currentAddress!,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    maxLines: 1,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Doomsday',
                                        color: Colors.black87,
                                        height: 1.5),
                                  ),
                                ),
                              )
                            ],
                          ),
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
                                StringMessage.naira + needMoneyController.text,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: TextDecoration.none,
                                ),
                                textAlign: TextAlign.start,
                              )

                              // style: TextStyle(
                              //   color:
                              //   _phoneVerified ? Colors.white : Colors.grey[350],
                              //   fontWeight: FontWeight.bold,
                              //   fontSize: 28,
                              //   decoration: _phoneVerified
                              //       ? TextDecoration.none
                              //       : TextDecoration.lineThrough,
                              // ),
                            ],
                          ),
                          // Container(
                          //   margin: const EdgeInsets.only(top: 12),
                          //   child: ElevatedButton.icon(
                          //     label: const Text(
                          //       'Edit parameters',
                          //       style: TextStyle(
                          //           color: MyColors.base_green_color,
                          //           fontSize: 18,
                          //           fontFamily: 'Ubuntu',
                          //           fontWeight: FontWeight.w500),
                          //     ),
                          //     icon: const Icon(
                          //       Icons.edit,
                          //       color: MyColors.base_green_color,
                          //     ),
                          //     onPressed: () {
                          //       // _showNewRequestModal('xxxxx');
                          //       // _showParametersModal();
                          //     },
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: Colors.white,
                          //       side: const BorderSide(color: Colors.white, width: 0),
                          //       elevation: 0.0,
                          //       shadowColor: Colors.transparent,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        }), onWillPop: ()async{
          return isCancellable == true;
        });
        return WillPopScope(
            onWillPop: () async => false,
            child: Wrap(
              children: [
                Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                            left: 17, right: 17, bottom: 6),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Looking option',
                              style: TextStyle(
                                  fontFamily: 'Doomsday',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 4),
                            ),
                            locationList.isEmpty
                                ? Row(
                                    children: [
                                      const CircularProgressIndicator(
                                        color: MyColors.base_green_color,
                                      ),
                                      Flexible(
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(left: 20),
                                          child: const Text(
                                            'We are looking for the right option for you. Please wait.',
                                            maxLines: 2,
                                            softWrap: true,
                                            overflow: TextOverflow.clip,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : Container(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child: SizedBox()),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(80),
                                              child: Image.network(
                                                locationList[_remainingTime]
                                                    .avatar,
                                                width: 80,
                                                height: 80,
                                              ),
                                            ),
                                            Expanded(child: SizedBox())
                                          ],
                                        ),
                                        Text(
                                          "${locationList[_remainingTime].firstname} ${locationList[_remainingTime].firstname}",
                                          style: TextStyle(
                                              fontFamily: 'Doomsday',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              height: 4),
                                        ),
                                        LinearProgressIndicator(
                                          value: progressBarAnimationController
                                              .value,
                                          semanticsLabel: '',
                                          color: MyColors.base_green_color,
                                          backgroundColor:
                                              MyColors.base_green_color_20,
                                        ),
                                      ],
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
                              margin:
                                  const EdgeInsets.only(top: 20, bottom: 10),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(50),
                                    elevation: 0.0,
                                    shadowColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _stopTimer();
                                    });
                                  },
                                  child: const Text(
                                    'Cancel search',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                        fontFamily: 'Doomsday'),
                                  )),
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
                        padding: const EdgeInsets.only(
                            left: 17, right: 17, top: 3, bottom: 20),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Text(
                                  'Your parameters',
                                  style: TextStyle(
                                      fontFamily: 'Doomsday',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 3),
                                  textAlign: TextAlign.start,
                                )
                              ],
                            ),

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
                            Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 13.0),
                                    child: Text(
                                      _currentAddress!,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Doomsday',
                                          color: Colors.black87,
                                          height: 1.5),
                                    ),
                                  ),
                                )
                              ],
                            ),
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
                                  StringMessage.naira +
                                      needMoneyController.text,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    decoration: TextDecoration.none,
                                  ),
                                  textAlign: TextAlign.start,
                                )

                                // style: TextStyle(
                                //   color:
                                //   _phoneVerified ? Colors.white : Colors.grey[350],
                                //   fontWeight: FontWeight.bold,
                                //   fontSize: 28,
                                //   decoration: _phoneVerified
                                //       ? TextDecoration.none
                                //       : TextDecoration.lineThrough,
                                // ),
                              ],
                            ),
                            // Container(
                            //   margin: const EdgeInsets.only(top: 12),
                            //   child: ElevatedButton.icon(
                            //     label: const Text(
                            //       'Edit parameters',
                            //       style: TextStyle(
                            //           color: MyColors.base_green_color,
                            //           fontSize: 18,
                            //           fontFamily: 'Ubuntu',
                            //           fontWeight: FontWeight.w500),
                            //     ),
                            //     icon: const Icon(
                            //       Icons.edit,
                            //       color: MyColors.base_green_color,
                            //     ),
                            //     onPressed: () {
                            //       // _showNewRequestModal('xxxxx');
                            //       // _showParametersModal();
                            //     },
                            //     style: ElevatedButton.styleFrom(
                            //       backgroundColor: Colors.white,
                            //       side: const BorderSide(color: Colors.white, width: 0),
                            //       elevation: 0.0,
                            //       shadowColor: Colors.transparent,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ));
      },
    );
    _persistentBottomSheetController?.closed.whenComplete(()  {
      print('OnClosing Modal');
      if(currentPosRequestId != ""){
        if(isAccepted == false){
          setState((){
            _stopTimer();
          });
        }

      }
    });
  }



  void _sendRequest(mile) async {
    try {
      _remainingTime = 0;
      locationList = [];
      setState(() {
        circles = {
          Circle(
              circleId: const CircleId('id'),
              center: LatLng(seletedLocationLat, seletedLocationLng),
              radius: 798.0 * mile,
              strokeWidth: 1,
              fillColor:
                  const Color.fromRGBO(138, 227, 177, 0.28627450980392155),
              strokeColor: Colors.white10)
        };
      });
      // get users location api
      LocationApi locationApi = LocationApi();
      LocationModel result = await locationApi.getUsers(
          seletedLocationLat.toString(),
          seletedLocationLng.toString(),
          _currentAddress,
          mile);
      if (result.locationData != null) {
        result.locationData?.map((res) async {
          setState(() async {
            if(res.avatar.isNotNullAndNotEmpty){
              _markers.add(
                Marker(
                  markerId: MarkerId(res.userId),
                  icon: await MarkerIcon.downloadResizePictureCircle(res.avatar,
                      size: 120,
                      addBorder: true,
                      borderColor: Colors.grey,
                      borderSize: 15),
                  position: LatLng(
                      double.parse(res.latitude), double.parse(res.longitude)),
                ),
              );
            }
            else{
              _markers.add(
                Marker(
                  markerId: MarkerId(res.userId),
                  icon: await MarkerIcon.circleCanvasWithText(size:const Size(150.0,150.0),text: CommonUtils.extractInitials("${res.firstname} ${res.lastname}"),
                      fontColor: Colors.white,
                      circleColor: MyColors.base_green_color,
                      fontSize: 75),
                  position: LatLng(double.parse(res.latitude), double.parse(res.longitude)),
                ),
              );
            }

          });
        }).toList();

        setState(() {
          locationList = result.locationData ?? [];
        });
      }
      if (locationList.isNotEmpty) {
        _startTimer();
      } else {
        CommonUtils.errorToast(context,
            "Sorry, no operators available at the moment. Please try again in a few minutes.");
        Navigator.of(context).pop();
      }
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }

  _distance(String distance) {
    List<String> splitted = distance.split('.');
    int ddd = int.parse(splitted[0]);
    if (ddd < 1000) {
      return '${ddd}m from you';
    } else {
      double dd = ddd / 100;
      int dddd = dd.toInt();
      return '${dddd / 10}km from you';
    }
  }

  void _stopTimer() async{
    if(currentPosRequestId != ""){
      context.loaderOverlay.show();
      try{
        _timer?.cancel();
        _requestStateSubscription?.cancel();
        progressBarAnimationController.stop();

        if (_requestStateSubscription != null) {
          print("Current Request ID: ${currentPosRequestId}");
          await _databaseRef.child(currentPosRequestId).update({"state": "cancel"});
          await _requestStateSubscription?.cancel();
          await posCashRequestApi.posResponse(currentPosRequestId, 'cancel');
        }
        context.loaderOverlay.hide();
        Navigator.pop(context);
        setState(() {
          currentPosRequestId = "";
          isCancellable = true;
        });
      }
      catch(e){
        context.loaderOverlay.hide();
      }
    }
    else{
      _timer?.cancel();
      _requestStateSubscription?.cancel();
      progressBarAnimationController.stop();
      Navigator.pop(context);
    }


  }

  void sendPosCashWithdrawalRequest({bool isFirst = true}) async {
    // progressBarAnimationController.reset();
    progressBarAnimationController.stop();
    progressBarAnimationController.forward(from: 0);
    _persistentBottomSheetController?.setState!(() {});
    if (_requestStateSubscription != null) {
      _requestStateSubscription?.cancel();
    }
    // Navigator.pop(context);
    // _showParametersModal();
    setState(() {
      isCancellable = false;
    });
    try{
      CommonModel posRequestResult = await posCashRequestApi.sendPosCashRequest(
          locationList[_remainingTime].userId,
          needMoneyController.text,
          locationList[_remainingTime].distance,
          seletedLocationLat,
          seletedLocationLng,
          _currentAddress!,
          isFirst ? currentPosRequestId : ""
      );

      if (posRequestResult.status == "true") {
        setState(() {
          isCancellable = true;
          currentPosRequestId = posRequestResult.data['pos_id'].toString();
        });
        subscribePosRequest();
      }
      else{
        // CommonUtils.errorToast(context, posRequestResult.message);
        _timer?.cancel();
        _requestStateSubscription?.cancel();
        progressBarAnimationController.stop();
        _remainingTime++;
        PreferencesManager.setString(StringMessage.active_request, "");
        _startTimer();
      }
    }
    catch(e){
      print("ERROR: ${e.toString()}");
    }

  }
  void subscribePosRequest(){
    _requestStateSubscription = _databaseRef
        .child(currentPosRequestId)
        .child("state")
        .onValue
        .listen((event) {
      String newPosStatus = event.snapshot.value.toString();
      print(
          "Pos Cash Request Status: ${currentPosRequestId} => ${newPosStatus}");
      if (newPosStatus == "accepted") {
        setState(() {
          isAccepted = true;
        });
        _timer?.cancel();
        // _requestStateSubscription?.cancel();
        Navigator.pop(context);
        progressBarAnimationController.stop();
        PreferencesManager.setString(
            StringMessage.active_request, currentPosRequestId);
        Globals.incoming_request = true;
        _showParametersModal();
      } else if (newPosStatus == "rejected") {
        _timer?.cancel();
        _requestStateSubscription?.cancel();
        progressBarAnimationController.stop();
        _remainingTime++;
        PreferencesManager.setString(StringMessage.active_request, "");
        _startTimer();
      } else if (newPosStatus == "cancel" || newPosStatus == "canceled") {
        // Navigator.pop(context);
        _persistentModalBottomSheetController?.close();

        _timer?.cancel();
        _requestStateSubscription?.cancel();
        progressBarAnimationController.stop();
        CommonUtils.errorToast(context, "This request has been canceled");
        // _showModal();
        // _remainingTime++;
        // PreferencesManager.setString(StringMessage.active_request, "");
        // _startTimer();
      } else if (newPosStatus == "deliveried") {
        print("Request has been delivered!!");
        if (_persistentModalBottomSheetController != null) {
          _persistentModalBottomSheetController?.setState!(() {
            isConfirmable = true;
          });
        }
      } else if (newPosStatus == "completed") {
        CommonUtils.successToast(context, "This request has been completed");
        PreferencesManager.setString(StringMessage.active_request, "");
        Navigator.pop(context);
        Navigator.pop(context);
        print('request has been completed');
      }
    });
  }

  void timerCallBack({bool isFirst = true}) {
    _requestStateSubscription?.cancel();
    if (_remainingTime == locationList.length) {
      Navigator.pop(context);
      setState(() {
        _timer?.cancel();
        _remainingTime = 0;
      });
      CommonUtils.errorToast(context,
          "Sorry, no operators available at the moment. Please try again in a few minutes.");
    } else {
      sendPosCashWithdrawalRequest(isFirst: isFirst);
    }
  }

  void _startTimer() async {
    _timer = Timer.periodic(const Duration(seconds: 100), (timer) async{
      // currentPosRequestId
      _remainingTime++;
      timerCallBack(isFirst: false);
    });
    timerCallBack(isFirst: true);
  }

  // We found the right option modal
  _showParametersModal<Null>() {
    _persistentModalBottomSheetController =
        _key.currentState!.showBottomSheet((context) {
      return BottomSheet(
        onClosing: () {
          setState(() {
            _stopTimer();
          });
        },
        builder: ((context) {
          return Wrap(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 17, right: 17, bottom: 6),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Your cash is on the way',
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
                          borderRadius: BorderRadius.circular(80),
                          child: Image.network(
                            locationList[_remainingTime].avatar,
                            width: 80,
                            height: 80,
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
                                        '${locationList[_remainingTime].firstname}',
                                        maxLines: 2,
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            height: 1.5),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          locationList[_remainingTime].address,
                                          maxLines: 2,
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              height: 1.3,
                                              fontFamily: 'Doomsday'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        _distance(locationList[_remainingTime]
                                            .distance),
                                        maxLines: 2,
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                        style: const TextStyle(
                                            fontFamily: 'Doomsday',
                                            fontSize: 14,
                                            color: Colors.grey,
                                            height: 1.5),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
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
                            onPressed: () async {
                              context.loaderOverlay.show();
                              try {
                                await posCashRequestApi.posResponseSuccess(
                                    currentPosRequestId, 'receive');
                                context.loaderOverlay.hide();
                              } catch (e) {
                                context.loaderOverlay.hide();
                              }
                            },
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
                              if (isConfirmable) {
                                Navigator.of(context).pushNamed("/contactus");
                              } else {
                                context.loaderOverlay.show();
                                try {
                                  await posCashRequestApi.posResponseSuccess(
                                      currentPosRequestId, 'noreceive');
                                  context.loaderOverlay.hide();
                                } catch (e) {
                                  context.loaderOverlay.hide();
                                }
                              }
                            },
                            child: Text(
                              isConfirmable ? "Help" : "Cancel",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontFamily: 'Ubuntu'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          margin: const EdgeInsets.only(top: 20, bottom: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0.0,
                            ),
                            onPressed: () {
                              // _showNewRequestModal();
                              String userId =
                                  locationList[_remainingTime].userId;
                              String userName =
                                  "${locationList[_remainingTime].firstname} ${locationList[_remainingTime].lastname}";
                              String userAvatar =
                                  locationList[_remainingTime].avatar;
                              ChatUserModel chatUserModel =
                                  ChatUserModel(userId, userName, userAvatar);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RequestChatScreen(
                                          currentPosRequestId, chatUserModel)));
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.chat,
                                  color: Colors.black87,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: const Text(
                                    'Chat',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontFamily: 'Doomsday'),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.black87,
                                )
                              ],
                            ),
                          ),
                        )),
                        const SizedBox(width: 20),
                        Expanded(
                            child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          margin: const EdgeInsets.only(top: 20, bottom: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0.0,
                            ),
                            onPressed: locationList[_remainingTime].mobile == ""
                                ? null
                                : () async {
                                    late String url =
                                        "tel:${locationList[_remainingTime].mobile}";
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
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: const Text(
                                    'Call',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontFamily: 'Doomsday'),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.black87,
                                )
                              ],
                            ),
                          ),
                        )),
                      ],
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
                padding: const EdgeInsets.only(
                    left: 17, right: 17, top: 3, bottom: 20),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _currentAddress!,
                            style: const TextStyle(
                                fontFamily: 'Doomsday',
                                fontSize: 15,
                                color: Colors.black87,
                                height: 1.5),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
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
                          StringMessage.naira + needMoneyController.text,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.start,
                        )
                      ],
                    ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     border: Border.all(
                    //       color: Colors.red,
                    //       width: 1,
                    //     ),
                    //     borderRadius: BorderRadius.circular(5),
                    //   ),
                    //   margin: const EdgeInsets.only(top: 20),
                    //   child: ElevatedButton(
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor: Colors.white,
                    //         minimumSize: const Size.fromHeight(50),
                    //         elevation: 0.0,
                    //         shadowColor: Colors.red,
                    //       ),
                    //       onPressed: () {
                    //         _stopTimer();
                    //       },
                    //       child: const Text(
                    //         'Cancel search',
                    //         style: TextStyle(
                    //             color: Colors.red,
                    //             fontSize: 18,
                    //             fontFamily: 'Doomsday'),
                    //       )),
                    // ),
                  ],
                ),
              )
            ],
          );
        }),
      );
    });

    // return showModalBottomSheet(
    //   isDismissible: false,
    //   context: context,
    //   isScrollControlled: true,
    //   useRootNavigator: true,
    //   builder: (BuildContext context) {
    //
    //   },
    // ).whenComplete((){
    //   Navigator.of(context).pushReplacement(
    //       MaterialPageRoute(
    //           builder: (context) => PosCashRequest(posId: currentPosRequestId),
    //           fullscreenDialog: true));
    // });
  }

  checkFee(double amount) {

    int fee = (amount.toInt() - 1) ~/ 5000;
    fee < 1 ? fee = 1 : fee = (fee + 1) | 0;
    return fee * 150 + 50;
  }

  void updateMyLocation(Prediction prediction) {
    if (prediction.description != null && prediction.lat != null && prediction.lng != null) {
      controller.text = prediction.description ?? '';
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: prediction.description!.length));
      print("-------");
      setState(() {
        _currentAddress = prediction.description ?? '';
      });

      final lat = prediction.lat!;
      final lang = prediction.lng!;
      var newlatlang =
      LatLng(double.parse(lat), double.parse(lang));
      seletedLocationLat = double.parse(lat);
      seletedLocationLng = double.parse(lang);
      circles = {
        Circle(
            circleId: const CircleId('id'),
            center: LatLng(double.parse(lat), double.parse(lang)),
            radius: 0,
            strokeWidth: 1596,
            fillColor: const Color.fromRGBO(138, 227, 177, 0.28),
            strokeColor: Colors.white10)
      };
      mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: newlatlang, zoom: 14)));
      if (_markers.length > 0) {
        Marker _marker = Marker(
          markerId: _markers.first.markerId,
          onTap: () {
            print("tapped");
          },
          position: LatLng(double.parse(lat), double.parse(lang)),
          icon: _markers.first.icon,
        );
        setState(() {
          _markers[0] = _marker;
        });
        // _markers.first//.position = LatLng(lat, lang);
      }
    }
  }
}
