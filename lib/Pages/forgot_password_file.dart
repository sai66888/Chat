// import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:upaychat/Apis/check_email_api.dart';
import 'package:upaychat/Apis/check_mobile_api.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/custom_ui_widgets.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/Pages/change_password_file.dart';
import 'package:upaychat/Pages/password_update_file.dart';
import 'package:upaychat/Pages/pincode_verification_file.dart';
import 'package:upaychat/globals.dart';

class ForgotPasswordFile extends StatefulWidget {
  final String? fromEmail;
  ForgotPasswordFile(
      {Key? key,   this.fromEmail})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ForgotPasswordFileState();
  }
}

class ForgotPasswordFileState extends State<ForgotPasswordFile> {
  bool showOtpVerificationDialog = false;
  bool _obscureEnable = false;
  TextEditingController pinEditingController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  String code = "";
  String mobileNumber = '';
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: MyColors.base_green_color_20,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(child: _body(context)),
      ),
    );
  }
  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }
  _body(BuildContext context) {
    return Container(
      child: Column(
        children: [
          CustomUiWidgets.forgotpasswordscreenHeader(context),
           mobileNoInputScreen(context),
        ],
      ),
    );
  }

  mobileNoInputScreen(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 8, right: 8),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(10, 20, 10, 5),
            child: Text(
              'Enter your email',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Doomsday',
                  color: MyColors.grey_color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            color: Colors.white,
            margin: const EdgeInsets.fromLTRB(8, 13, 5, 0),
            child: TextField(
              textAlign: TextAlign.center,
              controller: emailController,
              style: const TextStyle(
                fontFamily: 'Doomsday',
                fontSize: 24,
              ),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.all(Radius.circular(5.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: MyColors.base_green_color, width: 2.0),
                  borderRadius:
                  BorderRadius.all(Radius.circular(5.0)),
                ),
              ),
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
                backgroundColor:
                MaterialStateProperty.all<Color>(MyColors.base_green_color),
                // disabledColor: MyColors.base_green_color,
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    CustomUiWidgets.basicGreenButtonShape()),
              ),
              onPressed: () {
                _sendCodeAndCheck();
              },
              child: Text(
                'Continue',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: 'Doomsday',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendCodeAndCheck() async {
    if (Globals.isOnline) {
      if (emailController.text.isEmpty) {
        CommonUtils.errorToast(
            context, StringMessage.enter_correct_mobile_number);
      } else {
        context.loaderOverlay.show();
        CheckEmailApi _checkEmailApi = new CheckEmailApi();
        CommonModel result;
        try {
          result = await _checkEmailApi.search(emailController.text, true);
        } catch (e) {
          result = CommonModel("false", "", null);
        }
        context.loaderOverlay.hide();

        if (result.status == "true") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PinCodeVerificationScreen(
                      address: emailController.text,
                      isEmail: true,
                      isExists: true,
                      code: result.message,
                      onResponse: (state) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PasswordUpdateFile(mobilenumber:emailController.text)));
                      })));
        } else {
          CommonUtils.errorToast(context, result.message);
        }
      }
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }

  otpVerifyScreen(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: Container()),
          Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            child:const Text(
              'Enter Code',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Doomsday',
                  fontSize: 24
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left:20),
            width: double.infinity,
            child:const Text(
              'Enter the one time password sent to',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Doomsday',
                  fontSize: 16
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left:20),
            width: double.infinity,
            child: Text(
              emailController.text,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Doomsday',
                  fontSize: 16
              ),
              textAlign: TextAlign.left,
            ),
          ),
          if (false)
            Center(
              child: Text("Verification code $code (test only)"),
            ),
          SizedBox(height: 40,),
          Form(
            key: formKey,
            child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                child: PinCodeTextField(
                  appContext: context,
                  pastedTextStyle: TextStyle(
                    color: MyColors.base_green_color,
                    fontWeight: FontWeight.bold,
                  ),
                  length: 6,
                  obscureText: true,
                  blinkWhenObscuring: true,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                      shape: PinCodeFieldShape.circle,
                      //borderRadius: BorderRadius.circular(50),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      inactiveFillColor: MyColors.base_green_color_20,
                      errorBorderColor: MyColors.grey_color,
                      borderWidth : 1,
                      inactiveColor: MyColors.grey_color,
                      activeColor: Colors.blueAccent
                  ),
                  cursorColor: Colors.black,
                  animationDuration: Duration(milliseconds: 300),
                  enableActiveFill: true,
                  errorAnimationController: errorController,
                  controller: textEditingController,
                  keyboardType: TextInputType.number,
                  onCompleted: (v) {
                      verifyCode();

                  },
                  onChanged: (value) {

                  },
                )),
          ),
          Container(
            margin: EdgeInsets.only(left: 20),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: TextStyle(color: Colors.black54, fontSize: 15, fontFamily: 'Doomsday',),
                ),
                 TextButton(
                    onPressed: () => _resendCode(),
                    child: Text(
                      "RESEND",
                      style:
                      TextStyle(color: MyColors.base_green_color, fontSize: 16),
                    ))
              ],
            ),
          ),

          Expanded(child: Container()),

        ],
      ),
    );
  }

  Future<void> _resendCode() async {
    if (Globals.isOnline) {
      context.loaderOverlay.show();
      CheckMobileApi _checkMobileApi = new CheckMobileApi();
      CommonModel result =
      await _checkMobileApi.search(mobileNumber, 'true', "true");
      context.loaderOverlay.hide();

      if (result.status == "true") {
        code = result.message;
        CommonUtils.successToast(context, 'Code is resent to ' + mobileNumber);
      } else {
        CommonUtils.errorToast(context, result.message);
      }
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }

  void _checkCodeAndGo(String pin) {
    if (code == pin) {
      Navigator.pop(context);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => PasswordUpdateFile(
            mobilenumber: mobileNumber,
          )));
    } else {
      CommonUtils.errorToast(context, StringMessage.verification_code_invalid);
    }
  }

  void onPhoneNumberChange(
      String number, String globalNumber, String dialCode) {
    setState(() {
      mobileNumber = globalNumber;
    });
  }

  void verifyCode() {
    formKey.currentState!.validate();


  }
}
