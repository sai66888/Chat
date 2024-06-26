import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../CustomWidgets/my_colors.dart';

class FlutterwaveCheckoutFile extends StatefulWidget {
  String? redirectURL;
  FlutterwaveCheckoutFile({Key? key,
    required this.redirectURL
  }): super(key: key);
  @override
  State<StatefulWidget> createState() {
    return FlutterwaveCheckoutFileState();
  }
}
class FlutterwaveCheckoutFileState extends State<FlutterwaveCheckoutFile> {
  WebViewController? webViewController;
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    String redirectUrl = widget.redirectURL!;
    print("Flutterwave URL: ${redirectUrl}");
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        title: new Text(
          'Flutterwave Checkout',
          style: TextStyle(
              fontFamily: 'Doomsday',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(child:
      Stack(
        children: [
          WebView(
            initialUrl: redirectUrl,
            javascriptMode: JavascriptMode.unrestricted,
            userAgent: 'Flutter;Webview',
            javascriptChannels: <JavascriptChannel>{_toasterJavascriptChannel(context)},
            onPageFinished: (String url) {
              setState(() {
                isLoading = false;
              });
            },
            onPageStarted: (started){

            },
            onWebViewCreated: (WebViewController _webViewController){
              print('webview created');
              print(_webViewController);
              webViewController = _webViewController;
              // webViewController!.runJavascript("");

            },
            gestureNavigationEnabled: true,
            navigationDelegate: (NavigationRequest  navigation){

              print("Callback");
              print(navigation);
              if(navigation.url.contains("https://admin.upaychat.com/paymentsuccess")){
                if(navigation.url.contains('status=successful') || navigation.url.contains('status=completed')){
                  Navigator.pop(context, "success");
                }
                else if(navigation.url.contains('status%22%3A%22successful') || navigation.url.contains('status=completed')){
                  Navigator.pop(context, "success");
                }
                else{
                  Navigator.pop(context);
                }
                //close webview
              }
              return NavigationDecision.navigate;

              // return NavigationDecision.navigate;
            },
          ),
          isLoading ?  Container(color: MyColors.base_green_color_20,child: CommonUtils.progressDialogBox(),) : Stack()
        ],
      )
    ));
  }
  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {

    return JavascriptChannel(
        name: 'mn',
        onMessageReceived: (JavascriptMessage message) {
          print('New Channel Request');

        });
  }
  void verifyTransaction(String reference) {

  }

  Future<bool> browserBack(BuildContext context) async{
    print('activated');
    if (await webViewController!.canGoBack()) {
      // Scaffold.of(context).showSnackBar(
      //   const SnackBar(content: Text("Munching....")),
      // );
      print("onwill goback");
      webViewController!.goBack();
      return  Future.value(true);
    }
    else {
      // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      Navigator.pop(context);
      return Future.value(false);
    }
  }

}