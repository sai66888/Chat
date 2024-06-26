import 'package:upaychat/Models/faqmodel.dart';

import 'network_utils.dart';

class FetchBankTransferApi {
  NetworkUtils _netUtil = new NetworkUtils();

  Future<BankTransferDetailsModel> search(String transactionID) {
    String baseTokenUrl =
        NetworkUtils.api_url + NetworkUtils.fetch_bank_transfer;

    return _netUtil.post(baseTokenUrl,
        body: {"transaction_id": transactionID}).then((dynamic res) {
      BankTransferDetailsModel result = new BankTransferDetailsModel.map(res);
      return result;
    });
  }
}

class BankTransferDetailsModel {
  String status = '';
  String message = '';
  BankTransferDetails? data;
  BankTransferDetailsModel.map(dynamic obj) {
    if (obj != null) {
      this.status = obj["status"].toString();
      this.message = obj["message"].toString();
      if (status == "success") {
        this.data = BankTransferDetails.fromJson(obj['data']);
      }
    }
  }
}

class BankTransferDetails {
  int? id;
  String? accountNumber;
  String bankCode;
  String fullName;
  String createdAt;
  String currency;
  String amount;
  String fee;
  String reference;
  String bankName;

  BankTransferDetails.fromJson(Map jsonMap)
      : id = int.parse(jsonMap['id'].toString()),
        accountNumber = jsonMap['account_number'].toString(),
        bankCode = jsonMap['bank_code'].toString(),
        fullName = jsonMap['full_name'].toString(),
        createdAt = jsonMap['created_at'].toString(),
        currency = jsonMap['currency'].toString(),
        amount = jsonMap['amount'].toString(),
        fee = jsonMap['fee'].toString(),
        reference = jsonMap['reference'].toString(),
        bankName = jsonMap['bank_name'].toString();
}
