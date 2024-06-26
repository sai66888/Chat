import 'package:upaychat/Models/commonmodel.dart';

import 'network_utils.dart';

class SaveBillingAddressApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> save(
      String streetAddress,String city, String state, String zipCode, String country

      ) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.billingaddress;
    Map body = {
      "streetAddress": streetAddress,
      "city": city,
      "state": state ,
      "zipCode": zipCode,
      "country": country,
    };
    return _netUtil
        .post(
      baseTokenUrl,
      body: body,
    )
        .then((dynamic res) {
      CommonModel result = new CommonModel.map(res);
      return result;
    });
  }
}
