// ignore_for_file: prefer_const_constructors
//// import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:eventhandler/eventhandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:upaychat/Apis/addupdatecarddetail.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';
import 'package:upaychat/CommonUtils/string_files.dart';
import 'package:upaychat/CustomWidgets/card_type.dart';
import 'package:upaychat/CustomWidgets/my_colors.dart';
import 'package:upaychat/Models/carddetaildata.dart';
import 'package:upaychat/Models/commonmodel.dart';
// import 'package:flutter_credit_card/credit_card_form.dart';
// import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:http/http.dart' as http;
import 'package:upaychat/globals.dart';
import 'package:upaychat/CommonUtils/imagepicker.dart';
import '../Apis/checkcardholderapi.dart';
import '../Apis/createvirtualcardapi.dart';
import '../Apis/getexchangerateapi.dart';
import '../Apis/getstateslistapi.dart';
import '../Apis/idverificationinfo.dart';
import '../Apis/network_utils.dart';

import '../Apis/savebillingaddressapi.dart';
import '../CommonUtils/preferences_manager.dart';
import '../CustomWidgets/custom_ui_widgets.dart';
import '../Events/balanceevent.dart';
import '../Models/idverificationmodel.dart';

class AddNewVitualCardFile extends StatefulWidget {
  const AddNewVitualCardFile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddNewVitualCardFileState();
  }
}

class CardType {
  final String cardType;
  final String cardName;
  final String cardSubTitle;
  final List<Fee> fees;

  CardType(
      {required this.cardType,
      required this.cardName,
      required this.cardSubTitle,
      required this.fees});
}

class Fee {
  final IconData icon;
  final String title;
  final String description;
  final String type;

  Fee(
      {required this.icon,
      required this.title,
      required this.description,
      required this.type});
}

class AddNewVitualCardFileState extends State<AddNewVitualCardFile>
    with TickerProviderStateMixin, ImagePickerListener {
  bool idVerificated = false;
  bool isLoading = true;
  String cardNickName = '';
  TextEditingController amountController = TextEditingController();
  TextEditingController amountNGNController = TextEditingController();
  double amount = 0.00;
  double totalAmount = 0.00;
  double exchangeRate = 1;
  bool confirmedAmount = false;
  int currentPage = 0; // 0 : welcome, 1 : nickname , 2 : inputAmount, 3: final
  int selectedCardIndex = 0;
  int selectedModalIndex = 0;
  String googleApikey = "AIzaSyCT68yhS_gvlHzW9VdqIg4mKsPNPVITgz4";

  TextEditingController firstNameController = TextEditingController(),
      addressController = TextEditingController(),
      lastNameController = TextEditingController(),
      userNameController = TextEditingController(),
      bvnController = TextEditingController();
  File? _image;
  ImagePickerHandler? imagePicker;
  AnimationController? _controller;
  DateTime? birthday;
  XFile? _pickedFile;
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  late SingleValueDropDownController _stateController;
  final zipcodeController = TextEditingController();
  final houseNoController = TextEditingController();
  bool inValidStreet = false;
  bool inValidCity = false;
  bool inValidState = false;
  bool inValidZipCode = false;
  bool inValidCountry = false;
  bool inValidHouseCode = false;
  String? selectedCountry;

  List<dynamic> statesList = [];

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  PersistentBottomSheetController? _persistentBottomSheetController;
  List<CardType> cardTypes = [
    CardType(
      cardType: "visa",
      cardName: "Premium Dollar Card",
      cardSubTitle: "Shopping, Ads, Subscriptions & Digital Services",
      fees: [
        Fee(
            icon: Icons.credit_card,
            title: "Card creation fee",
            description: "\$3.00",
            type: "badge"),
        Fee(
            icon: Icons.monetization_on,
            title: "Transaction fees",
            type: "text",
            description: "Top-up below \$100 = \$1.5\nTop-up above \$100 = 1.5%"),
        Fee(
            icon: Icons.monetization_on,
            type: "text",
            title: "Card Maintenance fee",
            description: "\$1/month per active card"),
      ],
    ),
    // CardType(
    //   cardType: "mastercard",
    //   cardName: "Universal DollarCard",
    //   cardSubTitle: "Shopping & Digital Services",
    //   fees: [
    //     Fee(icon: Icons.credit_card, title: "Card creation fee", description: "\$5.00", type: "badge"),
    //     Fee(
    //         icon: Icons.monetization_on,
    //         title: "Top up fee",
    //         type: "text",
    //         description: "\$1 if funding is below \$100 and 1% if funding is equal to or above \$100"),
    //     Fee(icon: Icons.monetization_on, type: "text", title: "Card Declined", description: "\$1 termination fee after 3 insufficient funds transactions"),
    //   ],
    // )
  ];

  @override
  void initState() {
    _callExchangeRateApi();
    _stateController = SingleValueDropDownController();
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    imagePicker = new ImagePickerHandler(this, _controller);
    imagePicker!.init();
  }

  void _callExchangeRateApi() async {
    ExchangeRateApi exchangeRateApi = new ExchangeRateApi();
    int todayRate = await exchangeRateApi.search();
    exchangeRate = todayRate.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    return Scaffold(
        key: _key,
        appBar: AppBar(
          backgroundColor: MyColors.base_green_color,
          centerTitle: true,
          title: Text(
            'Add a New Card',
            style: TextStyle(
              fontFamily: 'Doomsday',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              if (currentPage == 0)
                Navigator.of(context).pop();
              else {
                setState(() {
                  currentPage -= 1;
                });
              }
            },
          ),
        ),
        body: currentPage == 0
            ? _buildWelcome()
            : currentPage == 1
                ? _buildAddMoneyForm()
                : _buildCheckoutForm());
  }

  @override
  userImage(File _image) {
    setState(() {
      if (_image != null) {
        this._image = _image;
      }
    });
  }

  Widget _buildWelcome() {
    return Container(
      padding: EdgeInsets.all(5),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            CarouselSlider(
              options: CarouselOptions(
                  enableInfiniteScroll: false,
                  onPageChanged: (int index, CarouselPageChangedReason reason) {
                    print("Active Card Type: ${index}");
                    setState(() {
                      selectedCardIndex = index;
                    });
                  }),
              items: cardTypes.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: CardTypeWidget(cardType: i.cardType));
                  },
                );
              }).toList(),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Text(
                cardTypes[selectedCardIndex].cardName,
                style: TextStyle(
                    fontFamily: 'Doomsday',
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: Text(
                cardTypes[selectedCardIndex].cardSubTitle,
                style: TextStyle(
                    fontFamily: 'Doomsday',
                    fontSize: 14,
                    color: MyColors.grey_color),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: cardTypes[selectedCardIndex].fees.length ?? 0,
              separatorBuilder: (BuildContext context, int index) => Divider(
                height: 3,
                color: Colors.transparent,
              ),
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: MyColors.light_grey_color,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          cardTypes[selectedCardIndex].fees[index].icon,
                          color: MyColors.grey_color,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      cardTypes[selectedCardIndex]
                                          .fees[index]
                                          .title,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: 'Doomsday',
                                        fontSize: 18,
                                        color: MyColors.grey_color,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: cardTypes[selectedCardIndex]
                                                .fees[index]
                                                .type ==
                                            "badge"
                                        ? Container(
                                            child: Text(
                                              cardTypes[selectedCardIndex]
                                                  .fees[index]
                                                  .description,
                                            ),
                                            decoration: BoxDecoration(
                                              color: MyColors.base_green_color,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            padding: EdgeInsets.all(5),
                                          )
                                        : Container(
                                            child: Text(
                                              cardTypes[selectedCardIndex]
                                                  .fees[index]
                                                  .description,
                                              style: TextStyle(
                                                fontFamily: 'Doomsday',
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 30, left: 10, right: 10),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(60, 15, 60, 15),
                  primary: MyColors.base_green_color,
                  shape: CustomUiWidgets.basicGreenButtonShape(),
                ),
                onPressed: () async {
                  context.loaderOverlay.show();
                  try {
                    CheckCardHolderApi checkCardHolderApi =
                        CheckCardHolderApi();
                    CommonModel result = await checkCardHolderApi.check();
                    context.loaderOverlay.hide();
                    print(result.status);
                    if (result.status == "true") {
                      setState(() {
                        currentPage = 1;
                      });
                    } else {
                      if (statesList.isEmpty) {
                        context.loaderOverlay.show();
                        StatesListAPI statesListApi = StatesListAPI();
                        CommonModel stateResponse =
                            await statesListApi.search();
                        setState(() {
                          statesList = stateResponse.data['states'];
                        });
                        print(statesList);
                        context.loaderOverlay.hide();
                      }
                      showCreateCardHolderModal();
                    }
                  } catch (e) {
                    context.loaderOverlay.hide();
                    print(e.toString());
                  }
                },
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Doomsday',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
    ;
  }

  void showCreateCardHolderModal() {
    firstNameController.text =
        PreferencesManager.getString(StringMessage.firstname);
    lastNameController.text =
        PreferencesManager.getString(StringMessage.lastname);

    streetController.text = PreferencesManager.getString(StringMessage.street);
    houseNoController.text =
        PreferencesManager.getString(StringMessage.house_no) ?? '';
    cityController.text =
        PreferencesManager.getString(StringMessage.city) ?? '';
    zipcodeController.text =
        PreferencesManager.getString(StringMessage.zipcode) ?? '';

    showDialog<void>(
        context: context,
        // isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter mystate) {
            return Dialog(
              insetPadding: EdgeInsets.zero,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  backgroundColor: MyColors.base_green_color,
                  centerTitle: true,
                  leading: new IconButton(
                    icon: new Icon(Icons.arrow_back),
                    onPressed: () {
                      if (selectedModalIndex == 0)
                        Navigator.of(context).pop();
                      else
                        mystate(() {
                          selectedModalIndex = 0;
                        });
                    },
                  ),
                  title: Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: 'Doomsday',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                body: Container(
                    color: MyColors.base_green_color_20,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: selectedModalIndex == 0
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 130,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        child: InkWell(
                                          onTap: () {
                                            imagePicker!.showDialog(context);
                                          },
                                          child: _image == null
                                              ? Container(
                                                  margin:
                                                      EdgeInsets.only(top: 15),
                                                  height: 120.0,
                                                  width: 120.0,
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          new BorderRadius
                                                              .circular(60.0),
                                                      child: CachedNetworkImage(
                                                        imageUrl: PreferencesManager
                                                            .getString(
                                                                StringMessage
                                                                    .profileimage),
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                CircleAvatar(
                                                          child: Text(
                                                            (PreferencesManager.getString(
                                                                            StringMessage.firstname)[
                                                                        0] +
                                                                    PreferencesManager.getString(
                                                                        StringMessage
                                                                            .lastname)[0])
                                                                .substring(0, 2)
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                                fontSize: 27),
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            CircleAvatar(
                                                          child: Text(
                                                            (PreferencesManager.getString(
                                                                            StringMessage.firstname)[
                                                                        0] +
                                                                    PreferencesManager.getString(
                                                                        StringMessage
                                                                            .lastname)[0])
                                                                .substring(0, 2)
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                                fontSize: 27),
                                                          ),
                                                        ),
                                                      )),
                                                )
                                              : Container(
                                                  margin:
                                                      EdgeInsets.only(top: 15),
                                                  height: 120.0,
                                                  width: 120.0,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(60.0),
                                                    child: Image.file(
                                                      _image!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 25,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () {
                                            imagePicker!.showDialog(context);
                                          },
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: MyColors.base_green_color,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Icon(
                                              Entypo.camera,
                                              color: Colors.white,
                                              size: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    imagePicker!.showDialog(context);
                                  },
                                  child: Text(
                                    "Tap to upload profile picture.",
                                    style: TextStyle(
                                      fontFamily: 'Doomsday',
                                      color: MyColors.base_green_color,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'First Name',
                                                style: TextStyle(
                                                  color: MyColors.grey_color,
                                                  fontFamily: 'Doomsday',
                                                  fontSize: 20,
                                                ),
                                                textAlign: TextAlign.left,
                                              )
                                            ],
                                          ),
                                          TextFormField(
                                            controller: firstNameController,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[a-zA-Z]"))
                                            ],
                                            cursorColor:
                                                MyColors.base_green_color,
                                            style: TextStyle(
                                              fontFamily: 'Doomsday',
                                              color: MyColors.grey_color,
                                              fontSize: 20,
                                            ),
                                            decoration: InputDecoration(
                                              labelStyle: TextStyle(
                                                color: MyColors.grey_color,
                                                fontSize: 18,
                                                fontFamily: 'Doomsday',
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(5)),
                                              ),
                                              contentPadding: EdgeInsets.all(5),
                                              focusedBorder: UnderlineInputBorder(
                                                  // borderSide: BorderSide(color: MyColors.grey_color),
                                                  ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Last Name',
                                                style: TextStyle(
                                                  color: MyColors.grey_color,
                                                  fontFamily: 'Doomsday',
                                                  fontSize: 20,
                                                ),
                                                textAlign: TextAlign.left,
                                              )
                                            ],
                                          ),
                                          TextFormField(
                                            controller: lastNameController,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[a-zA-Z]"))
                                            ],
                                            cursorColor:
                                                MyColors.base_green_color,
                                            style: TextStyle(
                                              color: MyColors.grey_color,
                                              fontFamily: 'Doomsday',
                                              fontSize: 20,
                                            ),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(5)),
                                              ),
                                              labelStyle: TextStyle(
                                                color: MyColors.grey_color,
                                                fontSize: 18,
                                                fontFamily: 'Doomsday',
                                              ),
                                              contentPadding: EdgeInsets.all(5),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: MyColors.grey_color),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      'Enter BVN',
                                      style: TextStyle(
                                        color: MyColors.grey_color,
                                        fontFamily: 'Doomsday',
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: bvnController,
                                  cursorColor: MyColors.base_green_color,
                                  style: TextStyle(
                                    color: MyColors.grey_color,
                                    fontFamily: 'Doomsday',
                                    fontSize: 20,
                                  ),
                                  maxLength: 11,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [bvnValidator!],
                                  decoration: InputDecoration(
                                    counter: null,
                                    counterText: "",
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                    ),
                                    labelStyle: TextStyle(
                                      color: MyColors.grey_color,
                                      fontSize: 18,
                                      fontFamily: 'Doomsday',
                                    ),
                                    contentPadding: EdgeInsets.all(5),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: MyColors.grey_color),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  margin: EdgeInsets.only(top: 30),
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding:
                                          EdgeInsets.fromLTRB(60, 15, 60, 15),
                                      primary: MyColors.base_green_color,
                                      shape: CustomUiWidgets
                                          .basicGreenButtonShape(),
                                    ),
                                    onPressed: () async {
                                      String avatarUrl =
                                          PreferencesManager.getString(
                                              StringMessage.profileimage);
                                      if (avatarUrl.isEmpty && _image == null) {
                                        CommonUtils.errorToast(context,
                                            'Please take your selfie.');
                                        return;
                                      }
                                      if (bvnController.text.length !=
                                          11) {
                                        CommonUtils.errorToast(context,
                                            'Incorrect BVN format.');
                                        return;
                                      }
                                      mystate(() {
                                        selectedModalIndex = 1;
                                      });
                                    },
                                    child: Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontFamily: 'Doomsday',
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Column(
                              children: [
                                TextField(
                                  controller: streetController,
                                  style: TextStyle(
                                    fontFamily: 'Doomsday',
                                    fontSize: 20,
                                  ),
                                  cursorColor: MyColors.base_green_color,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: MyColors.base_green_color,
                                          width: 2.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    hintText: 'Street address',
                                    labelText: 'Street address',
                                    labelStyle: TextStyle(
                                        color: inValidStreet
                                            ? Colors.red
                                            : MyColors.grey_color),
                                    errorText: inValidStreet
                                        ? 'Please enter a valid address.'
                                        : null,
                                  ),
                                ),
                                SizedBox(height: 15),
                                TextField(
                                  controller: houseNoController,
                                  style: TextStyle(
                                    fontFamily: 'Doomsday',
                                    fontSize: 20,
                                  ),
                                  keyboardType: TextInputType.number,
                                  cursorColor: MyColors.base_green_color,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: MyColors.base_green_color,
                                          width: 2.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    hintText: 'House No',
                                    labelText: 'House No',
                                    labelStyle: TextStyle(
                                        color: inValidHouseCode
                                            ? Colors.red
                                            : MyColors.grey_color),
                                    errorText: inValidHouseCode
                                        ? 'Please enter a valid Zip code'
                                        : null,
                                  ),
                                ),
                                SizedBox(height: 15),
                                TextField(
                                  controller: cityController,
                                  style: TextStyle(
                                    fontFamily: 'Doomsday',
                                    fontSize: 20,
                                  ),
                                  cursorColor: MyColors.base_green_color,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: MyColors.base_green_color,
                                          width: 2.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    hintText: 'City',
                                    labelText: 'City',
                                    labelStyle: TextStyle(
                                        color: inValidCity
                                            ? Colors.red
                                            : MyColors.grey_color),
                                    errorText: inValidCity
                                        ? 'Please enter a valid city.'
                                        : null,
                                  ),
                                ),
                                SizedBox(height: 15),
                                DropDownTextField(
                                  // initialValue: "name4",
                                  controller: _stateController,
                                  clearOption: true,
                                  // enableSearch: true,
                                  // dropdownColor: Colors.green,
                                  searchDecoration:
                                      const InputDecoration(hintText: "State"),
                                  validator: (value) {
                                    if (value == null) {
                                      return "Required field";
                                    } else {
                                      return null;
                                    }
                                  },
                                  textStyle: TextStyle(
                                    fontFamily: 'Doomsday',
                                    fontSize: 20,
                                  ),
                                  textFieldDecoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: MyColors.base_green_color,
                                          width: 2.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    hintText: 'State',
                                    labelText: 'State',
                                    labelStyle: TextStyle(
                                        color: inValidState
                                            ? Colors.red
                                            : MyColors.grey_color),
                                    errorText: inValidState
                                        ? 'Please enter a valid state.'
                                        : null,
                                  ),
                                  dropDownItemCount: 6,

                                  dropDownList: statesList
                                      .map((e) =>
                                          DropDownValueModel(name: e, value: e))
                                      .toList(),
                                  onChanged: (val) {},
                                ),
                                SizedBox(height: 15),
                                TextField(
                                  controller: zipcodeController,
                                  style: TextStyle(
                                    fontFamily: 'Doomsday',
                                    fontSize: 20,
                                  ),
                                  keyboardType: TextInputType.number,
                                  cursorColor: MyColors.base_green_color,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: MyColors.base_green_color,
                                          width: 2.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    hintText: 'Zip code',
                                    labelText: 'Zip code',
                                    labelStyle: TextStyle(
                                        color: inValidZipCode
                                            ? Colors.red
                                            : MyColors.grey_color),
                                    errorText: inValidZipCode
                                        ? 'Please enter a valid Zip code'
                                        : null,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      margin: EdgeInsets.only(top: 30),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.fromLTRB(
                                              15, 15, 15, 15),
                                          primary: MyColors.base_green_color,
                                          shape: CustomUiWidgets
                                              .basicGreenButtonShape(),
                                        ),
                                        onPressed: () async {
                                          String avatarUrl =
                                              PreferencesManager.getString(
                                                  StringMessage.profileimage);
                                          if (avatarUrl.isEmpty &&
                                              _image == null) {
                                            CommonUtils.errorToast(context,
                                                'Please take your selfie.');
                                            return;
                                          }
                                          if (firstNameController
                                                  .text.isNotEmpty &&
                                              lastNameController
                                                  .text.isNotEmpty &&
                                              bvnController.text.isNotEmpty &&
                                              bvnController.text.length == 11) {
                                            if (_stateController
                                                    .dropDownValue?.value ==
                                                null) {
                                              CommonUtils.errorToast(context,
                                                  'Missing State from your addrees.');
                                              return;
                                            }
                                            if (houseNoController
                                                .text.isEmpty) {
                                              CommonUtils.errorToast(context,
                                                  'Missing House No from your addrees.');
                                              return;
                                            }
                                            if (streetController.text.isEmpty) {
                                              CommonUtils.errorToast(context,
                                                  'Missing Street from your addrees.');
                                              return;
                                            }
                                            if (cityController.text.isEmpty) {
                                              CommonUtils.errorToast(context,
                                                  'Missing City from your addrees.');
                                              return;
                                            }
                                            if (zipcodeController
                                                .text.isEmpty) {
                                              CommonUtils.errorToast(context,
                                                  'Missing Post Code from your addrees.');
                                              return;
                                            }

                                            context.loaderOverlay.show();
                                            try {
                                              String token =
                                                  PreferencesManager.getString(
                                                      StringMessage.token);
                                              Map<String, String> headers = {
                                                'Accept': 'application/json',
                                                'Authorization': 'Bearer $token'
                                              };
                                              var uri = Uri.parse(NetworkUtils
                                                      .api_url +
                                                  "v2/createvirtualcardholder");
                                              var request =
                                                  new http.MultipartRequest(
                                                      "POST", uri);
                                              // multipart that takes file
                                              var multipartFileSign;
                                              if (_image != null) {
                                                var stream = http.ByteStream(
                                                    Stream.castFrom(
                                                        _image!.openRead()));
                                                var length =
                                                    await _image!.length();
                                                multipartFileSign =
                                                    http.MultipartFile(
                                                        'selfi_image',
                                                        stream,
                                                        length,
                                                        filename: _image!.path);
                                                request.files
                                                    .add(multipartFileSign);
                                              }
                                              request.headers.addAll(headers);
                                              request.fields['first_name'] =
                                                  firstNameController.text;
                                              request.fields['last_name'] =
                                                  lastNameController.text;
                                              request.fields['address'] =
                                                  streetController.text;
                                              request.fields['city'] =
                                                  cityController.text;
                                              request.fields['state'] =
                                                  _stateController
                                                      .dropDownValue?.value;
                                              request.fields['postal_code'] =
                                                  zipcodeController.text;
                                              request.fields['house_no'] =
                                                  houseNoController.text;
                                              request.fields['bvn'] =
                                                  bvnController.text;
                                              // send
                                              var response =
                                                  await request.send();
                                              // listen for response
                                              response.stream
                                                  .transform(utf8.decoder)
                                                  .listen((value) {
                                                try {
                                                  print(value);
                                                  final body =
                                                      json.decode(value);

                                                  String status =
                                                      body['status'].toString();
                                                  String msg = body['message'];
                                                  dynamic userData =
                                                      body['user_data'];
                                                  context.loaderOverlay.hide();
                                                  if (status == "success") {
                                                    Navigator.pop(context);

                                                    PreferencesManager
                                                        .setString(
                                                            StringMessage
                                                                .street,
                                                            userData[
                                                                    'street'] ??
                                                                '');
                                                    PreferencesManager.setString(
                                                        StringMessage.house_no,
                                                        userData['house_no'] ??
                                                            '');
                                                    PreferencesManager
                                                        .setString(
                                                            StringMessage.city,
                                                            userData['city'] ??
                                                                '');
                                                    PreferencesManager
                                                        .setString(
                                                            StringMessage.state,
                                                            userData['state'] ??
                                                                '');
                                                    PreferencesManager.setString(
                                                        StringMessage.zipcode,
                                                        userData['zipcode'] ??
                                                            '');
                                                    PreferencesManager
                                                        .setString(
                                                            StringMessage.bvn,
                                                            userData['bvn'] ??
                                                                '');
                                                    PreferencesManager
                                                        .setString(
                                                            StringMessage
                                                                .profileimage,
                                                            userData[
                                                                    'avatar'] ??
                                                                '');
                                                    PreferencesManager
                                                        .setString(
                                                        StringMessage
                                                            .firstname,
                                                        userData[
                                                        'firstname'] ??
                                                            '');
                                                    PreferencesManager
                                                        .setString(
                                                        StringMessage
                                                            .lastname,
                                                        userData[
                                                        'lastname'] ??
                                                            '');
                                                    setState(() {
                                                      currentPage = 1;
                                                    });
                                                  } else {
                                                    CommonUtils.errorToast(
                                                        context, msg);
                                                  }
                                                } catch (e) {
                                                  context.loaderOverlay.hide();
                                                  print(e);
                                                }
                                              });
                                            } catch (e) {
                                              CommonUtils.errorToast(
                                                  context, e.toString());
                                              context.loaderOverlay.hide();
                                            }
                                          } else {
                                            if (bvnController.text.length !=
                                                11) {
                                              CommonUtils.errorToast(context,
                                                  'Incorrect BVN format.');
                                            } else {
                                              CommonUtils.errorToast(context,
                                                  'Please fill all fields.');
                                            }
                                          }
                                        },
                                        child: Text(
                                          'Continue',
                                          style: TextStyle(
                                            fontFamily: 'Doomsday',
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ))
                                  ],
                                )
                              ],
                            ),
                    )),
              ),
            );
          });
        });
  }

  Widget _buildAddMoneyForm() {
    return Container(
        height: double.infinity,
        color: MyColors.base_green_color_20,
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
            child: Column(children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            alignment: Alignment.centerLeft,
            child: Text(
              'How much would you like to fund your card with?',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Doomsday',
                color: Colors.black,
                fontSize: 22,
              ),
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 10),
              padding: EdgeInsets.only(left: 5, top: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.green, spreadRadius: 3),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: amountController,
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        fontSize: 26,
                      ),
                      onChanged: (text) {
                        if (text.isNotEmpty) {
                          text = text.replaceAll(RegExp(r'[^0-9.]'), '');
                          String prev = text;
                          text = text.replaceAll(',', '');
                          text = text.replaceAll('.', '');
                          if (text.length >= 10) text = text.substring(0, 9);
                          double value = int.parse(text).toDouble() / 100;
                          if (value > 3000000) {
                            text = text.substring(0, 8);
                            value = int.parse(text).toDouble() / 100;
                          }
                          text = CommonUtils.toCurrency(value);
                          if (prev != text) {
                            amountController.text = text;
                            amountController.selection =
                                TextSelection.collapsed(offset: text.length);
                          }
                          amount = double.parse(
                              amountController.text.replaceAll(',', ''));
                          totalAmount = (amount + 3 + (amount < 100 ? 1.5 : amount * 0.015)) * exchangeRate;
                          amountNGNController.text =
                              CommonUtils.toCurrency(amount * exchangeRate);
                        }
                      },
                      inputFormatters: [amountValidator!],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "0.00",
                          labelText: "You receive",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: TextStyle(
                              fontSize: 18,
                              color: MyColors.grey_color,
                              decorationColor: MyColors.grey_color)),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    margin: EdgeInsets.only(top: 15),
                    decoration: BoxDecoration(
                        border: Border(
                      left: BorderSide(),
                    )),
                    child: Text(
                      'USD',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Doomsday',
                          fontSize: 18),
                    ),
                  )
                ],
              )),
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'Rate:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Text(
                    '1USD = ${exchangeRate} NGN',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Doomsday',
                      color: MyColors.grey_color,
                      fontSize: 18,
                    ),
                  ),
                ],
              )),
          SizedBox(width: 4),
          Container(
              margin: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 10),
              padding: EdgeInsets.only(left: 5, top: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.green, spreadRadius: 3),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      readOnly: true,
                      textAlign: TextAlign.center,
                      controller: amountNGNController,
                      style: TextStyle(
                        fontFamily: 'Doomsday',
                        fontSize: 24,
                      ),
                      inputFormatters: [amountValidator!],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "0.00",
                          labelText: "You pay",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: TextStyle(
                              fontSize: 18,
                              color: MyColors.grey_color,
                              decorationColor: MyColors.grey_color)),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 15),
                    decoration: BoxDecoration(
                        border: Border(
                      left: BorderSide(),
                    )),
                    child: Text(
                      'NGN',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Doomsday',
                          fontSize: 18),
                    ),
                  )
                ],
              )),
          Container(
            margin: EdgeInsets.only(top: 30, left: 10, right: 10),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.fromLTRB(60, 15, 60, 15),
                primary: MyColors.base_green_color,
                shape: CustomUiWidgets.basicGreenButtonShape(),
              ),
              onPressed: () {
                if (amount < 5) {
                  CommonUtils.errorToast(
                      context, "Minimum amount should be \$5.00");
                } else {
                  setState(() {
                    currentPage = 3;
                  });
                }
              },
              child: Text(
                'Continue',
                style: TextStyle(
                  fontFamily: 'Doomsday',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ])));
  }

  Widget _buildCheckoutForm() {
    return Container(
        height: double.infinity,
        color: MyColors.base_green_color_20,
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                margin: EdgeInsets.all(10),
                decoration: new BoxDecoration(
                  color: MyColors.base_green_color,
                  borderRadius: new BorderRadius.all(const Radius.circular(20)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ' Amount',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Doomsday',
                                color: Colors.white,
                                fontSize: 18),
                          ),
                        ),
                        Container(
                          width: 170,
                          child: Text(
                            '\$' + CommonUtils.toCurrency(amount),
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    Container(
                        height: 1,
                        color: MyColors.light_grey_divider_color,
                        margin: EdgeInsets.only(top: 15, bottom: 15)),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ' Creation Fee',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Doomsday',
                                color: Colors.white,
                                fontSize: 18),
                          ),
                        ),
                        Container(
                          width: 170,
                          child: Text(
                            "\$3.00",
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    Container(
                        height: 1,
                        color: MyColors.light_grey_divider_color,
                        margin: EdgeInsets.only(top: 15, bottom: 15)),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ' Top Up Fee',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Doomsday',
                                color: Colors.white,
                                fontSize: 18),
                          ),
                        ),
                        Container(
                          width: 170,
                          child: Text(
                            amount < 100 ? "\$1.5" : "\$${amount*0.015}",
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    Container(
                        height: 1,
                        color: MyColors.light_grey_divider_color,
                        margin: EdgeInsets.only(top: 15, bottom: 15)),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ' Total',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18),
                          ),
                        ),
                        Container(
                          width: 170,
                          child: Text(
                            StringMessage.naira +
                                CommonUtils.toCurrency(totalAmount),
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: () => {addVirtualCard(context, totalAmount, amount)},
                child: Container(
                    width: double.infinity,
                    height: 56,
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          "assets/logo_black.png",
                          height: 23,
                          width: 23,
                        ),
                        Text(
                          "  Pay from Upaychat Balance",
                          style: TextStyle(
                            fontFamily: 'Doomsday',
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ));
    ;
  }

  static RoundedRectangleBorder basicGreenButtonShape() {
    return RoundedRectangleBorder(
      side: BorderSide(color: MyColors.base_green_color),
      borderRadius: BorderRadius.circular(8.0),
    );
  }

  void addVirtualCard(
      BuildContext context, double totalAmount, double amount) async {
    if (totalAmount > Globals.walletbalance) {
      CommonUtils.errorToast(context,
          "You do not have sufficient funds to complete this transaction.");
      // Navigator.of(context).pop();
    } else {
      if (Globals.isOnline) {
        try {
          context.loaderOverlay.show();
          CreateVirtualCardAPI createVirtualCardAPI = CreateVirtualCardAPI();
          CommonModel? result;
          result = await createVirtualCardAPI.save(totalAmount, amount);
          context.loaderOverlay.hide();
          if (result.status == "success") {
            context.loaderOverlay.hide();
            CommonUtils.successToast(context, result.message);
            EventHandler().send(BalanceEvent('cardstatus'));
            EventHandler().send(BalanceEvent('wallet'));
            print(result.data['card_id']);
            int createdCardID = int.parse(result.data['card_id'].toString());

            Navigator.of(context).pushReplacementNamed("/virtualcarddetail",
                arguments: {"cardID": createdCardID});
          } else {
            if (result.message == 'missing_card_holder') {
              CommonUtils.errorToast(context, result.message);
              Navigator.pop(context);
            } else {
              CommonUtils.errorToast(context, result.message);
            }
          }
        } catch (e) {
          print(e);
          context.loaderOverlay.hide();
          CommonUtils.errorToast(context, StringMessage.network_server_error);
        }
      } else {
        CommonUtils.errorToast(context, StringMessage.network_Error);
      }
    }
  }
}
