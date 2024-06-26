import 'dart:async';
import 'dart:convert';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:eventhandler/eventhandler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:isw_mobile_sdk/isw_mobile_sdk.dart';
import 'package:isw_mobile_sdk/models/isw_mobile_sdk_payment_info.dart';
import 'package:isw_mobile_sdk/models/isw_mobile_sdk_payment_result.dart';
import 'package:isw_mobile_sdk/models/isw_mobile_sdk_sdk_config.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Apis/addmoneytowalletapi.dart';
import 'package:upaychat/Apis/getcardtokensapi.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/custom_ui_widgets.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Events/balanceevent.dart';
import 'package:upaychat/Models/addmoneytowalletmodel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/Pages/flutterwave_checkout_file.dart';
import 'package:upaychat/Pages/paystack_checkout_file.dart';
import 'package:upaychat/globals.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_paystack/flutter_paystack.dart';

import '../Apis/savecardrequestapi.dart';
import '../CustomWidgets/pay_with_saved_card.dart';

class DepositFile extends StatefulWidget {
  String? pageFeature;

  DepositFile({Key? key, this.pageFeature}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DepositFileState();
  }
}

class DepositFileState extends State<DepositFile> {
  TextEditingController amountController = TextEditingController();
  double amount = 0.00;
  double totalAmount = 0.00;
  int _radioValue = 0;
  bool isTokenCharging = false;
  bool isWillSaveCard = true;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  bool isSaveCard = false;
  OutlineInputBorder? border;

  final PaystackPlugin plugin = PaystackPlugin();
  int curIndex = 0;
  String pageMode = '';
  @override
  void initState() {
    pageMode = widget.pageFeature ?? 'deposit';
    curIndex = 0;
    plugin.initialize(
        publicKey: PreferencesManager.getString(StringMessage.paystackPubKey));
    initQuicktellerSdk();
    super.initState();
  }

  final CarouselController _controller = CarouselController();
  void onPageChange(int index, CarouselPageChangedReason changeReason) {
    setState(() {
      curIndex = index;
    });
  }

  Widget paymentDetail() {
    double fee = getFee();
    final double WIDTH = MediaQuery.of(context).size.width;

    return Container(
      width: WIDTH,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: EdgeInsets.all(10),
      decoration: new BoxDecoration(
        color: MyColors.base_green_color,
        borderRadius: new BorderRadius.all(const Radius.circular(20)),
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
                  StringMessage.naira + CommonUtils.toCurrency(amount),
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white, fontSize: 18),
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
                  ' Charges',
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
                  StringMessage.naira + CommonUtils.toCurrency(fee),
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white, fontSize: 18),
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
                  ' Total',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18),
                ),
              ),
              Container(
                width: 170,
                child: Text(
                  StringMessage.naira + CommonUtils.toCurrency(totalAmount),
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double getFee() {
    try {
      double fee = double.parse((amount / 0.985).toStringAsFixed(2)) - amount;

      // double fee = amount * 0.015 ;
      if (amount >= 2500.0) {
        fee =
            double.parse(((amount) / 0.985).toStringAsFixed(2)) - amount + 0.01;
      }
      if (fee > 2000) fee = 2000;
      // else if (amount > 5000.0) fee = 26.88;
      return fee;
    } catch (e) {}
    return 0;
  }

  var selectedCard;
  var map = new Map();
  bool isCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        title: new Text(
          pageMode == 'deposit'
              ? 'Deposit'
              : pageMode == 'add_money_to_virtual_card'
                  ? "Add Funds"
                  : '',
          style: TextStyle(
              fontFamily: 'Doomsday',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      body:Container(
        color: MyColors.base_green_color_20,
        height: double.infinity,
        child: SingleChildScrollView(

          child: !isCard
              ? Container(
            // height: double.infinity,
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Text(
                      StringMessage.naira +
                          CommonUtils.toCurrency(Globals.walletbalance),
                      style: TextStyle(
                        color: MyColors.base_green_color,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(Available Balance)',
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        color: MyColors.grey_color,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      margin: EdgeInsets.fromLTRB(8, 13, 5, 0),
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
                            if (text.length >= 10) text = text.substring(0, 9);
                            double value = int.parse(text).toDouble() / 100;
                            if (value > 3000000) {
                              text = text.substring(0, 8);
                              value = int.parse(text).toDouble() / 100;
                            }
                            text = CommonUtils.toCurrency(value);
                            if (prev != text) {
                              amountController.text = text;
                              amountController.selection =
                                  TextSelection.collapsed(offset: text.length);
                            }
                          }
                        },
                        inputFormatters: [amountValidator!],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(5.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: MyColors.base_green_color, width: 2.0),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5.0)),
                          ),
                          hintText: "0.00",
                        ),
                      ),
                    ),
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
                          try {
                            if (amountController.text.isEmpty) {
                              CommonUtils.errorToast(
                                  context, StringMessage.enter_amount);
                            } else {
                              amount = double.parse(
                                  amountController.text.replaceAll(',', ''));
                              if (amount < 100.0) {
                                CommonUtils.errorToast(context,
                                    StringMessage.enter_correct_amount);
                              } else {
                                double fee = getFee();

                                totalAmount = amount + fee;
                                totalAmount = (totalAmount * 100).round() / 100;
                                if (amount > 1000000) {
                                  CommonUtils.errorToast(context,
                                      'You cannot add more than ${StringMessage.naira}1,000,000');
                                } else {
                                  // cardNumber = '';
                                  // expiryDate = '';
                                  // cvvCode = '';
                                  // cardHolderName = '';
                                  setState(() {
                                    isCard = true;
                                  });
                                }
                              }
                            }
                          } catch (e) {
                            print(e);
                            CommonUtils.errorToast(
                                context, StringMessage.enter_correct_amount);
                          }
                        },
                        child: Text(
                          'Add money',
                          style: TextStyle(
                            fontFamily: 'Doomsday',
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(height: 100),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            "1.5%",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'Doomsday',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: MyColors.grey_color,
                            ),
                          ),
                          Text(
                            "Processing fee",
                            style: TextStyle(
                              fontFamily: 'Doomsday',
                              fontSize: 18,
                              color: MyColors.grey_color,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "✅ Transaction fees capped",
                            style: TextStyle(
                              fontFamily: 'Doomsday',
                              fontSize: 18,
                              color: MyColors.grey_color,
                            ),
                          ),
                          Text(
                            "  at NGN 2,000",
                            style: TextStyle(
                              fontFamily: 'Doomsday',
                              fontSize: 18,
                              color: MyColors.grey_color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ))
              : Container(
            padding: EdgeInsets.all(15),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  paymentDetail(),
                  SizedBox(height: 40),
                  Text(
                    "Select Payment Option",
                    style: TextStyle(
                      fontFamily: 'Doomsday',
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Use one of the payment methods below to pay",
                    style: TextStyle(
                      fontFamily: 'Doomsday',
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => {
                          setState(() => _radioValue = 1),
                          _callPaymentGateway(totalAmount, amount,
                              'flutterwave', _radioValue, true)
                        },
                        child: Container(
                            height: 56,
                            // width: 56,
                            width: double.infinity,
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
                                Icon(
                                  Icons.credit_card,
                                  color: Colors.black,
                                ),
                                Text(
                                  "  Top Up Now",
                                  style: TextStyle(
                                    fontFamily: 'Doomsday',
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )),
                      ),
                      SizedBox(width: 4),


                      // SizedBox(width: 4),
                      // GestureDetector(
                      //   onTap: () => {
                      //     setState(() => _radioValue = 0),
                      //     _callPaymentGateway(totalAmount, amount, 'quickteller',
                      //         _radioValue, true)
                      //   },
                      //   child: Container(
                      //       height: 56,
                      //       // width: 56,
                      //       width: double.infinity,
                      //       margin: const EdgeInsets.all(6),
                      //       padding: const EdgeInsets.all(6),
                      //       decoration: BoxDecoration(
                      //         color: Colors.transparent,
                      //         border:
                      //         Border.all(color: Colors.grey, width: 1),
                      //         borderRadius: BorderRadius.circular(10),
                      //       ),
                      //       child: Row(
                      //         children: <Widget>[
                      //           Icon(
                      //             Icons.credit_card,
                      //             color: Colors.black,
                      //           ),
                      //           Text(
                      //             "  Pay with Quickteller",
                      //             style: TextStyle(
                      //               fontFamily: 'Doomsday',
                      //               fontSize: 18,
                      //               color: Colors.black,
                      //             ),
                      //           ),
                      //         ],
                      //       )),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  Future<void> initQuicktellerSdk() async {
    try {
      String merchantId = PreferencesManager.getString(StringMessage.quickMerchantID),
          merchantCode = PreferencesManager.getString(StringMessage.quickMerchantCode),//"""MX21696",
          merchantSecret = PreferencesManager.getString(StringMessage.quickMerchantSecret),
          currencyCode = "566"; // e.g  566 for NGN
      print("QMerchantID${merchantCode}");
      var iswSdkConfig = new IswSdkConfig(
          merchantId, merchantSecret, merchantCode, currencyCode);
      print("CONFIG QUICKTELLER");

      await IswMobileSdk.initialize(iswSdkConfig, Environment.PRODUCTION);
      //print(IswMobileSdk.nameOf(Environment.PRODUCTION));
    } on PlatformException {
      CommonUtils.errorToast(context, "Error!!!");
    }
  }

  _callPaymentGateway(double totalAmount, double amount, String mode,
      int isWebView, bool isLoading) async {
    if (amount < 100) {
      CommonUtils.errorToast(context, "Minimum deposit amount is NGN 100");
      return;
    }
    if (Globals.isOnline) {
      try {
        // if (!isLoading) {
        // }
        if (mode == 'paystack') {
          context.loaderOverlay.show();
          Map accessCode =
              await CommonUtils.createAccessCode(totalAmount, amount);
          if (isWebView == 1) {
            context.loaderOverlay.hide();
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PaystackCheckoutFile(
                        redirectUrl:
                            'https://checkout.paystack.com/${accessCode["data"]["access_code"]}',
                        reference:
                            'upaychat${DateTime.now().microsecondsSinceEpoch.toString()}'))).then(
                (data) {
              print('RESULT------------------');
              print(data);
              if (data == 'success') {
                EventHandler().send(BalanceEvent(''));
                Navigator.pop(context);
                Fluttertoast.showToast(
                    msg: "Deposit Successful",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: MyColors.base_green_color,
                    textColor: Colors.white,
                    fontSize: 20);
              } else {
                // CommonUtils.errorToast(context, "Payment has been canceled.");
              }
            });
            if (!mounted) return;
          } else {
            SavedCardsApi savedCardsApi =
                new SavedCardsApi(totalAmount, amount);
            SavedCardsModel cardsModel = await savedCardsApi.search();
            context.loaderOverlay.hide();
            if (cardsModel.cardDetails.length == 0) {
              chargeFromPaystackCard(accessCode["data"]["access_code"]);
            } else {
              await showDialog<String?>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (context) => AlertDialog(
                  title: const Text('Pay with a saved card'),
                  backgroundColor: Color(0xffe8fce8),
                  content: PayWithSavedCard(accessCode['data']['access_code'],
                      cardsModel.cardDetails, totalAmount, amount, plugin),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ).then((valueFromDialog) {
                // use the value as you wish
                print(valueFromDialog);
                if (valueFromDialog != null && valueFromDialog! == 'paystack') {
                  chargeFromPaystackCard(accessCode['data']['access_code']);
                } else if (valueFromDialog != null &&
                    valueFromDialog! == 'paystack') {}
              });
              // Navigator.pop(context);
            }

            //

          }

          // PayWithPayStack().now(
          //     context: context,
          //     secretKey:
          //     PreferencesManager.getString(StringMessage.paystackSecKey),
          //     customerEmail: PreferencesManager.getString(StringMessage.email),
          //     reference: 'upaychat${DateTime.now().microsecondsSinceEpoch.toString()}',
          //     currency: "NGN",
          //     paymentChannel:["mobile_money", "card"],
          //     amount: (totalAmount * 100).round().toString(),
          //     metaData: {
          //       "charge_amount" : amount.toString()
          //     },
          //     transactionCompleted: () {
          //       print("Transaction Successful");
          //       EventHandler().send(BalanceEvent(''));
          //       CommonUtils.successToast(
          //           context, "Your payment has been successfully processed.");
          //       Navigator.pop(context);
          //     },
          //     transactionNotCompleted: () {
          //       print("Transaction Not Successful!");
          //       // Navigator.pop(context);
          //       CommonUtils.errorToast(context, "Transaction Not Successful!");
          //     }
          // );

          // Charge charge = Charge();
          // charge.card = PaymentCard(number: '', cvc: '', expiryMonth: null, expiryYear: null);
          // charge
          //   ..amount = (totalAmount * 100).round()
          //   ..email = PreferencesManager.getString(StringMessage.email)
          //   ..putCustomField('Charge Amount', (amount * 100).round().toString())
          //   .. putMetaData('charge_amount', amount);
          //
          //
          //
          // // Charge charge = Charge()
          // //   ..amount = (totalAmount * 100).round()
          // //   ..accessCode = accessCode["data"]["access_code"]
          // //   ..email = PreferencesManager.getString(StringMessage.email);
          // // charge.putMetaData('original_amount', (amount * 100).round().toString());
          // // charge = charge.putMetaData('original_amount', amount.toString());
          // // charge.putCustomField('original_amount', (amount * 100).round().toString());
          // print(charge.amount);
          // print(charge.metadata);
          // CheckoutResponse response = await plugin.chargeCard(
          //   context,
          //   charge: charge,
          // );
          // print(response);
          // if (response.status) {
          //   // _showDialog(totalAmount, amount, mode);
          //   EventHandler().send(BalanceEvent(''));
          //   CommonUtils.successToast(
          //       context, "Your payment has been successfully processed.");
          //   int _start = 3;
          //   Timer.periodic(
          //     const Duration(seconds: 2),
          //         (Timer timer) => setState(
          //           () {
          //         if (_start < 1) {
          //           timer.cancel();
          //           Navigator.pop(context);
          //
          //           Navigator.pop(context);
          //         } else {
          //           CommonUtils.successToast(
          //               context, "$_start");
          //           _start = _start - 1;
          //         }
          //       },
          //     ),
          //   );
          //
          // } else {
          //   Navigator.pop(context);
          //   CommonUtils.errorToast(context, response.message);
          // }
        }
        else if (mode == 'quickteller') {
          context.loaderOverlay.show();
          try {
            var customerId =
                    PreferencesManager.getString(StringMessage.username),
                customerName =
                    '${PreferencesManager.getString(StringMessage.firstname)} ${PreferencesManager.getString(StringMessage.lastname)}',
                customerEmail =
                    PreferencesManager.getString(StringMessage.email),
                customerMobile =
                    PreferencesManager.getString(StringMessage.email),
                reference = "Upaychat ${Uuid().v1()}";
            int amountInKobo = (totalAmount * 100).round();
            print('CREATE P INFO');
            // create payment info
            var iswPaymentInfo = new IswPaymentInfo(customerId, customerName,
                customerEmail, customerMobile, reference, amountInKobo);
            context.loaderOverlay.hide();
            print('TRIGGER P');
            Optional<IswPaymentResult?> result =
                await IswMobileSdk.pay(iswPaymentInfo);
            print('HANDLE RESULT');
            print(result);
            if (result.hasValue) {
              // process result
              // showPaymentSuccess(result.value);

            } else {
              // showPaymentError()
            }
            // intialize with environment, default is Environment.TEST
            // IswMobileSdk.initialize(config, Environment.SANDBOX);
          } on PlatformException {
            context.loaderOverlay.hide();
            CommonUtils.errorToast(context, "Error!!!");
          }
        } else if (mode == 'flutterwave') {
          context.loaderOverlay.show();
          Map<String, String> headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ' +
                PreferencesManager.getString(StringMessage.flutterwaveSecKey)
          };
          Map data = {
            "tx_ref": "Upaychat${Uuid().v1()}",
            "redirect_url": "https://admin.upaychat.com/paymentsuccess",
            "currency": "NGN",
            "amount": totalAmount,
            "meta": {
              "charge_amount": amount,
            },
            "customer": {
              "email": PreferencesManager.getString(StringMessage.email),
              "name": PreferencesManager.getString(StringMessage.username)
            },
            "customizations": {
              "title": "Upaychat Deposit",
              "logo": "https://admin.upaychat.com/favicon.png",
              "description": "Upaychat Deposit"
            },
            "payment_options": "ussd, bank, payattitude"
          };
          String payload = json.encode(data);
          http.Response response = await http.post(
            Uri.parse('https://api.flutterwave.com/v3/payments'),
            headers: headers,
            body: payload,
          );
          Map flutterwaveResponse = jsonDecode(response.body);
          context.loaderOverlay.hide();
          if (flutterwaveResponse['status'] == 'success') {
            // Navigator.pop(context);

            String redirectLink = flutterwaveResponse['data']['link'];
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FlutterwaveCheckoutFile(
                          redirectURL: redirectLink,
                        ))).then((data) {
              print('RESULT------------------');
              print(data);
              if (data == 'success') {
                EventHandler().send(BalanceEvent(''));
                Navigator.pop(context);
                Fluttertoast.showToast(
                    msg: "Deposit Successful",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: MyColors.base_green_color,
                    textColor: Colors.white,
                    fontSize: 20);
              } else {
                context.loaderOverlay.hide();
                CommonUtils.errorToast(context, "Payment has been canceled.");
              }
            });
            if (!mounted) return;
          } else {
            CommonUtils.errorToast(context, flutterwaveResponse['message']);
          }

          // final Customer customer = Customer(
          //     name: "Flutterwave Developer",
          //     phoneNumber: "1234566677777",
          //     email: "customer@customer.com");
          // final Flutterwave flutterwave = Flutterwave(
          //     context: context,
          //     publicKey: PreferencesManager.getString(StringMessage.flutterwavePubKey),
          //     currency: "NGN",
          //     redirectUrl: "https://upaychat.com",
          //     txRef: "UpayChat ${const Uuid().v1().toString()}",
          //     amount: "3000",
          //     customer: customer,
          //     paymentOptions: "ussd, card, barter, payattitude",
          //     customization: Customization(title: "My Payment"),
          //     isTestMode: true);
          // final ChargeResponse response = await flutterwave.charge();

        }
      } catch (e) {
        print(e);
        context.loaderOverlay.hide();
        CommonUtils.errorToast(context, e.toString());
      }
    } else {
      context.loaderOverlay.hide();
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }

  void _showDialog(double totalAmount, double amount, String mode) async {
    if (Globals.isOnline) {
      try {
        AddMoneyWalletApi _walletApi = new AddMoneyWalletApi();
        AddMoneyToWalletModel result =
            await _walletApi.search(totalAmount, amount, mode, "", "");
        if (result.status == "true") {
          Navigator.pop(context);
          setState(() {
            amountController.text = "";
            setState(() {
              Globals.walletbalance = double.parse(result.balance);
            });
          });
          EventHandler().send(BalanceEvent(''));
          EventHandler().send(BalanceEvent(''));
          Navigator.pop(context);
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: "Deposit Successful",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: MyColors.base_green_color,
              textColor: Colors.white,
              fontSize: 20);
          Navigator.pop(context);
          // Navigator.pop(context);
        } else {
          CommonUtils.errorToast(context, result.message);
          Navigator.pop(context);
        }
      } on Exception catch (e) {
        CommonUtils.errorToast(context, e.toString());
        Navigator.pop(context);
      }
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }

  void _handleRadioValueChanged(int? value) {
    if (value != null) setState(() => _radioValue = value);
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  void chargeFromPaystackCard(accessCode) async {
    Charge charge = Charge()
      ..amount = (totalAmount * 100).round()
      ..accessCode = accessCode
      ..email = PreferencesManager.getString(StringMessage.email);
    CheckoutResponse response = await plugin.checkout(
      context,
      method: CheckoutMethod.card,
      charge: charge,
    );
    print(response);
    if (response.status) {
      // _showDialog(totalAmount, amount, mode);
      EventHandler().send(BalanceEvent(''));
      EventHandler().send(BalanceEvent(''));
      Navigator.pop(context);

      Fluttertoast.showToast(
          msg: "Deposit Successful",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: MyColors.base_green_color,
          textColor: Colors.white,
          fontSize: 20);

      await showFinalDialog(response.reference);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      CommonUtils.errorToast(context, response.message);
    }
  }

  showFinalDialog(String? reference) async{
    return await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xffe8fce8),
          title: Column(
            children: [
              Icon(Icons.check_circle,
                  size: 50, color: MyColors.base_green_color),
              Text(
                'Deposit Successful',
                style: TextStyle(
                  fontFamily: 'Doomsday',
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Row(
                    children: [
                      Checkbox(
                          value: isWillSaveCard,
                          onChanged: (bool? newValue) {
                            setState(() {
                              isWillSaveCard = newValue!;
                            });
                          }),
                      Flexible(
                          child: Text(
                        'Save card details for my next payment',
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ))
                    ],
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Doomsday',
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                if (isWillSaveCard) {

                  SaveCardRequestApi saveApi = new SaveCardRequestApi();
                  CommonModel res = await saveApi.save(reference!);
                }

              },
            ),
          ],
        );
      },
    );
  }
}
