import 'package:flutter/cupertino.dart';
import 'package:upaychat/Apis/network_utils.dart';
import 'package:upaychat/Models/commonmodel.dart';

class PayApiRequest {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> search(String amount, String privacy, String caption,
      String toUserId, String user, String transactionType) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.addtransaction;

    return _netUtil.post(
      baseTokenUrl,
      body: {
        "touser_id": toUserId,
        "user": user,
        "transaction_type": transactionType,
        "amount": amount,
        "caption": caption,
        "privacy": privacy,
      },
    ).then((dynamic res) {
      CommonModel result = new CommonModel.map(res);
      return result;
    });
  }
}

class GetBankTransferFeeApi{
  //getbanktransferfee
  NetworkUtils _netUtil = new NetworkUtils();
  Future<BankTransferFeeModel> search(String amount) {
    String baseTokenUrl = NetworkUtils.api_url + "getbanktransferfee?amount=${amount}&currency=NGN" ;
    return _netUtil
        .get(
      baseTokenUrl,
    )
        .then((dynamic res) {
      BankTransferFeeModel result = new BankTransferFeeModel.map(res);
      return result;
    });
  }
}

class BankTransferFeeModel {
  String status = '';
  String message = '';
  List<BankTransferFeeData> feeList = [];

  BankTransferFeeModel.map(dynamic obj) {
    this.status = obj["status"].toString();
    this.message = obj["message"].toString();
    List resultList = obj['data'] as List;
    final  usedShortName = <String>[];
    for(int i = 0 ; i <resultList.length ; i ++ ){
      BankTransferFeeData tmpData = BankTransferFeeData.fromJson(obj['data'][i]);
      this.feeList.add(tmpData);
    }
    //
    // this.categoriesList =
    //     (obj['data'] as List).map((i) => {
    //       return FlutterwaveCategoriesData.fromJson(i);
    //     }).toList();
  }
}

class BankTransferFeeData {
  double fee;
  String currency;
  BankTransferFeeData.fromJson(Map jsonMap)
      : fee = double.parse(jsonMap['fee'].toString()),
        currency = jsonMap['currency'].toString();
  BankTransferFeeData({Key? key,required this.fee, required this.currency});
}


class PayBankApiRequest {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> search(String toUserId, String amount, String privacy, String caption,
      String bank_code, String account_number, double fee) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.addbanktransaction;

    return _netUtil.post(
      baseTokenUrl,
      body: {
        "touser_id": toUserId,
        "bank_code": bank_code,
        "account_number": account_number,
        "amount": amount,
        "caption": caption,
        "privacy": privacy,
        "fee_amount" : fee.toString()
      },
    ).then((dynamic res) {
      CommonModel result = new CommonModel.map(res);
      return result;
    });
  }
}

