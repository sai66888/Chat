import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/globals.dart';

class NetworkUtils {
  static const String api_url = Globals.base_url + '/api/';

  static const String login = 'login';
  static const String logout = 'logout';
  static const String register = 'register';
  static const String updateprofile = 'updateprofile';
  static const String checkemail = 'checkemail';
  static const String checkmobile = 'v2/checkmobile';
  static const String changepassword = 'changepassword';
  static const String wallet = 'wallet';
  static const String addmoneytowallet = 'addmoneytowallet';
  static const String usersearch = 'usersearch';
  static const String addtransaction = 'addtransaction';
  static const String addbanktransaction = 'addbanktransaction';
  static const String bankdetails = 'bankdetails';
  static const String addbank = 'addbank';
  static const String withdrawrequest = 'withdrawrequest';
  static const String pendingrequest = 'pendingrequest';
  static const String cancelrequest = 'cancelrequest';
  static const String acceptrequest = 'acceptrequest';
  static const String forgotpassword = 'forgotpassword';
  static const String addcomment = 'addcomment';
  static const String addlike = 'addlike';
  static const String transactionshistory = 'v3/transactionshistory';
  static const String mytransactionshistory = 'v2/mytransactionshistory';
  static const String faq = 'faq';
  static const String mynotification = 'mynotification';
  static const String stripepay = 'stripepay';
  static const String currenttime = 'currenttime';
  static const String carddetails = 'carddetails';

  static const String virtualcarddetails = 'virtualcarddetails';
  static const String virtualcardfulldetails = 'v2/virtualcardfulldetails';

  static const String virtualcarddetail = 'virtualcarddetail';
  static const String addmoneytovirtualcard = 'v2/addmoneytovirtualcard';
  static const String blockvirtualcard = 'v2/blockvirtualcard';
  static const String exchangerateurl = 'exchangerate';
  static const String deletebank = 'deletebank';
  static const String sendLocation = 'send_location';
  static const String getUsers = 'get_users';
  static const String deletecard = 'deletecard';

  static const String idverify = 'id_verify';
  static const String usercheck = 'user';
  static const String billingaddress = 'billingaddress';
  static const String getflutterwavecategories = 'getflutterwavecategories';

  static const String getsavedcards = 'getsavedcards';
  static const String removeSavedCard = 'removeSavedCard';
  static const String report_post = "report_post";

  static const String sendposcashrequest = 'send_pos_cash_request';
  static const String poscashwithdrawalresponse = 'pos_cash_withdrawal_response';
  static const String poscashwithdrawalresponsesuccess = 'pos_cash_withdrawal_response_success';
  static const String getPosRequestDatas = 'get_pos_request_datas';
  static const String getPosRequestData = 'get_pos_request_data';
  static const String safeLockFunds = 'safe_lock_funds';
  static const String loadFundsLocked = 'load_funds_locked';
  static const String enterReferralCode = 'enter_referral_code';
  static const String deleteAccountRequest = 'delete_account_request';
  static const String fetch_bank_transfer = 'fetch_bank_transfer';
  static const String checkCardHolder = 'check_card_holder';
  static const String createCardHolder = 'create_card_holder';

  static NetworkUtils _instance = new NetworkUtils.internal();

  NetworkUtils.internal();

  factory NetworkUtils() => _instance;

  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> post(String url, {body, encoding}) async {
    String token = PreferencesManager.getString(StringMessage.token);
    Map<String, String> headers;

    if (token != null) {
      // print(token);
      headers = {"Accept": "application/json",  "APP_VERSION" :  CommonUtils.CURRENT_APP_VERSION, "Authorization": "Bearer " + token};
    } else {
      headers = {
        "Accept": "application/json",  "APP_VERSION" :  CommonUtils.CURRENT_APP_VERSION
      };
    }

    return http.post(Uri.parse(url), body: body, headers: headers, encoding: encoding).then((http.Response response) {
      String res = response.body;
      int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 401 || json == null) {
        throw new Exception(statusCode);
      }
      else{
        try {
          dynamic result =  _decoder.convert(res);
          if(result['status'] == 'false' && result['message'] == 'APP_VERSION_ISSUE'){
            result['message'] = "Please update Upaychat APP";
            PreferencesManager.setString(StringMessage.newAppVersion,result['data']['version']);
            PreferencesManager.setBool(StringMessage.shallUpdate,true);
          }
          return result;
        } catch (e) {
          throw Exception("Couldn't Refresh Feed");
        }
      }

    }).timeout(const Duration(seconds: 300));
  }

  Future<dynamic> get(String url) async {
    String token = PreferencesManager.getString(StringMessage.token);
    print("APP_VERSION:${FlutterConfig.get("APP_VERSION")}");
    Map<String, String> headers;
    if (token != null) {
      headers = {"Accept": "application/json",  "APP_VERSION" :  CommonUtils.CURRENT_APP_VERSION, "Authorization": "Bearer " + token};
    } else {
      headers = {
        "Accept": "application/json",  "APP_VERSION" :  CommonUtils.CURRENT_APP_VERSION
      };
    }

    return http.get(Uri.parse(url), headers: headers).then((http.Response response) {
      String res = response.body;
      int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 401 || json == null) {
        throw new Exception(statusCode);
      }

      dynamic result =  _decoder.convert(res);
      if(result['status'] == 'false' && result['message'] == 'APP_VERSION_ISSUE'){
        result['message'] = "Please update Upaychat APP";
        PreferencesManager.setString(StringMessage.newAppVersion,result['data']['version']);
        PreferencesManager.setBool(StringMessage.shallUpdate,true);
      }
      return result;
    }).timeout(const Duration(seconds: 300));
  }
}

