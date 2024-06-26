import 'dart:async';
import 'dart:io' show Platform;
import 'package:eventhandler/eventhandler.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Apis/blockvirtualcardapi.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/Models/virtualcarddetaildata.dart';
import 'package:upaychat/Pages/add_money_to_virtual_card.dart';
import '../Apis/getvirtualcarddetailapi.dart';
import 'package:upaychat/CustomWidgets/virtual_card.dart';

import '../CustomWidgets/my_colors.dart';
import '../Events/balanceevent.dart';

class VirtualCardDetailFile extends StatefulWidget {
  const VirtualCardDetailFile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VirtualCardDetailState();
  }
}

class VirtualCardDetailState extends State<VirtualCardDetailFile> {
  //  final int cardID;
  //   final VirtualCardDetailData? carddata;
  int? cardId;
  late Timer _timer;

  bool? cardBalanceLoading;
  VirtualCardFullDetailData? cardDetail;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    // TODO: implement initState
    EventHandler().subscribe(_onBalanceEventCallback);

  }
  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();

  }

  void _onBalanceEventCallback(BalanceEvent event) {
    print('EVENT HANDLER CALLBACK:${event.mode}');
    switch (event.mode) {
      case 'cardbalance':
        _callGetDetailAPI();
        break;
      default:
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)!.settings.arguments ??
        <String, dynamic>{}) as Map;

    // TODO: implement build
    // throw UnimplementedError();
    if (cardDetail == null) {
      cardId = args['cardID'];
      _callGetDetailAPI();
      _callGetCardTransactionsAPI();
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: MyColors.base_green_color,
          centerTitle: true,
          title: Container(
              alignment: Alignment.centerLeft,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '\$${cardDetail == null ? '0.00' : cardDetail!.card_balance.toString()}',
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]))),
      body: Container(
        color: Color(0xffe8fce8),
        child: cardDetail == null
            ? CommonUtils.progressDialogBox()
            : Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                height: double.infinity,

                child: Column(children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 30, top: 10, left: 10, right: 10),
                    decoration: BoxDecoration(
                        color: MyColors.base_green_color_40,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20)
                        )
                    ),

                    child: VirtualCardWidget().buildCreditCardFullDetails(
                        cardDetail!.card_status == 'active'
                            ? MyColors.base_green_dark_color
                            : MyColors.grey_color,
                        cardDetail!.card_number,
                        cardDetail!.card_holder,
                        cardDetail!.expire_date,
                        cardDetail!.card_ccv,
                        cardKey),
                  ),


                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    padding: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(

                        color: MyColors.base_green_color_40,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50)
                        )
                    ),
                    child: cardDetail!.card_provider == 'stripe' ? Row(
                      children: [
                        Expanded(child: SizedBox()),
                        Column(
                          children: [
                            IconButton(onPressed: (){
                              Navigator.of(context).pushNamed(
                                  "/withdrawmoneyfromvitualcard",
                                  arguments: {"cardID": cardId, 'balance': cardDetail?.card_balance});
                            } , icon: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                  color:  Color(0xffff5557) ,
                                  borderRadius: BorderRadius.all(Radius.circular(50))
                              ),
                              child: Icon(Icons.download, color: Colors.white,),
                            )),
                            Text('Withdraw', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Doomsday',),)
                          ],
                        ),
                        SizedBox(width: 10,),
                        Column(
                          children: [
                            IconButton(onPressed: (){
                              updateStripeCard();
                            }, icon: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                  color: cardDetail!.card_status == 'active' ? Color(0xff5f18de) : MyColors.online_bg_color,
                                  borderRadius: BorderRadius.all(Radius.circular(50))
                              ),
                              child: Icon(Icons.upload, color: Colors.white,),
                            )),
                            Text('Upgrade', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Doomsday',),)
                          ],
                        ),
                        Expanded(child: SizedBox()),
                      ],
                    ) :
                    Row(
                      children: [
                        Expanded(child: SizedBox()),
                        Column(
                          children: [
                            IconButton(onPressed: cardDetail!.card_status == 'active' ?  (){
                              Navigator.of(context).pushNamed(
                                  "/addmoneytovitualcard",
                                  arguments: {"cardID": cardId});
                            } : null, icon: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                  color: cardDetail!.card_status == 'active' ? Color(0xff5370fd) : MyColors.grey_color,
                                  borderRadius: BorderRadius.all(Radius.circular(50))
                              ),
                              child: Icon(Icons.upload, color: Colors.white,),
                            )),
                            Text('Top up', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Doomsday',),)
                          ],
                        ),
                        SizedBox(width: 10,),
                        Column(
                          children: [
                            IconButton(onPressed: cardDetail!.card_status == 'active' ? (){
                              Navigator.of(context).pushNamed(
                                  "/withdrawmoneyfromvitualcard",
                                  arguments: {"cardID": cardId, 'balance': cardDetail?.card_balance});
                            } : null, icon: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                  color: cardDetail!.card_status == 'active' ? Color(0xffff5557) : MyColors.grey_color,
                                  borderRadius: BorderRadius.all(Radius.circular(50))
                              ),
                              child: Icon(Icons.download, color: Colors.white,),
                            )),
                            Text('Withdraw', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Doomsday',),)
                          ],
                        ),
                        SizedBox(width: 10,),
                        Column(
                          children: [

                            IconButton(onPressed: ()async{
                              await Clipboard.setData(ClipboardData(text: cardDetail!.card_number));
                              CommonUtils.successToast(context, "You card number has been copied to clipbaord.");
                            }, icon: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                  color: cardDetail!.card_status == 'active' ? Color(0xff7adb52) : MyColors.grey_color,
                                  borderRadius: BorderRadius.all(Radius.circular(50))
                              ),
                              child: Icon(Icons.copy, color: Colors.white,),
                            )),
                            Text('Copy', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Doomsday',),)
                          ],
                        ),
                        SizedBox(width: 10,),
                        Column(
                          children: [
                            IconButton(onPressed: (){
                              _blockVirtualCard();
                            }, icon: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                  color: cardDetail!.card_status == 'active' ? Color(0xff5f18de) : MyColors.online_bg_color,
                                  borderRadius: BorderRadius.all(Radius.circular(50))
                              ),
                              child: Icon(Icons.lock, color: Colors.white,),
                            )),
                            Text(cardDetail!.card_status == 'active' ? 'Lock' : 'Unlock', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Doomsday',),)
                          ],
                        ),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),


                  Platform.isAndroid
                      ? SizedBox()
                      : Platform.isIOS
                      ? SizedBox()
                      : SizedBox(),
                  SizedBox(height: 10,),
                  Container(child: Text("Transactions", style: TextStyle(
                    fontFamily: 'Doomsday',
                    fontSize: 18,
                    fontWeight: FontWeight.w900
                  ),), width: double.infinity,),
                  Expanded(child: SingleChildScrollView(child: _showCardTransactions(),))
                ]),
              ),
      ),
    );
  }
  updateStripeCard(){
    Navigator.of(context).pushReplacementNamed("/addvitualcard");
  }
  Widget _showCardTransactions() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(3, 5, 3, 5),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: cardDetail?.cardTransactions?.length ?? 0,
        separatorBuilder: (BuildContext context, int index) =>
            Divider(height: 3, color: MyColors.grey_color),
        itemBuilder: (context, index) {
          return _buildCardTransactionItem(cardDetail!.cardTransactions![index]);
        },
      )
    );
  }
  Widget _buildCardTransactionItem(dynamic transaction_detail){
    Map<String, dynamic> transaction_details = transaction_detail as Map<String, dynamic>;
    print(transaction_detail);
    // Map<String, dynamic> balance_transactions = transaction_details['balance_transactions'][0] as Map<String, dynamic>;
    Map<String, dynamic> merchant_data = transaction_details['merchant_data'] as Map<String, dynamic>;

    return Row(
      children: [
        Container(
          margin: EdgeInsets.all(5),
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: transaction_details['approved'] ? MyColors.base_green_dark_color : MyColors.grey_color,
            borderRadius: BorderRadius.all(Radius.circular(50))
          ),
          child: Icon(transaction_details['approved'] ? Icons.check : Icons.close, color: Colors.white,),
        ),
        Expanded(child: Container(
          margin: EdgeInsets.fromLTRB(12, 5, 12, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      merchant_data['name'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Text(

                    "\$" + (double.parse(transaction_details['amount'].toString())/100).toString() ,
                    style: TextStyle(
                      fontSize: 16,
                      color: double.parse(transaction_details['amount'].toString()) > 0
                          ? transaction_details['approved'] ? MyColors.base_green_color : MyColors.grey_color
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                CommonUtils.formattedTime(DateTime.fromMillisecondsSinceEpoch(transaction_details['created'] * 1000).toString()),
                style: TextStyle(
                  fontFamily: 'Doomsday',
                  color: MyColors.grey_color,
                ),
              ),
            ],
          ),
        ))
      ],
    );
  }
  void _blockVirtualCard() async {
    context.loaderOverlay.show();
    try{
      BlockVirtualCardApi blockVirtualCardApi = new BlockVirtualCardApi();
      CommonModel result = await blockVirtualCardApi.save(cardId!);
      EventHandler().send(BalanceEvent('cardstatus'));
      _callGetDetailAPI();
      context.loaderOverlay.hide();
    }
    catch(e){
      CommonUtils.errorToast(context, e.toString());
      context.loaderOverlay.hide();
    }

  }
  void _callGetCardTransactionsAPI() async{
    List<dynamic>? transactions = cardDetail?.cardTransactions;
    if(transactions != null){
      transactions.forEach((element) {
        dynamic transactionData = element;
        print("Transaction Amount ${transactionData.amount}");
      });
    }
  }
  void _callGetDetailAPI() async {
    setState(() {
      cardBalanceLoading = true;
    });

    VirtualCardFullDetailApi cardDetailApi =
        new VirtualCardFullDetailApi(cardId!);
    VirtualCardFullDetailDataModel result = await cardDetailApi.search();
    print("GetDetails of Virtual Card");
    print(result.cardData!.cardTransactions);
    if (result.status == 'true') {
      print(result.cardData!.card_status);
      setState(() {
        cardDetail = result.cardData;
        cardBalanceLoading = false;
      });
      Timer timer = new Timer(new Duration(seconds: 1), () {
        cardKey.currentState!.toggleCard();
        Timer timer1 = new Timer(new Duration(seconds: 3), () {
          cardKey.currentState!.toggleCard();
        });
      });
    }
  }
}
