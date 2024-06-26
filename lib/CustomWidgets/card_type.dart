import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/CustomWidgets/virtual_card.dart';

class CardTypeWidget extends StatelessWidget {
  String? cardType = "";
  CardTypeWidget({Key? key, String? cardType}){
    this.cardType = cardType;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: this.cardType == 'visa' ? MyColors.base_green_dark_color : Colors.deepPurple,
      /*1*/
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        height: 200,
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, bottom: 12.0, top: 12),
        child: Column(
          /*2*/
          crossAxisAlignment: CrossAxisAlignment.start,
          /*3*/
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            /* Here we are going to place the _buildLogosBlock */
            // _buildLogosBlock(),
            Row(
              children: [
                Image.asset(
                  "assets/logo_white.png",
                  height: 20,
                  width: 18,
                ),
               Expanded(child: SizedBox()),
                const Text(
                  'Virtual Card',
                  style: TextStyle(
                    fontFamily: 'Doomsday',
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              /* Here we are going to place the Card number */
              child: Text(
                '',
                style: TextStyle(
                    color: Colors.white, fontSize: 21, fontFamily: 'Doomsday'),
              ),
            ),


            Row(
              /*1*/
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child:Text(
                      '',

                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Arial',
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),

                  )
                  ,
                  Image.asset(

                    cardType == 'visa' ? "assets/icons8-visa-150.png" : "assets/icons8-mastercard-240.png",
                    height: 30,

                  ),
                ])
          ],
        ),
      ),
    );
  }

  Row _buildLogosBlock() {
    return Row(
      /*1*/

      children: <Widget>[
        Image.asset(
          "assets/logo_white.png",
          height: 20,
          width: 18,
        ),
        const SizedBox(
          width: 6,
        ),
        const Text(
          'UpayChat',
          style: TextStyle(
            fontFamily: 'Doomsday',
            color: Colors.white,
            fontSize: 18,
          ),
        ),


      ],
    );
  }
}