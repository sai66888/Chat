import 'package:upaychat/Apis/network_utils.dart';
import 'package:upaychat/Models/commonmodel.dart';

import '../Models/funds_locked.dart';
class LoadFundsLocked{
  NetworkUtils _netUtil = new NetworkUtils();
  Future<FundsLockedListModel> loadData() async {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.loadFundsLocked;
    return _netUtil
        .get(
      baseTokenUrl,
    ).then((dynamic res) {
      FundsLockedListModel result = new FundsLockedListModel.map(res);
      return result;
    });
  }
}