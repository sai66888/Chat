import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Apis/getflutterwavebanklistapi.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/Pages/send_money_file.dart';
import '../CustomWidgets/custom_ui_widgets.dart';
import '../CustomWidgets/my_colors.dart';

class BankTransactionSendFile extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BankTransactionSendState();
  }

}

class BankTransactionSendState extends State<BankTransactionSendFile>{
  String? mode;
  String? currentBankOption;
  List<FlutterwaveBankData> bankList = [];
  bool isNumberAccepted = false;
  SelectedListItem? selectedBank;
  TextEditingController bankAccountNameController = new TextEditingController();
  TextEditingController bankAccountNumberController =new TextEditingController();
  FlutterwaveBankDetail? bankAccountDetail;
  String selectedRecurrence = 'One Time';
  List<String> recurrences = [
    "One Time",
    "Hourly",
    "Daily",
    "Weekly",
    "Monthly",
  ];
  @override
  void initState() {
    // TODO: implement initState
    _callGetBankListApi();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomInset: true,

        body:SingleChildScrollView(
          child: _body(context),
        ) ,
    );
  }

  _body(BuildContext context) {
    mode = ModalRoute.of(context)!.settings.arguments.toString();
    return Container(
      color: Color(0xffe8fce8),
      child: Column(
          children: [
            CustomUiWidgets.searchPeopleHeader(context, mode ?? ''),
            Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.all(20),
              child: Text(
                "Recipient's details",
                style: TextStyle(
                  fontFamily: 'Doomsday',
                  color: MyColors.base_green_color,
                  fontSize: 20,
                  // fontWeight: FontWeight.bold
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 10,
              margin: EdgeInsets.only(right: 50, left: 20),
              // margin: EdgeInsets.only(right: 10),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: bankList.length > 0 ? TextFormField(
                  controller: bankAccountNameController ,
                  readOnly: true,
                  onTap: (){
                    // FocusScope.of(context).unfocus();
                    onBankNameFieldTap();
                  },
                  style: TextStyle(
                    fontFamily: 'Doomsday',
                    fontSize: 18,
                  ),

                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                          left: 10, right: 10, top: 7, bottom: 7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:BorderSide.none,
                        // BorderSide(color: MyColors.base_green_color),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: "Choose a bank"
                  ),
                ) : CommonUtils.progressDialogBox(),
              ),
            ),
            SizedBox(height: 30,),
            Container(
              width: MediaQuery.of(context).size.width - 10,
              margin: EdgeInsets.only(right: 50, left: 20),
              // margin: EdgeInsets.only(right: 10),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: bankAccountNumberController,
                  onChanged: (value) {


                      if(value.length ==10){
                        setState(() {
                          isNumberAccepted = true;
                        });
                        if(bankAccountNameController.text.isEmpty){
                          onBankNameFieldTap();

                        }
                        else{
                          _getBankDetails();
                        }
                      }
                      else{
                        if(isNumberAccepted)
                          setState(() {
                            isNumberAccepted = false;
                          });
                      }


                  },

                  style: TextStyle(
                    fontFamily: 'Doomsday',
                    fontSize: 18,
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                          left: 10, right: 10, top: 7, bottom: 7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:BorderSide.none,
                        // BorderSide(color: MyColors.base_green_color),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: "Account number"
                  ),
                ),
              ),
            ),
            Visibility(
                visible: bankAccountDetail != null,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.all(20),
                  child: Text(
                    bankAccountDetail?.account_name ?? '',
                    style: TextStyle(
                      fontFamily: 'Doomsday',
                      color: MyColors.base_green_color,
                      fontSize: 20,
                      // fontWeight: FontWeight.bold
                    ),
                  ),
                ),
            ),

            const SizedBox(height: 20),
            Container(
              height: 50,
              width: double.infinity,
              margin: const EdgeInsets.only(left: 20, right: 50),
              child: ElevatedButton(

                style: ButtonStyle(

                  backgroundColor: MaterialStateProperty.all<Color>(
                      (bankAccountNameController.text.isNotEmpty && isNumberAccepted) ? MyColors.base_green_color: MyColors.grey_color),

                ),
                onPressed: (bankAccountNameController.text.isNotEmpty && isNumberAccepted) ? continueToSendMoney :  null,
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Doomsday',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
      ])
    );
  }

  void _callGetBankListApi() async{
    GetFlutterWaveBankListApi _api = new GetFlutterWaveBankListApi();
    FlutterwaveBankListModel _listModel =  _api.search();
    if(_listModel.status == 'success'){
      setState(() {
        bankList = _listModel.banklist;
      });
      print('Bank List Count:${bankList.length}');
    }
  }

  void onBankNameFieldTap() {
    DropDownState(
      DropDown(
        bottomSheetTitle: const Text(
          'Choose a bank',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        data: bankList.map<SelectedListItem>((FlutterwaveBankData mData) {
          return SelectedListItem(name: mData.name, value: mData.code);
        }).toList(),

        selectedItems: (List<dynamic> selectedList) {
          List<String> list = [];
          print('ItemSeelcted ${selectedList.length}');
          for(var item in selectedList) {

            setState(() {
              selectedBank = item;
              bankAccountNameController.text = selectedBank!.name;
              if(isNumberAccepted){
                _getBankDetails();
              }
            });
            break;
          }
          // showSnackBar(list.toString());
        },
      ),
    ).showModal(context);
  }

  void continueToSendMoney() async{
    if(bankAccountNumberController.text.length != 10){
      return;
    }
    if(bankAccountDetail == null){

      checkBankDetails();
    }
    else{
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>  SendMoneyFile(
                from : 'bank',
                bankAccount: bankAccountNumberController.text,
                bankCode: selectedBank?.value ?? '',
                username: bankAccountDetail?.account_name ?? '',
              )));
    }

  }

  void _getBankDetails() async{
    if(selectedBank != null && selectedBank!.value != ""){
      context.loaderOverlay.show();
      GetFlutterwaveBankDetailsApi _bankApi = new GetFlutterwaveBankDetailsApi();
      FlutterwaveBankDetailModel _bankDetailModel = await _bankApi.search(selectedBank!.value ?? '', bankAccountNumberController.text);
      if(_bankDetailModel.status == 'success'){
        bankAccountDetail = _bankDetailModel.bankdetail;
      }
      else{
        bankAccountDetail = null;
      }
      context.loaderOverlay.hide();
    }
    else{
      // CommonUtils.errorToast(context, 'Sorry, Please select a bank.');
    }
  }

  void checkBankDetails() async {
    if (selectedBank != null && selectedBank!.value != "") {
      GetFlutterwaveBankDetailsApi _bankApi = new GetFlutterwaveBankDetailsApi();
      FlutterwaveBankDetailModel _bankDetailModel = await _bankApi.search(
          selectedBank!.value ?? '', bankAccountNumberController.text);
      if (_bankDetailModel.status == 'success') {
        bankAccountDetail = _bankDetailModel.bankdetail;
        continueToSendMoney();
      }
      else {
        CommonUtils.errorToast(
            context, 'Sorry, recipient account could not be validated.');
        bankAccountDetail = null;
      }
    }
    else{
      CommonUtils.errorToast(context, 'Please select a bank');
    }
  }

}

