import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:upaychat/Apis/locationapi.dart';
import 'package:upaychat/Apis/pendingrequestapi.dart';
import 'package:upaychat/Apis/wallet_api.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/Models/locationmodel.dart';
import 'package:upaychat/Models/pendingrequestmodel.dart';
import 'package:upaychat/Models/walletmodel.dart';
import 'package:upaychat/Pages/pos_cash_withdrawal.dart';
import 'package:upaychat/Pages/splash_screen.dart';
import 'package:upaychat/CommonUtils/firebase_utils.dart';
import 'package:upaychat/globals.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'Apis/poscashrequestapi.dart';
import 'Apis/updateuserkeyapi.dart';
import 'CustomWidgets/my_colors.dart';
import 'Models/requestmodel.dart';
import 'Pages/pos_cash_request.dart';
import 'firebase_options.dart';
import 'dart:ui';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geolocator_apple/geolocator_apple.dart';
import 'package:geolocator_android/geolocator_android.dart';
Position? _currentPosition;
final _databaseRef = FirebaseDatabase.instance.ref("users");
final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();
// End get current location
Future<void> _getCurrentPosition() async {
  _handleLocationPermission().then((hasPermission) {
    print("Check Location Permission: ${hasPermission}");
    if (!hasPermission) return;
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation)
        .then((Position position) {
      print("Get Location from Geolocator: ${position.latitude}, ${position.longitude}");
      _currentPosition = position;
      _getAddressFromLatLng(position);
      PreferencesManager.setDouble(StringMessage.myCurrentLatitude, position.latitude);
      PreferencesManager.setDouble(StringMessage.myCurrentLongitude, position.longitude);
    }).catchError((e) {
      debugPrint(e.toString());
    });
  });

}
bool isIncomingRequestScreenOpen = false;
Future<void> _getAddressFromLatLng(Position position) async {
  const apiKey = 'AIzaSyCT68yhS_gvlHzW9VdqIg4mKsPNPVITgz4';
  final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    if (jsonResponse['results'] != null && jsonResponse['results'].length > 0) {
      print("Location is collected from google map api");
      if(jsonResponse['results'][0]['formatted_address'] != "")
        PreferencesManager.setString(StringMessage.myAddress, jsonResponse['results'][0]['formatted_address']);
    }
  } else {
    throw Exception('Failed to fetch address from Google API');
  }

}

Future<bool> _handleLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    if (kDebugMode) {
      print('Location services are disabled. Please enable the services');
    }
    return false;
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    print('Location permissions are permanently denied, we cannot request permissions.');
    return false;
  }
  if (permission == LocationPermission.denied) {
    print('Location permissions are denied');
    return false;
  }
  return true;

}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  PreferencesManager.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationChannel);
  RemoteNotification? notification = message.notification;
  String? newTitle = notification?.title;
  if(notification?.title == "Session Expired"){
    PreferencesManager.setBool(StringMessage.isLogin, false);
    PreferencesManager.setString(StringMessage.token, "");
    FirebaseMessaging.instance.deleteToken();
    newTitle = "Session Expired";//notification.title = "";
    PreferencesManager.setBool(StringMessage.shallLogout,true);
  }
  String messageCategory = message.data['category'].toString();
  if(messageCategory == "cash_request"){
    incomingPosCashRequest = message.data['pos_id'].toString();
    // CommonUtils.showNotificationWithTextAction(message, payload: "cash_request:${incomingPosCashRequest}");
    await PreferencesManager.reload();

    PreferencesManager.setString(StringMessage.incomingRequestId, incomingPosCashRequest);
    PreferencesManager.setInt(StringMessage.newRequestAt, DateTime.now().millisecond);
  }
}
bool isFromNotification = false;
String incomingPosCashRequest = "";
String outgoingPosCashRequest = "";

void main() async {
  //
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await FlutterConfig.loadEnvVariables();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  isFromNotification = false;
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/launcher_icon');

  final List<DarwinNotificationCategory> darwinNotificationCategories =
  <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinNotificationCategoryText,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.text(
          'text_1',
          'Action 1',
          buttonTitle: 'Send',
          placeholder: 'Placeholder',
        ),
      ],
    ),
    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          navigationActionId,
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {
      print("NOtification dismissed");
      didReceiveLocalNotificationStream.add(
        ReceivedNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        ),
      );
    },
    notificationCategories: darwinNotificationCategories,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      if(notificationResponse.payload?.contains('cash_request') == true){
        incomingPosCashRequest = notificationResponse.payload?.split(":")[1] ?? "";
        _navigator.currentState!.push(MaterialPageRoute(
            builder: (context) => PosCashRequest(posId: incomingPosCashRequest, fromNotification: true),
            fullscreenDialog: true));
      }

      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          selectNotificationStream.add(notificationResponse.payload);
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (notificationResponse.actionId == navigationActionId) {
            selectNotificationStream.add(notificationResponse.payload);
          }
          break;
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );



  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.requestPermission();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationChannel);
  FirebaseMessaging.instance.onTokenRefresh
      .listen((fcmToken) {
    UpdateUserKeyApi updateuser = new UpdateUserKeyApi();
    updateuser.save('fcm_token', fcmToken);
    _databaseRef.child('${CommonUtils.getStrUserid()}/fcmToken').set(fcmToken);
  })
      .onError((err) {
    // Error getting token.
  });
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  HttpOverrides.global = MyHttpOverrides();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    print("App is loading from push notification: ${notificationAppLaunchDetails?.notificationResponse?.payload}");
    if(notificationAppLaunchDetails?.notificationResponse?.payload?.contains('cash_request') == true) {
      isFromNotification = true;
      incomingPosCashRequest = notificationAppLaunchDetails?.notificationResponse?.payload?.split(":")[1] ?? "";
    }

  }
  await PreferencesManager.init();
  bool isNewIncomingRequest = PreferencesManager.getBool(StringMessage.newIncomingRequest);
  bool hasIncomingRequest = Globals.incoming_request;
  if(hasIncomingRequest ==  false && isNewIncomingRequest == true){
    int newRequestAt = PreferencesManager.getInt(StringMessage.newRequestAt);
    print("Seconds ago: ${DateTime.now().millisecond - newRequestAt}");
    if(DateTime.now().millisecond - newRequestAt >= 90000){
      PreferencesManager.setBool(StringMessage.newIncomingRequest, false);
    }
    else{
      PreferencesManager.setBool(StringMessage.newIncomingRequest, false);
      isFromNotification = true;
      incomingPosCashRequest = PreferencesManager.getString(StringMessage.incomingRequestId);
    }

  }

  await FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage) {
    if(remoteMessage != null){
      print("App is opening from Remote Message");
      if(remoteMessage.data['category'].toString() == "cash_request"){
        isFromNotification = true;
        incomingPosCashRequest = remoteMessage.data['pos_id'].toString();
      }

    }
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    print("MessageOpened: ${message.data['category']}");
    if(message.data['category'].toString() == "cash_request"){
      isFromNotification = true;
      incomingPosCashRequest = message.data['pos_id'].toString();
    }
  });
  runApp(MyApp());



  FlutterNativeSplash.remove();
}



class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {

  Widget? screenView;
  final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(overlayWidget: const Center(
      child: SpinKitChasingDots(
        color: MyColors.base_green_color,
        size: 50.0,
      ),
    ),useDefaultLoading: false,
    // overlayOpacity: 0.4,
    overlayColor: Colors.black45,
    child:  GetMaterialApp(
      title: 'UpayChat',
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      navigatorKey: _navigator,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home:
      Scaffold(
        resizeToAvoidBottomInset: true,
        body: Center(child: screenView),
      ),

      routes: CommonUtils.returnRoutes(context),
    ),);
  }

  Timer? timerOnline;
  Timer? timer_15;
  Timer? timerCheckLogout;

  late final Timer timer;
  List<String> logs = [];

  @override
  void initState() {
    checkOnline();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    timerCheckLogout = Timer.periodic(Duration(seconds: 1), (timer) {
      bool willLogout = PreferencesManager.getBool(StringMessage.shallLogout);
      bool willUpdate = PreferencesManager.getBool(StringMessage.shallUpdate);
      if(willLogout){
        PreferencesManager.setBool(StringMessage.shallLogout, false);
        _navigator.currentState!.pushReplacementNamed('/login');
      }
      if(willUpdate){
        PreferencesManager.setBool(StringMessage.shallUpdate, false);
        String? newAppVersion = PreferencesManager.getString(StringMessage.newAppVersion);
        CommonUtils.logout(_navigator.currentContext!);
        showDialog<void>(
          context: _navigator.currentContext!,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title:  Text('Update Available'),
              content: SingleChildScrollView(
                child: ListBody(
                  children:  <Widget>[
                    Text('A new version of Upaychat is available.'),
                    Text("Please update to version ${ newAppVersion ?? "new"} now."),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Update'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    StoreRedirect.redirect(
                      androidAppId: "com.upaychat.finance",
                      iOSAppId: "1548246385",
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    });
    timer_15 = Timer.periodic(Duration(seconds: 10), (timer) {
      bool isLogin = PreferencesManager.getBool(StringMessage.isLogin);
      if (Globals.isOnline && isLogin) {
        getPendingRequest();
        getCurWalletBalance();
      }
    });
    handleTimeout();
    collectLocation();
    Timer.periodic(Duration(minutes: 2), (timer) {
      collectLocation();
    });
    WidgetsBinding.instance.addObserver(this);

  }
  collectLocation()async {
    await _getCurrentPosition();
    LocationApi locationApi = LocationApi();
    await locationApi.sendLocation(_currentPosition?.latitude, _currentPosition?.longitude);
  }
  StreamSubscription<ConnectivityResult>? networkConnection;
  void checkOnline() async {
    try {
      rootScaffoldMessengerKey.currentState!.clearSnackBars();
    } catch (e) {}
    networkEventListener(await Connectivity().checkConnectivity());
    networkConnection =
        Connectivity().onConnectivityChanged.listen(networkEventListener);
  }

  void networkEventListener(ConnectivityResult result) async {
    var connected = false;
    if (result == ConnectivityResult.mobile) {
      connected = true;
    } else if (result == ConnectivityResult.wifi) {
      connected = true;
    }
    if (Globals.isOnline != connected) {
      Globals.isOnline = connected;
      // if (connected == false) {
      //   _navigator.currentState.pushNamed('/offline');
      // }
      if (!connected) {
        rootScaffoldMessengerKey.currentState!
            .showSnackBar(CommonUtils.snackBar);
      } else {
        rootScaffoldMessengerKey.currentState!.clearSnackBars();
        if(CommonUtils.getStrUserid() != ""){
          _databaseRef.child('${CommonUtils.getStrUserid()}/onlineStatus').set('online');
        }

      }
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  void getUnreadMessages() {
    FirebaseUtils.getUnreadMessages().then((value) {
      setState(() {
        Globals.unreadMsgCount = value;
      });
    }).catchError((err) {
      print("unread msg: " + err.toString());
    });
  }
  _getIncomingRequestData({String from = "app"}) async {
    print("GetIncomingRequest From: ${from}");
    _navigator.currentContext?.loaderOverlay.show();
    try{
      PosCashRequestApi posCashRequestApi = PosCashRequestApi();
      RequestModel result = await posCashRequestApi.getPosRequestDatas();
      _navigator.currentContext?.loaderOverlay.hide();

      if(result.requestData != null) {
        String myId = PreferencesManager.getInt(StringMessage.id).toString();
        bool isNewIncomingRequest = false;
        bool isAccetedRequest = false;
        bool isOutGoingRequest = false;
        for(int i = 0 ; i < result.requestData!.length ; i ++){
          print('Track: ${result.requestData![i].state} -> ${result.requestData![i].frId} -> ${myId}');
          if( result.requestData![i].state == 'request' && result.requestData![i].toId == myId) {

              incomingPosCashRequest = result.requestData![i].posId;
              isNewIncomingRequest = true;
              break;

          }
          else if (result.requestData![i].state == 'request' && result.requestData![i].frId == myId){
            if(from != "Lifecycle"){
              outgoingPosCashRequest = result.requestData![i].posId;
              isOutGoingRequest = true;


              Map outGoingRequestData = {
                "user_id": result.requestData![i].toId,
                "latitude": result.requestData![i].toLat,
                "longitude": result.requestData![i].toLong,
                "address": result.requestData![i].toAddress,
                "distance": result.requestData![i].distance,
                "firstname": result.requestData![i].toFirstName,
                "lastname": result.requestData![i].toLastName,
                "mobile": result.requestData![i].toMobile,
                "avatar": result.requestData![i].toAvatar
              };
              result.requestData![i].amount;
              String elapsedTime = result.requestData![i].elapsedTime;
              LocationData outgoingLocationData = LocationData.fromJson(outGoingRequestData);
              _navigator.currentState!.push(MaterialPageRoute(
                  builder: (context) => PosCashWithdrawal(requestAmount: result.requestData![i].amount, elapsedTime: elapsedTime, outGoingRequestId: outgoingPosCashRequest, outgoingLocationData: outgoingLocationData,),
                  fullscreenDialog: true));



              break;
            }

          }
          else if ( result.requestData![i].state == 'accept'){
            incomingPosCashRequest = result.requestData![i].posId;
            isAccetedRequest = true;
            break;
          }
        }
        bool hasIncomingRequest = Globals.incoming_request;
        print("Opened Incoming Request: ${hasIncomingRequest}");
        if(isNewIncomingRequest && !hasIncomingRequest){
          isIncomingRequestScreenOpen = true;
          print("Navigate to pos cash request: isNewIncomingRequest");
          _navigator.currentState!.push(MaterialPageRoute(
              builder: (context) => PosCashRequest(posId: incomingPosCashRequest, fromNotification: false),
              fullscreenDialog: true));

        }

        else if (isAccetedRequest && !hasIncomingRequest){
          isIncomingRequestScreenOpen = true;
          print("Navigate to pos cash request: isAccetedRequest");
          _navigator.currentState!.push(MaterialPageRoute(
              builder: (context) => PosCashRequest(posId: incomingPosCashRequest, fromNotification: false, isAccepted : true,),
              fullscreenDialog: true));
        }
        else{
        }


      }
      else{
      }

    }catch(error){
      _navigator.currentContext?.loaderOverlay.hide();
      print("Error while load request data: ${error.toString()}");
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    super.didChangeAppLifecycleState(state);
    Globals.isInForeground = state == AppLifecycleState.resumed;
    print("AppLifeCycle: ${state}");
    await PreferencesManager.init();
    if(state == AppLifecycleState.detached){
      Globals.incoming_request = false;
      print("Clear Config Values");
      return;
    }

    bool hasIncomingRequest = Globals.incoming_request;
    print("App is in request screen: ${hasIncomingRequest}");
    if(state == AppLifecycleState.resumed && !hasIncomingRequest) {
      if(hasIncomingRequest == false) {
        _getIncomingRequestData(from: "Lifecycle");
      }
    }

  }

  @override
  void dispose() {
    timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (networkConnection != null) {
      networkConnection!.cancel();
    }
    Globals.incoming_request = false;
    print("Clear Config Values");
    super.dispose();
  }

  handleTimeout() async {
    try {
      await PreferencesManager.init();
      bool isFirstTime =
      PreferencesManager.getBool(StringMessage.firstTimeLogin);
      if (isFirstTime == false || isFirstTime == null) {
      } else {


          bool isLogin = PreferencesManager.getBool(StringMessage.isLogin);
          if (Globals.isOnline && isLogin) {

            bool hasIncomingRequest = Globals.incoming_request;
            print("Check Point 01: ${hasIncomingRequest} - ${isFromNotification}");
            if(isFromNotification && !hasIncomingRequest){
              _navigator.currentState!.pushReplacement(MaterialPageRoute(
                  builder: (context) => PosCashRequest(posId: incomingPosCashRequest, fromNotification: true),
                  fullscreenDialog: true));

            }
            else{

              _navigator.currentState!.pushReplacementNamed('/home');
              if(!hasIncomingRequest){
                await _getIncomingRequestData(from: "App Starting");
              }
            }
            return true;
          }


      }
    } catch (e) {
      print(e);
    }
    PreferencesManager.setBool(StringMessage.isLogin, false);
    setState(() {
      screenView = SplashScreen();
    });
  }

  getPendingRequest() async {
    int count = 0;
    try {
      PendingRequestApi _requestApi = new PendingRequestApi();
      PendingRequestModel result =
      await _requestApi.search().timeout(Duration(seconds: 2));
      if (result.status == "true") {
        if (result.pendingRequestList.isNotEmpty) {
          var pendingRequest = result.pendingRequestList;
          int userid = CommonUtils.getUserid();
          count = pendingRequest
              .where((element) => element.fromuser_id != userid)
              .length;
        }
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      Globals.unreadPending = count;
    });
  }

  getCurWalletBalance() async {

    double balance = 0;
    try {
      if (Globals.isOnline) {
        WalletApi _walletApi = new WalletApi();
        WalletModel result = await _walletApi.search(context);
        if (result != null && result.status == "true") {
          balance = double.parse(result.balance);
        }
      }
    } catch (e) {}
    setState(() {
      Globals.walletbalance = balance;
    });
  }
}