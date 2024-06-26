import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

import '../CustomWidgets/my_colors.dart';
import 'bank_transaction_send_file_dart.dart';
class SendMoneyMenuFile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SendMoneyMenuFileState();
  }
}
class SendMoneyMenuFileState extends State<SendMoneyMenuFile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        title: new Text(
          'Transfer',
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
        color: MyColors.base_green_color_20,
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 30, bottom: 10),
                child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed('/searchpeople', arguments: 'send');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Image.asset("assets/logo_black.png", width: 30,),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(child: Column(
                            children: [
                              Row(
                                children: [
                                  badges.Badge(
                                    position: badges.BadgePosition.topEnd(top: -15, end: -70),
                                    badgeContent: Text("Instant & Free", style: TextStyle(color: Colors.white,fontSize: 10),),
                                    badgeStyle: badges.BadgeStyle(
                                      shape: badges.BadgeShape.square,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child:Container(child: Text(
                                      "Send to Upaychat Account",
                                      style: TextStyle(
                                          fontFamily: 'Doomsday',
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                  Expanded(child: SizedBox())
                                ],
                              ),

                              Container(child: Text(
                                "Transfer to any phone number or username ",
                                style: TextStyle(
                                    fontFamily: 'Doomsday',
                                    color: MyColors.grey_color,
                                    fontSize: 14),
                              ), width: double.infinity,)
                            ],
                          )
                          ),
                          Icon(Icons.arrow_forward_ios_rounded)

                        ],
                      ),
                    ))),
            Container(
                margin: const EdgeInsets.only(top: 30, bottom: 10),
                child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BankTransactionSendFile()));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance, size: 30,),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(child: Column(
                            children: [
                              Container(child: Text(
                                "Send to Bank Account",
                                style: TextStyle(
                                    fontFamily: 'Doomsday',
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              ), width: double.infinity,),
                              Container(child: Text(
                                "Transfer to bank accounts",
                                style: TextStyle(
                                    fontFamily: 'Doomsday',
                                    color: MyColors.grey_color,
                                    fontSize: 14),
                              ), width: double.infinity,)
                            ],
                          )),
                          Icon(Icons.arrow_forward_ios_rounded)
                        ],
                      ),
                    )))
          ],
        ),
      ),
    );
  }

}