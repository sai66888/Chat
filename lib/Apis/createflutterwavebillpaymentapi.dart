

import '../Models/commonmodel.dart';
import '../Models/flutterwavebillingcreatedmodel.dart';
import 'network_utils.dart';

class CreateFlutterwaveBillPaymentApi{
  NetworkUtils _netUtil = new NetworkUtils();
  Future<FlutterwaveBillingCreatedModel> save(String databundleOption, String amount, String totalAmount,String customerID, String recurrency, {int isElectricity = 0}) {
    String baseTokenUrl = NetworkUtils.api_url + "createflutterwavebillpayment";

    Map body;
    body = {
      'bundle': databundleOption,
      'amount' : amount,
      'total_amount' : totalAmount,
      'customer' : customerID,
      'recurrency': recurrency,
      'is_electricity' : '$isElectricity'
    };


    return _netUtil.post(baseTokenUrl, body: body).then((dynamic res) {
      FlutterwaveBillingCreatedModel result = new FlutterwaveBillingCreatedModel.map(res);
      return result;
    });
  }
}