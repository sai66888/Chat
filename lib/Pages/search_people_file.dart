import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upaychat/Apis/usersearchapi.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/custom_images.dart';
import 'package:upaychat/CustomWidgets/custom_ui_widgets.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Models/usersearchmodel.dart';
import 'package:upaychat/Pages/bank_transaction_send_file_dart.dart';
import 'package:upaychat/globals.dart';

import 'request_money_file.dart';
import 'send_money_file.dart';

class SearchPeopleFile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchPeopleFileState();
  }
}

class SearchPeopleFileState extends State<SearchPeopleFile> {
  bool dataLoaded = false;
  List<UserList> extraList = [];
  List<UserList> allTopList = [];
  List<UserList> topList = [];
  UserList? unregisteredUser;
  String oldQuery = '';
  UserList? extraUser;
  String? mode;
  final TextEditingController userController = new TextEditingController();

  @override
  void initState() {
    _callAllUsersBeneficiary();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mode = ModalRoute.of(context)!.settings.arguments.toString();

    return Scaffold(
      body: Container(
        color: MyColors.base_green_color_20,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(child: _body(context)),
      ),
    );
  }

  Widget _renderLineAngle(double width) {
    return Container(
      height: 11,
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.only(top: 4),
              height: 1,
              color: Colors.grey,
            ),
          ),
          Positioned(
            left: (width - 14) / 2,
            bottom: -7,
            child: Transform.rotate(
              angle: 45 / 180 * pi,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _renderComments() {
    final double DEVICE_WIDTH = MediaQuery.of(context).size.width;
    final double _WIDTH = DEVICE_WIDTH * 2 / 3;
    return Container(
      padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
      margin: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: Color(0xffe8fce8),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 2,
            blurRadius: 2,
            offset: Offset.fromDirection(1, 3),
          ),
        ],
      ),
      width: _WIDTH,
      child: Container(
        child: Column(
          children: [
            _renderLineAngle(_WIDTH),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: const Text(
                "Type in phone#, username or email.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Doomsday',
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _body(BuildContext context) {
    return Container(
      color: const Color(0xffe8fce8),
      child: Column(
        children: [
          CustomUiWidgets.searchPeopleHeader(context, mode ?? ''),
          Container(
            color: const Color(0xffe8fce8),
            margin: const EdgeInsets.fromLTRB(18, 10, 18, 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${mode == 'request' ? "Request from" : "Send money to"} someone new",
                    style: const TextStyle(
                      fontFamily: 'Doomsday',
                      color: MyColors.base_green_color,
                      fontSize: 17,
                      // fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              onChanged: (value) {
                                filterSearchResults(value);
                              },
                              controller: userController,
                              style: const TextStyle(
                                fontFamily: 'Doomsday',
                                fontSize: 18,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp("[ ]"))
                              ],
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 7, bottom: 7),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  // BorderSide(color: MyColors.base_green_color),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                hintStyle: const TextStyle(color: Colors.grey),
                                hintText: '@username, phone or email',
                              ),
                            ),
                          ),
                        ],
                      )),
                      InkWell(
                        onTap: pickFromContacts,
                        splashColor: MyColors.base_green_color_20,
                        child: Container(
                          width: 45,
                          height: 50,
                          margin: const EdgeInsets.only(left: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            MaterialCommunityIcons.account,
                            color: MyColors.base_green_color,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _renderComments(),
                      ),
                      const SizedBox(
                        width: 70,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  if (unregisteredUser != null)
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(top: 10),
                      color: MyColors.base_green_color,
                      shadowColor: MyColors.light_grey_color,
                      child: InkWell(
                        splashColor: Colors.white.withAlpha(150),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => mode == 'request'
                                      ? RequestMoneyFile(
                                          userId: -1,
                                          username: unregisteredUser!.email ??
                                              unregisteredUser!.mobile,
                                        )
                                      : SendMoneyFile(
                                          userId: -1,
                                          username: unregisteredUser!.email ??
                                              unregisteredUser!.mobile ??
                                              '',
                                        )));
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(15, 18, 13, 18),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  (mode == 'request'
                                          ? "Request from "
                                          : "Send to ") +
                                      (unregisteredUser!.email ??
                                          unregisteredUser!.mobile ??
                                          ''),
                                  style: const TextStyle(
                                    fontFamily: 'Doomsday',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (extraUser != null)
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(top: 10),
                      color: MyColors.base_green_color,
                      shadowColor: MyColors.light_grey_color,
                      child: InkWell(
                        splashColor: Colors.white.withAlpha(150),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => mode == 'request'
                                      ? RequestMoneyFile(
                                          userId: extraUser!.user_id,
                                          username: extraUser!.username,
                                        )
                                      : SendMoneyFile(
                                          userId: extraUser!.user_id!,
                                          username: extraUser!.username ?? '',
                                        )));
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(5, 8, 3, 8),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(5),
                                height: 40.0,
                                width: 40.0,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(80.0)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(80.0),
                                  child: Image.asset(
                                    CustomImages.default_profile_pic,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  (mode == 'request'
                                          ? "Request from "
                                          : "Send to ") +
                                      (extraUser!.username ?? ''),
                                  style: const TextStyle(
                                    fontFamily: 'Doomsday',
                                    color: MyColors.grey_color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 40),
                  Container(
                      child: dataLoaded
                          ? ListView.builder(
                              itemCount: topList.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Container(
                                      // elevation: 4,
                                      child: InkWell(
                                        splashColor: MyColors.base_green_color
                                            .withAlpha(200),
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => mode ==
                                                          'request'
                                                      ? RequestMoneyFile(
                                                          userId: topList[index]
                                                              .user_id,
                                                          username:
                                                              '${topList[index].firstname ?? ''} ${topList[index].lastname ?? ''}',
                                                        )
                                                      : SendMoneyFile(
                                                          userId: topList[index]
                                                              .user_id!,
                                                          username:
                                                              '${topList[index].firstname ?? ''} ${topList[index].lastname ?? ''}',
                                                        )));
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          // padding: EdgeInsets.all(5),
                                          child: Row(
                                            children: [
                                              Container(
                                                //
                                                height: 40.0,
                                                width: 40.0,
                                                child: ClipRRect(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(60.0),
                                                    child: CachedNetworkImage(
                                                      imageUrl: topList[index]
                                                              .profile_image ??
                                                          '',
                                                      placeholder:
                                                          (context, url) =>
                                                              CircleAvatar(
                                                        child: Text(
                                                          '${topList[index].firstname!.substring(0, 1) ?? ''}${topList[index].lastname!.substring(0, 1) ?? ''}',
                                                          style: TextStyle(
                                                              fontSize: 25),
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Image.asset(
                                                        CustomImages
                                                            .default_profile_pic,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )),
                                              ),
                                              Expanded(
                                                  // flex: 6,
                                                  child: Container(
                                                margin: EdgeInsets.all(10),
                                                child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        topList[index]
                                                                .username ??
                                                            "",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Doomsday',
                                                          color: Colors.black,
                                                          // fontWeight:
                                                          // FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        (topList[index]
                                                                    .firstname ??
                                                                '') +
                                                            " " +
                                                            (topList[index]
                                                                    .lastname ??
                                                                ''),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Doomsday',
                                                          color: MyColors
                                                              .grey_color,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    )
                                  ],
                                );
                              })
                          : CommonUtils.progressDialogBox())
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _callAllUsersBeneficiary() async {
    if (Globals.isOnline) {
      try {
        UserSearchApi _searchApi = new UserSearchApi();
        UserSearchModel result = await _searchApi.search();
        if (result.status == "true") {
          for (int i = 0; i < result.userList.length; i++)
            if (result.userList[i].is_extra ?? false)
              extraList.add(result.userList[i]);
            else
              allTopList.add(result.userList[i]);
          topList.addAll(allTopList);
          if (mounted) {
            setState(() {
              dataLoaded = true;
            });
          }
        } else if (mounted) {
          Navigator.pop(context);
          CommonUtils.errorToast(context, result.message);
        }
      } catch (e) {
        print(e);
        if (mounted)
          CommonUtils.errorToast(context, StringMessage.network_server_error);
      }
    } else {
      CommonUtils.errorToast(context, StringMessage.network_Error);
    }
  }

  void pickFromContacts() async {
    final PermissionStatus permissionStatus = await getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Navigator.of(context).pushNamed('/pickcontact', arguments: {
        'onContactPicked': (mobile) {
          userController.text = mobile;
          filterSearchResults(mobile);
        }
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void filterSearchResults(String query) async {
    if (oldQuery == query) {
    } else {
      setState(() {
        unregisteredUser = null;
        topList = [];
        extraUser = null;
        oldQuery = query;
      });
      if (query.length >= 4) {
        setState(() {
          dataLoaded = false;
        });
        if (query.startsWith("0")) query = query.replaceFirst("0", "+234");

        if (Globals.isOnline) {
          try {
            UserSearchApi _searchApi = UserSearchApi();
            UserSearchModel result = await _searchApi.search(query: query);
            if (result.status == "true") {
              // for (int i = 0; i < result.userList.length; i++) {
              //   bool isInserted = false;
              //   for(int j = 0 ; j <topList.length ; j ++){
              //     if(topList[j].user_id != result.userList[i].user_id){
              //       isInserted = true;
              //       break;
              //     }
              //   }
              //   if(!isInserted){
              //     topList.add(result.userList[i]);
              //   }
              //
              // }
              topList = result.userList;

              if (topList.isEmpty) {
                if (CommonUtils.validateEmail(query)) {
                  unregisteredUser = UserList(null, null, null, null,
                      userController.text, null, null, false);
                } else if (CommonUtils.validateMobile(query)) {
                  unregisteredUser = UserList(null, null, null, null, null,
                      userController.text, null, false);
                }
              }

              if (mounted) {
                setState(() {
                  dataLoaded = true;
                });
              }
            } else if (mounted) {
              Navigator.pop(context);
              CommonUtils.errorToast(context, result.message);
            }
          } catch (e) {
            if (mounted)
              CommonUtils.errorToast(
                  context, StringMessage.network_server_error);
            setState(() {
              dataLoaded = true;
            });
          }
        } else {
          CommonUtils.errorToast(context, StringMessage.network_Error);
          setState(() {
            dataLoaded = true;
          });
        }
        setState(() {
          dataLoaded = true;
        });
      } else if (query.isEmpty) {
        topList.addAll(allTopList);
      } else {}
    }
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
}
