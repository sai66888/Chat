
import 'dart:ffi';

import 'network_utils.dart';

class ExchangeRateApi {
  NetworkUtils _netUtil = new NetworkUtils();
  int? cardID;
  VirtualCardDetailApi( int card_id){
    this.cardID = card_id;
  }
  Future<int> search({String type = 'exchange'}) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.exchangerateurl ;

    return _netUtil.post(baseTokenUrl, body: {
      "type": type,
    },).then((dynamic res) {

      int result = int.parse(res['result'].toString() );
      return result;
    });
  }
}
