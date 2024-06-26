import 'package:upaychat/Models/commonmodel.dart';

import 'network_utils.dart';

class EnterRefferalCodeApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> enterCode(String referral) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.enterReferralCode;

    return _netUtil.post(
      baseTokenUrl,
      body: {
        "code": referral,
      },
    ).then((dynamic res) {
      return CommonModel.map(res);
    });
  }
}
