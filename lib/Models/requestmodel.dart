class RequestModel {
  String status = '';
  String message = '';
  List<RequestData>? requestData;

  RequestModel.map(dynamic obj) {
    status = obj["status"].toString();
    message = obj["message"].toString();
    requestData = (obj['data'] as List).map((i) => RequestData.fromJson(i)).toList();
  }
}

class RequestData {
  String posId;
  String frId;
  String toId;
  String? toLat;
  String? toLong;
  String? toAvatar;
  String? toFirstName;
  String? toLastName;
  String? toAddress;
  String? toMobile;
  String amount;
  String state;
  String frAvatar;
  String frUsername;
  String frAddress;
  String frLongitude;
  String frLatitude;
  String distance;
  String mobile;
  String createdAt;
  String elapsedTime;
  String? receive;
  String? delivery;

  RequestData.fromJson(Map jsonMap)
      : posId = jsonMap['pos_id'].toString(),
        createdAt = jsonMap['requested_at'].toString(),
        elapsedTime = jsonMap['elapsed_time'].toString(),
        frId = jsonMap['fr_id'].toString(),
        toId = jsonMap['to_id'].toString(),
        amount = jsonMap['amount'].toString(),
        state = jsonMap['state'].toString(),
        frAvatar = jsonMap['fr_avatar'].toString(),
        frUsername = jsonMap['fr_username'].toString(),
        frAddress = jsonMap['address'].toString(),
        frLongitude = jsonMap['longitude'].toString(),
        frLatitude = jsonMap['latitude'].toString(),
        distance = jsonMap['distance'].toString(),
        receive = jsonMap['receive'].toString(),
        delivery = jsonMap['delivery'].toString(),
        mobile = jsonMap['mobile'].toString(),
        toLat = jsonMap['to_lat'].toString(),
        toLong = jsonMap['to_long'].toString(),
        toAvatar = jsonMap['to_avatar'].toString(),
        toFirstName = jsonMap['to_firstname'].toString(),
        toLastName = jsonMap['to_lastname'].toString(),
        toAddress = jsonMap['to_address'].toString(),
        toMobile = jsonMap['to_mobile'].toString();
}

