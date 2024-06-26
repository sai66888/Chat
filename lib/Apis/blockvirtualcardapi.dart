import 'package:upaychat/Models/commonmodel.dart';

import 'network_utils.dart';

class BlockVirtualCardApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> save(
      int cardID

      ) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.blockvirtualcard;
    Map body = {
      "card_id": cardID.toString()
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
