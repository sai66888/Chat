import 'package:flutter/material.dart';

import 'my_colors.dart';

class LocationPermissionPrompt extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return LocationPermissionPromptState();
  }

}

class LocationPermissionPromptState  extends State<LocationPermissionPrompt>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: MyColors.base_green_color_20,
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Image.asset("assets/loc_perm_image_01.png", width: 100,),
            Text(
              'Use your location',
              style: TextStyle(
                  fontFamily: 'Doomsday',
                  color: MyColors.base_green_color,
                  fontSize: 30,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w800
              ),
            ),
            Text(
              'Your location lets us connect you with friends in your area, enabling you to request or deliver cash, even when the app is closed or not in use.',
              style: TextStyle(
                  fontFamily: 'Doomsday',
                  color: MyColors.base_green_color,
                  fontSize: 20,
                  decoration: TextDecoration.none
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(child: Image.asset("assets/loc_perm_image_02.png")),
            Row(
              children: [
                Expanded(child: SizedBox()),
                TextButton(onPressed: (){
                  Navigator.of(context).pop(0);
                }, child: Text("Skip", style: TextStyle(
                  fontFamily: 'Doomsday',
                  color: Colors.blueAccent,
                  fontSize: 20,
                ))),
                Expanded(child: SizedBox()),
                TextButton(onPressed: (){
                  Navigator.of(context).pop(1);
                }, child: Text("Turn on", style: TextStyle(
                  fontFamily: 'Doomsday',
                  color: Colors.blueAccent,
                  fontSize: 20,
                ))),
                Expanded(child: SizedBox()),
              ],
            )
          ],
        ),
      ),
    );
  }

}