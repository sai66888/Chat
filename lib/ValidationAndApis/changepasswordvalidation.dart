import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Apis/changepasswordapi.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/globals.dart';

class ChangePasswordValidation {
  static changepassword(
      BuildContext context, TextEditingController oldpassword, TextEditingController newpassword, TextEditingController confirmpassword) async {
    if (Globals.isOnline) {
      if (CommonUtils.isEmpty(oldpassword, 6)) {
        CommonUtils.errorToast(context, StringMessage.enter_old_password);
      } else if (CommonUtils.isEmpty(newpassword, 6)) {
        CommonUtils.errorToast(context, StringMessage.enter_correnct_new_password);
      } else if (newpassword.text != confirmpassword.text) {
        CommonUtils.errorToast(context, StringMessage.enter_correct_confirm_password);
      } else {
        context.loaderOverlay.show();
        ChangePasswordApi _loginApi = new ChangePasswordApi();
        CommonModel result = await _loginApi.search(newpassword.text, oldpassword.text);
        if (result.status == "true") {
          context.loaderOverlay.hide();
          CommonUtils.successToast(context, result.message);
          Navigator.pop(context);
        } else {
          context.loaderOverlay.hide();
          CommonUtils.errorToast(context, result.message);
        }
      }
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }
}
