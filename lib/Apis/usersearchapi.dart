import 'package:upaychat/Apis/network_utils.dart';
import 'package:upaychat/Models/usersearchmodel.dart';

class UserSearchApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<UserSearchModel> search({String roll = '', String query = ''}) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.usersearch;

    return _netUtil.post(
      baseTokenUrl,
      body: {
        'roll': roll,
        'query' : query
      },
    ).then((dynamic res) {
      UserSearchModel result = new UserSearchModel.map(res);
      return result;
    });
  }
}
