// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;
import 'package:eventhandler/eventhandler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/extension.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loadmore/loadmore.dart';
import 'package:upaychat/Apis/transactionapi.dart';
import 'package:upaychat/Apis/wallet_api.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/custom_images.dart';
import 'package:upaychat/CustomWidgets/location_permission_prompt.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/CustomWidgets/transaction_post.dart';
import 'package:upaychat/Events/balanceevent.dart';
import 'package:upaychat/Models/transactionmodel.dart';
import 'package:upaychat/Models/walletmodel.dart';
import 'package:upaychat/Pages/mobile_number_file.dart';
import 'package:upaychat/Pages/pos_cash_request.dart';
import 'package:upaychat/Pages/profile_image_verification.dart';
import 'package:upaychat/Pages/report_post_file.dart';
import 'package:upaychat/globals.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../Apis/locationapi.dart';
import '../Apis/updateuserkeyapi.dart';
final _databaseRef = FirebaseDatabase.instance.ref("users");
DatabaseReference presenceRef =
    FirebaseDatabase.instance.ref('.info/connected');
class HomeFile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeFileState();
  }
}
class HomeFileState extends State<HomeFile> with TickerProviderStateMixin {
  int segmentedControlValue = 0;
  bool publicPressed = true, privatePressed = false, myTransPressed = false;
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  List<TransactionData> transList = [];
  bool isLoading = false;
  bool isWalletLoading = false;
  String userid = '';
  int id = 1192;
  bool _notificationsEnabled = false;
  Position? _currentPosition;
  Map<String, bool> isFinishedForType = Map<String, bool>();
  Map<String, PagingController<int, TransactionData>> _transactionControllers =
      Map<String, PagingController<int, TransactionData>>();
  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    EventHandler().unsubscribe(_onBalanceEventCallback);
    Globals.incoming_request = false;
    print("Clear Config Values");
    super.dispose();
  }

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
      });
    });
    userid = CommonUtils.getStrUserid();
    _transactionControllers['private'] = PagingController(firstPageKey: 0);
    _transactionControllers['public'] = PagingController(firstPageKey: 0);
    _transactionControllers['mine'] = PagingController(firstPageKey: 0);
    _transactionControllers['private']?.addPageRequestListener((pageKey) {
      loadMoreTransactions('private', pageKey);
    });
    _transactionControllers['public']?.addPageRequestListener((pageKey) {
      loadMoreTransactions('public', pageKey);
    });
    _transactionControllers['mine']?.addPageRequestListener((pageKey) {
      loadMoreTransactions('mine', pageKey);
    });
    _getData();
    EventHandler().subscribe(_onBalanceEventCallback);
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      print("FirebaseMessaging Instance Get Initial Message");
      if (message != null) {
        print(message.category);
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      String messageCategory = message.data['category'].toString();
      print("Message Category: ${messageCategory}");
      if (messageCategory == 'general') {
        CommonUtils.showNotificationWithTextAction(message);
      } else if (messageCategory == "cash_request") {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                PosCashRequest(posId: message.data['pos_id'].toString()),
            fullscreenDialog: true));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['category'].toString() == "cash_request") {
        bool hasIncomingRequest = Globals.incoming_request;
        if(hasIncomingRequest == false){
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  PosCashRequest(posId: message.data['pos_id'].toString()),
              fullscreenDialog: true));
        }

      }
    });
    _isAndroidPermissionGranted();
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    presenceRef.onValue.listen((event) {
      if (event.snapshot.value == false) {
        _databaseRef
            .child('${CommonUtils.getStrUserid()}/onlineStatus')
            .set('online');
        _databaseRef
            .child('${CommonUtils.getStrUserid()}/onlineStatus')
            .onDisconnect()
            .set('offline');
      }
    });
    super.initState();
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {});
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {},
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      setState(() {
        _notificationsEnabled = granted ?? false;
      });
    }
  }

  void _onBalanceEventCallback(BalanceEvent event) {
    switch (event.mode) {
      case '':
        setState(() {});
        break;
      case 'wallet':
        _callMyWalletApi();
        break;
      case 'safelock':
        _callMyWalletApi();
        break;
      case 'trans':
        _refreshTransactionHistories();
        break;
      case 'safelock':
        _refreshTransactionHistories();
        break;
      default:
        _getData();
    }
  }
  Future<void> _getData() async {
    _getNotificationSettings();
    _callMyWalletApi();
    FirebaseMessaging.instance.getToken().then((fcmToken) {
      UpdateUserKeyApi updateuser = new UpdateUserKeyApi();
      updateuser.save('fcm_token', fcmToken!);
    });
  }

  _getNotificationSettings() {
    Globals.notification_push_money_received = PreferencesManager.getBool(
        StringMessage.notification_push_money_received);
    Globals.notification_push_money_sent =
        PreferencesManager.getBool(StringMessage.notification_push_money_sent);
    Globals.notification_push_bank_withdraw = PreferencesManager.getBool(
        StringMessage.notification_push_bank_withdraw);
    Globals.notification_push_likes =
        PreferencesManager.getBool(StringMessage.notification_push_likes);
    Globals.notification_push_comments =
        PreferencesManager.getBool(StringMessage.notification_push_comments);
    Globals.notification_sms_money_received = PreferencesManager.getBool(
        StringMessage.notification_sms_money_received);
    Globals.notification_sms_money_sent =
        PreferencesManager.getBool(StringMessage.notification_sms_money_sent);
    Globals.notification_email_money_received = PreferencesManager.getBool(
        StringMessage.notification_email_money_received);
    Globals.notification_email_money_sent =
        PreferencesManager.getBool(StringMessage.notification_email_money_sent);
    Globals.notification_email_bank_withdraw = PreferencesManager.getBool(
        StringMessage.notification_email_bank_withdraw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      resizeToAvoidBottomInset: false,
      body: Container(
        color: MyColors.base_green_color_20,
        height: double.infinity,
        width: double.infinity,
        child: SafeArea(
          child: _body(context),
        ),
      ),
      drawer: homeNavigationDrawer(context, scaffoldState),
    );
  }

  checkIdentity(Function callback) async {
    context.loaderOverlay.show();
    String allowed = await CommonUtils.isIdAllowed();
    context.loaderOverlay.hide();
    if (allowed != "true") {
      CommonUtils.errorToast(context, allowed);
      return;
    }
    if (callback != null) callback();
  }

  Container homeNavigationDrawer(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldState) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    var _phoneVerified = CommonUtils.phoneVerified();
    var avatar = StringMessage.profileimage;
    var tmpAvatar = PreferencesManager.getString(StringMessage.profileimage);
    if (tmpAvatar != null && tmpAvatar.isNotEmpty) {
      avatar = tmpAvatar;
    }
    return Container(
      width: MediaQuery.of(context).size.width * .7,
      height: double.infinity,
      color: MyColors.navigation_bg_color,
      child: Padding(
        padding: EdgeInsets.only(left: 10, top: statusBarHeight, bottom: 50),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed("/editprofile");
                      },
                      child: Stack(
                        children: [
                          Positioned(
                            child: Container(
                              margin: EdgeInsets.only(top: 15),
                              height: 80.0,
                              width: 80.0,
                              child: ClipRRect(
                                borderRadius: new BorderRadius.circular(60.0),
                                child: avatar == null
                                    ? CircleAvatar(
                                        child: Text(
                                          PreferencesManager.getString(
                                                  StringMessage.firstname)
                                              .substring(0, 2)
                                              .toUpperCase(),
                                          style: TextStyle(fontSize: 25),
                                        ),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: avatar,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            CircleAvatar(
                                          child: Text(
                                            "${PreferencesManager.getString(StringMessage.firstname)[0]}${PreferencesManager.getString(StringMessage.lastname)[0]}"
                                                .toUpperCase(),
                                            style: TextStyle(fontSize: 25),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            CircleAvatar(
                                          child: Text(
                                            "${PreferencesManager.getString(StringMessage.firstname)[0]}${PreferencesManager.getString(StringMessage.lastname)[0]}"
                                                .toUpperCase(),
                                            style: TextStyle(fontSize: 25),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: MyColors.base_green_color,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Entypo.camera,
                                color: Colors.white,
                                size: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "${PreferencesManager.getString(StringMessage.firstname)} ${PreferencesManager.getString(StringMessage.lastname)}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        color: MyColors.grey_color,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      PreferencesManager.getString(StringMessage.email),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        color: MyColors.grey_color,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left: 3, right: 3),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                            isWalletLoading
                                ? '----'
                                : StringMessage.naira +
                                    CommonUtils.toCurrency(
                                        Globals.walletbalance),
                            style: TextStyle(
                              color: MyColors.grey_color,
                              fontSize: 18,
                              decoration: _phoneVerified
                                  ? TextDecoration.none
                                  : TextDecoration.lineThrough,
                            ),
                          )),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamed('/deposit');
                            },
                            child: Text(
                              "Add money",
                              style: TextStyle(
                                fontFamily: 'Doomsday',
                                color: MyColors.base_green_color,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 8),
                height: 1,
                color: MyColors.grey_color,
              ),

              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  child: Row(
                    children: const [
                      Icon(
                        Foundation.home,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Home',
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          color: MyColors.base_green_color,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, left: 40),
                height: 1,
                color: MyColors.grey_color,
              ),


              InkWell(
                onTap: () {
                  checkIdentity(() {
                    checkPhoneAction('/send_money_menu', 'send', true);
                  });
                },
                child: Container(
                  child: Row(
                    children: const [
                      Icon(
                        AntDesign.form,
                        color: MyColors.grey_color,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Send Money',
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, left: 40),
                height: 1,
                color: MyColors.grey_color,
              ),

              InkWell(
                onTap: () {
                  checkIdentity(() {
                    checkPhoneAction('/searchpeople', 'request', true);
                  });
                },
                child: Container(
                  child: Row(
                    children: const [
                      Icon(
                        Foundation.download,
                        color: MyColors.grey_color,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Request Money',
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, left: 40),
                height: 1,
                color: MyColors.grey_color,
              ),
              InkWell(
                onTap: () async{
                  if (CommonUtils.phoneVerified()) {
                    goToCashOut();

                  }
                  else{
                    String message = "";
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MobileNumberFile(
                          isExists: false,
                          message: message,
                          onResponse: (state, _) {
                            if (state == true) {

                              goToCashOut();





                            }
                          },
                        ),
                      ),
                    );
                  }


                },
                child: Container(
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        child: SvgPicture.asset(
                          cashIconName,
                        ),
                      ),

                      SizedBox(width: 10),
                      badges.Badge(
                        position: badges.BadgePosition.topEnd(top: -13, end: -30),
                        badgeContent: Text('New', style: TextStyle(color: Colors.white),),
                        badgeStyle:  badges.BadgeStyle(
                            shape: badges.BadgeShape.square,
                            borderRadius: BorderRadius.circular(5),
                            padding: EdgeInsets.all(2)
                        ),
                        child: Text(
                          'Withdraw Cash',
                          style: TextStyle(
                            fontFamily: 'Doomsday',
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, left: 40),
                height: 1,
                color: MyColors.grey_color,
              ),
              InkWell(
                onTap: () {
                  checkIdentity(() {
                    checkPhoneAction("/mycards", '', true);
                  });
                },
                child: Container(
                  child: Row(
                    children: const [
                      Icon(
                        Foundation.credit_card,
                        color: MyColors.grey_color,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Cards',
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, left: 40),
                height: 1,
                color: MyColors.grey_color,
              ),
              InkWell(
                onTap: () {
                  checkIdentity(() {
                    checkPhoneAction("/safelock", '', true);
                  });
                },
                child: Container(
                  child: Row(
                    children: const [
                      Icon(
                        MaterialCommunityIcons.cash_lock,
                        color: MyColors.grey_color,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'SafeLock',
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, left: 40),
                height: 1,
                color: MyColors.grey_color,
              ),
              InkWell(
                onTap: () {
                  checkIdentity(() {
                    checkPhoneAction('/airtime_data', '', true);
                  });
                },
                child: Container(
                  child: Row(
                    children: const [
                      Icon(
                        AntDesign.mobile1,
                        color: MyColors.grey_color,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Airtime & Data',
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, left: 40),
                height: 1,
                color: MyColors.grey_color,
              ),

              InkWell(
                onTap: () {
                  checkIdentity(() {
                    checkPhoneAction('/pay_bills', '', true);
                  });
                },
                child: Container(
                  child: Row(
                    children: const [
                      Icon(
                        FontAwesome.money,
                        color: MyColors.grey_color,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Pay Bills',
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, left: 40),
                height: 1,
                color: MyColors.grey_color,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed("/transaction");
                },
                child: Container(
                  child: Row(
                    children: const [
                      Icon(
                        FontAwesome.history,
                        color: MyColors.grey_color,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Transaction History',
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, left: 40),
                height: 1,
                color: MyColors.grey_color,
              ),

              InkWell(
                onTap: () {
                  checkIdentity(() {
                    checkPhoneAction('/pending', '', true);
                  });

                },
                child: Container(
                  child: Row(
                    children: [
                      Icon(
                        MaterialIcons.pending_actions,
                        color: MyColors.grey_color,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Pending',
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      if (Globals.unreadPending > 0)
                        Container(
                          width: 18,
                          height: 18,
                          padding: EdgeInsets.all(2.0),
                          margin: EdgeInsets.only(left: 0, bottom: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.red[900],
                          ),
                          child: Text(
                            Globals.unreadPending.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, left: 40),
                height: 1,
                color: MyColors.grey_color,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed("/refer_earn");
                },
                child: Container(
                  child: Row(
                    children: [
                      Icon(
                        Entypo.megaphone,
                        color: MyColors.grey_color,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Refer & Earn',
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      if (Globals.unreadMsgCount > 0)
                        Container(
                          width: 18,
                          height: 18,
                          padding: EdgeInsets.all(2.0),
                          margin: EdgeInsets.only(left: 0, bottom: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.red[900],
                          ),
                          child: Text(
                            Globals.unreadMsgCount.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, left: 40),
                height: 1,
                color: MyColors.grey_color,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed("/setting");
                },
                child: Container(
                  child: Row(
                    children: [
                      Icon(
                        MaterialCommunityIcons.cog_sync_outline,
                        color: MyColors.grey_color,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Settings & Help',
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      if (Globals.unreadMsgCount > 0)
                        Container(
                          width: 18,
                          height: 18,
                          padding: EdgeInsets.all(2.0),
                          margin: EdgeInsets.only(left: 0, bottom: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.red[900],
                          ),
                          child: Text(
                            Globals.unreadMsgCount.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, left: 40),
                height: 1,
                color: MyColors.grey_color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  getData(type) {
    //type=> 0:public, 1: private, 2: mine
    if (type == 0) {
      return transList.where((element) => element.privacy == "public").toList();
    } else if (type == 1) {
      return transList
          .where((element) => element.privacy == "private")
          .toList();
    } else if (type == 2) {
      return transList.where((element) => element.mine).toList();
    }
    return [];
  }

  Future<void> _refreshTransactionHistories() async {
    if (_tabController.index == 0)
      _transactionControllers['public']?.refresh();
    else if (_tabController.index == 1) _transactionControllers['private']?.refresh();
    else if (_tabController.index == 2) _transactionControllers['mine']?.refresh();
  }

  _body(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _createHeader(context),
          Container(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: TabBar(indicatorColor: Colors.transparent, labelPadding: EdgeInsets.symmetric(horizontal: 0.0), controller: _tabController, tabs: [

              Tab(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(right: 2),
                  padding: EdgeInsets.only(top: 2, bottom: 2),
                  decoration: BoxDecoration(
                    color: _tabController.index == 0
                        ? MyColors.base_green_color
                        : Colors.white,
                    border: Border.all(color: MyColors.base_green_color),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Icon(
                    Entypo.globe,
                    color: _tabController.index == 0
                        ? Colors.white
                        : MyColors.base_green_color,
                    size: 25,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(right: 2),
                padding: EdgeInsets.only(top: 2, bottom: 2),
                decoration: BoxDecoration(
                  color: _tabController.index == 1
                      ? MyColors.base_green_color
                      : Colors.white,
                  border: Border.all(color: MyColors.base_green_color),
                ),
                child: Icon(
                  Feather.user,
                  color: _tabController.index == 1
                      ? Colors.white
                      : MyColors.base_green_color,
                  size: 25,
                ),
              ),
              Container(
                width:double.infinity,
                padding: EdgeInsets.only(top: 2, bottom: 2),
                decoration: BoxDecoration(
                  color: _tabController.index == 2
                      ? MyColors.base_green_color
                      : Colors.white,
                  border: Border.all(color: MyColors.base_green_color),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Image.asset(
                  CustomImages.green_naira_note,
                  color: _tabController.index == 2 ? Colors.white : null,
                  height: 25,
                  width: 25,
                ),
              ),
            ]),
          ),
          isLoading
              ? CommonUtils.progressDialogBox()
              : Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      transactionHistory('public'),
                      transactionHistory('private'),
                      transactionHistory('mine')
                    ],
                  ),
                )
        ],
      ),
    );
  }

  _createHeader(BuildContext context) {
    var _phoneVerified = CommonUtils.phoneVerified();
    return Container(
      color: MyColors.base_green_color,
      padding: EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: EdgeInsets.only(top: 15, bottom: 15),
              primary: MyColors.base_green_color,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: MyColors.base_green_color),
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            onPressed: () {
              scaffoldState.currentState!.openDrawer();
            },
            child: badges.Badge(
              showBadge: (Globals.unreadMsgCount + Globals.unreadPending) > 0,
              badgeContent: Text(
                (Globals.unreadMsgCount + Globals.unreadPending).toString(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              child: Icon(
                Feather.menu,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    checkPhoneAction(null, '', false);
                  },
                  child: Column(
                    children: [
                      Text(
                        _phoneVerified
                            ? 'Available Balance'
                            : 'Balance not available\n(Verify your phone)',
                        style: TextStyle(
                          color:
                              _phoneVerified ? Colors.white : Colors.grey[200],
                          fontFamily: 'Doomsday',
                        ),
                      ),
                      Text(
                        StringMessage.naira +
                            CommonUtils.toCurrency(Globals.walletbalance),
                        style: TextStyle(
                          color:
                              _phoneVerified ? Colors.white : Colors.grey[350],
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          decoration: _phoneVerified
                              ? TextDecoration.none
                              : TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/deposit');
                },
                icon: Image.asset(
                  CustomImages.white_deposit,
                  height: 25,
                ),
              ),
              IconButton(
                onPressed: () {
                  checkIdentity(() {
                    checkPhoneAction('/send_money_menu', 'send', false);
                  });
                },
                icon: Image.asset(
                  CustomImages.white_pencil_naira,
                  height: 25,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
  void _callMyWalletApi() async {
    if (Globals.isOnline && mounted) {
      try {

        WalletApi _walletApi = new WalletApi();
        WalletModel result = await _walletApi.search(context);
        if (result != null && result.status == "true" && mounted) {
          setState(() {
            Globals.walletbalance = double.parse(result.balance);
          });
          PreferencesManager.setString(
              StringMessage.paystackPubKey, result.paystackPubKey);
          PreferencesManager.setString(
              StringMessage.paystackSecKey, result.paystackSecKey);
          PreferencesManager.setString(
              StringMessage.flutterwavePubKey, result.flutterwavePubKey);
          PreferencesManager.setString(
              StringMessage.flutterwaveSecKey, result.flutterwaveSecKey);

          PreferencesManager.setString(
              StringMessage.quickMerchantID, result.quickMerchantID);

          PreferencesManager.setString(
              StringMessage.quickMerchantCode, result.quickMerchantCode);

          PreferencesManager.setString(
              StringMessage.quickMerchantSecret, result.quickMerchantSecret);
        }

      } catch (e) {
        print("CallMyWallet Error:${e.toString()}");
        CommonUtils.errorToast(context, e.toString());

      }
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }

  void processPayment(String? page, String? arguments, bool? isPop) {
    if (isPop ?? false) {
      Navigator.pop(context);
    }
    Navigator.of(context).pushNamed(page ?? '', arguments: arguments);
  }

  void checkPhoneAction(String? page, String? arguments, bool? isPop) async {
    if (CommonUtils.phoneVerified()) {
      processPayment(page, arguments, isPop);
      return;
    }
    String message = "";

    if (arguments == "send") {
      message = StringMessage.send_msg;
    } else if (arguments == "request") {
      message = StringMessage.request_msg;
    } else if (page == "/pending") {
      message = StringMessage.pending_msg;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobileNumberFile(
          isExists: false,
          message: message,
          onResponse: (state, _) {
            if (state == true) {
              if (page == null) {
              } else {
                processPayment(page, arguments, isPop);
              }
            }
          },
        ),
      ),
    );
  }

  Widget transactionHistory(String feedType) {
    return RefreshIndicator(child: PagedListView<int, TransactionData>(
      pagingController: _transactionControllers[feedType]!,
      builderDelegate: PagedChildBuilderDelegate<TransactionData>(
        itemBuilder: (context, item, index) =>
            feedType == 'mine' ? _builderMyTransactionItem(context, item, index) : _buildTransactionItem(context, item, index),
        firstPageProgressIndicatorBuilder: (context){
          return Container(
            height: 65,
            width: 65,
            child: SpinKitChasingDots(
              color: MyColors.base_green_color,
              size: 50.0,
            ),
          );
        }
      ),

    ), onRefresh: _refreshTransactionHistories);
  }
  _builderMyTransactionItem(context, TransactionData transItem, index) {
    return Container(
      margin: EdgeInsets.fromLTRB(12, 5, 12, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  transItem.username,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              Text(
                (transItem.from_id != userid ||
                    transItem.username == 'Deposit' ||
                    transItem.username ==
                        'SafeLock Release'
                    ? '+'
                    : '-') +
                    transItem.amount,
                style: TextStyle(
                  fontSize: 16,
                  color: transItem.from_id != userid ||
                      transItem.username == 'Deposit' ||
                      transItem.username ==
                          'SafeLock Release'
                      ? MyColors.base_green_color
                      : Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            CommonUtils.formattedTime(transItem.timestamp),
            style: TextStyle(
              fontFamily: 'Doomsday',
              color: MyColors.grey_color,
            ),
          ),
        ],
      ),
    );
  }
  _buildTransactionItem(context, TransactionData transItem, index) {
    return Container(
      margin: EdgeInsets.fromLTRB(2, 5, 2, 5),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(top: 15),
            height: 55.0,
            width: 55.0,
            child: ClipRRect(
              borderRadius: new BorderRadius.circular(60.0),
              child: transItem.to_userimage != ""
                  ? CachedNetworkImage(
                      imageUrl: transItem.to_userimage,
                      placeholder: (context, url) => CircleAvatar(
                        child: Text(
                          (transItem.username != ''
                                  ? transItem.username
                                  : transItem.username + transItem.username)
                              .substring(0, 2)
                              .toUpperCase(),
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                      errorWidget: (context, error, stackTrace) => Image.asset(
                        CustomImages.default_profile_pic,
                        fit: BoxFit.cover,
                      ),
                    )
                  : CircleAvatar(
                      child: Text(
                        (transItem.username != ''
                                ? transItem.username
                                : transItem.username + transItem.username)
                            .substring(0, 2)
                            .toUpperCase(),
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transItem.message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        CommonUtils.timesAgoFeature(transItem.timestamp),
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          color: MyColors.grey_color,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      transItem.privacy == 'public'
                          ? Icon(
                              Entypo.globe,
                              color: MyColors.grey_color,
                              size: 12,
                            )
                          : Icon(
                              SimpleLineIcons.lock,
                              color: MyColors.base_green_color,
                              size: 12,
                            ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        transItem.caption,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              builder: (BuildContext _context) {
                                return SafeArea(child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  padding: const EdgeInsets.only(
                                      left: 12.0, top: 10, bottom: 10),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(_context).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ReportPostScreen(
                                                    isPost: true,
                                                    dataID: transItem.id,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.flag,
                                              size: 20,
                                            ),
                                            Text(
                                              "Report this post",
                                              style: TextStyle(fontSize: 18),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ));
                              });
                        },
                        child: Icon(Icons.more_horiz),
                      )
                    ],
                  ),
                  SizedBox(height: 5),
                  TransactionPost(transItem, _refreshTransactionHistories),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String loadMoreText(LoadMoreStatus status) {
    return "";
  }

  Future<bool> loadMoreTransactions(String feedType, int lastId) async {
    print("onLoadMore");
    try {
      TransactionApi _transApi = new TransactionApi();
      TransactionModel result =
          await _transApi.search(context, type: feedType, lastItemId: lastId);
      if (result != null && result.status == "true") {
        List<TransactionData> newItems = result.transactionData ?? [];
        if (newItems.length < 20) {
          _transactionControllers[feedType]
              ?.appendLastPage(result.transactionData ?? []);
        } else {
          _transactionControllers[feedType]?.appendPage(
              result.transactionData ?? [], newItems[newItems.length - 1].id);
        }
      }
    } catch (e) {

      CommonUtils.errorToast(context, e.toString() ?? "Something went wrong");
      return false;
    }

    return true;
  }
  Future<void> _getCurrentPosition() async {
    _handleLocationPermission().then((hasPermission) {
      print("Check Location Permission: ${hasPermission}");
      if (!hasPermission) return;
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation)
          .then((Position position) async{
        _currentPosition = position;
        await _getAddressFromLatLng(position);
        PreferencesManager.setDouble(StringMessage.myCurrentLatitude, position.latitude);
        PreferencesManager.setDouble(StringMessage.myCurrentLongitude, position.longitude);
      }).catchError((e) {
        debugPrint(e.toString());
      });
    });

  }
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

  void goToCashOut() async{

    var avatar = PreferencesManager.getString(StringMessage.profileimage);
    if(avatar.isNullOrEmpty){
      bool result = await Navigator.push(
        context,
        // Create the SelectionScreen in the next step.
        MaterialPageRoute(builder: (context) =>  ProfileImageVerification()),
      );
      print("Result from profile image: $result");
      if(result == false){
        return;
      }
    }
    avatar = PreferencesManager.getString(StringMessage.profileimage);
    if (avatar.isNotNullAndNotEmpty) {
      checkIdentity(() async{
        try{
          await _getCurrentPosition();
          String currentActiveRequest = PreferencesManager.getString(
              StringMessage.active_request);
          if (currentActiveRequest != "") {
            print("CHeckpoint 12");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      PosCashRequest(posId: currentActiveRequest),
                  fullscreenDialog: true));
            });
          } else {
            checkPhoneAction('/pos_cash_withdrawal', 'request', true);
          }
        }
        catch(error){
          CommonUtils.errorToast(context, "Error while get current location");
        }

      });
    }
    else{
      // CommonUtils.errorToast(context, "Before you can withdraw cash, we need a photo of your face.");
      // Navigator.of(context).pushNamed("/profile_image_verification");

    }
  }

}
