// ignore_for_file: prefer_const_constructors
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:eventhandler/eventhandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/interswitch_utils.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/Models/flutterwavecategoriesmodel.dart';
import 'package:upaychat/globals.dart';

import '../Apis/createflutterwaveairtimeapi.dart';
import '../Apis/createflutterwavebillpaymentapi.dart';
import '../Apis/getflutterwavecategories.dart';
import '../CommonUtils/preferences_manager.dart';
import '../CommonUtils/string_files.dart';
import '../Events/balanceevent.dart';
import '../Models/flutterwavebillingcreatedmodel.dart';

class AirtimeDataFile extends StatefulWidget {
  const AirtimeDataFile({super.key});

  @override
  State<StatefulWidget> createState() {
    return AirtimeDataFileState();
  }
}

class AirtimeDataFileState extends State<AirtimeDataFile> {
  List billers = List.empty();
  var selectedBillerId;
  bool isAirtime = true;
  bool saveBeneficiary = true;
  var dataBundleAmountController = TextEditingController();
  var airtimeAmountController = TextEditingController();
  String currentPage = 'first_page';
  var selectedBillOption;
  var currentBillOption;
  String? billCode, itemCode;
  String? currentDataBundleOption;
  String selectedRecurrence = 'One Time';
  bool isFee = false;
  String feeText = "No Fee";
  String userLabelName = "Mobile phone number";
  List<dynamic> categories = [];
  String referenceText = '';
  String transactionSuccessDateTime = "";
  GlobalKey globalKey = GlobalKey();


  List<FlutterwaveCategoriesData> flutterCategories = [];
  @override
  void initState() {
    airtimeAmountController.text = '100';
    super.initState();
  }
  Future<void> share(String title, String text) async {
    await FlutterShare.share(
        title: title,
        text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        title: Text(
          currentPage == 'first_page' ? 'Airtime & Data' :
          currentPage == 'airtime' ? 'Airtime' :
          currentPage == 'data_bundle_bills' ? 'Data Bundles' :
              currentPage == 'thankyou_airtime' || currentPage == 'thankyou_databundle' ? 'Transaction Result' :
          'Data Bundles'
        ,
          style: const TextStyle(
            fontFamily: 'Doomsday',
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (currentPage == 'first_page') {
              Navigator.of(context).pop();
            } else if (currentPage == 'airtime' ||
                currentPage == 'data_bundles') {
              setState(() {
                currentPage = 'first_page';
              });
            } else if (currentPage == 'data_bundle_bills') {
              setState(() {
                currentPage = 'data_bundles';
              });
            }
            else if (currentPage == 'thankyou_airtime' || currentPage == 'thankyou_databundle'){
              Navigator.of(context).pop();
            }
          },
        ),
      ),

      body: Container(
        color: Color(0xffe8fce8),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: _body(context),
        ),
      ),
      resizeToAvoidBottomInset : true,
      floatingActionButton:
      currentPage == 'thankyou_airtime' ?
        FloatingActionButton(
          backgroundColor: Colors.green,
          child: const Icon(Icons.download),
          onPressed: () {
            String transactionResultText = "";
            transactionResultText += "Amount:${airtimeAmountController.text}\n";
            transactionResultText += "DateTime:$transactionSuccessDateTime\n";
            transactionResultText += "Transaction Type:AirTime\n";

            transactionResultText += "Reference:$referenceText\n";
            transactionResultText += "Name:${PreferencesManager.getString(StringMessage.username)}\n";
            share("Transaction Result", transactionResultText);
        },)
          : SizedBox(),
    );
  }

  Future<PermissionStatus> getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.restricted;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      const snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      const snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void pickFromContacts() async {
    final PermissionStatus permissionStatus = await getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Navigator.of(context).pushNamed('/pickcontact', arguments: {
        'onContactPicked': (mobile) {
          userController.text = mobile;
        }
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  final TextEditingController userController = TextEditingController();
  List getProviders() {
    if (billers == null) return [];
    return billers.where((element) {
      String type = element['type'];
      if (isAirtime) {
        return type == "MO";
      }
      return element['type'] == "MP" || element['type'] == "";
    }).toList();
  }



  completeBuyDatabundle() async{
    if (CommonUtils.isEmpty(userController, 0)) {
      CommonUtils.errorToast(context, "Please input the phone number");
      return;
    }
    if (CommonUtils.isEmpty(dataBundleAmountController, 0) ||
        double.parse(dataBundleAmountController.text) <= 0) {
      CommonUtils.errorToast(context, "Please input the amount");
      return;
    }
    if(currentDataBundleOption == null){
      CommonUtils.errorToast(context, "Please choose data bundle.");
      return;
    }
    if (double.parse(dataBundleAmountController.text) > Globals.walletbalance) {
      CommonUtils.errorToast(context,
          "You do not have sufficient funds to complete this transaction.");
      // Navigator.of(context).pop();
      return;
    }
    context.loaderOverlay.show();
    var amount;
    amount = dataBundleAmountController.text;

    CreateFlutterwaveBillPaymentApi createFlutterwaveAirtimeApi = new CreateFlutterwaveBillPaymentApi();

    String postRecurrence = "";
    if (selectedRecurrence == "One Time") {
      postRecurrence = "ONCE";
    }
    else{
      postRecurrence = selectedRecurrence.toUpperCase();
    }
    FlutterwaveBillingCreatedModel result = await createFlutterwaveAirtimeApi.save(
        currentDataBundleOption!,amount, amount, userController.text, postRecurrence);
    context.loaderOverlay.hide();
    if(result.status == 'success'){

      CommonUtils.successToast(context, result.message);
      referenceText = result.billingResult!.reference!;
      // Navigator.of(context).pop();
      transactionSuccessDateTime =  DateFormat('d MMM yyyy,').add_jm().format(DateTime.now());
      currentPage = 'thankyou_databundle';

      EventHandler().send(BalanceEvent('wallet'));
      // Navigator.pop(context);
    }
    else{
      CommonUtils.errorToast(context, result.message);

    }
    // _interswitch.pay(transactionSuccessCallback, transactionFailureCallback, context);
  }
  completePayment() async {
    if (CommonUtils.isEmpty(userController, 0)) {
      CommonUtils.errorToast(context, "Please input the phone number");
      return;
    }

    if (CommonUtils.isEmpty(airtimeAmountController, 0) ||
        double.parse(airtimeAmountController.text) <= 0) {
      CommonUtils.errorToast(context, "Please input the amount");
      return;
    }
    if (
        double.parse(airtimeAmountController.text) < 100) {
      CommonUtils.errorToast(context, "Minimum amount should be NGN 100");
      return;
    }

    if (double.parse(airtimeAmountController.text) > Globals.walletbalance) {
      CommonUtils.errorToast(context,
          "You do not have sufficient funds to complete this transaction.");
      // Navigator.of(context).pop();
      return;
    }
    context.loaderOverlay.show();
    var amount;
    amount = airtimeAmountController.text;


    CreateFlutterwaveAirtimeApi createFlutterwaveAirtimeApi =
        CreateFlutterwaveAirtimeApi();
    String postRecurrence = "";
    if (selectedRecurrence == "One Time") {
      postRecurrence = "ONCE";
    }
    else{
      postRecurrence = selectedRecurrence.toUpperCase();
    }
    FlutterwaveBillingCreatedModel result = await createFlutterwaveAirtimeApi.save(
        amount, userController.text, selectedRecurrence);
    context.loaderOverlay.hide();
    if (result.status == 'success') {
      CommonUtils.successToast(context, result.message);
      referenceText = result.billingResult!.reference!;
      // Navigator.of(context).pop();
      transactionSuccessDateTime =  DateFormat('d MMM yyyy,').add_jm().format(DateTime.now());
      // currentPage = 'thankyou_airtime';

      EventHandler().send(BalanceEvent('wallet'));
      Navigator.pop(context);
    } else {
      CommonUtils.errorToast(context, result.message);
    }
  }

  Widget generateFirstPage() {
    return Container(
      color: const Color(0xe8fce8),
        child:Column(
      children: <Widget>[
        const SizedBox(
          height: 30,
        ),
        Container(
          width: MediaQuery.of(context).size.width - 40,
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 20),
          decoration: const BoxDecoration(
            border:
            Border(bottom: BorderSide(color: MyColors.light_grey_color)),
          ),
          child: InkWell(
            splashColor: Colors.black.withAlpha(200),
            onTap: () {
              setState(() {
                currentPage = 'airtime';
              });
            },
            child: Container(
              width: double.infinity,


              child: Row(
                children: <Widget>[
                  Container(
                    width: 60,
                    child:const Icon(
                      AntDesign.mobile1,
                      color: MyColors.grey_color,
                      size: 30,
                    ),
                  ),

                  const Expanded(
                      child: Text("Mobile Top-up",
                          style: TextStyle(
                            fontFamily: 'Doomsday',
                            color: Colors.black,
                            fontSize: 20,
                          ))),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          width: MediaQuery.of(context).size.width - 40,
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
          decoration: const BoxDecoration(
            border:
            Border(bottom: BorderSide(color: MyColors.light_grey_color)),
          ),
          child: InkWell(
            splashColor: Colors.black.withAlpha(200),
            onTap: () {
              setState(() {
                currentPage = 'data_bundles';
              });
            },
            child: Container(
              width: double.infinity,

              child: Row(
                children: <Widget>[
                  Container(
                    width: 60,
                    child:const Icon(
                      FontAwesome.money,
                      color: MyColors.grey_color,
                      size: 30,

                    ),
                  ),
                  Expanded(
                      child: Container(
                        child: const Text(
                          "Data Bundles",
                          style: TextStyle(
                            fontFamily: 'Doomsday',
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        )
      ],
    ));
  }

  getCategories(dynamic listData) async {
    bool isHideDlg = false;

    // CommonUtils.successToast(context, _model.message);

    //curShowPage = 1;
    setState(() {
      isFee = false;
      feeText = "";
      dataBundleAmountController.text = "0";
      currentDataBundleOption = listData['data'][0]['biller_name'];

      categories = listData['data'];
      currentPage = 'data_bundle_bills';
      billCode = listData['data'][0]['biller_code'];
      itemCode = listData['data'][0]['item_code'];
    });

        dataBundleAmountController.text =
            listData['data'][0]['amount'].toString();


        if (listData['data'][0]['commission_on_fee'].toString() == "true") {
          int feeAmount = int.parse(listData['data'][0]['fee']);
          setState((){
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
        dataBundleAmountController.text =
            (listData['data'][0]['amount'] + listData['data'][0]['fee'])
                .toString();
  }

  Widget _renderBundleCategories() {
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

  Widget renderBundleCategoryItem(categoryData) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: MyColors.light_grey_color)),
      ),
      child: InkWell(
        splashColor: Colors.black.withAlpha(200),
        onTap: () {
          currentBillOption = categoryData;
          getCategories(categoryData['data']);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(0, 15, 10,15),
          child: Row(
            children: [
              Image.asset(
                "assets/" + categoryData['image'] + ".png",
                height: 40,
                width: 65,
              ),
              Expanded(
                  child: Container(
                child: Text(categoryData['text'],
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Doomsday',
                  ),),
              )),

            ],
          ),
        ),
      ),
    );
  }

  _renderBundleBillsPage() {
    return Container(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 90,
              child: Image.asset(
                "assets/" + currentBillOption['image'] + ".png",
                height: 100,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Data Bundle",
                style: TextStyle(
                  color: MyColors.base_green_color,
                  fontSize: 18,
                  fontFamily: 'Doomsday',
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                              dataBundleAmountController.text =
                                  categories[i]['amount'].toString();
                              setState((){
                                billCode = categories[i]['biller_code'];
                                itemCode = categories[i]['item_code'];
                              });

                              if (categories[i]['commission_on_fee'].toString() == "true") {
                                int feeAmount = int.parse(categories[i]['fee']);
                                setState((){
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
                              dataBundleAmountController.text =
                                  (categories[i]['amount'] + categories[i]['fee'])
                                      .toString();
                              setState(() {
                                userLabelName = categories[i]['label_name'];
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

            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Text(
                "Amount",
                style: TextStyle(
                  color: MyColors.base_green_color,
                  fontSize: 18,
                  fontFamily: 'Doomsday',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5,),
            Container(
              margin: EdgeInsets.only(right: 50),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                color: MyColors.light_grey_divider_color
              ),
              child: TextField(
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: MyColors.base_green_color,
                  fontFamily: 'Doomsday',
                  fontSize: 25,
                ),
                controller: dataBundleAmountController,
                keyboardType: TextInputType.number,
                readOnly: true,
                inputFormatters: [amountValidator!],
                cursorColor: MyColors.base_green_color,
                decoration: InputDecoration(
                  focusColor: Colors.transparent,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintText: "0.00",
                ),
              ),
            ),

            Visibility(
              visible: isFee,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10,),

                  Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      feeText,
                      style: TextStyle(
                        color: MyColors.base_green_color,
                        fontSize: 18,
                        fontFamily: 'Doomsday',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ),
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

            SizedBox(
              height: 35,
            ),
            Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Text(
                userLabelName  ?? '',
                style: TextStyle(
                  color: MyColors.base_green_color,
                  fontSize: 18,
                  fontFamily: 'Doomsday',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        onChanged: (value) {
                          // filterSearchResults(value);
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
                              left: 10, right: 10, top: 0, bottom: 7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: MyColors.base_green_color),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: "Phone Number",
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: true,
                    child: InkWell(
                      onTap: pickFromContacts,
                      splashColor: MyColors.base_green_color_20,
                      child: Container(
                        width: 45,
                        height: 50,

                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          MaterialCommunityIcons.account,
                          color: MyColors.base_green_color,
                          size: 35,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),

            SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 50,
              child: Container(
                child: TextButton(
                  style: ButtonStyle(

                    backgroundColor: MaterialStateProperty.all<Color>(
                        MyColors.base_green_color),
                  ),
                  onPressed: completeBuyDatabundle, //
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
        ));
  }



  _renderThankyouDatabundlePage(){
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Column(
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
                Row(
                  children: [
                    Text("Amount", style: TextStyle(
                        fontSize: 18,
                        // fontFamily: 'Doomsday',
                        color: Colors.black
                    )),
                    Expanded(child: SizedBox()),
                    Text(double.parse(dataBundleAmountController.text).toStringAsFixed(2), style: TextStyle(
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
                    Text("Billing Payment", style: TextStyle(
                        fontSize: 18,
                        // fontFamily: 'Doomsday',
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
                        // fontFamily: 'Doomsday',
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
      ),
    );
  }
  _renderThankyouAirtimePage(){
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      height: double.infinity,
      child: Column(
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
                Row(
                  children: [
                    Text("Amount", style: TextStyle(
                        fontSize: 18,
                        // fontFamily: 'Doomsday',
                        color: Colors.black
                    )),
                    Expanded(child: SizedBox()),
                    Text(double.parse(airtimeAmountController.text).toStringAsFixed(2), style: TextStyle(
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
                    Text("Airtime", style: TextStyle(
                        fontSize: 18,
                        // fontFamily: 'Doomsday',
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
                        // fontFamily: 'Doomsday',
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
      ),
    );
  }
  _body(BuildContext context) {
    List lstData = getProviders();

    if (currentPage == "first_page") {
      return generateFirstPage();
    } else if (currentPage == 'airtime') {
      return Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Amount",
                style: TextStyle(
                  color: MyColors.base_green_color,
                  fontFamily: 'Doomsday',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                  padding: EdgeInsets.only(left: 4),
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 50),
                      Container(
                        width: 40,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: EdgeInsets.all(5),
                            backgroundColor: MyColors.light_grey_color,
                          ),
                          onPressed: () {
                            int currentAmount =
                            int.parse(airtimeAmountController.text);
                            if (currentAmount > 100) {
                              currentAmount -= 100;
                              airtimeAmountController.text = currentAmount.toString();
                            } else {
                              CommonUtils.errorToast(context,
                                  "Minimum amount should be NGN 100");
                            }
                          },
                          child: Text(
                            '-',
                            style: TextStyle(
                              color: MyColors.grey_color,
                              fontFamily: 'Doomsday',
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          // decoration: BoxDecoration(
                          //   color: Colors.white,
                          //   borderRadius: BorderRadius.circular(8),
                          // ),
                          child: TextField(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: MyColors.base_green_color,
                              fontFamily: 'Doomsday',
                              fontSize: 30,
                            ),
                            controller: airtimeAmountController,

                            keyboardType: TextInputType.number,
                            onChanged: (text) {

                            },
                            inputFormatters: [amountValidator!],
                            cursorColor: MyColors.base_green_color,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "0",
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: EdgeInsets.all(5),
                            backgroundColor: MyColors.light_grey_color,
                          ),
                          onPressed: () {
                            int currentAmount =
                            int.parse(airtimeAmountController.text);
                            currentAmount += 100;
                            airtimeAmountController.text = currentAmount.toString();
                          },
                          child: Text(
                            '+',
                            style: TextStyle(
                              color: MyColors.grey_color,
                              fontFamily: 'Doomsday',
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 50),
                    ],
                  )),
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 10,
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedRecurrence,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRecurrence = newValue!;
                      });
                    },
                    style: TextStyle(
                      fontFamily: 'Doomsday',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                    items: recurrences.map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    underline: SizedBox(),
                    selectedItemBuilder: (BuildContext context) {
                      return recurrences.map((var item) {
                        return Container(
                          width: 90,
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
                  ),
                  Expanded(
                    child: Container(
                      height: 10,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50,),
              Text(
                "Mobile Number",
                style: TextStyle(
                  color: MyColors.base_green_color,
                  fontSize: 18,
                  fontFamily: 'Doomsday',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
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
                          onChanged: (value) {
                            // filterSearchResults(value);
                          },
                          controller: userController,
                          style: TextStyle(
                            fontFamily: 'Doomsday',
                            fontSize: 18,
                            color: MyColors.grey_color
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
                            hintText: 'Phone Number',
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: pickFromContacts,
                      splashColor: MyColors.base_green_color_20,
                      child: Container(
                        width: 45,
                        height: 45,
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          MaterialCommunityIcons.account,
                          color: MyColors.base_green_color,
                          size: 35,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 30, left: 15, right: 15),
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
          ),
        ),
      );
    } else if (currentPage == 'data_bundles') {
      return _renderBundleCategories();
    } else if (currentPage == 'data_bundle_bills') {
      return _renderBundleBillsPage();
    }
    else if (currentPage == 'thankyou_airtime'){
      return _renderThankyouAirtimePage();
    }
    else if (currentPage == 'thankyou_databundle'){
      return _renderThankyouDatabundlePage();
    }
  }

}
