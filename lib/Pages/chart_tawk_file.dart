import 'package:flutter/material.dart';

import 'package:flutter_tawk/flutter_tawk.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';

import '../CommonUtils/common_utils.dart';
import '../CommonUtils/preferences_manager.dart';
import '../CommonUtils/string_files.dart';


class ChatTawk extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChatTawkState();
  }

}

class ChatTawkState extends State<ChatTawk>{
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text('Chat with us'),
            backgroundColor: MyColors.base_green_color,
            elevation: 0,
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Tawk(
                  directChatLink: 'https://tawk.to/chat/6377394fdaff0e1306d80ecc/1gi4rfoks',
                  visitor: TawkVisitor(
                    name: '${PreferencesManager.getString(StringMessage.firstname)} ${PreferencesManager.getString(StringMessage.lastname)}',
                    email: PreferencesManager.getString(StringMessage.email),
                  ),
                  onLoad: () {
                    print('Load Tawk');
                    setState((){
                      isLoading = true;
                    });
                  },
                  onLinkTap: (String url) {
                    print(url);
                  },
                  placeholder:  Center(
                    child: Container(color: MyColors.base_green_color_20,child: CommonUtils.progressDialogBox(),),
                  ),
                ),
              ),

            ],
          )
      ),
    );
  }
}