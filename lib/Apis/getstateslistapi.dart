import 'package:upaychat/Models/commonmodel.dart';

import 'network_utils.dart';

class StatesListAPI {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> search() {
    String baseTokenUrl = NetworkUtils.api_url + 'get_states';

    return _netUtil
        .post(
      baseTokenUrl,
    )
        .then((dynamic res) {
      CommonModel result = new CommonModel.map(res);
      return result;
    });
  }
}
