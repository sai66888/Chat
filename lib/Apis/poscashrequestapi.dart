import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/Models/pendingrequestmodel.dart';
import 'package:upaychat/Models/requestmodel.dart';

import 'network_utils.dart';

class PosCashRequestApi {
  final NetworkUtils _netUtil = NetworkUtils();

  Future<CommonModel> sendPosCashRequest(String? userId, String? amount, String distance, lat, lng, String address, String previousRequestId) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.sendposcashrequest;
    return _netUtil.post(
      baseTokenUrl,
      body: {
        "user_id" : userId,
        "amount" : amount,
        "lat" : lat.toString(),
        "lng" : lng.toString(),
        "distance" : distance,
        'address': address,
        "previousRequestId": previousRequestId
      },
    ).then((dynamic res) {
      return CommonModel.map(res);
    });
  }

  posResponse(posId, state) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.poscashwithdrawalresponse;
    return _netUtil.post(
      baseTokenUrl,
      body: {
        'pos_id': posId,
        'state' : state
      }
    ).then((dynamic res) {
      return CommonModel.map(res);
    });
  }

  posResponseSuccess(posId, state) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.poscashwithdrawalresponsesuccess;
    return _netUtil.post(
        baseTokenUrl,
        body: {
          'pos_id': posId,
          'state' : state
        }
    ).then((dynamic res) {
      return CommonModel.map(res);
    });
  }

  Future<RequestModel>getPosRequestDatas() {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.getPosRequestDatas;
    return _netUtil.post(
      baseTokenUrl
    ).then((dynamic res) {
      // print(res.toString());
      RequestModel result = RequestModel.map(res);
      return result;
    });
  }

  Future<RequestModel>getPosRequestData(posId) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.getPosRequestData;
    return _netUtil.post(
        baseTokenUrl,
      body: {
          'pos_id' : posId,
      }
    ).then((dynamic res) {
      RequestModel result = RequestModel.map(res);
      return result;
    });
  }
}