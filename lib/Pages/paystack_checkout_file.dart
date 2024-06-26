import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../CommonUtils/common_utils.dart';
import '../CustomWidgets/my_colors.dart';

class PaystackCheckoutFile extends StatefulWidget {
  String? reference;
  String? redirectUrl;
  PaystackCheckoutFile({Key? key,
    required this.reference, required this.redirectUrl,
    }): super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PaystackCheckoutFileState();
  }
}
class PaystackCheckoutFileState extends State<PaystackCheckoutFile> {
  WebViewController? webViewController;
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    String reference = widget.reference!;
    print('Access Token');
    print(widget.redirectUrl);
    return WillPopScope(child: Scaffold(
      appBar:  AppBar(
        backgroundColor: MyColors.base_green_color,
        centerTitle: true,
        title: new Text(
          'Paystack Checkout',
          style: TextStyle(
              fontFamily: 'Doomsday',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: '${widget.redirectUrl}',
            javascriptMode: JavascriptMode.unrestricted,
            userAgent: 'Flutter;Webview',
            javascriptChannels: <JavascriptChannel>{_toasterJavascriptChannel(context)},
            onPageFinished: (String url) {
              setState(() {
                isLoading = false;
              });
            },
            onWebViewCreated: (WebViewController _webViewController){
              print('webview created');
              print(_webViewController);
              webViewController = _webViewController;
              webViewController!.runJavascript("");
            },
            gestureNavigationEnabled: true,
            navigationDelegate: (NavigationRequest  navigation){
              //Listen for callback URL
              print("Callback");
              print(navigation);
              if(navigation.url == 'https://standard.paystack.co/close'){
                Navigator.pop(context, "success"); //close webview
              }
              if(navigation.url.contains("upaychat://cancel")){
                Navigator.pop(context); //close webview
              }
              if(navigation.url.contains("upaychat://success") ){
                // print('CCCCCCCCCCCCCCCCCCCCCCCCCCCC');
                // verifyTransaction(reference);
                Navigator.pop(context, "success"); //close webview
              }
              if(navigation.url.contains("https://upaychat.com/paystack/callback") ){
                // print('CCCCCCCCCCCCCCCCCCCCCCCCCCCC');
                // verifyTransaction(reference);
                Navigator.pop(context, "success"); //close webview
              }
              //https://upaychat.com/paystack/callback
              return NavigationDecision.navigate;
            },
          ),
          isLoading ? Container(color: MyColors.base_green_color_20,child: CommonUtils.progressDialogBox(),) : Stack()

        ],
      ),
    ), onWillPop: ()=> browserBack(context));
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
      // webViewController!.goBack();
      return  Future.value(true);
    }
    else {
      // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      Navigator.pop(context);
      return Future.value(false);
    }
  }
  
}