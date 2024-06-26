import 'package:upaychat/Models/commonmodel.dart';

import 'network_utils.dart';

class SaveCardRequestApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> save(String reference)
  {
    String baseTokenUrl = NetworkUtils.api_url + 'savepaystackcard';
    Map body = {
      "reference": reference,

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
