
import 'package:flutter/cupertino.dart';
import 'package:upaychat/Models/flutterwavebillingstatusmodel.dart';

import '../Models/flutterwavebillingverificationmodel.dart';
import '../Models/flutterwavecategoriesmodel.dart';
import 'network_utils.dart';

class GetFlutterWaveBillingStatusApi {
  NetworkUtils _netUtil = new NetworkUtils();
  Future<FlutterwaveBillingStatusModel> search(String reference) {
    String baseTokenUrl = NetworkUtils.api_url + "getflutterwavebillingstatus";
    baseTokenUrl += "?reference=" + reference ;
    return _netUtil
        .get(
      baseTokenUrl,
    )
        .then((dynamic res) {
      FlutterwaveBillingStatusModel result = new FlutterwaveBillingStatusModel.map(res);
      return result;
    });
  }
}
