import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/class/login.dart';
import 'package:test/class/phonenocheck.dart';
import 'package:test/screens/main_screen.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:location/location.dart';
import 'package:test/screens/otp.dart';

class Register extends StatefulWidget {
  static String routeName = "/register";
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController mobileController = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController _btn2Controller =
      RoundedLoadingButtonController();
  late Timer timer;
  String configs = '';
  bool verify = false;
  String deviceId = "";
  String deviceInfo = "";
  String osVersion = "";
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  LocationData? _currentPosition;
  Location location = Location();
  TextEditingController configsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setSharedPrefs();
    getDeviceInfo();
    /*WidgetsBinding.instance
        ?.addPostFrameCallback((_) => checkPasscode(context));*/
  }

  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }

  Future<void> setSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkConfigsPrefs = prefs.containsKey('configs');
    bool checkVerify = prefs.containsKey('verify');
    bool checkMobile = prefs.containsKey('mobile');
    bool checkMobileTemp = prefs.containsKey('mobileTemp');
    bool checkAccessToken = prefs.containsKey('accessToken');
    bool checkUsername = prefs.containsKey('username');

    if (!checkConfigsPrefs) {
      prefs.setString('configs', 'itransapi.harmonious.co.th');
    }
    if (!checkVerify) {
      prefs.setBool('verify', false);
    }
    if (!checkMobile) {
      prefs.setString('mobile', '');
    }
    if (!checkMobileTemp) {
      prefs.setString('mobileTemp', '');
    }
    if (!checkAccessToken) {
      prefs.setString('accessToken', '');
    }
    if (!checkUsername) {
      prefs.setString('username', '');
    }
    setState(() {
      verify = prefs.getBool('verify');
    });
  }

  Future<void> getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
    }

    _currentPosition = await location.getLocation();
    /*print('' +
        _currentPosition!.latitude.toString() +
        ',' +
        _currentPosition!.longitude.toString());*/
  }

  Future<void> getDeviceInfo() async {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    setState(() {
      deviceId = androidInfo.androidId;
      osVersion = 'Android(' + androidInfo.version.release + ')';
      deviceInfo = androidInfo.manufacturer + '(' + androidInfo.model + ')';
    });
  }

  Future<void> checkPasscode(BuildContext contexts) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      verify = prefs.getBool('verify');
    });
    if (verify == true) {
      _btn2Controller.reset();
      _showLockScreen(
        context,
        opaque: false,
        cancelButton: Text(
          'Cancel',
          style: const TextStyle(fontSize: 16, color: Colors.white),
          semanticsLabel: 'Cancel',
        ),
      );
    } else {
      _btn2Controller.reset();
      showErrorDialog('Please Verify Register');
      return;
    }
  }

  _showLockScreen(
    BuildContext context, {
    required bool opaque,
    CircleUIConfig? circleUIConfig,
    KeyboardUIConfig? keyboardUIConfig,
    required Widget cancelButton,
    List<String>? digits,
  }) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
            title: Text(
              'Enter App Passcode',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
            circleUIConfig: circleUIConfig,
            keyboardUIConfig: keyboardUIConfig,
            passwordEnteredCallback: _onPasscodeEntered,
            cancelButton: cancelButton,
            deleteButton: Text(
              'Delete',
              style: const TextStyle(fontSize: 16, color: Colors.white),
              semanticsLabel: 'Delete',
            ),
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: Colors.black.withOpacity(0.8),
            cancelCallback: _onPasscodeCancelled,
            digits: digits,
            passwordDigits: 4,
          ),
        ));
  }

  _onPasscodeEntered(String enteredPasscode) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String mobile = '';
      setState(() {
        configs = prefs.getString('configs');
        mobile = prefs.getString('mobile');
      });

      var url = Uri.parse('https://' +
          configs +
          '/api/Mobile/Login/' +
          mobile.toString() +
          '/' +
          enteredPasscode.toString() +
          '/' +
          deviceId +
          '/' +
          deviceInfo +
          '/' +
          osVersion);

      http.Response response = await http.post(url);
      var data = json.decode(response.body);
      Login checkAns = Login.fromJson(data);

      if (response.statusCode == 200) {
        _verificationNotifier.add(true);
        print(checkAns.accessToken.toString());
        prefs.setString('accessToken', checkAns.accessToken.toString());
        prefs.setString('username', checkAns.user!.userName.toString());
        timer = Timer(Duration(seconds: 1), () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MainScreen()));
        });
      } else {
        _verificationNotifier.add(false);
      }
    } catch (e) {
      showErrorDialog('Error occured while _onPasscodeEntered');
    }
  }

  _onPasscodeCancelled() {
    Navigator.maybePop(context);
  }

  void alertDialog(String msg, String type) {
    Icon icon = Icon(Icons.info_outline, color: Colors.lightBlue);
    switch (type) {
      case "Success":
        icon = Icon(Icons.check_circle_outline, color: Colors.lightGreen);
        break;
      case "Error":
        icon = Icon(Icons.error_outline, color: Colors.redAccent);
        break;
      case "Warning":
        icon = Icon(Icons.warning_amber_outlined, color: Colors.orangeAccent);
        break;
      case "Infomation":
        icon = Icon(Icons.info_outline, color: Colors.lightBlue);
        break;
    }

    showDialog(
        context: context,
        builder: (BuildContext builderContext) {
          timer = Timer(Duration(seconds: 5), () {
            Navigator.of(context, rootNavigator: true).pop();
          });

          return AlertDialog(
            title: Row(children: [icon, Text(" " + type)]),
            content: Text(msg),
          );
        }).then((val) {
      if (timer.isActive) {
        timer.cancel();
      }
    });
  }

  void showErrorDialog(String error) {
    alertDialog(error, 'Error');
  }

  void showSuccessDialog(String success) {
    alertDialog(success, 'Success');
  }

  Future<void> checkRegister() async {
    if (mobileController.text.length != 10) {
      _btnController.reset();
      showErrorDialog('Please Enter Mobile');
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        configs = prefs.getString('configs');
      });
      var mobile = mobileController.text;
      var url = Uri.parse(
          'https://' + configs + '/api/Mobile/PhoneNoCheck?phoneNo=' + mobile);
      http.Response response = await http.get(url);

      //print(url);

      var data = json.decode(response.body);
      PhoneNoCheck checkAns = PhoneNoCheck.fromJson(data);

      Timer(Duration(seconds: 3), () async {
        if (response.statusCode == 200) {
          prefs.setString('mobileTemp', mobileController.text.toString());
          _btnController.reset();
          mobileController.text = '';
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Otp()));
        } else {
          _btnController.reset();
          mobileController.text = '';
          showErrorDialog(checkAns.msg.toString());
        }
      });
    } catch (e) {
      _btnController.reset();
      mobileController.text = '';
      showErrorDialog('Error occured while PhoneNoCheck');
    }
  }

  Future<void> editConfigs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Icon icon = Icon(Icons.edit, color: Colors.lightBlue);

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(children: [icon, Text(" " + 'Edit Configs')]),
            content: SingleChildScrollView(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  //focusNode: focusNodes[3],
                  //autofocus: true, //set initail focus on dialog
                  //keyboardType: TextInputType.number,
                  readOnly: false,
                  controller: configsController
                    ..text = prefs.getString('configs').toString(),
                  decoration: InputDecoration(
                      labelText: 'Configs', hintText: "Enter Url"),
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {},
                ),
              ],
            )),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                //focusNode: focusNodes[5],
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Save'),
                onPressed: () {
                  setState(() {
                    prefs.setString('configs', configsController.text);
                    Navigator.pop(context);
                  });
                  alertDialog('Edit Successful', 'Success');
                },
              ),
            ],
          );
        });
  }

  Widget _titleWidget() {
    return Container(
        height: MediaQuery.of(context).size.height * .25,
        width: MediaQuery.of(context).size.width * 1.5,
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          'assets/SMC_logo.png',
          height: MediaQuery.of(context).size.height * .25,
          width: MediaQuery.of(context).size.width * 1.5,
          fit: BoxFit.cover,
        ));
  }

  Widget _bottomWidget() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height / 10,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            //top: MediaQuery.of(context).size.height / 1.135,
            right: MediaQuery.of(context).size.width / 2.5,
            child: Image.asset("assets/shms1.png", width: size.width * 0.38),
          ),
          Positioned(
            //top: MediaQuery.of(context).size.height / 1.135,
            right: MediaQuery.of(context).size.width / 80,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('1.1'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red[400], //
                shape: CircleBorder(),
                padding: EdgeInsets.all(12),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _contextWidget() {
    return Column(
      children: <Widget>[
        _entryFieldMobile("Mobile Number", isPassword: false),
      ],
    );
  }

  Widget _entryFieldMobile(String title, {bool isPassword = false}) {
    return Visibility(
        visible: !verify,
        child: TextFormField(
          keyboardType: TextInputType.number,
          maxLength: 10,
          controller: mobileController,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.phone),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(10)),
            prefix: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '(+66)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ));
  }

  Widget _RegisterButtonWidget() {
    return InkWell(
        child: Visibility(
      visible: !verify,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.5,
        padding: EdgeInsets.symmetric(vertical: 1),
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: RoundedLoadingButton(
            color: Colors.blue.shade300,
            successColor: Color(0xfffbb448).withAlpha(100),
            controller: _btnController,
            onPressed: () => checkRegister(),
            valueColor: Colors.black,
            child: Text('Register', style: TextStyle(color: Colors.white))),
      ),
    ));
  }

  Widget _LoginButtonWidget() {
    return InkWell(
        child: Visibility(
      visible: verify,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.5,
        padding: EdgeInsets.symmetric(vertical: 1),
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: RoundedLoadingButton(
            color: Colors.blue.shade300,
            successColor: Color(0xfffbb448).withAlpha(100),
            controller: _btn2Controller,
            onPressed: () => checkPasscode(context),
            valueColor: Colors.black,
            child: Text('Login', style: TextStyle(color: Colors.white))),
      ),
    ));
  }

  Widget _editWidget() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height / 11,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            //top: MediaQuery.of(context).size.height / 1.135,
            right: MediaQuery.of(context).size.width / 4,
            child: ElevatedButton(
              onPressed: () {
                editConfigs();
              },
              child: const Icon(
                Icons.settings,
                size: 30,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _forgetWidget() {
    return Visibility(
        visible: verify,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new GestureDetector(
                onTap: () {
                  setState(() {
                    verify = !verify;
                  });
                },
                child: Text(
                  "Don't have pin account? ",
                  style: TextStyle(fontSize: 14),
                )),
            new GestureDetector(
                onTap: () {
                  setState(() {
                    verify = !verify;
                  });
                },
                child: Text(
                  "Register",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                )),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return exit(0);
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Color(0xfff7f6fb),
            body: Container(
                child: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      _titleWidget(),
                      SizedBox(height: 36),
                      Container(
                        padding: EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _contextWidget(),
                            SizedBox(height: 12),
                            _RegisterButtonWidget(),
                            SizedBox(height: 12),
                            _LoginButtonWidget(),
                            SizedBox(height: 12),
                            _editWidget(),
                            SizedBox(height: 12),
                            _forgetWidget(),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      _bottomWidget(),
                    ],
                  ),
                ),
              ),
            ))));
  }
}
