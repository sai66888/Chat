import 'package:upaychat/Models/commonmodel.dart';

import 'network_utils.dart';

class CheckMobileApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> search(String mobile, String exist, String isVoice) {
    // true: twilio, false: multitexter
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.checkmobile;

    return _netUtil.post(
      baseTokenUrl,
      body: {
        "mobile": mobile,
        "exist": exist,
        "isVoice": isVoice,
      },
    ).then((dynamic res) {
      CommonModel result = new CommonModel.map(res);
      return result;
    });
  }
}

class CheckMobileOTPApi{
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> search(String code, String _id) {
    // true: twilio, false: multitexter
    String baseTokenUrl = NetworkUtils.api_url + 'checkotp';

    return _netUtil.post(
      baseTokenUrl,
      body: {
        "code": code,
        "id": _id,

      },
    ).then((dynamic res) {
      CommonModel result = new CommonModel.map(res);
      return result;
    });
  }
}
