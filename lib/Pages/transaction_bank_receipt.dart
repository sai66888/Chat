import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CustomWidgets/custom_images.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Models/mytransactionmodel.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../Apis/fetch_bank_transfer_api.dart';

class TypeResult {
  String? type;
  String? key;
  String? value;
}

class TransactionBankReceiptDetail extends StatefulWidget {
  final MyTransactionData transactionData;
  final BankTransferDetails bankTransferData;
  TransactionBankReceiptDetail({Key? key, required this.transactionData, required this.bankTransferData});
  @override
  State<StatefulWidget> createState() {
    return TransactionBankReceiptDetailState();
  }
}

class TransactionBankReceiptDetailState extends State<TransactionBankReceiptDetail> {
  @override
  void initState() {
    super.initState();
  }

  final _globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: _captureImage,
          backgroundColor: MyColors.base_green_color,
          child: Icon(
            Icons.download,
          ),
        ),
      ),
      body: RepaintBoundary(
        key: _globalKey,
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: _body(context),
        ),
      ),
    );
  }

  Future<PermissionStatus> getPermission() async {
    final PermissionStatus permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      final Map<Permission, PermissionStatus> permissionStatus =
      await [Permission.storage].request();
      return permissionStatus[Permission.storage] ??
          PermissionStatus.restricted;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
      SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  bool isCapture = false;

  _captureImage() async {
    final PermissionStatus permissionStatus = await getPermission();
    if (permissionStatus != PermissionStatus.granted) {
      _handleInvalidPermissions(permissionStatus);
      return;
    }
    context.loaderOverlay.show();
    setState(() {
      isCapture = true;
    });
    Future.delayed(Duration(milliseconds: 100), () async {
      try {
        var exported = await saveImage();
        if (exported) {
          CommonUtils.successToast(
              context, "Successfully Saved to your photos");
        } else {
          CommonUtils.successToast(
              context, "Can't save image, Please try again later");
        }
      } catch (e) {
        print(e);
        CommonUtils.successToast(context, "Export image error");
      }
      context.loaderOverlay.hide();
      setState(() {
        isCapture = false;
      });
    });
  }

  saveImage() async {
    final RenderRepaintBoundary boundary =
    _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    var directory = await getApplicationDocumentsDirectory();
    var exportPath =
        '${directory.path}/UpayChat-transaction#${widget.transactionData.tran.id.toString()}.png';
    final file = File(exportPath);
    await file.writeAsBytes(pngBytes);
    var respath = await GallerySaver.saveImage(exportPath);
    return respath;
  }

  listItem({String? title, String? value, bool bottomBorder: true}) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color:
                  bottomBorder ? MyColors.light_grey_color : Colors.white,
                  width: 1.5))),
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.fromLTRB(5, 15, 5, 5),
      child: Row(
        children: [
          Text(
            "$title:  ",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TypeResult getType() {
    TypeResult result = TypeResult();
    result.key = "Paid to";

    String userid = CommonUtils.getStrUserid();

    Transaction transaction = widget.transactionData!.tran;
    User transUser = widget.transactionData!.user;
    result.value = transUser.firstname + " " + transUser.lastname;

    switch (transaction.transaction_type) {
      case "bank_transfer":
        result.type = "Bank Transfer";
        result.key = "Debit from";
        result.value = "Wallet";
        break;
      default:
        result.type = transaction.transaction_type;
        result.key = "";
    }
    return result;
  }

  _body(BuildContext context) {
    TypeResult trans_type = getType();
    return Container(
      child: Column(
        children: [
          Container(
            color: MyColors.base_green_color,
            height: 100,
            child: Stack(
              children: [
                if (!isCapture)
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.only(top: 25, bottom: 8, left: 5),
                    child: InkWell(
                      child: Icon(
                        Icons.keyboard_arrow_left,
                        color: Colors.white,
                        size: 35,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(
                      top: 15, bottom: 20, left: isCapture ? 20 : 50),
                  child: Text(
                    'TRANSACTION RECEIPT',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Doomsday',
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(
                      top: 15, bottom: 4, left: isCapture ? 20 : 50),
                  child: Text(
                    CommonUtils.formattedTime(DateTime.now().toString()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontFamily: 'Doomsday',
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.only(top: 15, bottom: 10, right: 20),
                  child: Container(
                    color: Colors.white,
                    child: Image.asset(
                      CustomImages.ios_logo,
                      height: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.only(top: 3, bottom: 3, left: 2, right: 2),
              child: Column(
                children: [
                  listItem(
                      title: "Transaction Date",
                      value: DateFormat('dd/MM/yyyy hh:mm').format(DateTime.parse(widget.bankTransferData.createdAt))),
                  listItem(title: "Reference Number", value: widget.bankTransferData.reference),
                  listItem(title: "Sender", value: "${widget.transactionData.user.firstname} ${widget.transactionData.user.lastname}"),
                  listItem(
                      title: "Transaction Amount",
                      value: "₦" + widget.transactionData!.tran.amount.toString()),
                  listItem(title: "Transaction Type", value: 'Bank Transfer'),
                  listItem(title: "Receiver", value: widget.bankTransferData.fullName),
                  listItem(title: "Receiving Bank", value: widget.bankTransferData.bankName),
                  listItem(title: "Account Number", value: widget.bankTransferData.accountNumber),
                  listItem(title: "Remarks", value: widget.transactionData!.tran.caption),
                  SizedBox(height: 10,),
                  Text('Powered by Flutterwave®')
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}