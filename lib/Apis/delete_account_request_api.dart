import 'package:upaychat/Models/commonmodel.dart';

import 'network_utils.dart';

class DeleteAccountRequestApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> sendRequest(String password) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.deleteAccountRequest;

    return _netUtil.post(
      baseTokenUrl, body: {'password': password}
    ).then((dynamic res) {
      return CommonModel.map(res);
    });
  }
}
