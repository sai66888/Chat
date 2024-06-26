import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/Models/commonmodel.dart';

import 'network_utils.dart';

class ReportApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> report(String reportComment, String parentID, String isPost) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.report_post;

    return _netUtil.post(
      baseTokenUrl,
      body: {"report_comment": reportComment, "parent": parentID, "is_post": isPost},
    ).then((dynamic res) {
      CommonModel result = new CommonModel.map(res);
      return result;
    });
  }
}