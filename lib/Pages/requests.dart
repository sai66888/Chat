import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Pages/mobile_number_file.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:upaychat/Apis/usercheckapi.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Models/loginmodel.dart';
import 'package:upaychat/Pages/add_bank_file.dart';
import 'package:upaychat/Pages/add_card_file.dart';
import 'package:upaychat/Pages/airtime_data_file.dart';
import 'package:upaychat/Pages/bank_list_file.dart';
import 'package:upaychat/Pages/buy_electricity_file.dart';
import 'package:upaychat/Pages/change_password_file.dart';
import 'package:upaychat/Pages/chart_tawk_file.dart';
import 'package:upaychat/Pages/contact_us_file.dart';
import 'package:upaychat/Pages/deposit_file.dart';
import 'package:upaychat/Pages/edit_profile.dart';
import 'package:upaychat/Pages/faq_file.dart';
import 'package:upaychat/Pages/forgot_password.dart';
import 'package:upaychat/Pages/home_file.dart';
import 'package:upaychat/Pages/identity_verification_file.dart';
import 'package:upaychat/Pages/login_file.dart';
import 'package:upaychat/Pages/my_cards_file.dart';
import 'package:upaychat/Pages/notification_page.dart';
import 'package:upaychat/Pages/offline_file.dart';
import 'package:upaychat/Pages/password_update_file.dart';
import 'package:upaychat/Pages/pay_bills_file.dart';
import 'package:upaychat/Pages/pending_file.dart';
import 'package:upaychat/Pages/pick_contact_file.dart';
import 'package:upaychat/Pages/register_file.dart';
import 'package:upaychat/Pages/search_people_file.dart';
import 'package:upaychat/Pages/setting_file.dart';
import 'package:upaychat/Pages/splash_screen.dart';
import 'package:upaychat/Pages/transaction_detail_file.dart';
import 'package:upaychat/Pages/transaction_file.dart';
import 'package:upaychat/Pages/virtual_card_detail_file.dart';
import 'package:upaychat/Pages/virtual_card_details_file.dart';
import 'package:upaychat/Pages/withdraw_file.dart';
import 'package:http/http.dart' as http;
import 'package:upaychat/Pages/add_new_virtual_card_file.dart';
import 'package:upaychat/Pages/pos_cash_withdrawal.dart';
import 'package:upaychat/Pages/requests.dart';

import '../Apis/createvirtualcardapi.dart';
import '../CommonUtils/common_utils.dart';
import '../Models/commonmodel.dart';
import '../Pages/add_money_to_virtual_card.dart';
import '../Pages/electricity_receipt_file.dart';
import '../Pages/notification_settings_file.dart';
import '../globals.dart';

import 'package:flutter/material.dart';

import 'material_design_indicator.dart';
import 'package:upaychat/Apis/poscashrequestapi.dart';
import 'package:upaychat/Models/requestmodel.dart';
import 'package:upaychat/Pages/pos_cash_request.dart';

class Requests extends StatefulWidget {
  const Requests({Key? key});

  @override
  RequestsState createState() => RequestsState();
}

class RequestsState extends State<Requests> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late bool state = false;
  late String myId;

  PosCashRequestApi posCashRequestApi = PosCashRequestApi();

  List<RequestData>? posRequestDataList = [];
  List<RequestData>? posAcceptDataList = [];

  final _tabs = [
    const Tab(text: 'Pending'),
    const Tab(text: 'Cashout Request'),
    const Tab(text: 'Accepted Cashout'),
  ];

  _getRequestData() async {
    try{
      context.loaderOverlay.show();
      RequestModel result = await posCashRequestApi.getPosRequestDatas();
      if(result.requestData != null) {
        List<RequestData>? tempPosRequestDataList = [];
        List<RequestData>? tempPosAcceptDataList = [];

        result.requestData?.map((res) async {
          if(res.state == 'request' && res.frId != myId) {
            setState(() => tempPosRequestDataList.add(res));
          } else if(res.state == 'accept'){
            setState(() => tempPosAcceptDataList.add(res));
          }
        }).toList();

        setState(() {
          posRequestDataList = tempPosRequestDataList;
          posAcceptDataList = tempPosAcceptDataList;
          state = true;
        });
      }
      context.loaderOverlay.hide();
    }catch(error){
      print("Error while load request data: ${error.toString()}");
      context.loaderOverlay.hide();
    }
  }

  @override
  void initState() {
    myId = PreferencesManager.getInt(StringMessage.id).toString();
    _tabController = TabController(length: 3, vsync: this);
    _getRequestData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }


  @override
  Widget build(BuildContext context) {
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
                'Pending',
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
        child: Padding(

          padding: const EdgeInsets.all(15.0),
          child: Column(
              children: [
                /// Custom Tabbar with solid selected bg and transparent tabbar bg
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(width: 2, color: Colors.grey.shade200,),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white),
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.black,
                    tabs: _tabs,
                  ),
                ),

                state ? Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      PendingFile(),
                      // first tab bar view widget
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20,bottom: 20
                        ),
                        child: ListView(
                          children: posRequestDataList!.map((element) =>
                              _renderRequestListItem(element)
                          ).toList(),
                        ),
                      ),

                      // second tab bar view widget
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20,bottom: 20
                        ),
                        child: ListView(
                          children: posAcceptDataList!.map((element) =>
                              _renderRequestListItem(element)
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                ) : Container(),
              ]
          ),
        ),
      ),
    );
  }

  Widget _renderRequestListItem(RequestData item){
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => PosCashRequest(posId: item.posId),
                fullscreenDialog: true)).then((value) {
          _getRequestData();
        });
      },
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: item.frId == myId ? MyColors.base_green_color : Colors.black12,
            ),
            borderRadius: BorderRadius.circular(5)
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: Image.network(
                item.frAvatar,
                width: 60,
                height: 60,
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(children: [
                  Row(children: [
                    Text(
                      item.frUsername,
                      style: const TextStyle(
                        fontFamily: 'Doomsday',
                        height: 1.3,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],),

                  Row(children: [ Text(
                    StringMessage.naira + item.amount,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      height: 1.5,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.left,
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ],),

                  Row(children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.only(right: 13.0),
                        child: Text(
                          item.frAddress,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13.0,
                              fontFamily: 'Doomsday',
                              color: Colors.grey,
                              height: 1.2
                          ),
                        ),
                      ),
                    )
                  ],),
                ],),
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
