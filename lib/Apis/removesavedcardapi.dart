import '../Models/commonmodel.dart';
import 'network_utils.dart';

class RemoveSavedCardApi{
  NetworkUtils _netUtil = new NetworkUtils();

  Future<CommonModel> search(String cardID) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.removeSavedCard;

    return _netUtil.post(
      baseTokenUrl,
      body: {
        "card_id": cardID,
      },
    ).then((dynamic res) {
      CommonModel result = new CommonModel.map(res);
      return result;
    });
  }
}