import 'package:upaychat/Models/carddetaildata.dart';

import '../Models/virtualcarddetaildata.dart';
import 'network_utils.dart';

class VirtualCardListApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<VirtualCardListModel> search() {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.virtualcarddetails;

    return _netUtil
        .post(
      baseTokenUrl,
    )
        .then((dynamic res) {
      VirtualCardListModel result = new VirtualCardListModel.map(res);
      return result;
    });
  }
}