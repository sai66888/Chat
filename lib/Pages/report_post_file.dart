import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Apis/getStringListApi.dart';
import 'package:upaychat/Apis/reportapi.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/Models/commonmodel.dart';

import '../CustomWidgets/custom_ui_widgets.dart';
import '../CustomWidgets/my_colors.dart';

class ReportPostScreen extends StatefulWidget {
  final bool? isPost;
  final int? dataID;
  ReportPostScreen({Key? key, this.isPost, this.dataID})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ReportPostScreenState();
  }
}

class ReportPostScreenState extends State<ReportPostScreen>{
  List<String> reportOptions = [];
  @override
  void initState() {
    super.initState();
    loadReportOptions();
  }
  @override
  Widget build(BuildContext context) {
    TextEditingController myReportController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        title: new Text(
          "Report",
          style: TextStyle(
            fontFamily: 'Doomsday',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        )
      ),
      body: Container(
        color: MyColors.base_green_color_20,
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text("Choose a reason for reporting this ${widget.isPost == true ? 'post' : 'comment'}:", style: TextStyle(fontSize: 16, fontFamily: "Doomsday"),))
                ],
              ),
              ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(height: 3, color: MyColors.grey_color),
                  itemBuilder: (context, index){
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: InkWell(
                        onTap: (){
                          sendReport(reportOptions[index]);
                        },
                        child: Text(reportOptions[index], style: TextStyle(fontSize: 18, fontFamily: "Doomsday")),
                      ),
                    );
                  },itemCount: reportOptions.length),
              Divider(height: 3, color: MyColors.grey_color),
              Row(
                children: [
                  Expanded(child: Container(
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                      onTap: (){
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                elevation: 0.0,
                                backgroundColor: Colors.transparent,
                                child: StatefulBuilder(
                                    builder: (BuildContext context, StateSetter setState) {
                                      return Container(
                                        width: 250,
                                        height: 250,
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: SizedBox.expand(
                                          child: Column(
                                            children: [
                                              const Text(
                                                "Report",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Doomsday',
                                                  decoration: TextDecoration.none,
                                                  color: MyColors.grey_color,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 40),
                                              Container(
                                                height: 80,
                                                color: Colors.white,
                                                child: TextFormField(
                                                  textAlign: TextAlign.center,
                                                  controller: myReportController,
                                                  style: const TextStyle(fontFamily: 'Doomsday'),
                                                  decoration: const InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.all(Radius.circular(5)),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: MyColors.base_green_color, width: 2.0),
                                                    ),
                                                    hintText: 'Enter report',
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.fromLTRB(60, 15, 60, 15),
                                                  primary: MyColors.base_green_color,
                                                  shape: CustomUiWidgets.basicGreenButtonShape(),
                                                ),
                                                onPressed: () {
                                                  if (myReportController.text.isEmpty) {
                                                    CommonUtils.errorToast(context, "Enter report");
                                                  } else {
                                                    Navigator.of(context).pop();
                                                    sendReport(myReportController.text);
                                                  }
                                                },
                                                child: const Text(
                                                  'Submit',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontFamily: 'Doomsday',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              );
                            });
                      },
                      child: Text("Other", style: TextStyle(fontSize: 18, fontFamily: "Doomsday")),
                    ),
                  ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void loadReportOptions() async{
    try{
      context.loaderOverlay.show();
      GetStringListApi getStringListApi = GetStringListApi();
      StringListModel reportsModel = await getStringListApi.search("getreportoptions?isPost=${widget.isPost == true ? 'true' : 'false'}");
      if(reportsModel.status == "true"){
        reportsModel.data;
        setState(() {
          reportOptions = reportsModel.data;
        });
      }
      context.loaderOverlay.hide();
    }
    catch(e){
      context.loaderOverlay.hide();
    }

  }

  void sendReport(String text) async{
    context.loaderOverlay.show();
    try{
      ReportApi reportApi = ReportApi();
      CommonModel response = await reportApi.report(text, widget.dataID.toString(), widget.isPost == true ? 'true' : 'false');
      if(response.status == 'true'){
        context.loaderOverlay.hide();
        Navigator.of(context).pop();
        CommonUtils.successToast(context, response.message);
      }
      else{
        context.loaderOverlay.hide();
        CommonUtils.errorToast(context, response.message);
      }
      
    }
    catch(e){
      context.loaderOverlay.hide();
    }
  }
}