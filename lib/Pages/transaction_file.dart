import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:upaychat/Apis/mytransactionapi.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Models/mytransactionmodel.dart';
import 'package:upaychat/Pages/transaction_bank_receipt.dart';
import 'package:upaychat/globals.dart';

import '../Apis/fetch_bank_transfer_api.dart';

class TransactionHistory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TransactionHistoryState();
  }
}

class TransactionHistoryState extends State<TransactionHistory> {
  bool isLoaded = true;
  List<MyTransactionData> myTransactionList = [];
  PagingController<int, MyTransactionData> _transactionController = PagingController(firstPageKey: 0);
  @override
  void initState() {
    _transactionController.addPageRequestListener((pageKey) {
      _loadTransactions(pageKey);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        title: new Text(
          'Transaction History',
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

  String number_format(double value, int count, String comma1, String comma2) {
    return value.toString();
  }

  String getMessage(MyTransactionData data) {
    String message = "";
    String userid = CommonUtils.getStrUserid();

    Transaction transaction = data.tran;
    User transUser = data.user;

    switch (transaction.transaction_type) {
      case 'safelock':
        message = message = "You locked ₦${number_format(transaction.amount, 2, '.', ',')} from wallet.";
        break;
      case 'safelock_release':
        message = message = "Safelock of ₦${number_format(transaction.amount, 2, '.', ',')} is released.";
        break;
      case 'cashout_complete':
        message = message = "You completed ₦${number_format(transaction.amount, 2, '.', ',')} Cashout request from ${transUser.username}";
        break;
      case 'cashout_accept':
        message = message = "You accepted ₦${number_format(transaction.amount, 2, '.', ',')} Cashout request from ${transUser.username}";
        break;
      case 'cashout_cancel':
        message = message = "You cancelled ₦${number_format(transaction.amount, 2, '.', ',')} Cashout request from ${transUser.username}";
        break;
      case 'pay':
        if (transaction.user_id == userid) {
          message = "You paid ₦" +
              number_format(transaction.amount, 2, '.', ',') +
              " to " +
              transUser.firstname +
              " " +
              transUser.lastname;
        } else {
          message = transUser.firstname +
              " " +
              transUser.lastname +
              " paid you ₦" +
              number_format(transaction.amount, 2, '.', ',');
        }
        break;

      case 'request':
        if (transaction.user_id == userid) {
          message = "You requested ₦" +
              number_format(transaction.amount, 2, '.', ',') +
              " from " +
              transUser.firstname +
              " " +
              transUser.lastname;
        } else {
          message = transUser.firstname +
              " " +
              transUser.lastname +
              " requested ₦" +
              number_format(transaction.amount, 2, '.', ',') +
              " from you";
        }
        break;
      case "withdrawal":
        message = "You transferred ₦" +
            number_format(transaction.amount, 2, '.', ',') +
            " to your bank";
        break;

      case "wallet":
        message = "You added ₦" +
            number_format(transaction.amount, 2, '.', ',') +
            " to your wallet";
        break;
      case "virtualCard":
        message = "Transfer of ₦" +
            number_format(transaction.amount, 2, '.', ',') +
            " from wallet balance to virtual card balance ";
        break;
      case "virtualCardWithdraw":
        message = "Withdrawal of ₦" +
            number_format(transaction.amount, 2, '.', ',') +
            " from your virtual card.";
        break;
      case "takeback":
        message = "You take back ₦" +
            number_format(transaction.amount, 2, '.', ',') +
            " from " +
            transUser.firstname +
            " " +
            transUser.lastname;
        break;
      case "bank_transfer":
        message = "You paid ₦" +
            number_format(transaction.amount, 2, '.', ',') +
            " to " +
            transaction.touser_id + "'s bank account.";
        break;
      default:
        message = "You paid ₦" +
            number_format(transaction.amount, 2, '.', ',') +
            " to buy " +
            transaction.transaction_type;
        break;
    }
    return message;
  }

  _body(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(10),
        child: isLoaded
            ? Container(
                padding: EdgeInsets.only(top: 3, bottom: 3, left: 2, right: 2),
                child: RefreshIndicator(child: PagedListView<int, MyTransactionData>(
                  pagingController: _transactionController,
                  builderDelegate: PagedChildBuilderDelegate<MyTransactionData>(
                      itemBuilder: (context, item, index) =>
                          _builderMyTransactionItem(context, item, index),
                      firstPageProgressIndicatorBuilder: (context){
                        return Container(
                          height: 65,
                          width: 65,
                          child: SpinKitChasingDots(
                            color: MyColors.base_green_color,
                            size: 50.0,
                          ),
                        );
                      }
                  ),

                ), onRefresh: _refreshTransactionHistories),
              )
            : CommonUtils.progressDialogBox());
  }
  _builderMyTransactionItem(context, transactionData, index){
    return Card(
      margin: EdgeInsets.only(top: 10),
      child: InkWell(
        splashColor:
        MyColors.base_green_color.withAlpha(200),
        onTap: () async{
          if(transactionData.tran.transaction_type == 'electricity'){
            Navigator.of(context).pushNamed(
                '/transaction_detail_electricity',
                arguments: transactionData);
          }
          else{
            print(transactionData.tran.transaction_type);
            if(transactionData.tran.transaction_type == 'bank_transfer'){
              context.loaderOverlay.show();
              try{
                print(transactionData.tran.transactionID);
                FetchBankTransferApi transferApi = FetchBankTransferApi();
                BankTransferDetailsModel transferDetailsModel = await transferApi.search(transactionData.tran.transactionID);
                print(transferDetailsModel.status);
                if(transferDetailsModel.status == "success"){
                  context.loaderOverlay.hide();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TransactionBankReceiptDetail(
                            transactionData: transactionData,
                            bankTransferData: transferDetailsModel.data!,
                          ),
                    ),
                  );
                }
                else{
                  CommonUtils.errorToast(context, transferDetailsModel.message);
                  context.loaderOverlay.hide();

                }

              }
              catch(e){
                context.loaderOverlay.hide();
                CommonUtils.errorToast(context, e.toString());
              }

            }
            else{
              if(transactionData.tran.transaction_type == 'pay' || transactionData.tran.transaction_type == 'request' || transactionData.tran.transaction_type == 'wallet')
              Navigator.of(context).pushNamed(
                  '/transaction_detail',
                  arguments: transactionData);
            }

          }

        },
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        getMessage(
                            transactionData),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerRight,
                child: Text(
                  CommonUtils.timesAgoFeature(
                      transactionData
                          .tran
                          .created_at),
                  style: TextStyle(
                    color: MyColors.grey_color,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void>  _refreshTransactionHistories()async {
    _transactionController.refresh();
  }
  void _loadTransactions(int pageKey) async {
    print("Load Data");
    if (Globals.isOnline) {
      try {

        MyTransactionApi _myTransApi = new MyTransactionApi();
        MyTransactionModel result = await _myTransApi.search(lastItemId: pageKey);
        if (result.status == "true") {
          List<MyTransactionData> newItems = result.myTransactionData ?? [];
          if (newItems.length < 20) {
            _transactionController.appendLastPage(result.myTransactionData ?? []);
          } else {
            _transactionController.appendPage(result.myTransactionData ?? [],  newItems[newItems.length - 1].tran.id);
          }
        } else {
          CommonUtils.errorToast(context, result.message);
        }
      } catch (e) {
        _transactionController.error = e;
        CommonUtils.errorToast(context, e.toString());
      }
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }
}
