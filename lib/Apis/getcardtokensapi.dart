
import 'dart:ffi';

import 'network_utils.dart';

class SavedCardsApi {
  NetworkUtils _netUtil = new NetworkUtils();
  double? totalAmount;
  double? chargeAmount;
  SavedCardsApi( double amount, double charge_amount){
    this.totalAmount = amount;
    this.chargeAmount = charge_amount;
  }
  Future<SavedCardsModel> search() {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.getsavedcards ;

    return _netUtil.post(baseTokenUrl,  body: {
        "total_amount": totalAmount.toString(),
        "charge_amount": chargeAmount.toString(),
      },  ).then((dynamic res) {
      SavedCardsModel result = new SavedCardsModel.map(res);
      return result;
    });
  }
}

class SavedCardsModel {
  String status = '';
  String message = '';
  String accessToken = '';
  List<SavedCardDetails> cardDetails = [];

  SavedCardsModel.map(dynamic obj){
    this.status = obj["status"].toString();
    this.message = obj["message"].toString();
    this.cardDetails =
        (obj['data'] as List).map((i) => SavedCardDetails.fromJson(i)).toList();
  }
}

class SavedCardDetails {
  String? authorization_code;
  String? last4;
  String? exp_month;
  String? exp_year;
  String? bank;
  String? brand;
  String? account_name;
  String? id;
  SavedCardDetails.fromJson(dynamic jsonMap)
        :authorization_code = jsonMap['authorization_code'].toString(),
        id = jsonMap['id'].toString(),
        last4 = jsonMap['last4'].toString(),
        exp_month = jsonMap['exp_month'].toString(),
        exp_year = jsonMap['exp_year'].toString(),
        bank = jsonMap['bank'].toString(),
        account_name = jsonMap['account_name'].toString(),
        brand = jsonMap['brand'].toString();
}
