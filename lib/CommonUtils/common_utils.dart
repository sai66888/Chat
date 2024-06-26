import 'dart:async';
import 'dart:convert';
// import 'dart:js';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:upaychat/Apis/logout_api.dart';
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
import 'package:upaychat/Pages/delete_account_file.dart';
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
import 'package:upaychat/Pages/refer_earnings_file.dart';
import 'package:upaychat/Pages/register_file.dart';
import 'package:upaychat/Pages/safe_lock_file.dart';
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
import 'package:upaychat/Pages/withdraw_money_from_virtual_card.dart';
import 'package:uuid/uuid.dart';

import '../Apis/createvirtualcardapi.dart';
import '../Models/commonmodel.dart';
import '../Pages/account_manage_file.dart';
import '../Pages/add_money_to_virtual_card.dart';
import '../Pages/electricity_receipt_file.dart';
import '../Pages/new_funds_lock_file.dart';
import '../Pages/notification_settings_file.dart';
import '../Pages/profile_image_verification.dart';
import '../Pages/send_money_menu_file.dart';
import '../globals.dart';
import 'regexinputformatter.dart';
const AndroidNotificationChannel notificationChannel =
AndroidNotificationChannel(
  'upaychat_notification', // id
  'Upaychat Notification', // title
  description:
  'This channel is used for Upaychat notification.', // description
  importance: Importance.high,
);
class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
StreamController<String?>.broadcast();
final amountValidator = RegExInputFormatter.withRegex(
    '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,3})?\$');
final bvnValidator = RegExInputFormatter.withRegex(
    '^[0-9]*\$');
final formatCurrency = new NumberFormat("#,##0.00", "en_US");
const BankNumShowCount = 4;
const CardNumShowCount = 4;
const List<dynamic> bundleCategories = [
  {
    "text": "9Mobile Data Bundle",
    "image": "9mobile",
    "bill_code": "BIL111",
    "data": {
      "data": [
        {
          "id": 402,
          "biller_code": "BIL111",
          "name": "9MOBILE 1.5GB data bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "9MOBILE 1.5GB data bundle",
          "item_code": "MD154",
          "short_name": "9MOBILE 1.5GB data bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 1000
        },
        {
          "id": 405,
          "biller_code": "BIL111",
          "name": "9MOBILE 11GB data bundle ",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "9MOBILE 11GB data bundle ",
          "item_code": "MD361",
          "short_name": "9MOBILE 11GB data bundle ",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 4000
        },
        {
          "id": 406,
          "biller_code": "BIL111",
          "name": "9MOBILE 15GB data bundle ",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "9MOBILE 15GB data bundle ",
          "item_code": "MD362",
          "short_name": "9MOBILE 15GB data bundle ",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 5000
        },
        {
          "id": 17238,
          "biller_code": "BIL111",
          "name": "9MOBILE 1GB data bundle",
          "default_commission": 0.1,
          "date_added": "2022-09-19T18:28:19.13Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "9MOBILE 1GB data bundle",
          "item_code": "MD153",
          "short_name": "9MOBILE 1GB data bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 1000
        },
        {
          "id": 407,
          "biller_code": "BIL111",
          "name": "9MOBILE 27.5GB data bundle ",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "9MOBILE 27.5GB data bundle ",
          "item_code": "MD363",
          "short_name": "9MOBILE 27.5GB data bundle ",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 18000
        },
        {
          "id": 408,
          "biller_code": "BIL111",
          "name": "9MOBILE 30GB data bundle ",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "9MOBILE 30GB data bundle ",
          "item_code": "MD364",
          "short_name": "9MOBILE 30GB data bundle ",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 27500
        },
        {
          "id": 403,
          "biller_code": "BIL111",
          "name": "9MOBILE 4.5GB data bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "9MOBILE 4.5GB data bundle",
          "item_code": "MD155",
          "short_name": "9MOBILE 4.5GB data bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 2000
        },
        {
          "id": 404,
          "biller_code": "BIL111",
          "name": "9MOBILE 4GB data bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "9MOBILE 4GB data bundle",
          "item_code": "MD156",
          "short_name": "9MOBILE 4GB data bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 3000
        },
        {
          "id": 409,
          "biller_code": "BIL111",
          "name": "9MOBILE 60GB data bundle ",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "9MOBILE 60GB data bundle ",
          "item_code": "MD365",
          "short_name": "9MOBILE 60GB data bundle ",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 55000
        },
        {
          "id": 16871,
          "biller_code": "BIL111",
          "name": "9MOBILE 650 MB data bundle",
          "default_commission": 0.03,
          "date_added": "2020-05-30T00:00:00Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "9MOBILE 650 MB data bundle",
          "item_code": "MD152",
          "short_name": "9MOBILE 650 MB data bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 200
        }
      ]
    }
  },
  {
    "text": "Airtel Data Bundle",
    "image": "airtel",
    "bill_code": "BIL110",
    "data": {
      "data": [
        {
          "id": 392,
          "biller_code": "BIL110",
          "name": "AIRTEL 1.5GB data bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "AIRTEL 1.5GB data bundle",
          "item_code": "MD140",
          "short_name": "AIRTEL 1.5GB data bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 1000
        },
        {
          "id": 388,
          "biller_code": "BIL110",
          "name": "AIRTEL 100 MB data bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "AIRTEL 100 MB data bundle",
          "item_code": "MD136",
          "short_name": "AIRTEL 100 MB data bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 100
        },
        {
          "id": 396,
          "biller_code": "BIL110",
          "name": "AIRTEL 11GB Data Bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "AIRTEL 11GB Data Bundle",
          "item_code": "MD376",
          "short_name": "AIRTEL 11GB Data Bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 4000
        },
        {
          "id": 389,
          "biller_code": "BIL110",
          "name": "AIRTEL 200 MB data bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "AIRTEL 200 MB data bundle",
          "item_code": "MD137",
          "short_name": "AIRTEL 200 MB data bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 200
        },
        {
          "id": 397,
          "biller_code": "BIL110",
          "name": "AIRTEL 20GB Data Bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "AIRTEL 20GB Data Bundle",
          "item_code": "MD377",
          "short_name": "AIRTEL 20GB Data Bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 5000
        },
        {
          "id": 390,
          "biller_code": "BIL110",
          "name": "AIRTEL 350 MB data bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "AIRTEL 350 MB data bundle",
          "item_code": "MD138",
          "short_name": "AIRTEL 350 MB data bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 300
        },
        {
          "id": 393,
          "biller_code": "BIL110",
          "name": "AIRTEL 3GB Data Bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "AIRTEL 3GB Data Bundle",
          "item_code": "MD373",
          "short_name": "AIRTEL 3GB Data Bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 1500
        },
        {
          "id": 387,
          "biller_code": "BIL110",
          "name": "AIRTEL 40 MB data bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "AIRTEL 40 MB data bundle",
          "item_code": "MD135",
          "short_name": "AIRTEL 40 MB data bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 50
        },
        {
          "id": 398,
          "biller_code": "BIL110",
          "name": "AIRTEL 40GB Data Bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "AIRTEL 40GB Data Bundle",
          "item_code": "MD378",
          "short_name": "AIRTEL 40GB Data Bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 10000
        },
        {
          "id": 394,
          "biller_code": "BIL110",
          "name": "AIRTEL 6GB Data Bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "AIRTEL 6GB Data Bundle",
          "item_code": "MD374",
          "short_name": "AIRTEL 6GB Data Bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 2500
        },
        {
          "id": 391,
          "biller_code": "BIL110",
          "name": "AIRTEL 750 MB data bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "AIRTEL 750 MB data bundle",
          "item_code": "MD139",
          "short_name": "AIRTEL 750 MB data bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 500
        },
        {
          "id": 399,
          "biller_code": "BIL110",
          "name": "AIRTEL 75GB Data Bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "AIRTEL 75GB Data Bundle",
          "item_code": "MD379",
          "short_name": "AIRTEL 75GB Data Bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 15000
        }
      ]
    }
  },
  {
    "text": "GLO Data Bundle",
    "image": "glo",
    "bill_code": "BIL109",
    "data": {
      "data": [
        {
          "id": 376,
          "biller_code": "BIL109",
          "name": "GLO 1.05GB DATA BUNDLE ",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GLO 1.05GB DATA BUNDLE ",
          "item_code": "MD148",
          "short_name": "GLO 1.05GB DATA BUNDLE ",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 500
        },
        {
          "id": 380,
          "biller_code": "BIL109",
          "name": "GLO 10GB DATA BUNDLE",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GLO 10GB DATA BUNDLE",
          "item_code": "MD366",
          "short_name": "GLO 10GB DATA BUNDLE",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 3000
        },
        {
          "id": 386,
          "biller_code": "BIL109",
          "name": "GLO 119GB DATA BUNDLE",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GLO 119GB DATA BUNDLE",
          "item_code": "MD372",
          "short_name": "GLO 119GB DATA BUNDLE",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 18000
        },
        {
          "id": 381,
          "biller_code": "BIL109",
          "name": "GLO 13.25GB DATA BUNDLE",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GLO 13.25GB DATA BUNDLE",
          "item_code": "MD367",
          "short_name": "GLO 18GB DATA BUNDLE",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 4000
        },
        {
          "id": 382,
          "biller_code": "BIL109",
          "name": "GLO 18.25GB DATA BUNDLE",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GLO 18.25GB DATA BUNDLE",
          "item_code": "MD368",
          "short_name": "GLO 24GB DATA BUNDLE",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 5000
        },
        {
          "id": 377,
          "biller_code": "BIL109",
          "name": "GLO 2.5GB data purchase",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GLO 2.5GB data purchase",
          "item_code": "MD149",
          "short_name": "GLO 3.9GB data purchase",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 1000
        },
        {
          "id": 383,
          "biller_code": "BIL109",
          "name": "GLO 29.5GB DATA BUNDLE",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GLO 29.5GB DATA BUNDLE",
          "item_code": "MD369",
          "short_name": "GLO 29.5GB DATA BUNDLE",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 8000
        },
        {
          "id": 375,
          "biller_code": "BIL109",
          "name": "GLO 350 MB DATA BUNDLE",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GLO 350 MB DATA BUNDLE",
          "item_code": "MD147",
          "short_name": "GLO 350 MB DATA BUNDLE",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 200
        },
        {
          "id": 378,
          "biller_code": "BIL109",
          "name": "GLO 5.8GB data bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GLO 5.8GB data bundle",
          "item_code": "MD150",
          "short_name": "GLO 9.2GB data bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 2000
        },
        {
          "id": 384,
          "biller_code": "BIL109",
          "name": "GLO 50GB DATA BUNDLE",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GLO 50GB DATA BUNDLE",
          "item_code": "MD370",
          "short_name": "GLO 50GB DATA BUNDLE",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 10000
        },
        {
          "id": 379,
          "biller_code": "BIL109",
          "name": "GLO 7.2GB data bundle",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GLO 7.2GB data bundle",
          "item_code": "MD151",
          "short_name": "GLO 10.8GB data bundle",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 2500
        },
        {
          "id": 385,
          "biller_code": "BIL109",
          "name": "GLO 93GB DATA BUNDLE",
          "default_commission": 0.03,
          "date_added": "2020-02-11T11:16:42.727Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "GLO 93GB DATA BUNDLE",
          "item_code": "MD371",
          "short_name": "GLO 93GB DATA BUNDLE",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 15000
        }
      ]
    }
  },
  {
    "text": "MTN Data Bundle",
    "image": "mtn",
    "bill_code": "BIL108",
    "data": {
      "data": [
        {
          "id": 17638,
          "biller_code": "BIL108",
          "name": "MTN 11GB data purchase",
          "default_commission": 0.025,
          "date_added": "2023-01-09T00:12:38.213Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 11GB data purchase",
          "item_code": "MD570",
          "short_name": "MTN 11GB data purchase",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 3000
        },
        {
          "id": 17635,
          "biller_code": "BIL108",
          "name": "MTN 12GB data purchase",
          "default_commission": 0.025,
          "date_added": "2023-01-09T00:12:37.853Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 12GB data purchase",
          "item_code": "MD567",
          "short_name": "MTN 12GB data purchase",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 3500
        },
        {
          "id": 17641,
          "biller_code": "BIL108",
          "name": "MTN 13GB data purchase",
          "default_commission": 0.025,
          "date_added": "2023-01-09T00:12:38.563Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 13GB data purchase",
          "item_code": "MD573",
          "short_name": "MTN 11GB data purchase + 25MIN",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 3500
        },
        {
          "id": 17636,
          "biller_code": "BIL108",
          "name": "MTN 15000 data purchase\t",
          "default_commission": 0.025,
          "date_added": "2023-01-09T00:12:37.97Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 15000 data purchase\t",
          "item_code": "MD568",
          "short_name": "MTN 15000 data purchase\t",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 15000
        },
        {
          "id": 17202,
          "biller_code": "BIL108",
          "name": "MTN 1GB data purchase (1 day)",
          "default_commission": 0.025,
          "date_added": "2022-09-19T18:28:10.803Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 1GB data purchase (1 day)",
          "item_code": "MD489",
          "short_name": "MTN 1GB data purchase (1 day)",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 350
        },
        {
          "id": 16888,
          "biller_code": "BIL108",
          "name": "MTN 1GB data purchase (7 days)",
          "default_commission": 0.025,
          "date_added": "2020-05-30T00:00:00Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 1GB data purchase (7 days)",
          "item_code": "MD494",
          "short_name": "MTN 1GB data purchase (7 days)",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 600
        },
        {
          "id": 16873,
          "biller_code": "BIL108",
          "name": "MTN 2.5GB data purchase (2 Days)",
          "default_commission": 0.025,
          "date_added": "2020-05-30T00:00:00Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 2.5GB data purchase (2 Days)",
          "item_code": "MD496",
          "short_name": "MTN 2.5GB data purchase (2 Days)",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 600
        },
        {
          "id": 17682,
          "biller_code": "BIL108",
          "name": "MTN 20MB",
          "default_commission": 0.025,
          "date_added": "2023-09-19T19:20:27.587Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 20MB",
          "item_code": "MD591",
          "short_name": "MTN-20MB ",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 25
        },
        {
          "id": 17639,
          "biller_code": "BIL108",
          "name": "MTN 22GB data purchase",
          "default_commission": 0.025,
          "date_added": "2023-01-09T00:12:38.323Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 22GB data purchase",
          "item_code": "MD571",
          "short_name": "MTN 22GB data purchase",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 5000
        },
        {
          "id": 17637,
          "biller_code": "BIL108",
          "name": "MTN 25GB data purchase",
          "default_commission": 0.025,
          "date_added": "2023-01-09T00:12:38.087Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 25GB data purchase",
          "item_code": "MD569",
          "short_name": "MTN 25GB data purchase",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 10000
        },
        {
          "id": 17640,
          "biller_code": "BIL108",
          "name": "MTN 27GB data purchase",
          "default_commission": 0.025,
          "date_added": "2023-01-09T00:12:38.45Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 27GB data purchase",
          "item_code": "MD572",
          "short_name": "MTN 27GB data purchase",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 6000
        },
        {
          "id": 16886,
          "biller_code": "BIL108",
          "name": "MTN 2GB data purchase",
          "default_commission": 0.025,
          "date_added": "2020-05-30T00:00:00Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 2GB data purchase",
          "item_code": "MD492",
          "short_name": "MTN 2GB data purchase",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 1200
        },
        {
          "id": 17642,
          "biller_code": "BIL108",
          "name": "MTN 35GB data purchase",
          "default_commission": 0.025,
          "date_added": "2023-01-09T00:12:38.67Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 35GB data purchase",
          "item_code": "MD574",
          "short_name": "MTN 35GB data purchase",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 13500
        },
        {
          "id": 16885,
          "biller_code": "BIL108",
          "name": "MTN 3GB data purchase",
          "default_commission": 0.025,
          "date_added": "2020-05-30T00:00:00Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 3GB data purchase",
          "item_code": "MD491",
          "short_name": "MTN 3GB data purchase",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 1600
        },
        {
          "id": 17633,
          "biller_code": "BIL108",
          "name": "MTN 500MB data purchase",
          "default_commission": 0.025,
          "date_added": "2023-01-09T00:12:37.62Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 500MB data purchase",
          "item_code": "MD565",
          "short_name": "MTN 500MB data purchase",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 500
        },
        {
          "id": 17631,
          "biller_code": "BIL108",
          "name": "MTN 50MB data purchase",
          "default_commission": 0.025,
          "date_added": "2023-01-09T00:12:37.393Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 50MB data purchase",
          "item_code": "MD563",
          "short_name": "MTN 50MB data purchase",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 50
        },
        {
          "id": 17634,
          "biller_code": "BIL108",
          "name": "MTN 5GB data purchase",
          "default_commission": 0.025,
          "date_added": "2023-01-09T00:12:37.733Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 5GB data purchase",
          "item_code": "MD566",
          "short_name": "MTN 5GB data purchase",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 5000
        },
        {
          "id": 16887,
          "biller_code": "BIL108",
          "name": "MTN 6GB data purchase (7 days)",
          "default_commission": 0.025,
          "date_added": "2020-05-30T00:00:00Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "MTN 6GB data purchase (7 days)",
          "item_code": "MD493",
          "short_name": "MTN 6GB data purchase (7 days)",
          "fee": 0,
          "commission_on_fee": false,
          "label_name": "Mobile Number",
          "amount": 1500
        }
      ]
    }
  },
];
const List<String> recurrences = [
  "One Time",
  "Hourly",
  "Daily",
  "Weekly",
  "Monthly",
];

class CommonUtils {
  static const int CHECK_ONLINE_SECONDS = 5;
  static const int ONLINE_STATUS = 0;
  static const int OFFLINE_STATUS = -1;
  static const int TYPING_STATUS = 1;
  static const String USERID_PREFIX = "user_";
  static const String CURRENT_APP_VERSION = "12";
  bool isFlutterLocalNotificationsInitialized = false;

  static final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(
          MaterialCommunityIcons.wifi_off,
          color: Colors.white,
          size: 26,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'You are offline, Check your internet.',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Doomsday',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
    duration: Duration(days: 365),
    backgroundColor: Colors.red,
  );

  static String fbUser(String? id) {
    if (id == null) {
      id = '';
    }
    return USERID_PREFIX + id;
  }

  static String idFromFB(String str) {
    return str.replaceAll(USERID_PREFIX, "");
  }

  static String getStrUserid() {
    int userid = getUserid();
    if (userid == 0) return '';
    return userid.toString();
  }

  static int getUserid() {
    try {
      int userid = PreferencesManager.getInt(StringMessage.id);
      if (userid == 0) return 0;
      return userid;
    } catch (e) {}
    return 0;
  }
  static String extractInitials(String fullName) {
    // Remove leading and trailing whitespaces
    fullName = fullName.trim();

    // Check if there is a whitespace in the full name
    int whitespaceIndex = fullName.indexOf(' ');

    if (whitespaceIndex != -1) {
      // Split by whitespace and get the first characters
      List<String> names = fullName.split(' ');
      if (names.length >= 2) {
        // Take the first character of the first name and the first character of the last name
        return "${names[0][0]}${names[names.length - 1][0]}".toUpperCase();
      }
    } else if (fullName.length > 1) {
      // If there is no whitespace and the full name has at least 2 characters,
      // take the first two characters
      return fullName.substring(0, 2).toUpperCase();
    }

    // If the full name is empty or contains only one character, return the full name
    return fullName.toUpperCase();
  }
  static String tokenFormat(String oldToken){
    oldToken = oldToken.replaceAll('-', '');
    int n = 4;
    if (oldToken.length <= n) return oldToken;
    final buffer = StringBuffer();
    for (int i = 0; i < oldToken.length; i++) {
      buffer.write(oldToken[i]);
      if ((i + 1) % n == 0 && i != oldToken.length - 1) {
        buffer.write('-');
      }
    }
    return buffer.toString();
  }
  static dynamic returnRoutes(BuildContext context) {
    return {
      '/splashscreensec': (context) => SplashScreen(),
      '/login': (context) => LoginFile(),
      '/register': (context) => RegisterFile(),
      '/home': (context) => HomeFile(),
      '/forgotpassword': (context) => ForgotPassword(),
      '/passwordupdate': (context) => PasswordUpdateFile(),
      '/setting': (context) => SettingFile(),
      '/editprofile': (context) => EditProfile(),
      '/transaction': (context) => TransactionHistory(),
      '/addcard': (context) => AddCardFile(),
      '/addbank': (context) => AddBankFile(),
      '/changepassword': (context) => ChangePasswordFile(),
      '/searchpeople': (context) => SearchPeopleFile(),
      '/pending': (context) => Requests(),
      '/deposit': (context) => DepositFile(),
      '/withdraw': (context) => Withdraw(),
      '/banklist': (context) => BankListFile(),
      '/notification': (context) => NotificationFile(),
      '/notification_settings': (context) => NotificationSettingsFile(),
      '/faq': (context) => FaqFile(),
      '/contactus': (context) => ChatTawk(),
      '/pickcontact': (context) => PickContactFile(),
      '/airtime_data': (context) => AirtimeDataFile(),
      '/buy_electricity': (context) => BuyElectricityFile(),
      '/pay_bills': (context) => PayBillsFile(),
      '/identity_verification': (context) => IdentityVerificationFile(),
      '/transaction_detail': (context) => TransactionDetail(),
      '/offline': (context) => OfflineFile(),
      '/mycards': (context) => MyCardsFile(),
      '/addvitualcard': (context) => AddNewVitualCardFile(),
      '/virtualcarddetail': (context) => VirtualCardDetailFile(),
      '/addmoneytovitualcard': (context) => AddMoneyToVirtualCardFile(),
      '/virtualcardfulldetails': (context) => VirtualCardDetailsFile(),
      '/transaction_detail_electricity' : (context) => TransactionDetailForElectricity(),
      '/pos_cash_withdrawal' : (context) => PosCashWithdrawal(),
      '/requests' : (context) => Requests(),
      '/safelock':  (context) => SafeLockFile(),
      '/new_funds_lock':  (context) => NewFundsLockFile(),
      '/refer_earn':  (context) => ReferEarningsFile(),
      '/withdrawmoneyfromvitualcard': (context) => WithdrawMoneyFromVirtualCardFile(),
      '/manageaccount': (context) => AccountManagementFile(),
      '/deleteaccount': (context) => DeleteAccountFile(),
      '/send_money_menu': (context) => SendMoneyMenuFile(),
      '/profile_image_verification': (context) => ProfileImageVerification()
    };
  }

  static errorToast(BuildContext context, String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 0,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 20);
  }

  static messageToast(BuildContext context, String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black26,
        textColor: Colors.white,
        fontSize: 20);
  }

  static successToast(BuildContext context, String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: MyColors.base_green_color,
        textColor: Colors.white,
        fontSize: 20);
  }

  static String toCurrency(double amount) {
    return formatCurrency.format(amount);
  }

  static bool validateEmail(String email) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern.toString());
    if (!(regex.hasMatch(email)))
      return false;
    else
      return true;
  }

  static bool validateMobile(String mobile) {
    String pattern = r'(^([0]|[+]234|[+]1)[0-9]{10}$)';
    RegExp regExp = new RegExp(pattern);
    if (mobile.isNotEmpty) {
      return regExp.hasMatch(mobile);
    }
    return false;
  }

  static bool isEmpty(TextEditingController controller, int length) {
    String text = controller.text;
    if (text.isEmpty || text.length < length) {
      return true;
    } else {
      return false;
    }
  }

  static void saveData(LoginModel result, BuildContext context) {
    PreferencesManager.setBool(StringMessage.isLogin, true);

    PreferencesManager.setBool(StringMessage.shallLogout,false);
    PreferencesManager.setBool(StringMessage.shallUpdate,false);
    PreferencesManager.setInt(StringMessage.id, result.id);
    PreferencesManager.setString(StringMessage.firstname, result.firstname);

    PreferencesManager.setString(StringMessage.street, result.street ?? '');
    PreferencesManager.setString(StringMessage.house_no, result.house_no ?? '');
    PreferencesManager.setString(StringMessage.city, result.city ?? '');
    PreferencesManager.setString(StringMessage.state, result.state ?? '');
    PreferencesManager.setString(StringMessage.zipcode, result.zipcode ?? '');
    PreferencesManager.setString(StringMessage.bvn, result.bvn ?? '');


    PreferencesManager.setString(StringMessage.token, result.token);
    PreferencesManager.setString(StringMessage.roll, result.roll);
    PreferencesManager.setString(
        StringMessage.profileimage, result.profile_image);
    PreferencesManager.setString(StringMessage.lastname, result.lastname);
    PreferencesManager.setString(StringMessage.username, result.username);
    PreferencesManager.setString(StringMessage.email, result.email);
    PreferencesManager.setString(StringMessage.birthday, result.birthday);
    PreferencesManager.setString(StringMessage.mobile, result.mobile);
    PreferencesManager.setString(StringMessage.defaultprivacy, 'public');

    PreferencesManager.setBool(StringMessage.notification_push_money_received,
        result.notification_push_money_received);
    PreferencesManager.setBool(StringMessage.notification_push_money_sent,
        result.notification_push_money_sent);
    PreferencesManager.setBool(StringMessage.notification_push_bank_withdraw,
        result.notification_push_bank_withdraw);
    PreferencesManager.setBool(
        StringMessage.notification_push_likes, result.notification_push_likes);
    PreferencesManager.setBool(StringMessage.notification_push_comments,
        result.notification_push_comments);
    PreferencesManager.setBool(StringMessage.notification_sms_money_received,
        result.notification_sms_money_received);
    PreferencesManager.setBool(StringMessage.notification_sms_money_sent,
        result.notification_sms_money_sent);
    PreferencesManager.setBool(StringMessage.notification_email_money_received,
        result.notification_email_money_received);
    PreferencesManager.setBool(StringMessage.notification_email_money_sent,
        result.notification_email_money_sent);
    PreferencesManager.setBool(StringMessage.notification_email_bank_withdraw,
        result.notification_email_bank_withdraw);

    Globals.notification_push_money_received =
        result.notification_push_money_received;
    Globals.notification_push_money_sent = result.notification_push_money_sent;
    Globals.notification_push_bank_withdraw =
        result.notification_push_bank_withdraw;
    Globals.notification_push_likes = result.notification_push_likes;
    Globals.notification_push_comments = result.notification_push_comments;
    Globals.notification_sms_money_received =
        result.notification_sms_money_received;
    Globals.notification_sms_money_sent = result.notification_sms_money_sent;
    Globals.notification_email_money_received =
        result.notification_email_money_received;
    Globals.notification_email_money_sent =
        result.notification_email_money_sent;
    Globals.notification_email_bank_withdraw =
        result.notification_email_bank_withdraw;

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (c) => HomeFile()), (route) => false);
  }

  static void logout(BuildContext context) async {
    showProgressDialogComplete(context, true);
    try{

      LogoutApi logoutApi = LogoutApi();
      await logoutApi.logout();
      Navigator.pop(context);
      PreferencesManager.setBool(StringMessage.isLogin, false);
      FirebaseMessaging.instance.deleteToken();
      PreferencesManager.setBool(StringMessage.shallLogout,false);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginFile()), (route) => false);
    }
    catch(e){
      Navigator.pop(context);
      PreferencesManager.setBool(StringMessage.isLogin, false);
      FirebaseMessaging.instance.deleteToken();
      PreferencesManager.setBool(StringMessage.shallLogout,false);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginFile()), (route) => false);
      errorToast(context, e.toString());
    }

  }

  static void showProgressDialogComplete(
      BuildContext context, bool isDelay) async {
    if (isDelay) {
      await Future.delayed(Duration(milliseconds: 150));
    }
    try {

      showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel:
          MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: Colors.black45,
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (BuildContext buildContext, Animation animation,
              Animation secondaryAnimation) {
            return Center(
              child: Container(
                height: 65,
                width: 65,
                child: SpinKitChasingDots(
                  color: MyColors.base_green_color,
                  size: 50.0,
                ),
              ),
            );
          });
    } catch (e) {
      print(e);
    }
  }

  static progressDialogBox() {
    return Center(
      child: Container(
        height: 65,
        width: 65,
        child: SpinKitChasingDots(
          color: MyColors.base_green_color,
          size: 50.0,
        ),
      ),
    );
  }

  static String timesAgoFeature(String fromDate) {
    try {
      DateTime dateTime = DateTime.parse(fromDate);
      var locale = 'en';
      String timeMsg = timeago.format(dateTime, locale: locale);
      return timeMsg;
    } catch (e) {
      print(e);
      return '';
    }
  }

  static String formattedTime(String fromDate) {
    try {
      DateTime dateTime = DateTime.parse(fromDate);
      dateTime = dateTime.add(DateTime.now().timeZoneOffset);
      final format = new DateFormat('dd/MM/yyyy hh:mm');
      return format.format(dateTime);
    } catch (e) {
      print(e);
      return '';
    }
  }

  static String formattedDate(DateTime dateTime) {
    try {
      dateTime = dateTime.add(DateTime.now().timeZoneOffset);
      final format = new DateFormat('dd/MM/yyyy');
      return format.format(dateTime);
    } catch (e) {
      print(e);
      return "";
    }
  }

  static String dbFormattedDate(DateTime dateTime) {
    try {
      dateTime = dateTime.add(DateTime.now().timeZoneOffset);
      final format = new DateFormat('yyyy-MM-dd');
      return format.format(dateTime);
    } catch (e) {
      print(e);
      return "";
    }
  }

  static bool checkStringId(String str) {
    return str != '' && str.isNotEmpty && int.parse(str) > 0;
  }

  static const _upper_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _lower_chars = 'abcdefghijklmnopqrstuvwxyz';
  static const _number_chars = '1234567890';

  static String getIDVerificationCode(){
    return PreferencesManager.getString(StringMessage.iDVerificationCode);
  }
  static String generateIDVerificationCode(){
    String verification_code = CommonUtils.getRandomString(length: 8, isLower: false);
    PreferencesManager.setString(StringMessage.iDVerificationCode, verification_code);
    return verification_code;
  }

  static String getRandomString(
      {int length = 0,
        bool isUpper = true,
        bool isLower = true,
        bool isNum = true}) {
    Random _rnd = Random();
    String _chars = "";
    if (isUpper) _chars += _upper_chars;
    if (isLower) _chars += _lower_chars;
    if (isNum) _chars += _number_chars;
    if (_chars == '' || _chars.isEmpty) return "";
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static String bankNumberHolder(String banknumber) {
    int len = max(0, banknumber.length - BankNumShowCount);
    return "•••••••" + banknumber.substring(len);
  }

  static String fullCardNumberHolder(String cardNumber) {
    final maxLength = 19; // Maximum length of a card number with spaces
    final spaceInterval = 4; // Interval to insert spaces between groups of digits

    // Remove all non-digit characters from the card number
    var digitsOnly = cardNumber.replaceAll(RegExp(r'\D+'), '');

    if (digitsOnly.length > maxLength) {
      digitsOnly = digitsOnly.substring(0, maxLength);
    }

    // Insert spaces at specified intervals
    final formattedNumber = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i += spaceInterval) {
      final end = i + spaceInterval;
      final chunk = digitsOnly.substring(i, end < digitsOnly.length ? end : digitsOnly.length);
      formattedNumber.write(chunk);
      if (end < digitsOnly.length) {
        formattedNumber.write(' ');
      }
    }

    return formattedNumber.toString();
  }

  static String cardNumberHolder(String cardnumber) {
    cardnumber = cardnumber.replaceAll(" ", "");
    int len = max(0, cardnumber.length - CardNumShowCount);
    return "•••• •••• •••• " + cardnumber.substring(len);
  }

  static Future<String> isIdAllowed() async {
    try{
      UserCheckApi checkApi = new UserCheckApi();
      var res = await checkApi.search();
      if (res.status == "true") {
        if (res.data['user_status'] == "off") {
          return "Please complete your identity verification on settings page.";
        }
      }
      return "true";
    }
    catch (e){
      return 'false';
    }

  }

  static bool phoneVerified() {
    String mobileNumber = PreferencesManager.getString(StringMessage.mobile);
    return mobileNumber != '' &&
        mobileNumber != "null" &&
        mobileNumber.isNotEmpty;
  }

  static getTargetPath(String path) {
    return path
        .replaceAll(".jpg", "1.jpg")
        .replaceAll(".png", "1.png")
        .replaceAll(".gif", "1.gif");
  }

  static createAccessCode(double totalAmount, double amount) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization':
      'Bearer ' + PreferencesManager.getString(StringMessage.paystackSecKey)
    };
    Map data = {
      "amount": (totalAmount * 100).round(),
      "email": PreferencesManager.getString(StringMessage.email),
      "metadata" : {
        "charge_amount": amount.toString(),
        "cancel_action" : "upaychat://cancel"
      },
      "callback_url": "upaychat://success"
    };
    String payload = json.encode(data);
    http.Response response = await http.post(
      Uri.parse('https://api.paystack.co/transaction/initialize'),
      headers: headers,
      body: payload,
    );
    return jsonDecode(response.body);
  }

  static createFlutterwaveLink(double totalAmount, double amount) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization':
      'Bearer ' + PreferencesManager.getString(StringMessage.flutterwaveSecKey)
    };
    Map data = {
      "amount": (totalAmount * 100).round(),
      "email": PreferencesManager.getString(StringMessage.email),
      "metadata" : {
        "charge_amount": amount.toString(),
        "cancel_action" : "com.upaychat.com://cancel"
      }
    };
    String payload = json.encode(data);
    http.Response response = await http.post(
      Uri.parse('https://api.paystack.co/transaction/initialize'),
      headers: headers,
      body: payload,
    );
    return jsonDecode(response.body);
  }
  static  void showNotificationWithTextAction(
      RemoteMessage message, {String payload = "general", bool isFromBackground = false}) async {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      String? newTitle = notification.title;
      String? newBody = notification.body;
      String messageCategory = message.data['category'].toString();

      print("Notification Title ${notification.title}: ${messageCategory}");
      if(notification.title == "Session Expired"){
        // CommonUtils.logout(conte);
        PreferencesManager.setBool(StringMessage.isLogin, false);
        PreferencesManager.setString(StringMessage.token, "");
        FirebaseMessaging.instance.deleteToken();

        newTitle = "You’ve been signed out";//notification.title = "";
        PreferencesManager.setBool(StringMessage.shallLogout,true);
      }
      AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
          notificationChannel.id, notificationChannel.name,
          channelDescription: notificationChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          //ticker: 'ticker',
          icon: '@mipmap/launcher_icon'
      );

      const DarwinNotificationDetails darwinNotificationDetails =
      DarwinNotificationDetails(
        categoryIdentifier: darwinNotificationCategoryText,
      );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
        macOS: darwinNotificationDetails,
      );
      int notificatonUniqueId = notification.hashCode;
      await flutterLocalNotificationsPlugin.show(
          notificatonUniqueId,
          newTitle,
          newBody,
          notificationDetails,
          payload: payload).then((value) {
        if(messageCategory == "cash_request"){
          Timer(Duration(seconds: 90), ()async {
            print("Cancel Notification:${notificatonUniqueId}");
            await flutterLocalNotificationsPlugin.cancel(notificatonUniqueId);
          });
        }
      });
    }
  }


  static void showIncomingRequestNotification(cashRequestData, DateTime requestCreated) async{
    print(cashRequestData);
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        'pos_cash_request', notificationChannel.name,
        channelDescription: notificationChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        //ticker: 'ticker',
        icon: '@mipmap/ic_launcher'
    );

    const DarwinNotificationDetails darwinNotificationDetails =
    DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryText,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );
    /*
    * {
    *   amount: 1,000.00,
    *   from_id: 1394,
    *   meet_lng: 3.3080317,
    *   created_at: 1683830037314,
    *   meet_lat: 6.4790067,
    *   to_id: 326,
    *   state: request
    * }
    * */
    int notificationUniqueId  = (cashRequestData['created_at'] / 100).round() % 10000000;

    await flutterLocalNotificationsPlugin.show(
        notificationUniqueId,
        "New POS Cash Request",
        "A new cash request is coming in from ${cashRequestData['from_user']} for ${cashRequestData['amount']}NGN",
        notificationDetails,
        payload: "cash_request:${cashRequestData['pos_id']}").then((value) {
          print("Notification ${notificationUniqueId}will be closed after :${DateTime.now().difference(requestCreated).inSeconds.abs()}, ${90 - DateTime.now().difference(requestCreated).inSeconds.abs()} seconds");
        Timer(Duration(seconds: 90 - DateTime.now().difference(requestCreated).inSeconds.abs()), ()async {
          print("Cancel Notification:${notificationUniqueId}");
          await flutterLocalNotificationsPlugin.cancel(notificationUniqueId);
        });
    });
  }
}




const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'com.upaychat.finance';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'com.upaychat.finance';




const String cashIconName = 'assets/ic_cashout.svg';




