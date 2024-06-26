
import 'package:flutter/cupertino.dart';

import '../Models/flutterwavebillingverificationmodel.dart';
import '../Models/flutterwavecategoriesmodel.dart';
import 'network_utils.dart';

class GetFlutterWaveBillingVerificationApi {
  NetworkUtils _netUtil = new NetworkUtils();
  Future<FlutterwaveBillingVerificationModel> search(String itemCode, String billCode, String customer) {
    String baseTokenUrl = NetworkUtils.api_url + "getflutterwavebillingverification";
    baseTokenUrl += "?itemCode=" + itemCode + "&billCode=" + billCode + "&customer=" + customer;
    return _netUtil
        .get(
      baseTokenUrl,
    )
        .then((dynamic res) {
      FlutterwaveBillingVerificationModel result = new FlutterwaveBillingVerificationModel.map(res);
      return result;
    });
  }
}
