import 'package:upaychat/Models/addmoneytovirtualcardmodel.dart';
import 'package:upaychat/Models/addmoneytowalletmodel.dart';

import 'network_utils.dart';

class AddMoneyToVirtualCardApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<AddMoneyToVirtualCardModel> search(int virtualCardID,
      double totalamount, double amount, String gatewayname, String senderID, String receiverID,
      {String type = 'deposit'}) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.addmoneytovirtualcard;

    return _netUtil.post(
      baseTokenUrl,
      body: {
        "cardID": virtualCardID.toString(),
        "amount": amount.toString(),
        "totalamount": totalamount.toString(),
        "gatewayName": gatewayname.toString(),
        "senderID": "",
        "receiverID": "",
        "type": type
      },
    ).then((dynamic res) {
      AddMoneyToVirtualCardModel result = new AddMoneyToVirtualCardModel.map(res);
      return result;
    });
  }
}
