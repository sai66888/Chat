// import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upaychat/Apis/notificationapi.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/Models/notificationmodel.dart';
import 'package:upaychat/globals.dart';

import '../Apis/updateuserkeyapi.dart';
import '../CommonUtils/preferences_manager.dart';

class NotificationSettingsFile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NotificationSettingsState();
  }
}

class NotificationSettingsState extends State<NotificationSettingsFile> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<bool> _push_money_received;
  @override
  void initState() {
    loadSettings();
    super.initState();

  }
  void loadSettings(){
    _push_money_received = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('_push_money_received') ?? false;
    });
  }
  Future<void> _updateSettings(String key, bool Value) async {
    final SharedPreferences prefs = await _prefs;

    setState(() {
      prefs.setBool('key', Value).then((bool success) {
        loadSettings();
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        title: new Text(
          'Notification Settings',
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
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: _body(context),
      ),
    );
  }

  _body(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text('Push Notifications', style: TextStyle(color: Colors.black, fontFamily: 'Doomsday', fontSize: 20,),))
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(child: Text('Money Received', style: TextStyle(color: MyColors.base_green_color, fontFamily: 'Doomsday', fontSize: 20,),)),
              CupertinoSwitch( activeColor: MyColors.base_green_color, value: Globals.notification_push_money_received, onChanged: (bool newValue){
                 updateNotificationSettings('notification_push_money_received',newValue);
              })
            ],
          ),

          Row(
            children: <Widget>[
              Expanded(child: Text('Money Sent', style: TextStyle(color: MyColors.base_green_color, fontFamily: 'Doomsday', fontSize: 20,),)),
              CupertinoSwitch( activeColor: MyColors.base_green_color, value: Globals.notification_push_money_sent, onChanged: (bool newValue){
                updateNotificationSettings('notification_push_money_sent',newValue);
              })
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(child: Text('Bank Withdrawal', style: TextStyle(color: MyColors.base_green_color, fontFamily: 'Doomsday', fontSize: 20,),)),
              CupertinoSwitch( activeColor: MyColors.base_green_color, value: Globals.notification_push_bank_withdraw, onChanged: (bool newValue){
                updateNotificationSettings('notification_push_bank_withdraw',newValue);
              })
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(child: Text('Likes', style: TextStyle(color: MyColors.base_green_color, fontFamily: 'Doomsday', fontSize: 20,),)),
              CupertinoSwitch( activeColor: MyColors.base_green_color, value: Globals.notification_push_likes, onChanged: (bool newValue){
                updateNotificationSettings('notification_push_likes',newValue);
              })
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(child: Text('Comments', style: TextStyle(color: MyColors.base_green_color, fontFamily: 'Doomsday', fontSize: 20,),)),
              CupertinoSwitch( activeColor: MyColors.base_green_color, value: Globals.notification_push_comments, onChanged: (bool newValue){
                updateNotificationSettings('notification_push_comments',newValue);
              })
            ],
          ),

          SizedBox(height: 20,),


          Row(
            children: <Widget>[
              Expanded(child: Text('SMS Notifications', style: TextStyle(color: Colors.black, fontFamily: 'Doomsday', fontSize: 20,),))
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(child: Text('Money Received', style: TextStyle(color: MyColors.base_green_color, fontFamily: 'Doomsday', fontSize: 20,),)),
              CupertinoSwitch( activeColor: MyColors.base_green_color, value: Globals.notification_sms_money_received, onChanged: (bool newValue){
                updateNotificationSettings('notification_sms_money_received',newValue);
              })
            ],
          ),

          Row(
            children: <Widget>[
              Expanded(child: Text('Money Sent', style: TextStyle(color: MyColors.base_green_color, fontFamily: 'Doomsday', fontSize: 20,),)),
              CupertinoSwitch( activeColor: MyColors.base_green_color, value: Globals.notification_sms_money_sent, onChanged: (bool newValue){
                updateNotificationSettings('notification_sms_money_sent',newValue);
              })
            ],
          ),

          SizedBox(height: 20,),

          Row(
            children: <Widget>[
              Expanded(child: Text('Email Notifications', style: TextStyle(color: Colors.black, fontFamily: 'Doomsday', fontSize: 20,),))
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(child: Text('Money Received', style: TextStyle(color: MyColors.base_green_color, fontFamily: 'Doomsday', fontSize: 20,),)),
              CupertinoSwitch( activeColor: MyColors.base_green_color, value: Globals.notification_email_money_received, onChanged: (bool newValue){
                updateNotificationSettings('notification_email_money_received',newValue);
              })
            ],
          ),

          Row(
            children: <Widget>[
              Expanded(child: Text('Money Sent', style: TextStyle(color: MyColors.base_green_color, fontFamily: 'Doomsday', fontSize: 20,),)),
              CupertinoSwitch( activeColor: MyColors.base_green_color, value: Globals.notification_email_money_sent, onChanged: (bool newValue){
                updateNotificationSettings('notification_email_money_sent',newValue);
              })
            ],
          ),

          Row(
            children: <Widget>[
              Expanded(child: Text('Bank Withdrawal', style: TextStyle(color: MyColors.base_green_color, fontFamily: 'Doomsday', fontSize: 20,),)),
              CupertinoSwitch( activeColor: MyColors.base_green_color, value: Globals.notification_email_bank_withdraw, onChanged: (bool newValue){
                updateNotificationSettings('notification_email_bank_withdraw',newValue);
              })
            ],
          ),
 
        ],
      ),
        );;
  }
  updateNotificationSettings(String key, bool newValue) async{
    context.loaderOverlay.show();
    UpdateUserKeyApi updateApi= new UpdateUserKeyApi();
    CommonModel result = await updateApi.save(key, newValue ? '1' : '0');
    context.loaderOverlay.hide();
    if(result.status == 'true'){
      CommonUtils.successToast(context, result.message);
      PreferencesManager.setBool(key, newValue);

      setState(() {
        if(key == 'notification_push_money_received') Globals.notification_push_money_received = newValue;
        if(key == 'notification_push_money_sent') Globals.notification_push_money_sent = newValue;
        if(key == 'notification_push_bank_withdraw') Globals.notification_push_bank_withdraw = newValue;
        if(key == 'notification_push_likes') Globals.notification_push_likes = newValue;
        if(key == 'notification_push_comments') Globals.notification_push_comments = newValue;
        if(key == 'notification_sms_money_received') Globals.notification_sms_money_received = newValue;
        if(key == 'notification_sms_money_sent') Globals.notification_sms_money_sent = newValue;
        if(key == 'notification_email_money_received') Globals.notification_email_money_received = newValue;
        if(key == 'notification_email_money_sent') Globals.notification_email_money_sent = newValue;
        if(key == 'notification_email_bank_withdraw') Globals.notification_email_bank_withdraw = newValue;
      });
    }


  }
}
