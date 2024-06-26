
import 'package:flutter/cupertino.dart';

import '../Models/flutterwavecategoriesmodel.dart';
import 'network_utils.dart';

class GetFlutterWaveCategoriesApi {
  NetworkUtils _netUtil = new NetworkUtils();
  Future<FlutterwaveCategoriesModel> search(String billCode) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.getflutterwavecategories;
    baseTokenUrl += "?billCode=" + billCode;
    return _netUtil
        .get(
      baseTokenUrl,
    )
        .then((dynamic res) {
      FlutterwaveCategoriesModel result = new FlutterwaveCategoriesModel.map(res);
      return result;
    });
  }
}
