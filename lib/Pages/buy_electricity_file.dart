import 'package:cached_network_image/cached_network_image.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:eventhandler/eventhandler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upaychat/Apis/getStringListApi.dart';
import 'package:upaychat/Apis/getflutterwavecategories.dart';
import 'package:upaychat/Apis/getfluttwerwavebillingverificationapi.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/interswitch_utils.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:upaychat/Models/flutterwavebillingstatusmodel.dart';
import 'package:upaychat/Models/flutterwavebillingverificationmodel.dart';
import 'package:upaychat/Models/flutterwavecategoriesmodel.dart';

import '../Apis/createflutterwavebillpaymentapi.dart';
import '../Apis/getflutterwavebillingstatusapi.dart';
import '../CommonUtils/preferences_manager.dart';
import '../Events/balanceevent.dart';
import '../Models/commonmodel.dart';
import '../Models/flutterwavebillingcreatedmodel.dart';
import '../globals.dart';

class BuyElectricityFile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BuyElectricityFileState();
  }
}

class BuyElectricityFileState extends State<BuyElectricityFile> {
  var billers = [];
  var _interswitch = InterswitchUtils.getInstance();
  String? selectedCat;
  var selectedBill;
  var billItems;
  int curShowPage = 0; //0: categories, 1: bill, 2: completed
  var selectedBillOption;
  var currentBillOption;
  var amountController = TextEditingController();
  var billFieldsControllers = <String, TextEditingController>{};
  List<dynamic>  categories = [];
  final TextEditingController userController = new TextEditingController();
  String? currentDataBundleOption;
  String selectedRecurrence = 'One Time';
  bool isFee = false;
  String feeText = "No Fee";
  int feeAmount = 0;
  double totalAmount = 0.00;
  String? itemCode;
  String transactionSuccessDateTime = "";
  String? billCode;
  FlutterwaveBillingVerificationData? _verificationData;
  FlutterwaveBillingStatusModel? statusModel;
  List<String> recurrences = [
    "One Time",
    "Hourly",
    "Daily",
    "Weekly",
    "Monthly",
  ];
  List<dynamic> bundleCategories = [
    {"text": "EKEDC", "image": "ekedc", "bill_code" : "BIL112", "data" :{
      "status": "success",
      "message": "bill categories retrieval successful",
      "data": [
        {
          "id": 268,
          "biller_code": "BIL112",
          "name": "EKEDC POSTPAID TOPUP",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:09:48.087Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "EKEDC POSTPAID TOPUP",
          "item_code": "UB158",
          "short_name": "EKEDC POSTPAID TOPUP",
          "fee": 0,
          "commission_on_fee": true,
          "label_name": "Meter Number",
          "amount": 0
        },
        {
          "id": 267,
          "biller_code": "BIL112",
          "name": "EKEDC PREPAID TOPUP",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:09:48.087Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "EKEDC PREPAID TOPUP",
          "item_code": "UB157",
          "short_name": "EKEDC PREPAID TOPUP",
          "fee": 0,
          "commission_on_fee": true,
          "label_name": "Meter Number",
          "amount": 0
        }
      ]
    }},
    {"text": "IBADAN DISCO ELECTRICITY", "image": "ibedc", "bill_code" : "BIL114", "data" : {
      "status": "success",
      "message": "bill categories retrieval successful",
      "data": [
        {
          "id": 272,
          "biller_code": "BIL114",
          "name": "IBADAN DISCO ELECTRICITY POSTPAID",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:09:48.087Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "IBADAN DISCO ELECTRICITY POSTPAID",
          "item_code": "UB162",
          "short_name": "IBADAN DISCO ELECTRICITY POSTPAID",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "Meter Number",
          "amount": 0
        },
        {
          "id": 271,
          "biller_code": "BIL114",
          "name": "IBADAN DISCO ELECTRICITY PREPAID",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:09:48.087Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "IBADAN DISCO ELECTRICITY PREPAID",
          "item_code": "UB161",
          "short_name": "IBADAN DISCO ELECTRICITY PREPAID",
          "fee": 100,
          "commission_on_fee": true,
          "label_name": "Meter Number",
          "amount": 0
        }
      ]
    }},
    {"text": "IKEDC", "image": "ikedc", "bill_code" : "BIL113", "data" : {
      "status": "success",
      "message": "bill categories retrieval successful",
      "data": [
        {
          "id": 270,
          "biller_code": "BIL113",
          "name": "IKEDC  POSTPAID",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:09:48.087Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "IKEDC  POSTPAID",
          "item_code": "UB160",
          "short_name": "IKEDC  POSTPAID",
          "fee": 0,
          "commission_on_fee": true,
          "label_name": "Meter Number",
          "amount": 0
        },
        {
          "id": 269,
          "biller_code": "BIL113",
          "name": "IKEDC  PREPAID",
          "default_commission": 0.3,
          "date_added": "2020-02-11T11:09:48.087Z",
          "country": "NG",
          "is_airtime": false,
          "biller_name": "IKEDC  PREPAID",
          "item_code": "UB159",
          "short_name": "IKEDC  PREPAID",
          "fee": 0,
          "commission_on_fee": true,
          "label_name": "Meter Number",
          "amount": 0
        }
      ]
    }},

  ];
  List<String> meterNumbers  = [];
  String userLabelName = "Meter Number";
  @override
  void initState() {

    super.initState();
    loadMeterNumbers();
  }
  getCategories(dynamic listData) async {
    setState(() {
      bool isHideDlg = false;
      isFee = false;
      _verificationData = null;
      feeText = "";
      amountController.text = "0";
      categories = listData['data']!;
      currentDataBundleOption = listData['data'][0]['biller_name'];
      itemCode = listData['data'][0]['item_code'].toString();
      billCode = listData['data'][0]['biller_code'].toString();
      // CommonUtils.successToast(context, _model.message);

      curShowPage = 1;
    });


    amountController.text = '1000';
    if (listData['data'][0]['commission_on_fee'].toString() == "true") {
      setState(() {
        feeAmount = int.parse(listData['data'][0]['fee'].toString());
        isFee = true;
        feeText = "Commission fee: " +
            feeAmount.toString() +
            "NGN";
      });
    } else {
      setState(() {
        isFee = false;
      });
    }
    setState(() {
      totalAmount = double.parse(amountController.text) + feeAmount;
    });



    userController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            if (curShowPage == 0 || curShowPage == 2)
              Navigator.of(context).pop();
            else
              setState(() {
                curShowPage -= 1;
              });

          },
        ),
        title: new Text(
          'Buy Electricity',
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
        color: Color(0xffe8fce8),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: _body(context),
      ),
    );
  }

  getData() {
    return categories;
  }






  _renderBillsPage() {
    var listData = getData();
    return Container(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              child: Image.asset("assets/" +currentBillOption['image'] + ".png", height: 100,),

            ),
            SizedBox(height: 10,),
            Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Text("Select a package",
                style: TextStyle(
                  color: MyColors.base_green_color,
                  fontSize: 18,
                  fontFamily: 'Doomsday',
                  fontWeight: FontWeight.bold,
                ),),
            ),
            SizedBox(height: 5,),
            Container(
              width: MediaQuery.of(context).size.width - 10,
              margin: EdgeInsets.only(right: 50),
              // margin: EdgeInsets.only(right: 10),
              child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white, //background color of dropdown button
                    borderRadius: BorderRadius.circular(
                        10), //border raiuds of dropdown button
                  ),
                  child: Padding(
                      padding: EdgeInsets.only(left: 30, right: 10),

                      child: DropdownButton<String>(

                        value: currentDataBundleOption,
                        underline: SizedBox(),
                        style: TextStyle(
                            fontFamily: 'Doomsday',
                            color: Colors.black, //Font color
                            fontSize: 15 //font size on dropdown button
                        ),
                        items: categories.map<DropdownMenuItem<String>>(
                                (dynamic categoryData) {
                              return DropdownMenuItem(
                                child: Text(categoryData['biller_name']),
                                value: categoryData['biller_name'],
                              );
                            }).toList(),
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState((){
                            currentDataBundleOption = newValue;
                          });

                          for (int i = 0; i < categories.length; i++) {
                            if (categories[i]['biller_name'] == newValue) {
                              amountController.text ='1000';
                              setState((){
                                itemCode = categories[i]['item_code'].toString();
                                billCode = categories[i]['biller_code'].toString();
                              });

                              if (categories[i]['commission_on_fee'].toString() == "true") {

                                setState((){
                                  feeAmount = int.parse(categories[i]['fee'].toString());
                                  isFee = true;
                                  feeText = "Commission fee: " +
                                      feeAmount.toString() +
                                      "NGN";
                                });

                              } else {
                                setState((){
                                  isFee = false;
                                });

                              }
                              setState((){
                                totalAmount = double.parse(amountController.text) + feeAmount;
                              });


                            }
                          }
                        },
                        icon: Padding(
                          //Icon at tail, arrow bottom is default icon
                            padding: EdgeInsets.only(left: 20),
                            child: Icon(Icons.arrow_drop_down)),
                        iconEnabledColor: Colors.grey, //I
                      ))),
            ),

            SizedBox(height: 10,),
            Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Text("Amount",
                style: TextStyle(
                  color: MyColors.base_green_color,
                  fontSize: 18,
                  fontFamily: 'Doomsday',
                  fontWeight: FontWeight.bold,
                ),),
            ),
            Container(
              margin: EdgeInsets.only(right: 50),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  color: Colors.white
              ),
              child: TextField(
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: MyColors.base_green_color,
                  fontFamily: 'Doomsday',
                  fontSize: 30,
                ),
                controller: amountController,
                keyboardType: TextInputType.number,

                inputFormatters: [amountValidator!],
                cursorColor: MyColors.base_green_color,
                decoration: InputDecoration(
                  focusColor: Colors.transparent,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintText: "0",
                ),
                onChanged: (text) {
                  if (text.isNotEmpty) {

                    totalAmount = double.parse(amountController.text) + feeAmount;
                    // feeText = "Commission fee: " + feeAmount.toString() + "NGN" ;
                  }
                },
              ),
            ),
            Visibility(
              visible: isFee,
              child: Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: Text(feeText,
                  style: TextStyle(
                    color: MyColors.base_green_color,
                    fontSize: 18,
                    fontFamily: 'Doomsday',
                    fontWeight: FontWeight.bold,
                  ),),
              ),),
            Row(
              // margin: EdgeInsets.only(right: 50),
                children: [
                  Expanded(child: Row(
                    children: <Widget>[
                      Expanded(child: SizedBox(),),
                      Container( width: 90, child: DropdownButton<String>(
                        value: selectedRecurrence,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRecurrence = newValue!;
                          });
                        },
                        style: TextStyle(
                            fontFamily: 'Doomsday',
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                        ),
                        underline: SizedBox(),
                        items: recurrences.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        selectedItemBuilder: (BuildContext context) {
                          return recurrences.map((var item) {
                            return Container(
                              alignment: Alignment.center,
                              child: Text(
                                item,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList();
                        },
                      ),),
                      Expanded(child: SizedBox())
                    ],
                  ),),
                  SizedBox(width: 50)
                ]
            ),
            SizedBox(height: 30,),
            Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Text(userLabelName,

                style: TextStyle(
                  color: MyColors.base_green_color,
                  fontSize: 18,
                  fontFamily: 'Doomsday',
                  fontWeight: FontWeight.bold,
                ),),
            ),
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(


                        onChanged: (String newValue){
                          int limitMeterNumberLength = 13;
                          print(currentBillOption['text'].toString());
                          if(currentBillOption['text'].toString() == 'IKEDC'){
                            limitMeterNumberLength = 11;
                          }
                          print(limitMeterNumberLength);
                          print(newValue.length == limitMeterNumberLength);
                          if(newValue.length == limitMeterNumberLength){
                            validateMetaNumber(newValue);
                          }
                          else{
                            _verificationData = null;
                          }
                        },
                        controller: userController,
                        style: TextStyle(
                          fontFamily: 'Doomsday',
                          fontSize: 18,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp("[ ]"))
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(
                              left: 10, right: 10, top: 5, bottom: 5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: MyColors.base_green_color),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: userLabelName,

                          hintStyle: TextStyle(color: MyColors.grey_color),
                            suffixIcon :  InkWell(
                              onTap: (){
                                DropDownState(
                                  DropDown(
                                    bottomSheetTitle: const Text(
                                      'Choose a meter number you used.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                    data: meterNumbers.map<SelectedListItem>((String meterNumber) {
                                      return SelectedListItem(name:meterNumber, value: meterNumber);
                                    }).toList(),

                                    selectedItems: (List<dynamic> selectedList) {
                                      for(var selectedItem in selectedList) {
                                        SelectedListItem item = selectedItem;
                                        userController.text = item!.value!;
                                        validateMetaNumber(userController.text);
                                      }
                                    },
                                  ),
                                ).showModal(context);
                              },
                              child: Icon(Icons.arrow_drop_down),
                            ),
                        ),
                      ),
                    ),
                  ),



                ],
              ),

            ),

            Visibility(
              visible: _verificationData != null,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Text(_verificationData != null ? _verificationData!.name! : "",
                  style: TextStyle(
                    color: MyColors.base_green_color,
                    fontSize: 18,
                    fontFamily: 'Doomsday',
                    fontWeight: FontWeight.bold,
                  ),),)),
            SizedBox(height: 30,),

            SizedBox(height:10),
            Container(
              width: double.infinity,
              height: 50,
              child: Container(
                child: TextButton(
                  style: ButtonStyle(

                    backgroundColor: MaterialStateProperty.all<Color>(
                        MyColors.base_green_color),
                  ),
                  onPressed: completePayment,
                  child: Text(
                    'Buy',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  completePayment() async{
    if (CommonUtils.isEmpty(userController, 0)) {
      CommonUtils.errorToast(context, "Please input the meter number");
      return;
    }

    if (CommonUtils.isEmpty(amountController, 0) ||
        double.parse(amountController.text.replaceAll(',', '')) <= 0) {
      CommonUtils.errorToast(context, "Please input the amount");
      return;
    }
    if (double.parse(amountController.text.replaceAll(',', '')) < 1000) {
      CommonUtils.errorToast(context, "Minimum amount should be NGN 1000");
      return;
    }
    if(currentDataBundleOption == null){
      CommonUtils.errorToast(context, "Please select a package.");
      return;
    }
    if (double.parse(amountController.text) > Globals.walletbalance) {
      CommonUtils.errorToast(context,
          "You do not have sufficient funds to complete this transaction.");
      // Navigator.of(context).pop();
      return;
    }
    context.loaderOverlay.show();


    String postRecurrence = "";
    if (selectedRecurrence == "One Time") {
      postRecurrence = "ONCE";
    }
    else{
      postRecurrence = selectedRecurrence.toUpperCase();
    }
    CreateFlutterwaveBillPaymentApi createFlutterwaveAirtimeApi = new CreateFlutterwaveBillPaymentApi();

    String amount = amountController.text;

    try{
      FlutterwaveBillingCreatedModel result = await createFlutterwaveAirtimeApi.save(
          currentDataBundleOption!, amount, totalAmount.toString(), userController.text, postRecurrence, isElectricity: 1);
      // Navigator.of(context).pop();
      if(result.status == 'success'){
        if(result.billingResult!.reference != null){
          GetFlutterWaveBillingStatusApi getFlutterWaveBillingStatusApi  = new GetFlutterWaveBillingStatusApi();
          statusModel = await getFlutterWaveBillingStatusApi.search(result.billingResult!.reference!);
          if(statusModel!.status == 'success'){
            setState(() {
              transactionSuccessDateTime =  DateFormat('d MMM yyyy,').add_jm().format(DateTime.now());
              curShowPage = 2;
            });
          }
        }
        CommonUtils.successToast(context, result.message);
        context.loaderOverlay.hide();
        EventHandler().send(BalanceEvent('wallet'));
      }
      else if(result.status == 'pending'){
        CommonUtils.successToast(context, result.message);
        context.loaderOverlay.hide();
        Navigator.of(context).pop();
        EventHandler().send(BalanceEvent('wallet'));
      }
      else{
        CommonUtils.errorToast(context, result.message);
        context.loaderOverlay.hide();
      }
    }
    catch(e){
      CommonUtils.errorToast(context, e.toString());
      context.loaderOverlay.hide();
    }

    // _interswitch.pay(transactionSuccessCallback, transactionFailureCallback, context);
  }


  _renderBillComplete() {
    return Column(
      children: <Widget>[
        Container(
          height: 150,
          width: MediaQuery.of(context).size.width,
          color: MyColors.base_green_color,
          child: Column(
            children: <Widget>[
              SizedBox(height: 35,),
              Icon(Icons.check_circle_outline, color: MyColors.grey_color,size: 30,),
              SizedBox(height: 20,),
              Text("Thanks for using Upaychat!", style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Doomsday',
                  color: Colors.white
              )),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: SizedBox()),
                  Image.asset("assets/logo_white.png", width: 12,),
                  SizedBox(width: 5,),
                  Text("Upaychat", style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Doomsday',
                      color: Colors.white
                  )),
                  Expanded(child: SizedBox()),
                ],
              ),

            ],

          ),

        ),

        Container(
          color: Colors.white,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text("TOKEN", style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Doomsday',
                  color: Colors.grey
              )),
              Text(statusModel != null ? statusModel!.billingResult != null ? CommonUtils.tokenFormat(statusModel!.billingResult!.extra ?? '') : '' : '', style: TextStyle(
                  fontSize: 34,
                  fontFamily: 'Doomsday',
                  color: Colors.grey,

              ), textAlign: TextAlign.center,),
              SizedBox(height:20),
              Row(
                children: [
                  Text("Amount", style: TextStyle(
                      fontSize: 18,
                      // fontFamily: 'Doomsday',
                      color: Colors.black
                  )),
                  Expanded(child: SizedBox()),
                  Text('₦' + double.parse(amountController.text).toStringAsFixed(2), style: TextStyle(
                      fontSize: 18,
                      // fontFamily: 'Doomsday',
                      color: Colors.black
                  )),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                children: [
                  Text("Date & Time", style: TextStyle(
                      fontSize: 18,
                      // fontFamily: 'Doomsday',
                      color: Colors.black
                  )),
                  Expanded(child: SizedBox()),
                  Text(transactionSuccessDateTime, style: TextStyle(
                      fontSize: 18,
                      // fontFamily: 'Doomsday',
                      color: Colors.black
                  )),
                ],
              ),
              Container(
                height: 30,
                decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: Colors.grey),
                    )
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text("Transaction Type", style: TextStyle(
                      fontSize: 18,
                      // fontFamily: 'Doomsday',
                      color: Colors.black
                  )),
                  Expanded(child: SizedBox()),
                  Text("Electricity", style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Doomsday',
                      color: Colors.black
                  )),
                ],
              ),
              Container(
                height: 15,
                decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: Colors.grey),
                    )
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text("Reference", style: TextStyle(
                      fontSize: 18,
                      // fontFamily: 'Doomsday',
                      color: Colors.black
                  )),
                  Expanded(child: SizedBox()),
                  Text(userController.text, style: TextStyle(
                      fontSize: 18,
                      color: Colors.black
                  )),

                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text("Name", style: TextStyle(
                      fontSize: 18,
                      // fontFamily: 'Doomsday',
                      color: Colors.black
                  )),
                  Expanded(child: SizedBox()),
                  Text(PreferencesManager.getString(StringMessage.username), style: TextStyle(
                      fontSize: 18,
                      // fontFamily: 'Doomsday',
                      color: Colors.black
                  )),
                ],
              ),
            ],
          ),
        )
      ],
    );
    return Container(
      child: Column(
        children: [
          SizedBox(height: 10,),
          Container(
            child: Text("Transaction Summary",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Doomsday',
                  color: Colors.grey.shade800),),
          ),
          SizedBox(height: 10,),
          Container(
            child: Text("You have purchased power!",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Doomsday',
                  color: Colors.grey.shade800),),
          ),
          SizedBox(height: 20,),
          Container(
            child: Text("Token",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Doomsday',
                  color: Colors.grey.shade800),),
          ),
          SizedBox(height: 10,),
          Container(
            child: Text(statusModel != null ? statusModel!.billingResult != null ? statusModel!.billingResult!.extra ?? '' : '' : '',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Doomsday',
                  color: Colors.grey.shade800),),
          ),
        ],
      ),
    );
  }

  void transactionSuccessCallback(payload) {
    final snackBar = SnackBar(
      content: Text(payload.toString()),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void transactionFailureCallback(payload) {
    final snackBar = SnackBar(
      content: Text(payload.toString()),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  Widget renderBundleCategoryItem(categoryData){
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: MyColors.light_grey_color)),
      ),
      child: InkWell(
        splashColor: Colors.black.withAlpha(200),
        onTap: () {
          setState(() {
            currentBillOption = categoryData;
          });
          getCategories(categoryData['data']);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
          child: Row(
            children: [
              Image.asset("assets/" +categoryData['image'] + ".png",height: 40,
                width: 65,),
              Expanded(child: Container(
                child: Text(categoryData['text'], style: TextStyle(
                  fontFamily: 'Doomsday',
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),),
              )),

            ],
          ),
        ),
      ),
    );

  }
  Widget _renderBundleCategories(){
    //bundleCategories
    return Container(
      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: ListView.builder(
        itemCount: bundleCategories.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) =>
            renderBundleCategoryItem(bundleCategories[index]),
      ),
    );
  }
  _body(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: (curShowPage == 0)
            ? _renderBundleCategories()
            : (curShowPage == 1) ?  _renderBillsPage() : _renderBillComplete()
      ),
    );
  }
  validateMetaNumber(String value) async{
    print("Validate Meter Number");
    if(value.length == 13 || value.length == 11){

      if(itemCode != null && billCode != null){
        context.loaderOverlay.show();
        try{

          GetFlutterWaveBillingVerificationApi getFlutterWaveBillingVerificationApi = new GetFlutterWaveBillingVerificationApi();
          FlutterwaveBillingVerificationModel _model = await getFlutterWaveBillingVerificationApi.search(itemCode!, billCode!, value);
          if(_model.status == "success"){
            _verificationData = _model.verificationData;
          }
          else{
            CommonUtils.errorToast(context, "The Meter number cannot be validated");
          }
          context.loaderOverlay.hide();
        }
        catch(e){
          print("Error in validate meter number");
          print(e);
          CommonUtils.errorToast(context, "The Meter number cannot be validated");
          context.loaderOverlay.hide();
        }

      }
    }



  }

  void loadMeterNumbers() async{
    GetStringListApi _listApi = GetStringListApi();
    StringListModel _listModel = await _listApi.search('get_meternumbers');
    if(_listModel.status == 'true'){
      setState(() {
        meterNumbers = _listModel.data;

      });
      print(meterNumbers);
    }
  }
}
