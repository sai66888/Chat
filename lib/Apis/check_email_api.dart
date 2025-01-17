import 'package:upaychat/Models/commonmodel.dart';

import 'network_utils.dart';

class CheckEmailApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> search(String email, [bool isExist = false]) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.checkemail;

    return _netUtil.post(
      baseTokenUrl,
      body: {
        "email": email,
        "isExist" : '${isExist}'
      },
    ).then((dynamic res) {
      CommonModel result = new CommonModel.map(res);
      return result;
    });
  }
}
