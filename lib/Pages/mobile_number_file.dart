import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Apis/check_mobile_api.dart';
import 'package:upaychat/Apis/network_utils.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/custom_ui_widgets.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/Pages/pincode_verification_file.dart';
import 'package:http/http.dart' as http;
import 'package:upaychat/globals.dart';

class MobileNumberFile extends StatefulWidget {
  final Function? onResponse;
  final bool? isExists;
  final String? message;

  MobileNumberFile(
      {Key? key,
      @required this.onResponse,
      @required this.isExists,
      this.message})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MobileNumberFileState();
  }
}

class MobileNumberFileState extends State<MobileNumberFile> {
  TextEditingController pinEditingController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  String? mobileNumber;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    pinEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        title: new Text(
          'Verify Your Mobile Number',
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
        child: SingleChildScrollView(child: _body(context)),
      ),
    );
  }

  _body(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10, left: 12, right: 12),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(10, 20, 10, 15),
                child: Text(
                  widget.message ?? "",
                  style: TextStyle(
                      fontFamily: 'Doomsday',
                      color: MyColors.grey_color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),

              TextFormField (
                maxLength: 11,
                onChanged: (value) {
                  setState(() {
                    if(value.length > 0 && value[0] == '0'){
                      value = value.replaceFirst(RegExp(r'0'), '');

                    }

                    mobileNumber = '+234' + value;
                  });
                },
                controller: phoneNumberController,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 10, right: 10, top: 20, bottom: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:BorderSide(width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:BorderSide(width: 1.0),
                    ),
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(
                    ),
                    prefixIcon: Container(
                      margin: EdgeInsets.only(left: 5),
                      child: DecoratedBox(
                        decoration: BoxDecoration(),
                        child: Padding(
                          padding:EdgeInsets.only(left: 1),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'assets/flags/ng.png',
                                package: 'intl_phone_field',
                                width: 32,
                              ),
                              SizedBox(width: 5,),
                              FittedBox(
                                child: Text(
                                  '+234',
                                ),
                              ),

                              SizedBox(width: 4),
                              SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    )
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                child: TextButton(
                  style: ButtonStyle(
                    // textColor: Colors.white,
                    // highlightColor: MyColors.base_green_color_20,
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.fromLTRB(60, 15, 60, 15)),
                    // splashColor: MyColors.base_green_color_20,
                    backgroundColor: MaterialStateProperty.all<Color>(
                        MyColors.base_green_color),
                    // disabledColor: MyColors.base_green_color,
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                        CustomUiWidgets.basicGreenButtonShape()),
                  ),
                  onPressed: _sendVerifyCode,
                  child: Text(
                    'Continue',
                    style: TextStyle(
                        fontFamily: 'Doomsday',
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    ));
  }

  void _sendVerifyCode() async {
    if (Globals.isOnline) {
      if (mobileNumber == null ||
          (mobileNumber != null && mobileNumber!.isEmpty)) {
        CommonUtils.errorToast(
            context, StringMessage.enter_correct_mobile_number);
      } else {
        context.loaderOverlay.show();
        try{
          CheckMobileApi _checkMobileApi = new CheckMobileApi();
          CommonModel result = await _checkMobileApi.search(mobileNumber ?? '',
              widget.isExists ?? false ? 'true' : 'false', "false");
          if (result.status == "true") {
            context.loaderOverlay.hide();
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PinCodeVerificationScreen(
                  address: mobileNumber ?? '',
                  isEmail: false,
                  isExists: widget.isExists ?? false,
                  code: result.message,
                  onResponse: (state) {
                    PreferencesManager.setString(
                        StringMessage.mobile, mobileNumber ?? '');
                    updatePhone();
                    widget.onResponse!(state ?? '', mobileNumber ?? '');
                  },
                ),
              ),
            );
          } else {
            context.loaderOverlay.hide();
            CommonUtils.errorToast(context, result.message);
          }
        }
        catch (e) {
          context.loaderOverlay.hide();
          CommonUtils.errorToast(context, StringMessage.network_Error);
        }
      }
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }

  void onPhoneNumberChange(
      String number, String globalNumber, String dialCode) {
    setState(() {
      mobileNumber = globalNumber;
    });
  }

  void updatePhone() async {
    try {
      String token = PreferencesManager.getString(StringMessage.token);
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };
      var uri = Uri.parse(NetworkUtils.api_url + NetworkUtils.updateprofile);
      var request = new http.MultipartRequest("POST", uri);
      print("URL: " + NetworkUtils.api_url + NetworkUtils.updateprofile);
      request.headers.addAll(headers);
      request.fields['mobile'] = mobileNumber ?? '';
      await request.send();
    } catch (e) {
      print(e);
    }
  }
}
