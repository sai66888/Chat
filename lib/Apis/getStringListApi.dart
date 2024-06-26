import 'network_utils.dart';

class GetStringListApi{
  NetworkUtils _netUtil = new NetworkUtils();
  Future<StringListModel> search(String action) {
    String baseTokenUrl = NetworkUtils.api_url ;//+ "getflutterwavebillingverification";
    baseTokenUrl += action;

    return _netUtil
        .get(
      baseTokenUrl,
    )
        .then((dynamic res) {
      StringListModel result = new StringListModel.map(res);
      return result;
    });
  }
}

class StringListModel {
  String status = '';
  String message = '';
  List<String> data = [];
  StringListModel.map(dynamic obj) {
    this.status = obj["status"].toString();
    this.message = obj["message"].toString();
    this.data =(obj['data'] as List).map((i) => i.toString()).toList();
  }

}