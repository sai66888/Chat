import 'package:eventhandler/eventhandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Apis/load_funds_locked_api.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/Models/funds_locked.dart';

import '../CustomWidgets/my_colors.dart';
import '../Events/balanceevent.dart';

class SafeLockFile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SafeLockFileState();
  }
}

class SafeLockFileState extends State<SafeLockFile> {

  List<FundsLocked> fundsLockedList = [];
  String totalLocked = '0.00';
  @override
  void initState() {
    EventHandler().subscribe(_onLockFundsEventHandler);
    loadFundsLocked();
  }
  @override
  void dispose() {
    EventHandler().unsubscribe(_onLockFundsEventHandler);
    super.dispose();
  }
  void _onLockFundsEventHandler(BalanceEvent event){
    switch (event.mode) {
      case 'safelock':
        loadFundsLocked();
        break;
    }
  }
  loadFundsLocked() async{
    context.loaderOverlay.show();
    try{
      LoadFundsLocked loadFundsLocked = LoadFundsLocked();
      FundsLockedListModel response =  await loadFundsLocked.loadData();
      if(response.status == "true"){
        print("TOtal Amount: ${response.total}");
        setState(() {
          fundsLockedList = response.fundsLockedList;
          totalLocked = response.total;
        });
      }
      else{
        CommonUtils.errorToast(context, response.message);
      }
      context.loaderOverlay.hide();
    }
    catch(error){
      CommonUtils.errorToast(context, error.toString());
      context.loaderOverlay.hide();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: IconButton(
                icon: const Icon(size: 30, Icons.chevron_left),
                onPressed: () { Navigator.pop(context); },
              ),
            );
          },
        ),
        leadingWidth: 40,
        title: Row(
          children: const [
            Spacer(),
            Text(
              'SafeLock',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Spacer(),
            SizedBox(width: 40),
          ],
        ),
        backgroundColor: MyColors.base_green_color,
        actions: [
          TextButton.icon(
            icon:Icon(MaterialCommunityIcons.plus, color: Colors.white,),
            label: Text("New", style: TextStyle(color: Colors.white),),
            onPressed: () {
              Navigator.of(context).pushNamed('/new_funds_lock');
            }
          )
        ],
      ),
      body: Container(
        color: MyColors.base_green_color_20,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("Safelock Balance", textAlign: TextAlign.left, style: TextStyle(
                          fontFamily: 'Doomsday',
                          fontSize: 20
                      ),)
                    ],
                  ),
                  Row(
                    children: [
                      Text("${StringMessage.naira}${CommonUtils.toCurrency(double.parse(totalLocked))}", style: TextStyle(
                          fontSize: 25
                      ),)
                    ],
                  )
                ],
              ),
            ),
            Expanded(child: ListView.builder(
              itemBuilder: (context, ind){
                int totalDays = DateTime.parse(fundsLockedList[ind].paybackAt!).difference(DateTime.parse(fundsLockedList[ind].lockedAt!)).inDays;
                int leftDays = DateTime.parse(fundsLockedList[ind].paybackAt!).difference(DateTime.now()).inDays;
                double percentRange = totalDays == 0 ? 0 :  leftDays / totalDays;

                return Container(
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(10),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: MyColors.base_green_color,),
                      SizedBox(width: 10,),
                      Expanded(child: Column(
                        children: [
                          Row(
                            children: [
                              Text(fundsLockedList[ind].safeLockName ?? "", textAlign: TextAlign.left, style: TextStyle(
                                fontFamily: 'Doomsday',
                                fontSize: 18
                              ),)
                            ],
                          ),
                          Row(
                            children: [
                              Text("${StringMessage.naira}${CommonUtils.toCurrency(fundsLockedList[ind].lockAmount ?? 0.00)}", style: TextStyle(
                                fontSize: 16
                              ),)
                            ],
                          ),
                          Table(
                            columnWidths: const <int, TableColumnWidth>{
                              0: FlexColumnWidth(),
                              1: IntrinsicColumnWidth(),
                            },
                            children: [
                              TableRow(
                                  children: [
                                    Container(
                                      child: const Text('Payback Date', style: TextStyle(
                                          fontSize: 14,
                                          color: MyColors.grey_color,
                                          fontFamily: 'Doomsday'
                                      ),),
                                    ),
                                    Container(
                                      child: const Text('Interest Earned', style: TextStyle(
                                          fontSize: 14,
                                          color: MyColors.grey_color,
                                          fontFamily: 'Doomsday'
                                      )),
                                    ),
                                  ]
                              ),
                              TableRow(
                                  children: [
                                    Container(
                                      child: Text(DateFormat('d MMM yyyy').format(DateTime.parse(fundsLockedList[ind].paybackAt!)), style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Doomsday',
                                          fontWeight: FontWeight.w900
                                      ),),
                                    ),
                                    Container(
                                      child: Text('${StringMessage.naira}${CommonUtils.toCurrency(fundsLockedList[ind].interestEarned ?? 0.00)}', style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Arial',
                                          fontWeight: FontWeight.w900
                                      )),
                                    ),
                                  ]
                              ),

                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child:LinearProgressIndicator(
                                    // valueColor: MyColors.base_green_color,
                                    backgroundColor: MyColors.light_grey_color,
                                    color: MyColors.base_green_color,
                                    value: percentRange,
                                  ) ),
                              SizedBox(width: 20,),
                              Text('${leftDays} Days left', style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Doomsday',
                              ))
                            ],
                          )
                        ],
                      )),
                    ],
                  ),
                );
              },
              itemCount: fundsLockedList.length,))
          ],
        ),
      ),
    );
  }

}