import 'package:dotted_line/dotted_line.dart';
import 'package:eventhandler/eventhandler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Apis/cancelrequestapi.dart';
import 'package:upaychat/Apis/getflutterwavebillingstatusapi.dart';
import 'package:upaychat/Apis/pendingrequestapi.dart';
import 'package:upaychat/Apis/requestpayapi.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/custom_images.dart';
import 'package:upaychat/CustomWidgets/custom_ui_widgets.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Events/balanceevent.dart';
import 'package:upaychat/Models/addmoneytowalletmodel.dart';
import 'package:upaychat/Models/pendingrequestmodel.dart';
import 'package:upaychat/globals.dart';

import '../Models/flutterwavebillingstatusmodel.dart';

class PendingFile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PendingFileState();
  }
}

class PendingFileState extends State<PendingFile> {
  List<PendingRequestData> pendingRequest = [];
  bool isLoaded = false;
  bool isData = false;
  int? userId;
  bool isPrivacyPublic = true;
  bool isPrivacyPrivate = false;
  int currentPage = 1;
  FlutterwaveBillingStatusModel? statusModel;
  @override
  void initState() {
    userId = CommonUtils.getUserid();
    _callApiForPendingFile();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        color: MyColors.base_green_color_20,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: isLoaded
            ? isData
                ? currentPage == 1 ? ListView.builder(
                    itemCount: pendingRequest.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Visibility(visible: pendingRequest[index]
                                .transaction_type != 'bills', child:  Container(
                              margin: EdgeInsets.only(top: 15),
                              height: 55.0,
                              width: 55.0,
                              child: ClipRRect(
                                borderRadius: new BorderRadius.circular(60.0),
                                child: Image.network(
                                  Globals.base_url +
                                      pendingRequest[index].to_userimage,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child,
                                      loadingProgress) =>
                                  (loadingProgress == null)
                                      ? child
                                      : Center(
                                      child:
                                      CircularProgressIndicator()),
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                        CustomImages.default_profile_pic,
                                        fit: BoxFit.cover,
                                      ),
                                ),
                              ),
                            ),),

                            Expanded(
                              child: Card(
                                elevation: 2,
                                color: Colors.white,
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: 5, bottom: 5, left: 2, right: 2),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.topLeft,
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                pendingRequest[index].message,
                                                style: TextStyle(
                                                  fontFamily: 'Doomsday',
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 3),
                                              Text(
                                                pendingRequest[index].caption,
                                                style: TextStyle(
                                                  fontFamily: 'Doomsday',
                                                  fontSize: 16,
                                                  color: MyColors.grey_color,
                                                ),
                                              ),
                                              SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      CommonUtils
                                                          .timesAgoFeature(
                                                              pendingRequest[
                                                                      index]
                                                                  .timestamp),
                                                      style: TextStyle(
                                                        fontFamily: 'Doomsday',
                                                        color:
                                                            MyColors.grey_color,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    StringMessage.naira +
                                                        CommonUtils.toCurrency(
                                                            double.parse(
                                                                pendingRequest[
                                                                        index]
                                                                    .amount)),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  if (pendingRequest[index]
                                                              .status ==
                                                          0 ||
                                                      pendingRequest[index]
                                                              .status ==
                                                          4)
                                                    Expanded(
                                                      child: Container(
                                                        width: double.infinity,
                                                        margin: EdgeInsets.only(
                                                            left: 4, right: 4),
                                                        child: TextButton(
                                                          style: ButtonStyle(
                                                            // textColor: Colors.white,
                                                            // highlightColor: MyColors.base_green_color_20,
                                                            padding: MaterialStateProperty.all<
                                                                    EdgeInsets>(
                                                                EdgeInsets.only(
                                                                    top: 4,
                                                                    bottom: 4)),
                                                            // splashColor: MyColors.base_green_color,
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all<Color>(
                                                                        MyColors
                                                                            .base_green_color_20),
                                                            // disabledColor: MyColors.base_green_color_20,
                                                            shape: MaterialStateProperty.all<
                                                                    RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                color: MyColors
                                                                    .light_grey_divider_color,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            )),
                                                          ),
                                                          onPressed: () {
                                                            if(pendingRequest[index]
                                                                .transaction_type == 'bills'){
                                                              _callGetPendingBillStatus(pendingRequest[
                                                              index].transaction_id);
                                                            }
                                                            else{
                                                              _callApiForCancel(
                                                                  pendingRequest[
                                                                  index],
                                                                  index);
                                                            }

                                                          },
                                                          child: Text(
                                                            pendingRequest[index]
                                                                .transaction_type == 'bills' ? 'Try again' :  'Cancel',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Doomsday',
                                                              fontSize: 14,
                                                              color: MyColors
                                                                  .base_green_color,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  pendingRequest[index]
                                                              .fromuser_id !=
                                                          userId
                                                      ? Expanded(
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 4,
                                                                    right: 4),
                                                            child: TextButton(
                                                              style:
                                                                  ButtonStyle(
                                                                // textColor: Colors.white,
                                                                // highlightColor: MyColors.base_green_color_20,
                                                                padding: MaterialStateProperty.all<
                                                                        EdgeInsets>(
                                                                    EdgeInsets.only(
                                                                        top: 4,
                                                                        bottom:
                                                                            4)),
                                                                // splashColor: MyColors.base_green_color_20,
                                                                backgroundColor:
                                                                    MaterialStateProperty.all<
                                                                            Color>(
                                                                        MyColors
                                                                            .base_green_color),
                                                                // disabledColor: MyColors.base_green_color,
                                                                shape: MaterialStateProperty.all<
                                                                        RoundedRectangleBorder>(
                                                                    RoundedRectangleBorder(
                                                                  side: BorderSide(
                                                                      color: MyColors
                                                                          .base_green_color),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                )),
                                                              ),
                                                              onPressed: () {
                                                                _openPrivacyDialogBox(
                                                                    pendingRequest[
                                                                        index],
                                                                    index);
                                                              },
                                                              child: Text(
                                                                'Pay',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Doomsday',
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Container()
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }) : _renderBillComplete()
                : Center(
                    child: Text(
                      'No Request Found',
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        color: MyColors.grey_color,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
            : CommonUtils.progressDialogBox(),
      ),
    );
  }

  void _callApiForPendingFile() async {
    if (Globals.isOnline) {
      try {
        PendingRequestApi _requestApi = new PendingRequestApi();
        PendingRequestModel result = await _requestApi.search();
        if (result.status == "true") {
          if (result.pendingRequestList.isNotEmpty) {
            pendingRequest = result.pendingRequestList;
            setState(() {
              isLoaded = true;
              isData = true;
            });
          } else {
            setState(() {
              isLoaded = true;
              isData = false;
            });
          }
        } else {
          CommonUtils.errorToast(context, result.message);
          Navigator.pop(context);
        }
      } catch (e) {
        print(e);
        Navigator.pop(context);
        CommonUtils.errorToast(context, e.toString());
      }
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }

  void _callApiForCancel(PendingRequestData listData, int index) async {
    if (Globals.isOnline) {
      try {
        context.loaderOverlay.show();
        CancelRequestApi _cancelRequestApi = new CancelRequestApi();
        AddMoneyToWalletModel result =
            await _cancelRequestApi.search(listData.id.toString());
        if (result.status == "true") {
          context.loaderOverlay.hide();
          CommonUtils.successToast(context, result.message);
          setState(() {
            Globals.walletbalance = double.parse(result.balance);
          });
          EventHandler().send(BalanceEvent('wallet'));

          setState(() {
            pendingRequest.removeAt(index);
          });
        } else {
          context.loaderOverlay.hide();
          CommonUtils.errorToast(context, result.message);
          _callApiForPendingFile();
        }
      } catch (e) {
        print(e);
        context.loaderOverlay.hide();
        CommonUtils.errorToast(context, e.toString());
      }
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }

  void _openPrivacyDialogBox(PendingRequestData listData, int index) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: 320,
                width: 300,
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: SizedBox.expand(
                  child: Column(
                    children: [
                      Text(
                        "Who can see this?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 25),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                isPrivacyPublic = true;
                                isPrivacyPrivate = false;
                                PreferencesManager.setString(
                                    StringMessage.defaultprivacy, 'public');
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Entypo.globe,
                                  size: 30,
                                  color: MyColors.base_green_color,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Public",
                                        style: TextStyle(
                                          fontFamily: 'Doomsday',
                                          decoration: TextDecoration.none,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        "Visible to everyone on the internet",
                                        style: TextStyle(
                                          fontFamily: 'Doomsday',
                                          decoration: TextDecoration.none,
                                          color: Colors.black45,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                isPrivacyPublic
                                    ? Icon(
                                        MaterialIcons.check,
                                        color: MyColors.base_green_color,
                                        size: 30,
                                      )
                                    : SizedBox(width: 25),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          DottedLine(
                            direction: Axis.horizontal,
                            lineLength: double.infinity,
                            lineThickness: 1.0,
                            dashLength: 4.0,
                            dashColor: Colors.black,
                            dashRadius: 0.0,
                            dashGapLength: 4.0,
                            dashGapColor: Colors.transparent,
                            dashGapRadius: 0.0,
                          ),
                          SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isPrivacyPublic = false;
                                isPrivacyPrivate = true;
                                PreferencesManager.setString(
                                    StringMessage.defaultprivacy, 'private');
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  SimpleLineIcons.lock,
                                  color: MyColors.base_green_color,
                                  size: 30,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Private",
                                        style: TextStyle(
                                          fontFamily: 'Doomsday',
                                          decoration: TextDecoration.none,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        "Visible to sender and recipient only",
                                        style: TextStyle(
                                          fontFamily: 'Doomsday',
                                          decoration: TextDecoration.none,
                                          color: Colors.black45,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                isPrivacyPrivate
                                    ? Icon(
                                        MaterialIcons.check,
                                        color: MyColors.base_green_color,
                                        size: 30,
                                      )
                                    : SizedBox(width: 25),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Expanded(child: Container()),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.fromLTRB(60, 15, 60, 15),
                          primary: MyColors.base_green_color,
                          shape: CustomUiWidgets.basicGreenButtonShape(),
                        ),
                        onPressed: () {
                          if (isPrivacyPrivate) {
                            Navigator.pop(context);
                            _callApiForPay(listData.id, index, "private");
                          } else {
                            Navigator.pop(context);
                            _callApiForPay(listData.id, index, "public");
                          }
                        },
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            fontFamily: 'Doomsday',
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  void _callApiForPay(int transactionId, int index, String privacy) async {
    if (Globals.isOnline) {
      try {
        context.loaderOverlay.show();
        RequestForPayApi _requestRequestApi = new RequestForPayApi();
        AddMoneyToWalletModel result =
            await _requestRequestApi.search(transactionId.toString(), privacy);
        if (result.status == "true") {
          context.loaderOverlay.hide();
          CommonUtils.successToast(context, result.message);
          setState(() {
            Globals.walletbalance = double.parse(result.balance);
          });
          EventHandler().send(BalanceEvent('both'));

          setState(() {
            pendingRequest.removeAt(index);
          });
        } else {
          context.loaderOverlay.hide();
          CommonUtils.errorToast(context, result.message);
          if (result.message?.toLowerCase() ==
              "insufficient balance in wallet") {
            String allowed = await CommonUtils.isIdAllowed();
            if (allowed == "true") {
              Navigator.of(context).pushNamed('/deposit');
            }
          }
        }
      } catch (e) {
        print(e);
        context.loaderOverlay.hide();
        CommonUtils.errorToast(context, e.toString());
      }
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }

  void _callGetPendingBillStatus(String  reference) async{
    context.loaderOverlay.show();
    GetFlutterWaveBillingStatusApi getFlutterWaveBillingStatusApi  = new GetFlutterWaveBillingStatusApi();
    FlutterwaveBillingStatusModel _statusModel = await getFlutterWaveBillingStatusApi.search(reference);

    if(_statusModel.status == "success"){
      setState(() {
        statusModel = _statusModel;
        currentPage = 2;
      });
    }
    else{
      CommonUtils.errorToast(context, "No response from service provider, try again later.");
    }
    context.loaderOverlay.hide();
  }
  _renderBillComplete() {
    return Column(
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
              Text(statusModel != null ? statusModel!.billingResult != null ? statusModel!.billingResult!.extra ?? '' : '' : '', style: TextStyle(
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
                  Text('₦' + double.parse(statusModel!.billingResult!.amount!).toStringAsFixed(2), style: TextStyle(
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
                  Text(statusModel!.billingResult!.transaction_date!, style: TextStyle(
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
                      fontFamily: 'Doomsday',
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
                  Text(statusModel!.billingResult!.customer_id!, style: TextStyle(
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
    );
    return Container(
      child: Column(
        children: [
          SizedBox(height: 10,),
          Container(
            child: Text("Transaction Summary",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Doomsday',
                  color: Colors.grey.shade800),),
          ),
          SizedBox(height: 10,),
          Container(
            child: Text("You have purchased power!",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Doomsday',
                  color: Colors.grey.shade800),),
          ),
          SizedBox(height: 20,),
          Container(
            child: Text("Token",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Doomsday',
                  color: Colors.grey.shade800),),
          ),
          SizedBox(height: 10,),
          Container(
            child: Text(statusModel != null ? statusModel!.billingResult != null ? statusModel!.billingResult!.extra ?? '' : '' : '',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Doomsday',
                  color: Colors.grey.shade800),),
          ),
        ],
      ),
    );
  }
}
