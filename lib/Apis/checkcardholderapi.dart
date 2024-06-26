import 'package:upaychat/Models/commonmodel.dart';

import 'network_utils.dart';

class CheckCardHolderApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> check() {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.checkCardHolder;

    return _netUtil.post(
      baseTokenUrl,
      body: {},
    ).then((dynamic res) {
      CommonModel result = new CommonModel.map(res);
      return result;
    });
  }
}
