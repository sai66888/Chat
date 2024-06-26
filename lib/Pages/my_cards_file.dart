import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventhandler/eventhandler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upaychat/Apis/banklistapi.dart';
import 'package:upaychat/Apis/cardlistapi.dart';
import 'package:upaychat/Apis/checkcardholderapi.dart';
import 'package:upaychat/Apis/deletebankapi.dart';
import 'package:upaychat/Apis/deletecardapi.dart';
import 'package:upaychat/Apis/idverificationinfo.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Models/banklistmodel.dart';
import 'package:upaychat/Models/carddetaildata.dart';
import 'package:upaychat/Models/idverificationmodel.dart';
import 'package:upaychat/Pages/add_bank_file.dart';
import 'package:upaychat/Pages/add_card_file.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:upaychat/Pages/virtual_card_detail_file.dart';
import 'package:upaychat/globals.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Apis/virtualcardlistapi.dart';
import 'package:http/http.dart' as http;
import '../Apis/createvirtualcardapi.dart';
import '../Apis/network_utils.dart';
import '../CommonUtils/imagepicker.dart';
import '../CommonUtils/preferences_manager.dart';
import '../CustomWidgets/custom_ui_widgets.dart';
import '../Events/balanceevent.dart';
import '../Models/commonmodel.dart';
import '../Models/virtualcarddetaildata.dart';

class MyCardsFile extends StatefulWidget {
  final String receiverid;
  final String receiver;
  final String avatar;
  final String avatarTxt;

  const MyCardsFile(
      {Key? key,
      this.receiverid = '',
      this.receiver = '',
      this.avatar = '',
      this.avatarTxt = ''})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyCardsFileState();
  }
}

class MyCardsFileState extends State<MyCardsFile> {
  bool shouldPop = true;
  bool isLoaded = false;
  List<VirtualCardDetailData> cardList = [];


  @override
  void initState() {
    // TODO: implement initState
    EventHandler().subscribe(_onCardUpdatededCallback);
    super.initState();

    checkCardList();

  }
  void checkCardList() async{

    await _callCardListApi();
    if(cardList.isEmpty){
      Navigator.of(context).pushNamed("/addvitualcard");
    }

  }
  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    EventHandler().unsubscribe(_onCardUpdatededCallback);
    super.dispose();
  }
  void _onCardUpdatededCallback(BalanceEvent event) {
    switch (event.mode) {
      case 'cardstatus':
        _callCardListApi();
        break;
      default:
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        actions: <Widget>[
          GestureDetector(
            onTap: (){
              //checkVerification();
              createNewCard();

            },
            child: Row(
              children: <Widget>[
                // IconButton(
                //   icon: const Icon(Icons.add_box_outlined),
                //   tooltip: 'Add a Card',
                //
                //
                // ),
                // Image.asset(
                //   "assets/logo_black.png",
                //   height: 23,
                //   width: 23,
                // ),
                Icon(Icons.add_box_outlined),
                Container(
                  margin: EdgeInsets.only(right: 10),
                    child:
                    Text(
                      'Create card',
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                )
              ],
            ),
          )


        ],
        title: new Text(
          '',
          style: TextStyle(
            fontFamily: 'Doomsday',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Container(
        color: Color(0xffe8fce8),
        width: double.infinity,
        height: double.infinity,
        child: RefreshIndicator(
          onRefresh: _getData,

          child: isLoaded ?  cardList.length > 0 ? _body(context) : Container(


            padding: EdgeInsets.all(30),
            child: Column(
              children: const <Widget>[
                SizedBox(height: 10),
                Text("Create your virtual card", style: TextStyle(
                  fontFamily: 'Doomsday',
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                  textAlign: TextAlign.center,),
                SizedBox(height: 10),
                Text("Add a new virtual card by tapping the ", style: TextStyle(
                  fontFamily: 'Doomsday',
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                  textAlign: TextAlign.center,),
                Text("\"Create Card\" button above.", style: TextStyle(
                  fontFamily: 'Doomsday',
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                  textAlign: TextAlign.center,)
              ],
            ),
          ) : Container(color: Color(0xffe8fce8),child:CommonUtils.progressDialogBox()),
        ),
      ),
    );
  }

  Future<void> _callCardListApi() async {
    print("Load card list");
    setState(() {
      cardList = [];
    });
    bool isError = false;
    if (Globals.isOnline) {
      try {
        VirtualCardListApi _cardListApi = new VirtualCardListApi();
        VirtualCardListModel result = await _cardListApi.search();
        if (result.status == "true") {
          if (result.cardlist != null && result.cardlist!.isNotEmpty) {
            setState((){
              cardList = result.cardlist!;
            });

          } else {
            isError = true;
          }
        } else {
          isError = true;
          CommonUtils.errorToast(context, result.message);
        }
      } catch (e) {
        print(e);
        isError = true;
      }

      // Navigator.pop(context);
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
      isError = true;
    }
    isLoaded = true;
    if (isError) {
      cardList.clear();
    }
  }
  Future<void> _getData() async {

    _callCardListApi();
  }
  Widget renderCardItem(BuildContext context, int index) {
    final bool isAdd = index < 0;

    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed(
          "/virtualcarddetail",arguments:{"cardID": cardList[index].id}).then((value) => _callCardListApi());
          // VirtualCardDetailFile(cardID: cardList[index].id))
      },
        child: Card(
          color: cardList[index].card_status == 'active' ?  MyColors.base_green_color : MyColors.grey_color,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      elevation: 4,
      child: InkWell(
        splashColor: MyColors.base_green_color.withAlpha(200),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(10, 14, 10, 10),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cardList[index].card_holder,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: 'Doomsday',
                              ),
                            ),
                            Text(
                              cardList[index].card_provider == 'stripe' ? 'inactive' : cardList[index].card_status,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                fontFamily: 'Doomsday',
                              ),
                            ),
                          ]),
                      SizedBox(height: 6),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CommonUtils.cardNumberHolder(
                                cardList[index].card_number),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: 'Doomsday',
                            ),
                          ),
                          Text(
                            "Exp: " + cardList[index].expire_date,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Doomsday',
                            ),
                          ),

                          // Expanded(
                          //   child: Text(
                          //     "CVV/CCV: " + "•••",
                          //     // "CVV/CCV: " + cardList[index].cvv,
                          //     style: TextStyle(
                          //       color: MyColors.grey_color,
                          //       fontSize: 18,
                          //       fontFamily: 'Doomsday',
                          //     ),
                          //   ),
                          // ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  _body(BuildContext context) {
    return SingleChildScrollView(

        child: Container(
          color: Color(0xffe8fce8),
      alignment: Alignment.center,
      child: Container(
          color: Color(0xffe8fce8),
          child: Container(
              color: Color(0xffe8fce8),
              margin: EdgeInsets.only(top: 10, left: 8, right: 8),
              child: ListView.builder(
                itemCount: (cardList.length),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: renderCardItem,
              ))),
    ));
  }
  createNewCard() async{
    Navigator.of(context).pushNamed("/addvitualcard");


  }


}

