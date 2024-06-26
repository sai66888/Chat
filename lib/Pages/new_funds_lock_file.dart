import 'package:eventhandler/eventhandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Apis/lock_funds_api.dart';
import 'package:upaychat/Models/commonmodel.dart';
import 'package:upaychat/Models/funds_lock_option.dart';
import 'package:upaychat/globals.dart';

import '../CommonUtils/common_utils.dart';
import '../CommonUtils/string_files.dart';
import '../CustomWidgets/my_colors.dart';
import '../Events/balanceevent.dart';
class NewFundsLockFile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewFundsLockFileState();
  }
}

class NewFundsLockFileState extends State<NewFundsLockFile> {
  TextEditingController lockAmountController = TextEditingController();
  TextEditingController paybackDateController = TextEditingController();
  TextEditingController safeLockNameController = TextEditingController();
  DateTime? paybackDate;
  double lockAmount = 0.00;
  double earnings = 0.00;
  double interest_earned = 0.00;
  int lockDuration = 0;
  int pageIndex = 0;
  String searchFilter = "";
  /*
  * Our safe lock duration
  10 - 30 days (6%) per annum
  31 - 60 days (7%) per annum
  61 - 90 days (9%) per annum
  91 - 364 days (10%) per annum
  366 - 730 days (12.5%) per annum
  731 - 1000 days (26%) per annum
  Over 1000 days (36%) per annum
  * */
  List<FundsLockOption> lockOptions = [
    FundsLockOption(description: "10 - 30 days (6%) p.a", fromDay: 10, toDay: 30, interestRate: 6),
    FundsLockOption(description: "31 - 60 days (7%) p.a", fromDay: 31, toDay: 60, interestRate: 7),
    FundsLockOption(description: "61 - 90 days (9%) p.a", fromDay: 61, toDay: 90, interestRate: 9),
    FundsLockOption(description: "91 - 365 days (10%) p.a", fromDay: 91, toDay: 365, interestRate: 10),
    FundsLockOption(description: "366 - 730 days (12.5%) p.a", fromDay: 366, toDay: 730, interestRate: 12.5),
    FundsLockOption(description: "731 - 1000 days (13%) p.a", fromDay: 731, toDay: 1000, interestRate: 13),
    // FundsLockOption(description: "Over 1000 days (36%) p.a", fromDay: 1000, toDay: -1, interestRate: 36)
  ];
  int selectedLockOption = -1;
  @override
  Widget build(BuildContext context) {
    if(selectedLockOption == -1){
      earnings = 0;
      interest_earned = 0;
    }
    else {
      interest_earned = (lockAmount * ((lockOptions[selectedLockOption].interestRate ?? 0)  / 100)* (paybackDate?.difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays ?? 0) / 365);
      earnings = lockAmount + interest_earned;
    }
    bool isLockable = false;
    isLockable = lockAmount >= 1000 && lockAmount <= 100000000 && safeLockNameController.text.isNotEmpty && !paybackDate.isNull;
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: IconButton(
                icon: const Icon(size: 30, Icons.chevron_left),
                onPressed: () {
                  if(pageIndex == 0){
                    Navigator.pop(context);
                  }
                  else{
                    setState(() {
                      pageIndex = pageIndex - 1;
                    });
                  }
                },
              ),
            );
          },
        ),
        leadingWidth: 40,
        title: Row(
          children: const [
            Spacer(),
            Text(
              'New Funds Lock',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Spacer(),
            SizedBox(width: 40),
          ],
        ),
        backgroundColor: MyColors.base_green_color,

      ),
      body: SafeArea(
        child: Container(
          color: MyColors.base_green_color_20,
          padding: EdgeInsets.all(10),
          child: Column(
            children: [

              Expanded(
                  child: SingleChildScrollView(
                    child: pageIndex == 0 ? Column(

                      children: [
                        Row(
                          children: [
                            Expanded(child: Text("Safelock duration", style: TextStyle(fontSize: 20,fontFamily: 'Doomsday'),))
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(child: Text("Select a duration that you want to lock your money & earn upfront interests of up to 13%.", style: TextStyle(fontSize: 14,fontFamily: 'Doomsday', color: MyColors.light_grey_color),))
                          ],
                        ),
                        SizedBox(height: 20,),
                        SizedBox(
                          child: GridView.count(
                            shrinkWrap: true,
                            childAspectRatio: ((MediaQuery.of(context).size.width - 10) / 50),
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            children: lockOptions.asMap().entries.map((lockOption) {
                              return InkWell(
                                onTap: (){
                                  setState(() {
                                    selectedLockOption = lockOption.key;
                                    paybackDate = null;
                                    paybackDateController.text = "";
                                    pageIndex = 1;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: MyColors.base_green_color),
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      color: selectedLockOption ==  lockOption.key ? MyColors.base_green_color: Colors.white,

                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Text(lockOption.value.description ?? "", style: TextStyle(color:  selectedLockOption !=  lockOption.key ? Colors.black: Colors.white), textAlign: TextAlign.center,),
                                  ),
                                ),
                              );
                            }).toList(),
                            crossAxisCount: 1,

                          ),
                        ),
                        SizedBox(height: 10,),
                      ],

                    ) : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text("Lock your money", style: TextStyle(fontSize: 18,fontFamily: 'Doomsday',fontWeight: FontWeight.w900),))
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(child: Text("Amount to lock", style: TextStyle(fontSize: 14,fontFamily: 'Doomsday'),))
                          ],
                        ),
                        SizedBox(height: 10,),
                        Container(
                          color: Colors.white,
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                          child: TextField(
                            textAlign: TextAlign.start,
                            controller: lockAmountController,
                            style: const TextStyle(
                              fontFamily: 'Doomsday',
                              fontSize: 18,
                            ),
                            onChanged: (text) async {
                              if (text.isNotEmpty) {
                                text = text.replaceAll(RegExp(r'[^0-9.]'), '');
                                String prev = text;
                                text = text.replaceAll(',', '');
                                text = text.replaceAll('.', '');
                                if (text.length >= 12) text = text.substring(0, 9);
                                double value = int.parse(text).toDouble() / 100;
                                if (value > 100000000) {
                                  text = text.substring(0, 8);
                                  value = int.parse(text).toDouble() / 100;
                                }
                                setState(() {
                                  lockAmount = value;
                                });
                                text = CommonUtils.toCurrency(value);
                                if (prev != text) {
                                  lockAmountController.text = text;
                                  lockAmountController.selection =
                                      TextSelection.collapsed(offset: text.length);
                                }

                              }
                            },
                            inputFormatters: [amountValidator!],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: MyColors.base_green_color, width: 2.0),
                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              ),
                              hintText: "Min ${StringMessage.naira}1,000 - Max ${StringMessage.naira}100,000,000",
                              hintStyle: TextStyle(fontSize: 14, fontFamily: 'Arial')
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(child: Text("Name of the safelock", style: TextStyle(fontSize: 14,fontFamily: 'Doomsday'),))
                          ],
                        ),
                        Container(
                          color: MyColors.base_green_color_20,
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                          child: TextField(
                            textAlign: TextAlign.start,
                            controller: safeLockNameController,
                            style: const TextStyle(
                              fontFamily: 'Doomsday',
                              fontSize: 18,
                            ),
                            maxLength: 30,
                            decoration: const InputDecoration(
                                contentPadding:
                                EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyColors.base_green_color, width: 2.0),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(child: Text("Payback date", style: TextStyle(fontSize: 14,fontFamily: 'Doomsday'),))
                          ],
                        ),
                        Container(
                          color: Colors.white,
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                          child: TextField(
                            textAlign: TextAlign.start,
                            controller: paybackDateController,
                            readOnly: true,
                            onTap: (){
                              print("onCLick...");
                              if(selectedLockOption != -1){
                                DateTime firstDate = DateTime.now().add(Duration(days: lockOptions[selectedLockOption].fromDay ?? 0));

                                DateTime lastDate =  DateTime.now().add(Duration(days: lockOptions[selectedLockOption].toDay ?? 0));

                                if(lockOptions[selectedLockOption].toDay == -1){
                                  lastDate =  DateTime(2101);
                                }
                                showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  builder: (context){
                                    return StatefulBuilder(
                                      builder: (BuildContext context, StateSetter mystate){
                                        return SafeArea(child: Container(
                                          // height: 400,
                                            child: Column(
                                              children: [

                                                Container(

                                                  child: Text("Select Payback Date", style: TextStyle(
                                                    fontFamily: 'Doomsday',
                                                    fontSize: 18,
                                                  ),),
                                                  margin: EdgeInsets.only(top: 20, bottom: 10),
                                                ),
                                                Container(
                                                  child: TextField(
                                                    decoration: const InputDecoration(
                                                      contentPadding:
                                                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: MyColors.base_green_color, width: 2.0),
                                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      print("Trigger OnChanged: ${value}");
                                                      mystate(() {
                                                        searchFilter = value;
                                                      });

                                                    },

                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                ),
                                                Expanded(child: ListView.builder(
                                                    padding: const EdgeInsets.all(8),
                                                    itemCount: lastDate.difference(firstDate).inDays + 1,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      String dateStr = DateFormat.yMMMMd().format(firstDate.add(Duration(days:  index)));
                                                      print("Render list: ${searchFilter}");
                                                      return searchFilter == "" || dateStr.contains(searchFilter) ?  InkWell(
                                                        onTap: (){
                                                          setState(() {
                                                            lockDuration = (lockOptions[selectedLockOption].fromDay ?? 0) + index;
                                                            paybackDate = firstDate.add(Duration(days: index));
                                                            paybackDateController.text = '$lockDuration  Days is ${DateFormat.yMMMd().format(firstDate.add(Duration(days: index)))}';
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                        child: Container(
                                                          height: 50,
                                                          child: Text('[${(lockOptions[selectedLockOption].fromDay ?? 0)+ index}]: ${dateStr} '),
                                                        ),
                                                      ) : null;
                                                    }
                                                ))
                                              ],
                                            )
                                        ));
                                      },
                                    );
                                  },
                                ).then((value){
                                  setState((){
                                    searchFilter = "";
                                });
                                });

                              }
                              else{
                                CommonUtils.errorToast(context, "Please choose safelock duration");
                              }

                            },
                            style: const TextStyle(
                              fontFamily: 'Doomsday',
                              fontSize: 18,
                            ),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding:
                                EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyColors.base_green_color, width: 2.0),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                                hintText: "Select payback date",
                                hintStyle: TextStyle(fontSize: 14),
                              suffixIcon: Icon(Icons.arrow_forward_ios_rounded)
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: MyColors.light_grey_divider_color,
                            borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          child: Column(
                            children: [
                              Text("Total Earnings", style: TextStyle(fontFamily: "Doomsday", fontSize: 14,  fontWeight: FontWeight.w600)),
                              Text(StringMessage.naira + CommonUtils.toCurrency(
                                paybackDate != null && selectedLockOption != -1 ? earnings : 0.00
                              ), style: TextStyle(color: MyColors.base_green_dark_color, fontSize: 24,  fontWeight: FontWeight.w900),),
                            ],
                          ),
                        ),
                        SizedBox(height: 30,),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: isLockable ? MyColors.base_green_color : MyColors.light_grey_color,

                              ),
                              onPressed: isLockable  ?  () {
                                if(lockAmount == 0){
                                  CommonUtils.errorToast(context, "Missing amount to lock!");
                                  return;
                                }
                                if(selectedLockOption == -1){
                                  CommonUtils.errorToast(context, "Missing lock duration.");
                                  return;
                                }
                                if(paybackDate == null){
                                  CommonUtils.errorToast(context, "Please choose payback date");
                                  return;
                                }
                                if(Globals.walletbalance >= lockAmount){
                                  showModalBottomSheet<void>(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.white,
                                    builder: (BuildContext dialogContext) {
                                      return SafeArea(child: Container(
                                        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                                        child: Wrap(
                                          alignment: WrapAlignment.start,
                                          spacing: 0,
                                          runSpacing: 0,
                                          children: [

                                            Container(

                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment(0.8, 1),
                                                  colors: <Color>[
                                                    Color(0xffdc8c13),
                                                    Color(0xffEFAF4E),
                                                  ], // Gradient from https://learnui.design/tools/gradient-generator.html
                                                  tileMode: TileMode.mirror,
                                                ),
                                              ),
                                              margin: const EdgeInsets.only(bottom: 10, top: 30),
                                              child: Table(
                                                columnWidths: const <int, TableColumnWidth>{
                                                  0: FlexColumnWidth(),
                                                  1: IntrinsicColumnWidth(),
                                                },
                                                children: [
                                                  TableRow(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.only(top: 20, left: 20, bottom: 10),
                                                          child: const Text('Amount to lock', style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.white,
                                                              fontFamily: 'Doomsday'
                                                          ),),
                                                        ),
                                                        Container(
                                                          padding: const EdgeInsets.only(top: 20, left: 20, bottom: 10, right: 10),
                                                          child: const Text('Lock duration', style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.white,
                                                              fontFamily: 'Doomsday'
                                                          )),
                                                        ),
                                                      ]
                                                  ),
                                                  TableRow(
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets.only(left: 20),
                                                          child: Text('${StringMessage.naira}${CommonUtils.toCurrency(lockAmount)}', style: const TextStyle(
                                                              fontSize: 16,
                                                              color: Colors.white,
                                                              fontFamily: 'Arial',
                                                              fontWeight: FontWeight.w900
                                                          ),),
                                                        ),
                                                        Container(
                                                          padding: EdgeInsets.only(left: 20, right: 10),
                                                          child: Text('${lockDuration} Days', style: const TextStyle(
                                                              fontSize: 16,
                                                              color: Colors.white,
                                                              fontFamily: 'Doomsday',
                                                              fontWeight: FontWeight.w900
                                                          )),
                                                        ),
                                                      ]
                                                  ),
                                                  TableRow(
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets.only(top: 20, left: 20, bottom: 10),
                                                          child: const Text('Interest to earn', style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.white,
                                                              fontFamily: 'Doomsday'
                                                          ),),
                                                        ),
                                                        Container(
                                                          padding: EdgeInsets.only(top: 20, left: 20, bottom: 10, right: 10),
                                                          child: const Text('Interest', style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.white,
                                                              fontFamily: 'Doomsday'
                                                          )),
                                                        ),
                                                      ]
                                                  ),
                                                  TableRow(
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets.only(left: 20, bottom: 20),
                                                          child: Text('${StringMessage.naira}${CommonUtils.toCurrency(earnings)}', style: const TextStyle(
                                                              fontSize: 16,
                                                              color: Colors.white,
                                                              fontFamily: 'Arial',
                                                              fontWeight: FontWeight.w900
                                                          ),),
                                                        ),
                                                        Container(
                                                          padding: EdgeInsets.only(left: 20, right: 10, bottom: 20),
                                                          child: Text('${(lockOptions[selectedLockOption].interestRate ?? 0) / 100}%', style: const TextStyle(
                                                              fontSize: 16,
                                                              color: Colors.white,
                                                              fontFamily: 'Doomsday',
                                                              fontWeight: FontWeight.w900
                                                          )),
                                                        ),
                                                      ]
                                                  )
                                                ],
                                              ),
                                            ),
                                            const Text('🔒Interest will be paid immediately. Locked funds CANNOT be withdrawn till payback date.', style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: "Doomsday",
                                            )),
                                            Container(
                                              margin: EdgeInsets.only(top: 5),
                                              width: MediaQuery.of(context).size.width,
                                              height: 50,
                                              child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: MyColors.base_green_color,

                                                  ),
                                                  onPressed: () async{
                                                    context.loaderOverlay.show();
                                                    try{
                                                      LockFundsApi lockFundsApi = LockFundsApi();
                                                      CommonModel response = await lockFundsApi.lockFunds(lockAmount.toString(), lockOptions[selectedLockOption].interestRate.toString(), lockDuration.toString(), interest_earned.toString(), CommonUtils.toCurrency(earnings),DateFormat('yyyy-MM-dd').format(paybackDate!),DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now())  , safeLockNameController.text);
                                                      if(response.status == "true"){
                                                        CommonUtils.successToast(context, response.message);
                                                        EventHandler().send(BalanceEvent('safelock'));
                                                        context.loaderOverlay.hide();
                                                        Navigator.pop(context);
                                                      }
                                                      else{
                                                        CommonUtils.errorToast(context, response.message);
                                                      }
                                                      context.loaderOverlay.hide();
                                                    }
                                                    catch(error){
                                                      print("Error: ${error.toString()}");
                                                      context.loaderOverlay.hide();
                                                    }
                                                  },
                                                  child: const Text('Confirm', style: TextStyle(
                                                      fontSize: 18,
                                                      fontFamily: "Doomsday",
                                                      color: Colors.white
                                                  ))),
                                            ),
                                            SizedBox(height: 30,),
                                          ],
                                        ),
                                      ));
                                    },
                                  );
                                }
                                else{
                                  CommonUtils.errorToast(context, 'Insufficient funds!');
                                }
                              } : null,
                              child: const Text('Safelock now', style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Doomsday",
                                  color: Colors.white
                              ))),
                        )
                      ],
                    ),
                  )),

            ],
          ),
        ),
      ),
    );
  }

}