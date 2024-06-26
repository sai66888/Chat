// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:upaychat/Apis/check_mobile_api.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/custom_ui_widgets.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/Pages/password_update_file.dart';
import 'package:upaychat/globals.dart';

class ForgotPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ForgotPasswordState();
  }
}

class ForgotPasswordState extends State<ForgotPassword> {
  bool showOtpVerificationDialog = false;
  bool _obscureEnable = false;
  TextEditingController pinEditingController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  String code = "";
  String mobileNumber = '';
  List<Country> phoneInputCountries = [
    Country(
      name: "Nigeria",
      flag: "🇳🇬",
      code: "NG",
      dialCode: "234",
      minLength: 10,
      maxLength: 11,
    ),
  ];
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

  _body(BuildContext context) {
    return Container(
      child: Column(
        children: [
          CustomUiWidgets.forgotpasswordscreenHeader(context),
          showOtpVerificationDialog
              ? otpVerifyScreen(context)
              : mobileNoInputScreen(context),
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
              'Enter your phone',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Doomsday',
                  color: MyColors.grey_color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: TextFormField(
              maxLength: 11,
              onChanged: (value) {
                setState(() {
                  mobileNumber = '+234' + value;
                });
              },
              controller: phoneNumberController,
              style: TextStyle(fontSize: 18, color: Colors.black),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.0),
                  ),
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(),
                  prefixIcon: Container(
                    margin: EdgeInsets.only(left: 5),
                    child: DecoratedBox(
                      decoration: BoxDecoration(),
                      child: Padding(
                        padding: EdgeInsets.only(left: 1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/flags/ng.png',
                              package: 'intl_phone_field',
                              width: 32,
                            ),
                            SizedBox(
                              width: 5,
                            ),
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
                  )),
            ),
            //  InternationalPhoneInput(
            //   onPhoneNumberChange: onPhoneNumberChange,
            //   initialSelection: '+234',
            //   enabledCountries: ['NG', 'US'],
            //   labelStyle: TextStyle(
            //     fontFamily: 'Doomsday',
            //     fontSize: 20,
            //   ),
            //   hintStyle: TextStyle(
            //     fontFamily: 'Doomsday',
            //     fontSize: 20,
            //   ),
            //   hintText: 'Mobile Number',
            // ),
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
      if (mobileNumber.isEmpty) {
        CommonUtils.errorToast(
            context, StringMessage.enter_correct_mobile_number);
      } else {
        context.loaderOverlay.show();
        CheckMobileApi _checkMobileApi = new CheckMobileApi();
        CommonModel result =
            await _checkMobileApi.search(mobileNumber, 'true', "false");
        context.loaderOverlay.hide();

        if (result.status == "true") {
          code = result.message;
          setState(() {
            showOtpVerificationDialog = true;
          });
        } else {
          CommonUtils.errorToast(context, result.message);
        }
      }
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }

  otpVerifyScreen(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 8, right: 8),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(10, 25, 10, 0),
            child: Text(
              'Enter the code sent to your mobile $mobileNumber',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Doomsday',
                  color: MyColors.grey_color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),

          /// FIRST NAME
          Container(
            margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
            child: PinInputTextField(
              pinLength: 6,
              controller: pinEditingController,
              decoration: BoxLooseDecoration(
                strokeWidth: 0,
                gapSpace: 10,
                textStyle: TextStyle(
                  fontFamily: 'Doomsday',
                  color: MyColors.base_green_color,
                  fontSize: 20,
                ),
                strokeColorBuilder: PinListenColorBuilder(
                    MyColors.base_green_color, Colors.white),
                bgColorBuilder: PinListenColorBuilder(
                    Colors.white, MyColors.base_green_color),
                obscureStyle: ObscureStyle(
                  isTextObscure: _obscureEnable,
                ),
              ),
              autoFocus: true,
              textInputAction: TextInputAction.go,
              onSubmit: (pin) {
                if (pin.length == 6) {
                  _checkCodeAndGo(pin);
                } else {
                  CommonUtils.messageToast(context, "Enter correct code");
                }
              },
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
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    CustomUiWidgets.basicGreenButtonShape()),
              ),
              onPressed: () {
                String pin = pinEditingController.text;

                if (pin.length == 6) {
                  _checkCodeAndGo(pin);
                } else {
                  CommonUtils.messageToast(context, "Enter correct code");
                }
              },
              child: Text(
                'Submit code',
                style: TextStyle(
                    fontSize: 20, color: Colors.white, fontFamily: 'Doomsday'),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(10, 25, 10, 0),
            child: InkWell(
                onTap: () {
                  _resendCode();
                },
                child: Text(
                  'Resend code',
                  style: TextStyle(
                      color: MyColors.base_green_color,
                      fontSize: 20,
                      fontFamily: 'Doomsday'),
                )),
          ),
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
}
