import 'dart:convert';

import 'package:eventhandler/eventhandler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/custom_ui_widgets.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Events/balanceevent.dart';
import 'package:upaychat/globals.dart';

import '../Apis/addmoneytovirtualcardapi.dart';
import '../Apis/getexchangerateapi.dart';
import '../Models/addmoneytovirtualcardmodel.dart';

class AddMoneyToVirtualCardFile extends StatefulWidget {
  AddMoneyToVirtualCardFile({super.key});
  @override
  State<StatefulWidget> createState() {
    return AddMoneyToVirtualCardFileState();
  }
}

class AddMoneyToVirtualCardFileState extends State<AddMoneyToVirtualCardFile> {
  final PaystackPlugin plugin = PaystackPlugin();
  int? virtualCardID;
  bool confirmedAmount = false;
  TextEditingController amountController = TextEditingController();
  TextEditingController amountNGNController = TextEditingController();
  double amount = 0.00;
  double totalAmount = 0.00;
  double exchangeRate = 1;
  @override
  void initState() {
    // TODO: implement initState
    plugin.initialize(
        publicKey: PreferencesManager.getString(StringMessage.paystackPubKey));
    _callExchangeRateApi();
    super.initState();
  }

  @override
  Widget build(BuildContext _context) {
    final args = (ModalRoute.of(context)!.settings.arguments ??
        <String, dynamic>{}) as Map;
    virtualCardID = args['cardID'];
    return Scaffold(
        appBar: new AppBar(
          backgroundColor: MyColors.base_green_color,
          centerTitle: true,
          title: new Text(
            'Add Money',
            style: TextStyle(
                fontFamily: 'Doomsday',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        body: exchangeRate == 1
            ? CommonUtils.progressDialogBox()
            : (confirmedAmount == false
                ? Container(
                    height: double.infinity,
                    color: MyColors.base_green_color_20,
                    padding: EdgeInsets.all(10),
                    child: SingleChildScrollView(
                        child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Amount to charge',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'Doomsday',
                              color: MyColors.grey_color,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.green, spreadRadius: 3),
                              ],
                            ),
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    controller: amountController,
                                    style: TextStyle(
                                      fontFamily: 'Doomsday',
                                      fontSize: 24,
                                    ),
                                    onChanged: (text) {
                                      if (text.isNotEmpty) {
                                        text = text.replaceAll(RegExp(r'[^0-9.]'), '');
                                        String prev = text;
                                        text = text.replaceAll(',', '');
                                        text = text.replaceAll('.', '');
                                        if (text.length >= 10)
                                          text = text.substring(0, 9);
                                        double value =
                                            int.parse(text).toDouble() / 100;
                                        if (value > 3000000) {
                                          text = text.substring(0, 8);
                                          value =
                                              int.parse(text).toDouble() / 100;
                                        }
                                        text = CommonUtils.toCurrency(value);
                                        if (prev != text) {
                                          amountController.text = text;
                                          amountController.selection =
                                              TextSelection.collapsed(
                                                  offset: text.length);
                                        }
                                        amount = double.parse(amountController
                                            .text
                                            .replaceAll(',', ''));
                                        totalAmount = (amount + (amount < 100 ? 1.5 : amount * 0.015)) * exchangeRate;
                                        amountNGNController.text =
                                            CommonUtils.toCurrency(totalAmount);
                                      }
                                    },
                                    inputFormatters: [amountValidator!],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      hintText: "0.00",
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                    left: BorderSide(),
                                  )),
                                  child: Text(
                                    'USD',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Doomsday',
                                        fontSize: 18),
                                  ),
                                )
                              ],
                            )),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Rate: 1USD = ${exchangeRate} NGN',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'Doomsday',
                              color: MyColors.grey_color,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.green, spreadRadius: 3),
                              ],
                            ),
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: TextField(
                                    readOnly: true,
                                    textAlign: TextAlign.center,
                                    controller: amountNGNController,
                                    style: TextStyle(
                                      fontFamily: 'Doomsday',
                                      fontSize: 24,
                                    ),
                                    inputFormatters: [amountValidator!],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      hintText: "0.00",
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                    left: BorderSide(),
                                  )),
                                  child: Text(
                                    'NGN',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Doomsday',
                                        fontSize: 18),
                                  ),
                                )
                              ],
                            )),
                        Container(
                          margin: EdgeInsets.only(top: 30, left: 10, right: 10),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.fromLTRB(60, 15, 60, 15),
                              primary: MyColors.base_green_color,
                              shape: CustomUiWidgets.basicGreenButtonShape(),
                            ),
                            onPressed: () {
                              if (amount < 5) {
                                CommonUtils.errorToast(
                                    context, "Minimum amount should be \$5.00");
                                return;
                              }
                              if (amount > 0) {
                                setState(() {
                                  confirmedAmount = true;
                                });
                              } else {
                                CommonUtils.errorToast(
                                    context, "Please input amount to charge.");
                              }
                            },
                            child: Text(
                              'Proceed',
                              style: TextStyle(
                                fontFamily: 'Doomsday',
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        //   GestureDetector(
                        //     onTap: () {
                        //       print('Charge in card');
                        //       print(totalAmount);
                        //       _callPaymentGateway(_context, totalAmount, amount,
                        //           'paystack', 0, false);
                        //     },
                        //     child: Container(
                        //         height: 56,
                        //         // width: 56,
                        //         width: double.infinity,
                        //         margin: const EdgeInsets.all(6),
                        //         padding: const EdgeInsets.all(6),
                        //         decoration: BoxDecoration(
                        //           color: Colors.transparent,
                        //           border: Border.all(color: Colors.grey, width: 1),
                        //           borderRadius: BorderRadius.circular(10),
                        //         ),
                        //         child: Row(
                        //           children: <Widget>[
                        //             Icon(
                        //               Icons.credit_card,
                        //               color: Colors.black,
                        //             ),
                        //             Text(
                        //               "  Pay with Card",
                        //               style: TextStyle(
                        //                 fontFamily: 'Doomsday',
                        //                 fontSize: 18,
                        //                 color: Colors.black,
                        //               ),
                        //             ),
                        //           ],
                        //         )),
                        //   ),
                        //   SizedBox(width: 4),
                        //   GestureDetector(
                        //     onTap: () => {},
                        //     child: Container(
                        //         width: double.infinity,
                        //         height: 56,
                        //         margin: const EdgeInsets.all(6),
                        //         padding: const EdgeInsets.all(6),
                        //         decoration: BoxDecoration(
                        //           color: Colors.transparent,
                        //           border: Border.all(color: Colors.grey, width: 1),
                        //           borderRadius: BorderRadius.circular(10),
                        //         ),
                        //         child: Row(
                        //           children: <Widget>[
                        //             Icon(
                        //               Icons.account_balance,
                        //               color: Colors.black,
                        //             ),
                        //             Text(
                        //               "  Pay with Bank",
                        //               style: TextStyle(
                        //                 fontFamily: 'Doomsday',
                        //                 fontSize: 18,
                        //                 color: Colors.black,
                        //               ),
                        //             ),
                        //           ],
                        //         )),
                        //   ),
                        //
                      ],
                    )),
                  )
                : Container(
                    height: double.infinity,
                    color: MyColors.base_green_color_20,
                    padding: EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            margin: EdgeInsets.all(10),
                            decoration: new BoxDecoration(
                              color: MyColors.base_green_color,
                              borderRadius: new BorderRadius.all(
                                  const Radius.circular(20)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        ' Amount',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Doomsday',
                                            color: Colors.white,
                                            fontSize: 18),
                                      ),
                                    ),
                                    Container(
                                      width: 170,
                                      child: Text(
                                        '\$' + CommonUtils.toCurrency(amount),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                    height: 1,
                                    color: MyColors.light_grey_divider_color,
                                    margin:
                                    EdgeInsets.only(top: 15, bottom: 15)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        ' Top Up Fee',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Doomsday',
                                            color: Colors.white,
                                            fontSize: 18),
                                      ),
                                    ),
                                    Container(
                                      width: 170,
                                      child: Text(
                                        amount < 100 ? "\$1.5" : "\$${amount*0.015}",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                    height: 1,
                                    color: MyColors.light_grey_divider_color,
                                    margin:
                                        EdgeInsets.only(top: 15, bottom: 15)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        ' Rate',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Doomsday',
                                            color: Colors.white,
                                            fontSize: 18),
                                      ),
                                    ),
                                    Container(
                                      width: 170,
                                      child: Text(
                                        StringMessage.naira +
                                            CommonUtils.toCurrency(
                                                exchangeRate),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                    height: 1,
                                    color: MyColors.light_grey_divider_color,
                                    margin:
                                        EdgeInsets.only(top: 15, bottom: 15)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        ' Costs',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 18),
                                      ),
                                    ),
                                    Container(
                                      width: 170,
                                      child: Text(
                                        StringMessage.naira +
                                            CommonUtils.toCurrency(totalAmount),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          GestureDetector(
                            onTap: () {
                              if (totalAmount > Globals.walletbalance) {
                                CommonUtils.errorToast(_context,
                                    "You do not have sufficient funds to complete this transaction.");
                                Navigator.of(context).pushNamed('/deposit');
                              } else {
                                _showDialog(
                                    _context, totalAmount, amount, "UpayChat");
                              }
                            },
                            child: Container(
                                width: double.infinity,
                                height: 56,
                                margin: const EdgeInsets.all(6),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      "assets/logo_black.png",
                                      height: 23,
                                      width: 23,
                                    ),
                                    Text(
                                      "  Pay from Upaychat Balance",
                                      style: TextStyle(
                                        fontFamily: 'Doomsday',
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ))));
  }

  void _callExchangeRateApi() async {
    print('Before call exchange rate api');
    ExchangeRateApi exchangeRateApi = new ExchangeRateApi();
    int todayRate = await exchangeRateApi.search();
    exchangeRate = todayRate.toDouble();
    print('ExchangeRate');
    print(exchangeRate);
  }

  

  void _showDialog(BuildContext _context, double totalAmount, double amount,
      String mode) async {
    if (Globals.isOnline) {
      context.loaderOverlay.show();
      AddMoneyToVirtualCardApi _cardBalanceApi = new AddMoneyToVirtualCardApi();
      AddMoneyToVirtualCardModel result = await _cardBalanceApi.search(
          virtualCardID!, totalAmount, amount, mode, "", "");
      context.loaderOverlay.hide();
      if (result.status == "true") {
        // Navigator.pop(_context);
        setState(() {
          amountController.text = "";
          setState(() {
            if (mode == 'UpayChat') {
              Globals.walletbalance = double.parse(result.balance);
            }
            //
          });
        });
        EventHandler().send(BalanceEvent('cardbalance'));
        CommonUtils.successToast(
            _context, "Your payment has been successfully processed.");
        Navigator.pop(_context);
      } else {
        CommonUtils.errorToast(_context, result.message);
        Navigator.pop(_context);
      }
    } else {
      CommonUtils.errorToast(_context, StringMessage.network_Error);
    }
  }

  Future<void> _payWithUpaychatDialogBuilder(BuildContext _context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pay from Upaychat balance'),
          content: Container(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Amount',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Doomsday',
                            color: Colors.black,
                            fontSize: 18),
                      ),
                    ),
                    Container(
                      width: 170,
                      child: Text(
                        '\$' + CommonUtils.toCurrency(amount),
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ],
                ),
                Container(
                    height: 1,
                    color: MyColors.light_grey_divider_color,
                    margin: EdgeInsets.only(top: 15, bottom: 15)),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Balance',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Doomsday',
                            color: Colors.black,
                            fontSize: 18),
                      ),
                    ),
                    Container(
                      width: 170,
                      child: Text(
                        StringMessage.naira +
                            CommonUtils.toCurrency(Globals.walletbalance),
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ],
                ),
                Container(
                    height: 1,
                    color: MyColors.light_grey_divider_color,
                    margin: EdgeInsets.only(top: 15, bottom: 15)),
                // Row(
                //   children: [
                //     Expanded(
                //       child: Text(
                //         'Pay Amount',
                //         style: TextStyle(
                //             fontWeight: FontWeight.bold,
                //             color: Colors.black,
                //             fontSize: 18),
                //       ),
                //     ),
                //     Container(
                //       width: 170,
                //       child: Text(
                //         StringMessage.naira +
                //             CommonUtils.toCurrency(totalAmount),
                //         textAlign: TextAlign.right,
                //         style: TextStyle(color: Colors.black, fontSize: 18),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                setState(() {
                  confirmedAmount = false;
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Pay'),
              onPressed: () {
                if (totalAmount > Globals.walletbalance) {
                  CommonUtils.errorToast(_context,
                      "Sorry, You have no balance in Upaychat. Please choose another option or deposit money.");
                  Navigator.of(context).pop();
                } else {
                  _showDialog(_context, totalAmount, amount, "UpayChat");
                }
              },
            ),
          ],
        );
      },
    );
  }
}
