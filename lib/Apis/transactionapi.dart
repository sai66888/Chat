import 'package:flutter/cupertino.dart';
import 'package:upaychat/Apis/network_utils.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/Models/transactionmodel.dart';

class TransactionApi {
  final NetworkUtils _netUtil = NetworkUtils();

  Future<TransactionModel> search(BuildContext context, {String type = 'all', int lastItemId = 0}) {
    String baseTokenUrl =
        NetworkUtils.api_url + NetworkUtils.transactionshistory;

    return _netUtil.post(baseTokenUrl, body: {
      "type": type,
      "lastItemId": "$lastItemId"
    }).then((dynamic res) {
      if (res["message"] == "Unauthenticated.") {
        CommonUtils.logout(context);
        return TransactionModel();
      } else {
        TransactionModel result = TransactionModel.map(res);
        return result;
      }
    });
  }
}
