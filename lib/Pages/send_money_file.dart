import 'package:dotted_line/dotted_line.dart';
import 'package:eventhandler/eventhandler.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Apis/payapi.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/custom_ui_widgets.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Events/balanceevent.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/globals.dart';

class SendMoneyFile extends StatefulWidget {
  final int? userId;
  final String? username;
  final String? from;
  final String? bankAccount;
  final String? bankCode;

  const SendMoneyFile({Key? key, this.userId, this.username, this.from, this.bankAccount, this.bankCode}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SendMoneyFileState();
  }
}

class SendMoneyFileState extends State<SendMoneyFile> {
  bool isGeneratingCode = false;
  bool isPrivacyPublic = true;
  bool isPrivacyPrivate = false;
  BankTransferFeeData? feeData;
  TextEditingController amountController = TextEditingController(),
      descriptionController = TextEditingController();

  @override
  void initState() {
    if (PreferencesManager.getString(StringMessage.defaultprivacy) ==
        "public") {
      isPrivacyPublic = true;
      isPrivacyPrivate = false;
    } else {
      isPrivacyPublic = false;
      isPrivacyPrivate = true;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: MyColors.base_green_color_20,
        child: Column(
          children: [
            CustomUiWidgets.payrequestscreenHeader(context),
            Expanded(
              child: _body(context),
            ),
          ],
        ),
      ),
    );
  }

  _body(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: MyColors.light_grey_divider_color,
            height: 2,
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: 8, right: 3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.username ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Doomsday',
                      color: MyColors.base_green_color,
                      fontSize: 20,
                    ),
                  ),


                ),
                Row(
                  children: [
                    Text(
                      StringMessage.naira,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 4),
                      width: 110,
                      child: TextField(
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          fontSize: 20,
                        ),
                        controller: amountController,
                        keyboardType: TextInputType.number,

                        onChanged: (text) {
                          if (text.isNotEmpty) {
                            text = text.replaceAll(RegExp(r'[^0-9.]'), '');
                            String prev = text;
                            text = text.replaceAll(',', '');
                            text = text.replaceAll('.', '');
                            if (text.length >= 9) text = text.substring(0, 8);
                            double value = int.parse(text).toDouble() /100;


                            text = CommonUtils.toCurrency(value);
                            if (prev != text) {
                              amountController.text = text;
                              amountController.selection =
                                  TextSelection.collapsed(offset: text.length);
                            }
                            if(widget.from == "bank"){

                              getBankTransferFee(value.toString());
                            }
                            else{

                            }
                          }



                        },
                        inputFormatters: [amountValidator!],
                        cursorColor: MyColors.base_green_color,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: widget.from == "bank" ? "0" :  "0.00",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: MyColors.light_grey_divider_color,
            height: 2,
          ),
          SizedBox(height: 5),
          Container(
            color: MyColors.light_grey_divider_color,
            height: 2,
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 3, right: 3),
              child: TextFormField(
                cursorColor: MyColors.base_green_color,
                style: TextStyle(
                  fontFamily: 'Doomsday',
                  fontSize: 18,
                ),
                inputFormatters: [
                  new LengthLimitingTextInputFormatter(160),
                ],
                keyboardType: TextInputType.multiline,
                controller: descriptionController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: ' What is it for?',
                ),
              ),
            ),
          ),
          Container(
            color: MyColors.light_grey_divider_color,
            height: 2,
          ),
          Container(
            height: 115,
            child: Column(
              children: [
                Container(
                  height: 20,
                  color: MyColors.base_green_color_20,
                  alignment: Alignment.centerRight,
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.end,
                    // mainAxisAlignment: MainAxisAlignment.end,

                    children: [

                      Expanded(
                        child: feeData != null ? Text(
                          widget.from == "bank" ? "Transfer fee is ${feeData!.fee!.toString() }" : '',
                          style: TextStyle(
                              fontFamily: 'Doomsday',
                              color: MyColors.grey_color,
                              fontSize: 18
                          ),
                        ) :
                        Text(
                          widget.from == "bank" ? "Calculating transfer fee....." : '',
                          style: TextStyle(
                              fontFamily: 'Doomsday',
                              color: MyColors.grey_color,
                              fontSize: 18
                          ),
                        ) ,),
                      Icon(
                        Entypo.globe,
                        size: 10,
                        color: MyColors.base_green_color,
                      ),
                      SizedBox(width: 2),
                      Text(
                        PreferencesManager.getString(
                            StringMessage.defaultprivacy),
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          color: MyColors.grey_color,
                        ),
                      ),
                      SizedBox(width: 4),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: MyColors.base_green_color,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      primary: MyColors.base_green_color,
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (amountController.text.isEmpty ||
                          amountController.text == '0.00') {
                        CommonUtils.errorToast(
                            context, StringMessage.enter_amount);
                      } else if (descriptionController.text.isEmpty) {
                        CommonUtils.errorToast(context, 'What is it for?');
                      } else if (double.parse(
                              amountController.text.replaceAll(',', '')) >
                          Globals.walletbalance) {
                        CommonUtils.errorToast(
                            context, "Insufficient balance in wallet");
                        String allowed = await CommonUtils.isIdAllowed();
                        if (allowed == "true") {
                          Navigator.of(context).pushNamed('/deposit');
                        }
                      } else {
                        _openPrivacyDialogBox();
                      }
                    },
                    child: Text(
                      'Send',
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openPrivacyDialogBox() {
    String text = amountController.text;
    text = text.replaceAll(',', '');
    // text = text.replaceAll('.', '');
    if(double.parse(text) < 100.00){
      CommonUtils.errorToast(context, "Minimum transfer amount is NGN 100.00");
    }
    else{
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
                              onPressed: processPayment,
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

  }

  void processPayment() {

       if (isPrivacyPrivate) {
        _callApiForPay("private");
      } else {
        _callApiForPay("public");
      }

  }

  void _callApiForPay(String privacy) async {
    if (Globals.isOnline) {
      // Navigator.pop(context);
      try {
        context.loaderOverlay.show();
        PayApiRequest _payApi = new PayApiRequest();
        String username = widget.username ?? '';
        if (widget.userId == -1 &&
            username.startsWith("0") &&
            CommonUtils.validateMobile(username))
          username = username.replaceFirst("0", "+234");
        CommonModel? result ;

        if(widget.from == 'bank'){
          PayBankApiRequest _payApi = new PayBankApiRequest();
          result = await _payApi.search(
            widget.username ?? '',
              amountController.text.replaceAll(',', ''),
              privacy,
              descriptionController.text,
              widget.bankCode ?? '',
              widget.bankAccount ?? '' , feeData!.fee ?? 0.00);
        }
        else{
          result = await _payApi.search(
              amountController.text.replaceAll(',', ''),
              privacy,
              descriptionController.text,
              widget.userId.toString(),
              username,
              'pay');
        }

        print(result);
        if (result.status == "true") {
          context.loaderOverlay.hide();
          EventHandler().send(BalanceEvent('both'));

          String msg =
              'You sent ${StringMessage.naira + CommonUtils.toCurrency(double.parse(amountController.text.replaceAll(',', '')))}\n to ${widget.username}';
          Navigator.pop(context);
          CommonUtils.successToast(context, msg);
          Navigator.pop(context);

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

  void getBankTransferFee(String amount) async{

    double requestAmount = double.parse(amount);
    int feeAmount = 0;

    if (requestAmount < 5000) {
      feeAmount = 25;
    } else if (requestAmount < 50000) {
      feeAmount = 35;
    } else {
      feeAmount = 65;
    }
  print("Check Fee");
    setState((){
      feeData = BankTransferFeeData(
        fee: feeAmount.toDouble(),
        currency: "NGN"
      );
    });

  }
}
