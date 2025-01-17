import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:upaychat/Apis/network_utils.dart';
import 'package:upaychat/Models/loginmodel.dart';

class LoginApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<LoginModel> search(String loginUser, String password, String deviceId) async {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.login;
    String? fcmToken;
    try{
      fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
    }
    catch(e){

    }


    print('FCM TOken');
    return _netUtil.post(
      baseTokenUrl,
      body: {
        "login_user": loginUser,
        "password": password,
        'fcm_token': fcmToken ?? '',
        'deviceId': deviceId ?? '',
        'app_version': '2.0.1'
      },
    ).then((dynamic res) {
      LoginModel result = new LoginModel.map(res);
      return result;
    });
  }
}
