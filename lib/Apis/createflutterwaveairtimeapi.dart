

import '../Models/commonmodel.dart';
import '../Models/flutterwavebillingcreatedmodel.dart';
import 'network_utils.dart';

class CreateFlutterwaveAirtimeApi{
  NetworkUtils _netUtil = new NetworkUtils();
  Future<FlutterwaveBillingCreatedModel> save(String amount, String customerID, String recurrency) {
    String baseTokenUrl = NetworkUtils.api_url + "createflutterwaveairtime";

    Map body;
    body = {
      'amount' : amount,
      'customer' : customerID,
      'recurrency': recurrency
    };


    return _netUtil.post(baseTokenUrl, body: body).then((dynamic res) {
      FlutterwaveBillingCreatedModel result = new FlutterwaveBillingCreatedModel.map(res);
      return result;
    });
  }
}