
import 'dart:ffi';

import 'package:upaychat/Models/virtualcarddetaildata.dart';
import 'network_utils.dart';

class VirtualCardDetailApi {
  NetworkUtils _netUtil = new NetworkUtils();
  int? cardID;
  VirtualCardDetailApi( int card_id){
    this.cardID = card_id;
  }
  Future<VirtualCardDetailDataModel> search() {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.virtualcarddetail + "/" + cardID.toString();

    return _netUtil.post(baseTokenUrl).then((dynamic res) {

      VirtualCardDetailDataModel result = new VirtualCardDetailDataModel.map(res);
      return result;
    });
  }
}

class VirtualCardFullDetailApi{
  NetworkUtils _netUtil = new NetworkUtils();
  int? cardID;
  VirtualCardFullDetailApi( int card_id){
    this.cardID = card_id;
  }
  Future<VirtualCardFullDetailDataModel> search() {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.virtualcardfulldetails + "/" + cardID.toString();

    return _netUtil.post(baseTokenUrl).then((dynamic res) {

      VirtualCardFullDetailDataModel result = new VirtualCardFullDetailDataModel.map(res);
      return result;
    });
  }
}