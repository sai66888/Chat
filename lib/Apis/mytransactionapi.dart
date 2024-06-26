import 'package:upaychat/Apis/network_utils.dart';
import 'package:upaychat/Models/mytransactionmodel.dart';

class MyTransactionApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<MyTransactionModel> search({int lastItemId = 0}) {
    String baseTokenUrl =
        NetworkUtils.api_url + NetworkUtils.mytransactionshistory;

    return _netUtil
        .post(
      baseTokenUrl,
      body: {
        "lastItemId": "$lastItemId"
      }
    )
        .then((dynamic res) {
      MyTransactionModel result = new MyTransactionModel.map(res);
      return result;
    });
  }
}
