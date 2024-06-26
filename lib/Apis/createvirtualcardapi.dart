

import '../Models/commonmodel.dart';
import 'network_utils.dart';

class CreateVirtualCardAPI{
  NetworkUtils _netUtil = new NetworkUtils();
  Future<CommonModel> save(double totalAmount, double amount) {
    String baseTokenUrl = NetworkUtils.api_url + "v2/createvirtualcard";

    Map body;
      body = {
          'total_amount' : totalAmount.toString(),
          'amount' : amount.toString()
      };


    return _netUtil.post(baseTokenUrl, body: body).then((dynamic res) {
      CommonModel result = new CommonModel.map(res);
      return result;
    });
  }
}