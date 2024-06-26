import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/Pages/Chat/ChatBubble.dart';

import '../../CommonUtils/preferences_manager.dart';
import '../../CommonUtils/string_files.dart';
import '../../CustomWidgets/my_colors.dart';
import 'ChatUserModel.dart';
final _databaseRef = FirebaseDatabase.instance.reference();
class RequestChatScreen extends StatefulWidget {
  final ChatUserModel chatUserModel;
  final String chatId ;
  const RequestChatScreen(this.chatId, this.chatUserModel);

  @override
  State<StatefulWidget> createState() {
    return RequestChatScreenState();
  }
}

class RequestChatScreenState extends State<RequestChatScreen>{
  FocusNode _focus = new FocusNode();
  String messageText = '';
  TextEditingController messageTextController = TextEditingController();
  late Stream<QuerySnapshot> _messagesStream;
  bool isUserWithMe = false;
  @override
  void initState() {
    super.initState();
    _messagesStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
    _databaseRef.child('users/${CommonUtils.getStrUserid()}/chatWithUser').set(widget.chatUserModel.userId);
    _databaseRef.child('users/${widget.chatUserModel.userId}/chatWithUser').onValue.listen((event) {
      setState(() {
        isUserWithMe = event.snapshot.value == CommonUtils.getStrUserid();
      });
    });
  }
  @override
  void dispose() {
    _databaseRef.child('users/${CommonUtils.getStrUserid()}/chatWithUser').set("");

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: MyColors.base_green_color,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back,color: Colors.black,),
                ),
                SizedBox(width: 2,),
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      widget.chatUserModel.provileAvatar),
                  maxRadius: 20,
                ),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(widget.chatUserModel.userName,style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.w600),),
                      SizedBox(height: 6,),
                      Text(isUserWithMe? "Active" : "Away",style: TextStyle(color: Colors.grey.shade600, fontSize: 13),),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _messagesStream,
                  builder: (context, snapshot) {
                    final messages = snapshot.data?.docs;
                    return ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data?.docs.length ?? 0,
                        itemBuilder: (context, index) {

                            final message = messages?[index].data() as Map<String, dynamic>;
                            if(message != null){
                              bool isFromMe = message['sender'] == CommonUtils.getStrUserid();
                              String formatedTimeStamp = "";
                              if(message['createdAt'] != null){
                                DateTime timestamp = (message['createdAt'] as Timestamp).toDate();
                                Duration timeDuration = DateTime.now().difference(timestamp);
                                if(timeDuration.inDays >= 1){
                                  formatedTimeStamp = "${timeDuration.inDays} Days";
                                }
                                else if(timeDuration.inHours >= 1){
                                  formatedTimeStamp = "${timeDuration.inHours} Hours";
                                }
                                else if (timeDuration.inMinutes >= 1){
                                  formatedTimeStamp = "${timeDuration.inMinutes} Mins";
                                }
                                else{
                                  formatedTimeStamp = "Just Now";
                                }
                              }

                              return ChatBubble(
                                  message: message['message'], time: formatedTimeStamp,userImageUrl:  isFromMe ? PreferencesManager.getString(StringMessage.profileimage) : widget.chatUserModel.provileAvatar,
                                  isSent: isFromMe
                              );
                              // return Container(
                              //   padding: EdgeInsets.only(left: 14,right: 14,top: 2,bottom: 2),
                              //   child: Align(
                              //     alignment: (!isFromMe ?Alignment.topLeft:Alignment.topRight),
                              //     child: Container(
                              //       decoration: BoxDecoration(
                              //         borderRadius: BorderRadius.circular(20),
                              //         color: (!isFromMe ?Colors.grey.shade200:Colors.blue[200]),
                              //       ),
                              //       padding: EdgeInsets.only(left: 16, right: 16, top: 3, bottom: 3),
                              //       child: Column(
                              //         children: [
                              //           Text(message['message'], style: TextStyle(fontSize: 15),),
                              //           formatedTimeStamp != "" ? Text(formatedTimeStamp, style: TextStyle(fontSize: 10), textAlign: TextAlign.right,): SizedBox()
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              // );
                            }
                            else{
                              return Container();
                            }


                        },
                    );
                  },
                )),
            Container(
              decoration: BoxDecoration(
                color: MyColors.light_grey_divider_color,
                boxShadow: [
                  BoxShadow(color: Colors.grey, spreadRadius: 1),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      focusNode: _focus,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Doomsday',
                      ),
                      onChanged: (value) {

                        setState(() {
                          messageText = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                        hintText: 'Type your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async{
                      if(messageText != ""){
                        final messageData = {
                          'message': messageText,
                          'sender': CommonUtils.getStrUserid(),
                          'createdAt': FieldValue.serverTimestamp(),
                        };
                        messageText = "";
                        messageTextController.text = "";
                        await FirebaseFirestore.instance
                            .collection('chats')
                            .doc(widget.chatId)
                            .collection('messages').add(messageData);
                      }
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.lightBlueAccent,
                      size: 22,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}