import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:upaychat/Apis/network_utils.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/Models/loginmodel.dart';

class LogoutApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> logout() async {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.logout;
    print(baseTokenUrl);
    return _netUtil.post(
      baseTokenUrl).then((dynamic res) {
      CommonModel result = new CommonModel.map(res);
      return result;
    });
  }
}
