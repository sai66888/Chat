

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Apis/getvirtualcarddetailapi.dart';
import '../Apis/virtualcardlistapi.dart';
import '../CommonUtils/common_utils.dart';
import '../CustomWidgets/my_colors.dart';
import '../CustomWidgets/virtual_card.dart';
import '../Models/virtualcarddetaildata.dart';

class VirtualCardDetailsFile extends StatefulWidget{
  const VirtualCardDetailsFile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VirtualCardDetailsFileState();
  }
}

class VirtualCardDetailsFileState extends State<VirtualCardDetailsFile> {
  int? cardId;
  VirtualCardFullDetailData? cardDetail;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final args = (ModalRoute.of(context)!.settings.arguments ??
        <String, dynamic>{}) as Map;

    cardId = args['cardID'];
    _callGetFullDetailAPI();
    return Scaffold(
      appBar: AppBar(
          backgroundColor: MyColors.base_green_color,
          centerTitle: true,
          title: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'Card Details',
                style: TextStyle(
                  fontFamily: 'Doomsday',
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),)),
      body: Container(
        child: cardDetail == null
            ? CommonUtils.progressDialogBox()
            : Container(
            padding: EdgeInsets.all(10),
            child: Column(children: <Widget>[

              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text('Card Holder:',
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(cardDetail!.card_holder,
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ))
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text('Card Number:',
                    style: TextStyle(
                      fontFamily: 'Doomsday',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),),
                  Text(cardDetail!.card_number,
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ))
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text('Expire Date:',
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(cardDetail!.expire_date,
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ))
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text('Card CCV:',
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(cardDetail!.card_ccv,
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ))
                ],
              ),
            ])),
      ),
    );

  }


  void _callGetFullDetailAPI() async {
    VirtualCardFullDetailApi cardDetailApi = new VirtualCardFullDetailApi(cardId!);
    VirtualCardFullDetailDataModel result = await cardDetailApi.search();
    print("GetDetails of Virtual Card");
    print(result);
    ;
    if (result.status == 'true') {
      print(result.cardData);
      cardDetail = result.cardData;
    }
  }
}