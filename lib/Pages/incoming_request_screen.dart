import 'dart:async';
import 'dart:io' show Platform, exit;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class IncomingRequestScreen extends StatefulWidget {
  final String callUUID;
  final String sender;

  const IncomingRequestScreen(this.callUUID, this.sender);
  @override
  State<StatefulWidget> createState() {
    return IncomingRequestScreenState();
  }
}
class IncomingRequestScreenState extends State<IncomingRequestScreen> {
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    // initTimer();

  }
  void initTimer(){
    Timer(const Duration(seconds: 5), (){
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Incoming Call',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                '${widget.sender} is calling...',
                style: TextStyle(fontSize: 18),
              ),
              ElevatedButton(
                onPressed: () => _answerCall(context),
                child: Text('Answer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _answerCall(BuildContext context) {
    // Handle the incoming call
    // Replace with your own implementation
  }
}