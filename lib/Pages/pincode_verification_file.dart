import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:upaychat/Apis/check_email_api.dart';
import 'package:upaychat/Apis/check_mobile_api.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/globals.dart';
import 'package:upaychat/CustomWidgets/custom_images.dart';

import '../CustomWidgets/custom_ui_widgets.dart';

class PinCodeVerificationScreen extends StatefulWidget {
  final String? address;
  final bool? isEmail;
  final bool? isExists;
  final String? code;
  final Function? onResponse;

  PinCodeVerificationScreen(
      {Key? key,
      @required this.address,
      this.onResponse,
      this.isEmail,
      this.isExists,
      this.code})
      : super(key: key);
  @override
  _PinCodeVerificationScreenState createState() =>
      _PinCodeVerificationScreenState();
}

class _PinCodeVerificationScreenState extends State<PinCodeVerificationScreen> {
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  String code = "";
  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    code = widget.code ?? '';
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        title: new Text(
          widget.isEmail ?? false
              ? "Email Verification"
              : "Phone Number Verification",
          style: TextStyle(
            fontFamily: 'Doomsday',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Center(
        child: Container(
          color: MyColors.base_green_color_20,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: _body(context),
        )

      ),
    );
  }
  void verifySMSCode() async{
    if (Globals.isOnline) {
      context.loaderOverlay.show();
      try{
        CheckMobileOTPApi _checkMobileApi = new CheckMobileOTPApi();
        CommonModel result = await _checkMobileApi.search(currentText, code);
        if (result.status == "true") {
          context.loaderOverlay.hide();
          CommonUtils.successToast(context, 'Thank you!');
          Navigator.pop(context);
          widget.onResponse!(true);
        } else {
          context.loaderOverlay.hide();
          CommonUtils.errorToast(context, result.message);
        }
      }
      catch (e){
        CommonUtils.errorToast(context, StringMessage.network_Error);
        context.loaderOverlay.hide();
      }
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }
  void verifyCode() {
    formKey.currentState!.validate();
      if (currentText.length != 6 || currentText != code) {
        errorController!.add(ErrorAnimationType.shake);
        setState(() => hasError = true);
      } else {
        Navigator.pop(context);
        widget.onResponse!(true);
      }


  }

  Future<void> _resendCode() async {
    if (Globals.isOnline) {
      context.loaderOverlay.show();
      try {
        CheckEmailApi _checkEmailApi = new CheckEmailApi();
        CheckMobileApi _checkMobileApi = new CheckMobileApi();

        CommonModel result = await (widget.isEmail ?? false
            ? _checkEmailApi.search(widget.address ?? '', widget.isExists!)
            : _checkMobileApi.search(widget.address ?? '',
                widget.isExists ?? false ? 'true' : 'false', "true"));
        if (result.status == "true") {
          setState(() {
            code = result.message;
          });
          CommonUtils.successToast(
              context, 'Code is resent to ' + (widget.address ?? ''));
        } else {
          CommonUtils.errorToast(context, result.message);
        }
      } catch (e) {
        CommonUtils.errorToast(context, e.toString() ?? "Someting went wrong");
      }
      context.loaderOverlay.hide();
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }
  Widget _body(BuildContext context) {
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
              "${widget.address}",
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
                    setState(() {
                      currentText = value;
                    });
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
               widget.isEmail ?? false ?  TextButton(
                   onPressed: () => _resendCode(),
                   child: Text(
                     "RESEND",
                     style:
                     TextStyle(color: MyColors.base_green_color, fontSize: 16),
                   )) : Container()
             ],
           ),
         ),
          (widget.isEmail ?? false) == false ?
        Container(
            margin: EdgeInsets.only(left:10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                    onPressed: () => _resendVoiceMessage(),
                    icon: Icon(
                      Icons.phone,
                      size: 24.0,
                    ),
                    label: Text(
                      "Call Me",
                      style:
                      TextStyle(color: Colors.blue, fontSize: 16),
                    )),

              ],
            ) ): Container(),
          Expanded(child: Container()),

        ],
      ),
    );
  }
  Widget _body1(BuildContext context) {
    return ListView(
      children: <Widget>[
        SizedBox(height: 30),
        Container(
          height: MediaQuery.of(context).size.height / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(CustomImages.otp_fig),
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
          child: RichText(
            text: TextSpan(
                text: "Enter the code sent to ",
                children: [
                  TextSpan(
                      text: "${widget.address}",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
                style: TextStyle(color: Colors.black54, fontSize: 15)),
            textAlign: TextAlign.center,
          ),
        ),

          // Center(
          //   child: Text("Verification code $code (test only)"),
          // ),
        SizedBox(
          height: 20,
        ),
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
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
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
                  setState(() {
                    currentText = value;
                  });
                },
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            hasError ? StringMessage.verification_code_invalid : "",
            style: TextStyle(
                color: Colors.red, fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the code? ",
              style: TextStyle(color: Colors.black54, fontSize: 15),
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
        SizedBox(
          height: 14,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
          child: ButtonTheme(
            height: 50,
            child: TextButton(
              onPressed: verifyCode,
              child: Center(
                  child: Text(
                "VERIFY",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
            ),
          ),
          decoration: BoxDecoration(
              color: MyColors.base_green_color,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                    color: Colors.green.shade200,
                    offset: Offset(1, -2),
                    blurRadius: 5)
              ]),
        ),
      ],
    );
  }

  _resendVoiceMessage() async{
    if (Globals.isOnline) {
      context.loaderOverlay.show();
      try{
        CheckMobileApi _checkMobileApi = new CheckMobileApi();
        CommonModel result = await _checkMobileApi.search(widget.address ?? '',
            widget.isExists ?? false ? 'true' : 'false', "true");
        if (result.status == "true") {
          context.loaderOverlay.hide();
          CommonUtils.successToast(context, 'UpayChat dialed your number.');
            print('VOICEMESSAGEID');
            print(result.message);
            setState(() {
              code =  result.message;
            });

        } else {
          context.loaderOverlay.hide();
          CommonUtils.errorToast(context, result.message);
        }
      }
      catch (e){
        CommonUtils.errorToast(context, StringMessage.network_Error);
        context.loaderOverlay.hide();
      }
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }
}

