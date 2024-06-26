import 'package:upaychat/Models/commonmodel.dart';

import 'network_utils.dart';

class UpdateUserKeyApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> save(String key,String value)
  {
    String baseTokenUrl = NetworkUtils.api_url + 'updateusersettings';
    Map body = {
      "key": key,
      "value": value,

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
