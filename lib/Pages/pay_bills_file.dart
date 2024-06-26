// ignore_for_file: prefer_const_constructors
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventhandler/eventhandler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upaychat/Apis/getflutterwavebillingstatusapi.dart';
import 'package:upaychat/Apis/getflutterwavecategories.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/interswitch_utils.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:upaychat/Models/flutterwavecategoriesmodel.dart';
import 'package:upaychat/globals.dart';

import '../Apis/createflutterwavebillpaymentapi.dart';
import '../Apis/getfluttwerwavebillingverificationapi.dart';
import '../CommonUtils/preferences_manager.dart';
import '../Events/balanceevent.dart';
import '../Models/commonmodel.dart';
import '../Models/flutterwavebillingcreatedmodel.dart';
import '../Models/flutterwavebillingverificationmodel.dart';
import 'buy_electricity_file.dart';

class PayBillsFile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PayBillsFileState();
  }
}

class PayBillsFileState extends State<PayBillsFile> {
  var billers = [];
  var _interswitch = InterswitchUtils.getInstance();
  String? selectedCat;
  var selectedBill;
  var billItems;
  int curShowPage = 0;
  var selectedBillOption;
  var currentBillOption;
  String billCode = "", itemCode = "";
  var amountController = TextEditingController();
  var billFieldsControllers = <String, TextEditingController>{};
  List<dynamic>  categories = [];
  final TextEditingController userController = new TextEditingController();
  FlutterwaveBillingVerificationData? _verificationData;
  String? currentDataBundleOption;
  String selectedRecurrence = 'One Time';
  int totalAmount = 0;
  bool isFee = false;
  String feeText = "No Fee";
  String referenceText = '';
  String transactionSuccessDateTime = "";
  List<String> recurrences = [
    "One Time",
    "Hourly",
    "Daily",
    "Weekly",
    "Monthly",
  ];
  List<dynamic> bundleCategories = [

    {"text": "DSTV", "image": "dstv", "bill_code" : "BIL121", "data" : {
      "status": "success",
      "message": "bill categories retrieval successful",
      "data": [
        {
          "id": 16925,
          "biller_code": "BIL121",
          "name": "Asian",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:02.643Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Asian",
          "item_code": "CB523",
          "short_name": "Asian",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 8300
        },
        {
          "id": 16949,
          "biller_code": "BIL121",
          "name": "Asian + HD/ExtraView",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:17:57.71Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Asian + HD/ExtraView",
          "item_code": "CB547",
          "short_name": "Asian + HD/ExtraView",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 11700
        },
        {
          "id": 16956,
          "biller_code": "BIL121",
          "name": "Asian + Showmax",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:17:59.347Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Asian + Showmax",
          "item_code": "CB556",
          "short_name": "Asian + Showmax",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 11200
        },
        {
          "id": 16943,
          "biller_code": "BIL121",
          "name": "Box Office (New Premier Price)",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:05.14Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Box Office (New Premier Price)",
          "item_code": "CB541",
          "short_name": "Box Office (New Premier Price)",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 1100
        },
        {
          "id": 16931,
          "biller_code": "BIL121",
          "name": "Compact + Asia",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:03.533Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Compact + Asia",
          "item_code": "CB529",
          "short_name": "Compact + Asia",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 18800
        },
        {
          "id": 16935,
          "biller_code": "BIL121",
          "name": "Compact + Asia + Xtraview",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:04.063Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Compact + Asia + Xtraview",
          "item_code": "CB533",
          "short_name": "Compact + Asia + Xtraview",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 18800
        },
        {
          "id": 16936,
          "biller_code": "BIL121",
          "name": "Compact + French Plus",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:04.2Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Compact + French Plus",
          "item_code": "CB534",
          "short_name": "Compact + French Plus",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 22100
        },
        {
          "id": 16932,
          "biller_code": "BIL121",
          "name": "Compact + French Touch",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:03.667Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Compact + French Touch",
          "item_code": "CB530",
          "short_name": "Compact + French Touch",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 13800
        },
        {
          "id": 16934,
          "biller_code": "BIL121",
          "name": "Compact + French Touch + Xtraview",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:03.933Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Compact + French Touch + Xtraview",
          "item_code": "CB532",
          "short_name": "Compact + French Touch + Xtraview",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 13800
        },
        {
          "id": 16958,
          "biller_code": "BIL121",
          "name": "Compact + Showmax",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:17:59.957Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Compact + Showmax",
          "item_code": "CB558",
          "short_name": "Compact + Showmax",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 11950
        },
        {
          "id": 16933,
          "biller_code": "BIL121",
          "name": "Compact + Xtraview",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:03.793Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Compact + Xtraview",
          "item_code": "CB531",
          "short_name": "Compact + Xtraview",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 10500
        },
        {
          "id": 16899,
          "biller_code": "BIL121",
          "name": "Compact Plus + Asia +Xtraview",
          "default_commission": 0.3,
          "date_added": "2020-06-01T00:00:00Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "Compact Plus + Asia +Xtraview",
          "item_code": "CB509",
          "short_name": "Compact Plus + Asia +Xtraview",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "Smartcard Number",
          "amount": 24900
        },
        {
          "id": 16904,
          "biller_code": "BIL121",
          "name": "Compact Plus + French Plus",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "Compact Plus + French Plus",
          "item_code": "CB511",
          "short_name": "Compact Plus + French Plus",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 28200
        },
        {
          "id": 16903,
          "biller_code": "BIL121",
          "name": "Compact Plus + French Touch",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "Compact Plus + French Touch",
          "item_code": "CB510",
          "short_name": "Compact Plus + French Touch",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 19900
        },
        {
          "id": 16930,
          "biller_code": "BIL121",
          "name": "CompactPlus + French Plus + Xtraview",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:03.4Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "CompactPlus + French Plus + Xtraview",
          "item_code": "CB528",
          "short_name": "CompactPlus + French Plus + Xtraview",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 28200
        },
        {
          "id": 16957,
          "biller_code": "BIL121",
          "name": "CompactPlus + Showmax",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:17:59.827Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "CompactPlus + Showmax",
          "item_code": "CB557",
          "short_name": "CompactPlus + Showmax",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 18050
        },
        {
          "id": 16959,
          "biller_code": "BIL121",
          "name": "Confam + Showmax",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:18:00.13Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Confam + Showmax",
          "item_code": "CB559",
          "short_name": "Confam + Showmax",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 7650
        },
        {
          "id": 16953,
          "biller_code": "BIL121",
          "name": "Confam + Xtraview",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:17:58.763Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Confam + Xtraview",
          "item_code": "CB552",
          "short_name": "Confam + Xtraview",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 11400
        },
        {
          "id": 17656,
          "biller_code": "BIL121",
          "name": "DSTV ACCESS",
          "default_commission": 0.3,
          "date_added": "2023-09-19T19:20:16.13Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV ACCESS",
          "item_code": "CB171",
          "short_name": "DSTV ACCESS",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 2000
        },
        {
          "id": 17657,
          "biller_code": "BIL121",
          "name": "DSTV ACCESS + ASIA",
          "default_commission": 0.3,
          "date_added": "2023-09-19T19:20:16.24Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV ACCESS + ASIA",
          "item_code": "CB172",
          "short_name": "DSTV ACCESS + ASIA",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 7400
        },
        {
          "id": 17658,
          "biller_code": "BIL121",
          "name": "DSTV ACCESS + HD",
          "default_commission": 0.3,
          "date_added": "2023-09-19T19:20:16.337Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV ACCESS + HD",
          "item_code": "CB173",
          "short_name": "DSTV ACCESS + HD",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 4200
        },
        {
          "id": 16939,
          "biller_code": "BIL121",
          "name": "DStv Asian Add-on Bouquet E36",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:04.603Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "DStv Asian Add-on Bouquet E36",
          "item_code": "CB537",
          "short_name": "DStv Asian Add-on Bouquet E36",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 8300
        },
        {
          "id": 295,
          "biller_code": "BIL121",
          "name": "DSTV BOX OFFICE",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV BOX OFFICE",
          "item_code": "CB221",
          "short_name": "DSTV BOX OFFICE",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 800
        },
        {
          "id": 287,
          "biller_code": "BIL121",
          "name": "DSTV COMPACT",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV COMPACT",
          "item_code": "CB177",
          "short_name": "DSTV COMPACT",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 12500
        },
        {
          "id": 288,
          "biller_code": "BIL121",
          "name": "DSTV COMPACT + HD",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV COMPACT + HD",
          "item_code": "CB178",
          "short_name": "DSTV COMPACT + HD",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 11900
        },
        {
          "id": 289,
          "biller_code": "BIL121",
          "name": "DSTV COMPACT PLUS",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV COMPACT PLUS",
          "item_code": "CB179",
          "short_name": "DSTV COMPACT PLUS",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 19800
        },
        {
          "id": 290,
          "biller_code": "BIL121",
          "name": "DSTV COMPACT PLUS + ASIA",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV COMPACT PLUS + ASIA",
          "item_code": "CB180",
          "short_name": "DSTV COMPACT PLUS + ASIA",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 24900
        },
        {
          "id": 291,
          "biller_code": "BIL121",
          "name": "DSTV COMPACT PLUS + HD",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV COMPACT PLUS + HD",
          "item_code": "CB181",
          "short_name": "DSTV COMPACT PLUS + HD",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 20000
        },
        {
          "id": 16962,
          "biller_code": "BIL121",
          "name": "DSTV COMPACT PLUS + XTRAVIEW",
          "default_commission": 0.3,
          "date_added": "2022-09-19T23:29:13.46Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "DSTV COMPACT PLUS + XTRAVIEW",
          "item_code": "CB562",
          "short_name": "DSTV COMPACT PLUS + XTRAVIEW",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 20000
        },
        {
          "id": 16894,
          "biller_code": "BIL121",
          "name": "DSTV Confam",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV Confam",
          "item_code": "CB483",
          "short_name": "DSTV Confam",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 7400
        },
        {
          "id": 17662,
          "biller_code": "BIL121",
          "name": "DStv Confam + XTRA VIEW",
          "default_commission": 0.3,
          "date_added": "2023-09-19T19:20:17.73Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DStv Confam + XTRA VIEW",
          "item_code": "CB485",
          "short_name": "DStv Confam + XTRA VIEW",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 7115
        },
        {
          "id": 17659,
          "biller_code": "BIL121",
          "name": "DSTV FAMILY",
          "default_commission": 0.3,
          "date_added": "2023-09-19T19:20:16.423Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV FAMILY",
          "item_code": "CB174",
          "short_name": "DSTV FAMILY",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 4000
        },
        {
          "id": 17660,
          "biller_code": "BIL121",
          "name": "DSTV FAMILY + ASIA",
          "default_commission": 0.3,
          "date_added": "2023-09-19T19:20:16.523Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV FAMILY + ASIA",
          "item_code": "CB175",
          "short_name": "DSTV FAMILY + ASIA",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 9400
        },
        {
          "id": 17661,
          "biller_code": "BIL121",
          "name": "DSTV FAMILY + HD",
          "default_commission": 0.3,
          "date_added": "2023-09-19T19:20:16.607Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV FAMILY + HD",
          "item_code": "CB176",
          "short_name": "DSTV FAMILY + HD",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 6200
        },
        {
          "id": 16940,
          "biller_code": "BIL121",
          "name": "DStv French Plus Add-on Bouquet E36",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:04.74Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "DStv French Plus Add-on Bouquet E36",
          "item_code": "CB538",
          "short_name": "DStv French Plus Add-on Bouquet E36",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 11600
        },
        {
          "id": 16938,
          "biller_code": "BIL121",
          "name": "DStv French Touch Add-on Bouquet E36",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:04.467Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "DStv French Touch Add-on Bouquet E36",
          "item_code": "CB536",
          "short_name": "DStv French Touch Add-on Bouquet E36",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 3300
        },
        {
          "id": 16941,
          "biller_code": "BIL121",
          "name": "Dstv Great Wall standalone Bouquet",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:04.867Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Dstv Great Wall standalone Bouquet",
          "item_code": "CB539",
          "short_name": "Dstv Great Wall standalone Bouquet",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 2050
        },
        {
          "id": 16937,
          "biller_code": "BIL121",
          "name": "DStv HDPVR Access Service E36",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:04.34Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "DStv HDPVR Access Service E36",
          "item_code": "CB535",
          "short_name": "DStv HDPVR Access Service E36",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 3400
        },
        {
          "id": 16905,
          "biller_code": "BIL121",
          "name": "DSTV PADI",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV PADI",
          "item_code": "CB512",
          "short_name": "DSTV PADI",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 2950
        },
        {
          "id": 16906,
          "biller_code": "BIL121",
          "name": "DSTV PADI + XTRA VIEW",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV PADI + XTRA VIEW",
          "item_code": "Cb513",
          "short_name": "DSTV PADI + XTRA VIEW",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 2500
        },
        {
          "id": 292,
          "biller_code": "BIL121",
          "name": "DSTV PREMIUM",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV PREMIUM",
          "item_code": "CB182",
          "short_name": "DSTV PREMIUM",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 29500
        },
        {
          "id": 294,
          "biller_code": "BIL121",
          "name": "DSTV PREMIUM + HD",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV PREMIUM + HD",
          "item_code": "CB184",
          "short_name": "DSTV PREMIUM + HD",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 20900
        },
        {
          "id": 293,
          "biller_code": "BIL121",
          "name": "DSTV PREMIUM ASIA",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV PREMIUM ASIA",
          "item_code": "CB183",
          "short_name": "DSTV PREMIUM ASIA",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 33000
        },
        {
          "id": 17613,
          "biller_code": "BIL121",
          "name": "Dstv Xtraview Access",
          "default_commission": 0.3,
          "date_added": "2022-10-05T12:45:29.78Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Dstv Xtraview Access",
          "item_code": "CB563",
          "short_name": "Dstv Xtraview Access",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 3400
        },
        {
          "id": 16889,
          "biller_code": "BIL121",
          "name": "DSTV Yanga",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DSTV Yanga",
          "item_code": "CB482",
          "short_name": "DSTV Yanga",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 4200
        },
        {
          "id": 17167,
          "biller_code": "BIL121",
          "name": "DStv Yanga + XTRA VIEW",
          "default_commission": 0.1,
          "date_added": "2022-09-19T18:27:57.243Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "DStv Yanga + XTRA VIEW",
          "item_code": "CB484",
          "short_name": "DStv Yanga + XTRA VIEW",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 6900
        },
        {
          "id": 16950,
          "biller_code": "BIL121",
          "name": "Family + Asia",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:17:58.19Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Family + Asia",
          "item_code": "CB548",
          "short_name": "Family + Asia",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 9400
        },
        {
          "id": 16947,
          "biller_code": "BIL121",
          "name": "French 11",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:17:57.407Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "French 11",
          "item_code": "CB545",
          "short_name": "French 11",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 3180
        },
        {
          "id": 16942,
          "biller_code": "BIL121",
          "name": "French 11 Bouquet E36",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:05.007Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "French 11 Bouquet E36",
          "item_code": "CB540",
          "short_name": "French 11 Bouquet E36",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 5150
        },
        {
          "id": 17651,
          "biller_code": "BIL121",
          "name": "Great Wall Standalone Bouquet E36 + Showmax",
          "default_commission": 0.3,
          "date_added": "2023-07-26T13:29:17.71Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "Great Wall Standalone Bouquet E36 + Showmax",
          "item_code": "CB586",
          "short_name": "Great Wall Standalone Bouquet E36 + Showmax",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 4950
        },
        {
          "id": 16961,
          "biller_code": "BIL121",
          "name": "Padi + Showmax",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:18:00.397Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Padi + Showmax",
          "item_code": "CB561",
          "short_name": "Padi + Showmax",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 5400
        },
        {
          "id": 16928,
          "biller_code": "BIL121",
          "name": "Premium + French",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:03.09Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Premium + French",
          "item_code": "CB526",
          "short_name": "Premium + French",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 36600
        },
        {
          "id": 16929,
          "biller_code": "BIL121",
          "name": "Premium + French + Xtraview",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:03.227Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Premium + French + Xtraview",
          "item_code": "CB527",
          "short_name": "Premium + French + Xtraview",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 36600
        },
        {
          "id": 16951,
          "biller_code": "BIL121",
          "name": "Premium + French Touch + HD/ExtraView",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:17:58.37Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Premium + French Touch + HD/ExtraView",
          "item_code": "CB549",
          "short_name": "Premium + French Touch + HD/ExtraView",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 28050
        },
        {
          "id": 16955,
          "biller_code": "BIL121",
          "name": "Premium + Showmax",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:17:59.167Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Premium + Showmax",
          "item_code": "CB555",
          "short_name": "Premium + Showmax",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 24500
        },
        {
          "id": 16926,
          "biller_code": "BIL121",
          "name": "Premium + Xtraview",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:02.813Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "Premium + Xtraview",
          "item_code": "CB524",
          "short_name": "Premium + Xtraview",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 33500
        },
        {
          "id": 16948,
          "biller_code": "BIL121",
          "name": "Premium Asia + HD/ExtraView",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:17:57.54Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Premium Asia + HD/ExtraView",
          "item_code": "CB546",
          "short_name": "Premium Asia + HD/ExtraView",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 30900
        },
        {
          "id": 16952,
          "biller_code": "BIL121",
          "name": "Premium French Bonus + HD/Extraview",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:17:58.577Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Premium French Bonus + HD/Extraview",
          "item_code": "CB550",
          "short_name": "Premium French Bonus + HD/Extraview",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 25005
        },
        {
          "id": 17663,
          "biller_code": "BIL121",
          "name": "Premiumasia + Xtraview",
          "default_commission": 0.3,
          "date_added": "2023-09-19T19:20:18.397Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "Premiumasia + Xtraview",
          "item_code": "CB525",
          "short_name": "Premiumasia + Xtraview",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 27500
        },
        {
          "id": 16954,
          "biller_code": "BIL121",
          "name": "PremiumAsia Showmax",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:17:58.967Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "PremiumAsia Showmax",
          "item_code": "CB553",
          "short_name": "PremiumAsia Showmax",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 27500
        },
        {
          "id": 17614,
          "biller_code": "BIL121",
          "name": "PremiumFrench + Showmax",
          "default_commission": 0.3,
          "date_added": "2022-10-14T17:59:53.913Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "PremiumFrench + Showmax",
          "item_code": "CB554",
          "short_name": "PremiumFrench + Showmax",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 36600
        },
        {
          "id": 16960,
          "biller_code": "BIL121",
          "name": "Yanga + Showmax",
          "default_commission": 0.3,
          "date_added": "2022-08-01T05:18:00.267Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "Yanga + Showmax",
          "item_code": "CB560",
          "short_name": "Yanga + Showmax",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 4950
        },
        {
          "id": 17664,
          "biller_code": "BIL121",
          "name": "Yanga + Xtraview",
          "default_commission": 0.3,
          "date_added": "2023-09-19T19:20:19.977Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "Yanga + Xtraview",
          "item_code": "CB544",
          "short_name": "Yanga + Xtraview",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 5850
        }
      ]
    }},
    {"text": "GoTV", "image": "gotv", "bill_code" : "BIL122", "data":{
      "status": "success",
      "message": "bill categories retrieval successful",
      "data": [
        {
          "id": 16897,
          "biller_code": "BIL122",
          "name": "GOtv Jinja",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GOtv Jinja",
          "item_code": "CB486",
          "short_name": "GOtv Jinja",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 2700
        },
        {
          "id": 16898,
          "biller_code": "BIL122",
          "name": "GOtv Jolli",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GOtv Jolli",
          "item_code": "CB487",
          "short_name": "GOtv Jolli",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 3950
        },
        {
          "id": 299,
          "biller_code": "BIL122",
          "name": "GOTV MAX",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:13:29.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GOTV MAX",
          "item_code": "CB188",
          "short_name": "GOTV MAX",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 4850
        },
        {
          "id": 17666,
          "biller_code": "BIL122",
          "name": "GOTV PLUS",
          "default_commission": 0.3,
          "date_added": "2023-09-19T19:20:21.967Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GOTV PLUS",
          "item_code": "CB187",
          "short_name": "GOTV PLUS",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 1900
        },
        {
          "id": 17649,
          "biller_code": "BIL122",
          "name": "GOtv SMALLIE (Monthly)",
          "default_commission": 0.3,
          "date_added": "2023-07-26T13:22:22.697Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GOtv SMALLIE (Monthly)",
          "item_code": "CB185",
          "short_name": "GOtv SMALLIE (Monthly)",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 1300
        },
        {
          "id": 17650,
          "biller_code": "BIL122",
          "name": "GOtv Smallie (Quarterly)",
          "default_commission": 0.3,
          "date_added": "2023-07-26T13:23:00.157Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GOtv Smallie (Quarterly)",
          "item_code": "CB514",
          "short_name": "GOtv Smallie (Quarterly) ",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 8600
        },
        {
          "id": 17648,
          "biller_code": "BIL122",
          "name": "GOtv Smallie (Yearly)",
          "default_commission": 0.3,
          "date_added": "2023-07-26T13:21:44.893Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GOtv Smallie (Yearly)",
          "item_code": "CB542",
          "short_name": "GOtv Smallie (Yearly)\t",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 8600
        },
        {
          "id": 16945,
          "biller_code": "BIL122",
          "name": "GOtv Supa",
          "default_commission": 0.3,
          "date_added": "2022-07-26T21:23:06.407Z",
          "country": "NG",
          "is_airtime": true,
          "biller_name": "GOtv Supa",
          "item_code": "CB543",
          "short_name": "GOtv Supa",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 7600
        },
        {
          "id": 17665,
          "biller_code": "BIL122",
          "name": "GOTV VALUE",
          "default_commission": 0.3,
          "date_added": "2023-09-19T19:20:21.88Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GOTV VALUE",
          "item_code": "CB186",
          "short_name": "GOTV VALUE",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "SmartCard Number",
          "amount": 1250
        }
      ]
    }}
  ];
  String userLabelName = "Smart Card Number";
  @override
  void initState() {
    super.initState();
  }

  getCategories(dynamic listData) async {
    bool isHideDlg = false;
    setState((){
      isFee = false;
      feeText = "";
      amountController.text = "0";
      currentDataBundleOption = listData['data'][0]['biller_name'];
      categories = listData['data'];


      // CommonUtils.successToast(context, _model.message);
      billCode = listData['data'][0]['biller_code'];
      itemCode = listData['data'][0]['item_code'];
      totalAmount = listData['data'][0]['amount'] + listData['data'][0]['fee'];
      userLabelName = listData['data'][0]['label_name'];
      //curShowPage = 1;
      curShowPage = 1;
    });
    amountController.text =
        listData['data'][0]['amount'].toString();


    if (listData['data'][0]['commission_on_fee'].toString() == "true") {
      int feeAmount = int.parse(listData['data'][0]['fee'].toString());
      setState((){
        isFee = true;
        feeText = "Commission fee: " +
            feeAmount.toString() +
            "NGN";
      });
    } else {
      setState((){
        isFee = false;
      });
    }
    amountController.text =
        (listData['data'][0]['amount']  )
            .toString();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            if (curShowPage == 0 || curShowPage == 2)
              Navigator.of(context).pop();
            else
              setState(() {
                curShowPage -= 1;
              });
          },
        ),
        title: new Text(
          'Pay Bills',
          style: TextStyle(
            fontFamily: 'Doomsday',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

      ),
      resizeToAvoidBottomInset : true,
      body: Container(
        color: Color(0xffe8fce8),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: _body(context),
      ),
    );
  }
  getData() {
    return categories;
  }
  _renderBillsPage() {
    var listData = getData();
    return Container(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 150,
            padding: EdgeInsets.all(30),
            child: Image.asset("assets/" +currentBillOption['image'] + ".png", height: 60,),

          ),
          SizedBox(height: 10,),
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Text("Select a package",
              style: TextStyle(
                color: MyColors.base_green_color,
                fontSize: 18,
                fontFamily: 'Doomsday',
                fontWeight: FontWeight.bold,
            ),),
          ),
          SizedBox(height: 5,),
          Container(
            width: MediaQuery.of(context).size.width - 10,
            margin: EdgeInsets.only(right: 50),
            // margin: EdgeInsets.only(right: 10),
            child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white, //background color of dropdown button
                  borderRadius: BorderRadius.circular(
                      10), //border raiuds of dropdown button
                ),
                child: Padding(
                    padding: EdgeInsets.only(left: 30, right: 10),

                    child: DropdownButton<String>(

                      value: currentDataBundleOption,
                      underline: SizedBox(),
                      style: TextStyle(
                          fontFamily: 'Doomsday',
                          color: Colors.black, //Font color
                          fontSize: 15 //font size on dropdown button
                      ),
                      items: categories.map<DropdownMenuItem<String>>(
                              (dynamic categoryData) {
                            return DropdownMenuItem(
                              child: Text(categoryData['biller_name']),
                              value: categoryData['biller_name'],
                            );
                          }).toList(),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState((){
                          currentDataBundleOption = newValue;
                        });

                        for (int i = 0; i < categories.length; i++) {
                          if (categories[i]['biller_name'] == newValue) {
                            amountController.text =
                                categories[i]['amount'].toString();
                            setState((){
                              billCode = categories[i]['biller_code'];
                              itemCode = categories[i]['item_code'];
                            });

                            if (categories[i]['commission_on_fee'].toString() == "true") {
                              int feeAmount = int.parse(categories[i]['fee'].toString());
                              setState((){
                                isFee = true;

                                feeText = "Commission fee: " +
                                    feeAmount.toString() +
                                    "NGN";
                              });

                            } else {
                              setState((){
                                isFee = false;
                              });

                            }
                            amountController.text =
                                (categories[i]['amount']  )
                                    .toString();
                            setState((){
                              totalAmount = categories[i]['amount'] + categories[i]['fee'];
                                  userLabelName = categories[i]['label_name'];
                            });

                          }
                        }
                      },
                      icon: Padding(
                        //Icon at tail, arrow bottom is default icon
                          padding: EdgeInsets.only(left: 20),
                          child: Icon(Icons.arrow_drop_down)),
                      iconEnabledColor: Colors.grey, //I
                    ))),
          ),

          SizedBox(height: 10,),
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Text("Amount",
              style: TextStyle(
                color: MyColors.base_green_color,
                fontSize: 18,
                fontFamily: 'Doomsday',
                fontWeight: FontWeight.bold,
              ),),
          ),
          SizedBox(height: 5,),
          Container(
            margin: EdgeInsets.only(right: 50),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                color: MyColors.light_grey_divider_color
            ),
            child: TextField(
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MyColors.base_green_color,
                fontFamily: 'Doomsday',
                fontSize: 25,
              ),
              controller: amountController,
              keyboardType: TextInputType.number,
              readOnly: true,
              inputFormatters: [amountValidator!],
              cursorColor: MyColors.base_green_color,
              decoration: InputDecoration(
                focusColor: Colors.transparent,
                focusedBorder: InputBorder.none,
                border: InputBorder.none,
                hintText: "0.00",
              ),
            ),
          ),
          Visibility(
            visible: isFee,
            child: Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Text(feeText,
              style: TextStyle(
                color: MyColors.base_green_color,
                fontSize: 18,
                fontFamily: 'Doomsday',
                fontWeight: FontWeight.bold,
              ),),
          ),),
          Row(
            // margin: EdgeInsets.only(right: 50),
              children: [
                Expanded(child: Row(
                  children: <Widget>[
                    Expanded(child: SizedBox(),),
                    Container( width: 90, child: DropdownButton<String>(
                      value: selectedRecurrence,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedRecurrence = newValue!;
                        });
                      },
                      style: TextStyle(
                          fontFamily: 'Doomsday',
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                      underline: SizedBox(),
                      items: recurrences.map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      selectedItemBuilder: (BuildContext context) {
                        return recurrences.map((var item) {
                          return Container(
                            alignment: Alignment.center,
                            child: Text(
                              item,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList();
                      },
                    ),),
                    Expanded(child: SizedBox())
                  ],
                ),),
                SizedBox(width: 50)
              ]
          ),
          SizedBox(height: 20,),
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Text(userLabelName,

              style: TextStyle(
                color: MyColors.base_green_color,
                fontSize: 18,
                fontFamily: 'Doomsday',
                fontWeight: FontWeight.bold,
              ),),
          ),
          SizedBox(height: 5,),
          Container(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      onChanged: (value) {
                        // filterSearchResults(value);
                        if(value.length == 10){
                          validateSmartCardNumber(value);
                        }
                      },
                      controller: userController,
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        fontSize: 18,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp("[ ]"))
                      ],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                            left: 10, right: 10, top: 5, bottom: 5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: MyColors.base_green_color),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: userLabelName,

                        hintStyle: TextStyle(color: MyColors.grey_color)
                      ),
                    ),
                  ),
                ),

                
              ],
            ),

          ),
          Visibility(
              visible: _verificationData != null,
              child: Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: Text(_verificationData != null ? _verificationData!.name! : "",
                  style: TextStyle(
                    color: MyColors.base_green_color,
                    fontSize: 18,
                    fontFamily: 'Doomsday',
                    fontWeight: FontWeight.bold,
                  ),),)),
          SizedBox(height:30),
          Container(
            width: double.infinity,
            height: 50,
            child: Container(
              child: TextButton(
                style: ButtonStyle(
                  //    textColor: Colors.white,
                  // highlightColor: MyColors.base_green_color_20,
                  // splashColor: MyColors.base_green_color_20,
                  // color: MyColors.base_green_color,
                  // disabledColor: MyColors.base_green_color,
                  backgroundColor: MaterialStateProperty.all<Color>(
                      MyColors.base_green_color),
                ),
                onPressed: completePayment,
                child: Text(
                  'Buy',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String cardNumber = "";
  String expiryDate = "";
  String cardHolderName = "";
  String cvvCode = "";
  bool isCvvFocused = false;
  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  completePayment() async{
    if (CommonUtils.isEmpty(userController, 0)) {
      CommonUtils.errorToast(context, "Please input the number");
      return;
    }

    if (CommonUtils.isEmpty(amountController, 0) ||
        double.parse(amountController.text) <= 0) {
      CommonUtils.errorToast(context, "Please input the amount");
      return;
    }
    if(currentDataBundleOption == null){
      CommonUtils.errorToast(context, "Please choose data bundle.");
      return;
    }
    if (double.parse(amountController.text) > Globals.walletbalance) {
      CommonUtils.errorToast(context,
          "You do not have sufficient funds to complete this transaction.");
      // Navigator.of(context).pop();
      return;
    }
    context.loaderOverlay.show();
    try{
      var amount;
      amount = amountController.text;
      String postRecurrence = "";
      if (selectedRecurrence == "One Time") {
        postRecurrence = "ONCE";
      }
      else{
        postRecurrence = selectedRecurrence.toUpperCase();
      }
      CreateFlutterwaveBillPaymentApi createFlutterwaveAirtimeApi = new CreateFlutterwaveBillPaymentApi();


      FlutterwaveBillingCreatedModel result = await createFlutterwaveAirtimeApi.save(
          currentDataBundleOption!,amount,totalAmount.toString(), userController.text, postRecurrence);
      context.loaderOverlay.hide();
      if(result.status == 'success'){
        CommonUtils.successToast(context, result.message);
        referenceText = result.billingResult!.reference!;
        transactionSuccessDateTime =  DateFormat('d MMM yyyy,').add_jm().format(DateTime.now());
        // Navigator.of(context).pop();
        curShowPage += 1;
        EventHandler().send(BalanceEvent('wallet'));
      }
      else{
        CommonUtils.errorToast(context, result.message);

      }

    }
    catch(e){
      context.loaderOverlay.hide();
    }
  }


  _renderBillComplete() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            color: MyColors.base_green_color,
            child: Column(
              children: <Widget>[
                SizedBox(height: 35,),
                Icon(Icons.check_circle_outline, color: MyColors.grey_color,size: 30,),
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
                Row(
                  children: [
                    Text("Amount", style: TextStyle(
                        fontSize: 18,
                        // fontFamily: 'Doomsday',
                        color: Colors.black
                    )),
                    Expanded(child: SizedBox()),
                    Text(double.parse(amountController.text).toStringAsFixed(2), style: TextStyle(
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
                    Text(transactionSuccessDateTime, style: TextStyle(
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
                    Text("Billing Payment", style: TextStyle(
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
                    Text(userController.text, style: TextStyle(
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
    );
  }

  void transactionSuccessCallback(payload) {
    final snackBar = SnackBar(
      content: Text(payload.toString()),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void transactionFailureCallback(payload) {
    final snackBar = SnackBar(
      content: Text(payload.toString()),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  Widget renderBundleCategoryItem(categoryData){
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: MyColors.light_grey_color)),
      ),
      child: InkWell(
        splashColor: Colors.black.withAlpha(200),
        onTap: () {
          setState(() {
            currentBillOption = categoryData;
            userLabelName = categoryData['text'] == 'DSTV' ? "Smart Card Number" : "Decoder Number (ICU)";
          });

          getCategories(categoryData['data']);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(0, 15, 10, 15),
          child: Row(
            children: [
              Image.asset("assets/" +categoryData['image'] + ".png",height: 40,
                width: 65,),
              Expanded(child: Container(
                child: Text(categoryData['text'] + "",style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Doomsday',
                ),),
              )),

            ],
          ),
        ),
      ),
    );

  }
  Widget _renderBundleCategories(){
    //bundleCategories
    return Container(
      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: ListView.builder(
        itemCount: bundleCategories.length + 1,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext mContext, int index) =>
            (index == 0 ) ? Container(
              child:  InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  BuyElectricityFile()));
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(width: 12.5,),
                      Container(
                        color: MyColors.base_green_dark_color,
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Fontisto.lightbulb,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Buy Electricity',
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ) : renderBundleCategoryItem(bundleCategories[index -1]),
      ),
    );
  }
  _body(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: (curShowPage == 0)
            ? _renderBundleCategories()
            : curShowPage == 1 ? _renderBillsPage()
            : _renderBillComplete(),
      ),
    );
  }

  void validateSmartCardNumber(String value) async{
    print("Validate SmartCard Number");
    if(itemCode != null && billCode != null){
      context.loaderOverlay.show();
      try{

        GetFlutterWaveBillingVerificationApi getFlutterWaveBillingVerificationApi = new GetFlutterWaveBillingVerificationApi();
        FlutterwaveBillingVerificationModel _model = await getFlutterWaveBillingVerificationApi.search(itemCode!, billCode!, value);
        if(_model.status == "success"){
          _verificationData = _model.verificationData;
        }
        else{
          CommonUtils.errorToast(context, "The SmartCard number cannot be validated.");
        }
        context.loaderOverlay.hide();
      }
      catch(e){
        print("Error in validate SmartCard number");
        CommonUtils.errorToast(context, "The SmartCard number cannot be validated.");
        context.loaderOverlay.hide();
        print(e);
        // Navigator.pop(context);
      }

    }
  }
}
