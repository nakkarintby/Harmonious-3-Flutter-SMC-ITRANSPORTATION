import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/class/resvalidatedocument.dart';
import 'package:test/class/resvalidatelocation.dart';
import 'package:test/class/resvalidatepalletitem.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:test/mywidget.dart';
import 'package:test/screens/history.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ReLabel extends StatefulWidget {
  const ReLabel({Key? key}) : super(key: key);

  @override
  _ReLabelState createState() => _ReLabelState();
}

class _ReLabelState extends State<ReLabel> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController documentController = TextEditingController();
  TextEditingController locationFromController = TextEditingController();
  TextEditingController gradeLabel1Controller = TextEditingController();
  TextEditingController gradeLabel2Controller = TextEditingController();
  TextEditingController locationToController = TextEditingController();
  TextEditingController gradeLabel3Controller = TextEditingController();
  TextEditingController gradeLabel4Controller = TextEditingController();

  bool documentVisible = false;
  bool locationFromVisible = false;
  bool gradeLabel1Visible = false;
  bool gradeLabel2Visible = false;
  bool locationToVisible = false;
  bool gradeLabel3Visible = false;
  bool gradeLabel4Visible = false;

  bool documentReadonly = false;
  bool locationFromReadonly = false;
  bool gradeLabel1Readonly = false;
  bool gradeLabel2Readonly = false;
  bool locationToReadonly = false;
  bool gradeLabel3Readonly = false;
  bool gradeLabel4Readonly = false;

  Color documentColor = Color(0xFFFFFFFF);
  Color locationFromColor = Color(0xFFFFFFFF);
  Color gradeLabel1Color = Color(0xFFFFFFFF);
  Color gradeLabel2Color = Color(0xFFFFFFFF);
  Color locationToColor = Color(0xFFFFFFFF);
  Color gradeLabel3Color = Color(0xFFFFFFFF);
  Color gradeLabel4Color = Color(0xFFFFFFFF);

  bool backEnabled = false;
  bool skipEnabled = false;
  bool finishEnabled = false;

  //step
  int step = 0;
  //variable call api
  String documentIdInput = '';
  String locationFromInput = '';
  String gradeLabel1Input = '';
  String gradeLabel2Input = '';
  String locationToInput = '';
  String gradeLabel3Input = '';
  String gradeLabel4Input = '';

  late ResValidateDocument? resultValDocument;
  late ResValidateLocation? resultValLocation;
  late ResValidatePalletitem? resultValPallet;
  late Document? resultDocument;
  late Location? resultLocationFrom;
  late Location? resultLocationTo;
  late Palletitem? resultPalletitem;
  late List<Palletitem?> listPalletitem = [];

  int isUsername = 0;
  String username = "";
  late List<FocusNode> focusNodes = List.generate(8, (index) => FocusNode());
  late Timer timer;

  String configs = '';

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
    getSession();
    setState(() {
      step = 0;
    });
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  Future<void> showProgressLoading(bool finish) async {
    ProgressDialog pr = ProgressDialog(context);
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: true);
    pr.style(
        progress: 50.0,
        message: "Please wait...",
        progressWidget: Container(
            padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

    if (finish == false) {
      await pr.show();
    } else {
      await pr.hide();
    }
  }

  Future<void> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      configs = prefs.getString('configs');
    });
  }

  Future<void> getSession() async {
    isUsername = await FlutterSession().get("token_username");
    setState(() {
      username = isUsername.toString();
    });
  }

  void setVisible() {
    if (step == 0) {
      setState(() {
        documentVisible = true;
        locationFromVisible = false;
        gradeLabel1Visible = false;
        gradeLabel2Visible = false;
        locationToVisible = false;
        gradeLabel3Visible = false;
        gradeLabel4Visible = false;
      });
    } else if (step == 1) {
      setState(() {
        documentVisible = true;
        locationFromVisible = true;
        gradeLabel1Visible = false;
        gradeLabel2Visible = false;
        locationToVisible = false;
        gradeLabel3Visible = false;
        gradeLabel4Visible = false;
      });
    } else if (step == 2) {
      setState(() {
        documentVisible = true;
        locationFromVisible = true;
        gradeLabel1Visible = true;
        gradeLabel2Visible = false;
        locationToVisible = false;
        gradeLabel3Visible = false;
        gradeLabel4Visible = false;
      });
    } else if (step == 3) {
      setState(() {
        documentVisible = true;
        locationFromVisible = true;
        gradeLabel1Visible = true;
        gradeLabel2Visible = true;
        locationToVisible = false;
        gradeLabel3Visible = false;
        gradeLabel4Visible = false;
      });
    } else if (step == 4) {
      setState(() {
        documentVisible = true;
        locationFromVisible = true;
        gradeLabel1Visible = true;
        gradeLabel2Visible = true;
        locationToVisible = true;
        gradeLabel3Visible = false;
        gradeLabel4Visible = false;
      });
    } else if (step == 5) {
      setState(() {
        documentVisible = true;
        locationFromVisible = true;
        gradeLabel1Visible = true;
        gradeLabel2Visible = true;
        locationToVisible = true;
        gradeLabel3Visible = true;
        gradeLabel4Visible = false;
      });
    } else if (step == 6) {
      setState(() {
        documentVisible = true;
        locationFromVisible = true;
        gradeLabel1Visible = true;
        gradeLabel2Visible = true;
        locationToVisible = true;
        gradeLabel3Visible = true;
        gradeLabel4Visible = true;
      });
    } else if (step == 7) {
      setState(() {
        documentVisible = true;
        locationFromVisible = true;
        gradeLabel1Visible = true;
        gradeLabel2Visible = true;
        locationToVisible = true;
        gradeLabel3Visible = true;
        gradeLabel4Visible = true;
      });
    }
  }

  void setReadOnly() {
    if (step == 0) {
      setState(() {
        documentReadonly = false;
        locationFromReadonly = false;
        gradeLabel1Readonly = false;
        gradeLabel2Readonly = false;
        locationToReadonly = false;
        gradeLabel3Readonly = false;
        gradeLabel4Readonly = false;

        backEnabled = false;
        skipEnabled = false;
        finishEnabled = false;
      });
    } else if (step == 1) {
      setState(() {
        documentReadonly = true;
        locationFromReadonly = false;
        gradeLabel1Readonly = false;
        gradeLabel2Readonly = false;
        locationToReadonly = false;
        gradeLabel3Readonly = false;
        gradeLabel4Readonly = false;

        backEnabled = true;
        skipEnabled = false;
        finishEnabled = false;
      });
    } else if (step == 2) {
      setState(() {
        documentReadonly = true;
        locationFromReadonly = true;
        gradeLabel1Readonly = false;
        gradeLabel2Readonly = false;
        locationToReadonly = false;
        gradeLabel3Readonly = false;
        gradeLabel4Readonly = false;

        backEnabled = true;
        skipEnabled = false;
        finishEnabled = false;
      });
    } else if (step == 3) {
      setState(() {
        documentReadonly = true;
        locationFromReadonly = true;
        gradeLabel1Readonly = true;
        gradeLabel2Readonly = false;
        locationToReadonly = false;
        gradeLabel3Readonly = false;
        gradeLabel4Readonly = false;

        backEnabled = true;
        skipEnabled = true;
        finishEnabled = false;
      });
    } else if (step == 4) {
      setState(() {
        documentReadonly = true;
        locationFromReadonly = true;
        gradeLabel1Readonly = true;
        gradeLabel2Readonly = true;
        locationToReadonly = false;
        gradeLabel3Readonly = false;
        gradeLabel4Readonly = false;

        backEnabled = true;
        skipEnabled = false;
        finishEnabled = false;
      });
    } else if (step == 5) {
      setState(() {
        documentReadonly = true;
        locationFromReadonly = true;
        gradeLabel1Readonly = true;
        gradeLabel2Readonly = true;
        locationToReadonly = true;
        gradeLabel3Readonly = false;
        gradeLabel4Readonly = false;

        backEnabled = true;
        skipEnabled = false;
        finishEnabled = false;
      });
    } else if (step == 6) {
      setState(() {
        documentReadonly = true;
        locationFromReadonly = true;
        gradeLabel1Readonly = true;
        gradeLabel2Readonly = true;
        locationToReadonly = true;
        gradeLabel3Readonly = true;
        gradeLabel4Readonly = false;

        backEnabled = true;
        skipEnabled = false;
        finishEnabled = false;
      });
    } else if (step == 7) {
      setState(() {
        documentReadonly = true;
        locationFromReadonly = true;
        gradeLabel1Readonly = true;
        gradeLabel2Readonly = true;
        locationToReadonly = true;
        gradeLabel3Readonly = true;
        gradeLabel4Readonly = true;

        backEnabled = true;
        skipEnabled = false;
        finishEnabled = true;
      });
    }
  }

  void setColor() {
    if (step == 0) {
      setState(() {
        documentColor = Color(0xFFFFFFFF);
        locationFromColor = Color(0xFFFFFFFF);
        gradeLabel1Color = Color(0xFFFFFFFF);
        gradeLabel2Color = Color(0xFFFFFFFF);
        locationToColor = Color(0xFFFFFFFF);
        gradeLabel3Color = Color(0xFFFFFFFF);
        gradeLabel4Color = Color(0xFFFFFFFF);
      });
    } else if (step == 1) {
      setState(() {
        documentColor = Color(0xFFEEEEEE);
        locationFromColor = Color(0xFFFFFFFF);
        gradeLabel1Color = Color(0xFFFFFFFF);
        gradeLabel2Color = Color(0xFFFFFFFF);
        locationToColor = Color(0xFFFFFFFF);
        gradeLabel3Color = Color(0xFFFFFFFF);
        gradeLabel4Color = Color(0xFFFFFFFF);
      });
    } else if (step == 2) {
      setState(() {
        documentColor = Color(0xFFEEEEEE);
        locationFromColor = Color(0xFFEEEEEE);
        gradeLabel1Color = Color(0xFFFFFFFF);
        gradeLabel2Color = Color(0xFFFFFFFF);
        locationToColor = Color(0xFFFFFFFF);
        gradeLabel3Color = Color(0xFFFFFFFF);
        gradeLabel4Color = Color(0xFFFFFFFF);
      });
    } else if (step == 3) {
      setState(() {
        documentColor = Color(0xFFEEEEEE);
        locationFromColor = Color(0xFFEEEEEE);
        gradeLabel1Color = Color(0xFFEEEEEE);
        gradeLabel2Color = Color(0xFFFFFFFF);
        locationToColor = Color(0xFFFFFFFF);
        gradeLabel3Color = Color(0xFFFFFFFF);
        gradeLabel4Color = Color(0xFFFFFFFF);
      });
    } else if (step == 4) {
      setState(() {
        documentColor = Color(0xFFEEEEEE);
        locationFromColor = Color(0xFFEEEEEE);
        gradeLabel1Color = Color(0xFFEEEEEE);
        gradeLabel2Color = Color(0xFFEEEEEE);
        locationToColor = Color(0xFFFFFFFF);
        gradeLabel3Color = Color(0xFFFFFFFF);
        gradeLabel4Color = Color(0xFFFFFFFF);
      });
    } else if (step == 5) {
      setState(() {
        documentColor = Color(0xFFEEEEEE);
        locationFromColor = Color(0xFFEEEEEE);
        gradeLabel1Color = Color(0xFFEEEEEE);
        gradeLabel2Color = Color(0xFFEEEEEE);
        locationToColor = Color(0xFFEEEEEE);
        gradeLabel3Color = Color(0xFFFFFFFF);
        gradeLabel4Color = Color(0xFFFFFFFF);
      });
    } else if (step == 6) {
      setState(() {
        documentColor = Color(0xFFEEEEEE);
        locationFromColor = Color(0xFFEEEEEE);
        gradeLabel1Color = Color(0xFFEEEEEE);
        gradeLabel2Color = Color(0xFFEEEEEE);
        locationToColor = Color(0xFFEEEEEE);
        gradeLabel3Color = Color(0xFFEEEEEE);
        gradeLabel4Color = Color(0xFFFFFFFF);
      });
    } else if (step == 7) {
      setState(() {
        documentColor = Color(0xFFEEEEEE);
        locationFromColor = Color(0xFFEEEEEE);
        gradeLabel1Color = Color(0xFFEEEEEE);
        gradeLabel2Color = Color(0xFFEEEEEE);
        locationToColor = Color(0xFFEEEEEE);
        gradeLabel3Color = Color(0xFFEEEEEE);
        gradeLabel4Color = Color(0xFFEEEEEE);
      });
    }
  }

  void setText() {
    if (step == 0) {
      setState(() {
        documentController.text = '';
        locationFromController.text = '';
        gradeLabel1Controller.text = '';
        gradeLabel2Controller.text = '';
        locationToController.text = '';
        gradeLabel3Controller.text = '';
        gradeLabel4Controller.text = '';
      });
    }
    if (step == 1) {
      setState(() {
        documentController.text = documentIdInput;
        locationFromController.text = '';
        gradeLabel1Controller.text = '';
        gradeLabel2Controller.text = '';
        locationToController.text = '';
        gradeLabel3Controller.text = '';
        gradeLabel4Controller.text = '';
      });
    } else if (step == 2) {
      setState(() {
        documentController.text = documentIdInput;
        locationFromController.text = locationFromInput;
        gradeLabel1Controller.text = '';
        gradeLabel2Controller.text = '';
        locationToController.text = '';
        gradeLabel3Controller.text = '';
        gradeLabel4Controller.text = '';
      });
    } else if (step == 3) {
      setState(() {
        documentController.text = documentIdInput;
        locationFromController.text = locationFromInput;
        gradeLabel1Controller.text = gradeLabel1Input;
        gradeLabel2Controller.text = '';
        locationToController.text = '';
        gradeLabel3Controller.text = '';
        gradeLabel4Controller.text = '';
      });
    } else if (step == 4) {
      setState(() {
        documentController.text = documentIdInput;
        locationFromController.text = locationFromInput;
        gradeLabel1Controller.text = gradeLabel1Input;
        gradeLabel2Controller.text = gradeLabel2Input;
        locationToController.text = '';
        gradeLabel3Controller.text = '';
        gradeLabel4Controller.text = '';
      });
    } else if (step == 5) {
      setState(() {
        documentController.text = documentIdInput;
        locationFromController.text = locationFromInput;
        gradeLabel1Controller.text = gradeLabel1Input;
        gradeLabel2Controller.text = gradeLabel2Input;
        locationToController.text = locationToInput;
        gradeLabel3Controller.text = '';
        gradeLabel4Controller.text = '';
      });
    } else if (step == 6) {
      setState(() {
        documentController.text = documentIdInput;
        locationFromController.text = locationFromInput;
        gradeLabel1Controller.text = gradeLabel1Input;
        gradeLabel2Controller.text = gradeLabel2Input;
        locationToController.text = locationToInput;
        gradeLabel3Controller.text = gradeLabel3Input;
        gradeLabel4Controller.text = '';
      });
    } else if (step == 7) {
      setState(() {
        documentController.text = documentIdInput;
        locationFromController.text = locationFromInput;
        gradeLabel1Controller.text = gradeLabel1Input;
        gradeLabel2Controller.text = gradeLabel2Input;
        locationToController.text = locationToInput;
        gradeLabel3Controller.text = gradeLabel3Input;
        gradeLabel4Controller.text = gradeLabel4Input;
      });
    }
  }

  void setFocus() {
    if (step == 0) {
      Future.delayed(Duration(milliseconds: 100))
          .then((_) => FocusScope.of(context).requestFocus(focusNodes[0]));
    } else if (step == 1) {
      Future.delayed(Duration(milliseconds: 100))
          .then((_) => FocusScope.of(context).requestFocus(focusNodes[1]));
    } else if (step == 2) {
      Future.delayed(Duration(milliseconds: 100))
          .then((_) => FocusScope.of(context).requestFocus(focusNodes[2]));
    } else if (step == 3) {
      Future.delayed(Duration(milliseconds: 100))
          .then((_) => FocusScope.of(context).requestFocus(focusNodes[3]));
    } else if (step == 4) {
      Future.delayed(Duration(milliseconds: 100))
          .then((_) => FocusScope.of(context).requestFocus(focusNodes[4]));
    } else if (step == 5) {
      Future.delayed(Duration(milliseconds: 100))
          .then((_) => FocusScope.of(context).requestFocus(focusNodes[5]));
    } else if (step == 6) {
      Future.delayed(Duration(milliseconds: 100))
          .then((_) => FocusScope.of(context).requestFocus(focusNodes[6]));
    } else if (step == 7) {
      Future.delayed(Duration(milliseconds: 100))
          .then((_) => FocusScope.of(context).requestFocus(focusNodes[7]));
    }
  }

  void showErrorDialog(String error) {
    //MyWidget.showMyAlertDialog(context, "Error", error);
    alertDialog(error, 'Error');
  }

  void showSuccessDialog(String success) {
    //MyWidget.showMyAlertDialog(context, "Success", success);
    alertDialog(success, 'Success');
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

  Future<void> documentCheck() async {
    setState(() {
      documentIdInput = documentController.text;
    });
    var url =
        Uri.parse(configs + '/api/api/document/validatere/' + documentIdInput);
    http.Response response = await http.get(url);

    if (response.statusCode != 200) {
      showErrorDialog('Error Http Requests documentCheck ReLabel');
      return;
    }

    var data = json.decode(response.body);
    setState(() {
      resultValDocument = ResValidateDocument.fromJson(data);
      resultDocument = resultValDocument?.document;
    });

    if (resultDocument == null) {
      showErrorDialog(resultValDocument!.errorMsg.toString());
    } else {
      setState(() {
        step++;
      });
    }
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  Future<void> locationFromCheck() async {
    setState(() {
      locationFromInput = locationFromController.text;
    });
    var url = Uri.parse(
        configs + '/api/api/location/validatere/' + locationFromInput);
    http.Response response = await http.get(url);

    if (response.statusCode != 200) {
      showErrorDialog('Error Http Requests locationFromCheck ReLabel');
      return;
    }

    var data = json.decode(response.body);
    setState(() {
      resultValLocation = ResValidateLocation.fromJson(data);
      resultLocationFrom = resultValLocation?.location;
    });

    if (resultLocationFrom == null) {
      showErrorDialog(resultValLocation!.errorMsg.toString());
    } else {
      setState(() {
        step++;
      });
    }
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  Future<void> grade1Check() async {
    setState(() {
      gradeLabel1Input = gradeLabel1Controller.text;
      gradeLabel1Input = gradeLabel1Input.replaceAll('/', ' ');
    });

    int? temp = resultLocationFrom?.binId;
    int locationFrombinIdTemp = temp!;

    double totalpalletweight = 0;
    for (int i = 0; i < listPalletitem.length; i++) {
      if (listPalletitem[i]!.movementTypeId == 303) {
        double? tempWeight = listPalletitem[i]?.weight;
        totalpalletweight += tempWeight!;
      }
    }
    var url = Uri.parse(configs +
        '/api/api/palletitem/validatere/' +
        resultDocument!.documentId.toString() +
        '/' +
        gradeLabel1Input +
        '/' +
        locationFrombinIdTemp.toString() +
        '/' +
        'From' +
        '/' +
        totalpalletweight.toString());
    http.Response response = await http.get(url);

    if (response.statusCode != 200) {
      showErrorDialog('Error Http Requests grade1Check ReLabel');
      return;
    }

    var data = json.decode(response.body);
    setState(() {
      resultValPallet = ResValidatePalletitem.fromJson(data);
      resultPalletitem = resultValPallet?.palletitem;
    });

    if (resultPalletitem == null) {
      showErrorDialog(resultValPallet!.errorMsg.toString());
    } else {
      String? temp2 = resultValPallet?.aUnit;
      String aUnitTemp = temp2!;
      if (aUnitTemp == "JB") {
        setState(() {
          step++;
        });
      } else {
        setState(() {
          step = step + 2;
        });
      }
      setState(() {
        resultPalletitem!.scanBy = username;
        resultPalletitem!.createdBy = username;
        resultPalletitem!.gradeLabel = gradeLabel1Input;
        listPalletitem.add(resultPalletitem);
      });
    }
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  Future<void> grade2Check() async {
    setState(() {
      gradeLabel2Input = gradeLabel2Controller.text;
      gradeLabel2Input = gradeLabel2Input.replaceAll('/', ' ');
    });

    int? temp = resultLocationFrom?.binId;
    int locationFrombinIdTemp = temp!;

    double totalpalletweight = 0;
    for (int i = 0; i < listPalletitem.length; i++) {
      if (listPalletitem[i]!.movementTypeId == 303) {
        double? tempWeight = listPalletitem[i]?.weight;
        totalpalletweight += tempWeight!;
      }
    }
    var url = Uri.parse(configs +
        '/api/api/palletitem/validatere/' +
        resultDocument!.documentId.toString() +
        '/' +
        gradeLabel2Input +
        '/' +
        locationFrombinIdTemp.toString() +
        '/' +
        'From' +
        '/' +
        totalpalletweight.toString());
    http.Response response = await http.get(url);

    if (response.statusCode != 200) {
      showErrorDialog('Error Http Requests grade2Check ReLabel');
      return;
    }

    var data = json.decode(response.body);
    setState(() {
      resultValPallet = ResValidatePalletitem.fromJson(data);
      resultPalletitem = resultValPallet?.palletitem;
    });

    bool gradeDuplicate = false;
    for (int i = 0; i < listPalletitem.length; i++) {
      if (listPalletitem[i]!.gradeLabel == gradeLabel2Input &&
          listPalletitem[i]!.movementTypeId == 303) {
        gradeDuplicate = true;
      }
    }
    if (resultPalletitem == null) {
      showErrorDialog(resultValPallet!.errorMsg.toString());
    } else if (gradeDuplicate) {
      showErrorDialog("#E11 GradeLabel is Duplicate");
    } else {
      setState(() {
        step++;
        resultPalletitem!.scanBy = username;
        resultPalletitem!.createdBy = username;
        resultPalletitem!.gradeLabel = gradeLabel2Input;
        listPalletitem.add(resultPalletitem);
      });
    }
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  Future<void> locationToCheck() async {
    setState(() {
      locationToInput = locationToController.text;
    });
    var url =
        Uri.parse(configs + '/api/api/location/validatetr/' + locationToInput);
    http.Response response = await http.get(url);

    if (response.statusCode != 200) {
      showErrorDialog('Error Http Requests locationToCheck ReLabel');
      return;
    }

    var data = json.decode(response.body);
    setState(() {
      resultValLocation = ResValidateLocation.fromJson(data);
      resultLocationTo = resultValLocation?.location;
    });

    if (resultLocationTo == null) {
      showErrorDialog(resultValLocation!.errorMsg.toString());
    } else {
      setState(() {
        step++;
      });
    }
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  Future<void> grade3Check() async {
    setState(() {
      gradeLabel3Input = gradeLabel3Controller.text;
      gradeLabel3Input = gradeLabel3Input.replaceAll('/', ' ');
    });

    int? temp = resultLocationTo?.binId;
    int locationTobinIdTemp = temp!;

    double totalpalletweight = 0;
    for (int i = 0; i < listPalletitem.length; i++) {
      if (listPalletitem[i]!.movementTypeId == 304) {
        double? tempWeight = listPalletitem[i]?.weight;
        totalpalletweight += tempWeight!;
      }
    }
    var url = Uri.parse(configs +
        '/api/api/palletitem/validatere/' +
        resultDocument!.documentId.toString() +
        '/' +
        gradeLabel3Input +
        '/' +
        locationTobinIdTemp.toString() +
        '/' +
        'To' +
        '/' +
        totalpalletweight.toString());
    http.Response response = await http.get(url);

    if (response.statusCode != 200) {
      showErrorDialog('Error Http Requests grade3Check ReLabel');
      return;
    }

    var data = json.decode(response.body);
    setState(() {
      resultValPallet = ResValidatePalletitem.fromJson(data);
      resultPalletitem = resultValPallet?.palletitem;
    });

    bool checkMatch304 = false;
    for (int i = 0; i < listPalletitem.length; i++) {
      if (listPalletitem[i]!.movementTypeId == 304 &&
          listPalletitem[i]!.gradeLabel == gradeLabel3Input) {
        checkMatch304 = true;
      }
    }

    int numbercheckNotMatch303 = 0;
    for (int i = 0; i < listPalletitem.length; i++) {
      if (listPalletitem[i]!.movementTypeId == 303) {
        numbercheckNotMatch303++;
      }
    }

    double check303Weight = 0;
    for (int i = 0; i < listPalletitem.length; i++) {
      if (listPalletitem[i]!.movementTypeId == 303) {
        double? temp = listPalletitem[i]?.weight;
        check303Weight += temp!;
        break;
      }
    }

    double? temp3;
    double palletWeight = 0;
    if (resultPalletitem != null) {
      temp3 = resultPalletitem?.weight;
      palletWeight = temp3!;
    }

    if (resultPalletitem == null) {
      showErrorDialog(resultValPallet!.errorMsg.toString());
    } else if (checkMatch304) {
      showErrorDialog("#E11 GradeLabel is Duplicate");
    } else if (numbercheckNotMatch303 == 1 && check303Weight != palletWeight) {
      showErrorDialog("#E12 GradeLabel is not match");
    } else {
      if (numbercheckNotMatch303 == 1) {
        setState(() {
          step = step + 2;
        });
      } else {
        setState(() {
          step++;
        });
      }
      setState(() {
        resultPalletitem!.scanBy = username;
        resultPalletitem!.createdBy = username;
        resultPalletitem!.gradeLabel = gradeLabel3Input;
        listPalletitem.add(resultPalletitem);
      });
    }

    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  Future<void> grade4Check() async {
    setState(() {
      gradeLabel4Input = gradeLabel4Controller.text;
      gradeLabel4Input = gradeLabel4Input.replaceAll('/', ' ');
    });

    int? temp = resultLocationTo?.binId;
    int locationTobinIdTemp = temp!;

    double totalpalletweight = 0;
    for (int i = 0; i < listPalletitem.length; i++) {
      if (listPalletitem[i]!.movementTypeId == 304) {
        double? tempWeight = listPalletitem[i]?.weight;
        totalpalletweight += tempWeight!;
      }
    }
    var url = Uri.parse(configs +
        '/api/api/palletitem/validatere/' +
        resultDocument!.documentId.toString() +
        '/' +
        gradeLabel4Input +
        '/' +
        locationTobinIdTemp.toString() +
        '/' +
        'To' +
        '/' +
        totalpalletweight.toString());
    http.Response response = await http.get(url);

    if (response.statusCode != 200) {
      showErrorDialog('Error Http Requests grade4Check ReLabel');
      return;
    }

    var data = json.decode(response.body);
    setState(() {
      resultValPallet = ResValidatePalletitem.fromJson(data);
      resultPalletitem = resultValPallet?.palletitem;
    });

    bool checkMatch304 = false;
    for (int i = 0; i < listPalletitem.length; i++) {
      if (listPalletitem[i]!.movementTypeId == 304 &&
          listPalletitem[i]!.gradeLabel == gradeLabel4Input) {
        checkMatch304 = true;
      }
    }

    double totalpalletweight303 = 0;
    for (int i = 0; i < listPalletitem.length; i++) {
      if (listPalletitem[i]!.movementTypeId == 303) {
        double? tempWeight = listPalletitem[i]?.weight;
        totalpalletweight303 += tempWeight!;
      }
    }

    double totalpalletweight304 = 0;
    for (int i = 0; i < listPalletitem.length; i++) {
      if (listPalletitem[i]!.movementTypeId == 304) {
        double? tempWeight = listPalletitem[i]?.weight;
        totalpalletweight304 += tempWeight!;
      }
    }

    double? temp3;
    double palletWeight = 0;
    if (resultPalletitem != null) {
      temp3 = resultPalletitem?.weight;
      palletWeight = temp3!;
    }

    if (resultPalletitem == null) {
      showErrorDialog(resultValPallet!.errorMsg.toString());
    } else if (checkMatch304) {
      showErrorDialog("#E11 GradeLabel is Duplicate");
    } else if (totalpalletweight304 + palletWeight != totalpalletweight303) {
      showErrorDialog("#E13 Pallet is wrong weight");
    } else {
      setState(() {
        step++;
        resultPalletitem!.scanBy = username;
        resultPalletitem!.createdBy = username;
        resultPalletitem!.gradeLabel = gradeLabel3Input;
        listPalletitem.add(resultPalletitem);
      });
    }

    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  Future<void> finishReLabel() async {
    await showProgressLoading(false);
    String tempAPI = configs + '/api/api/palletitem/createrelabel';
    final uri = Uri.parse(tempAPI);
    final headers = {'Content-Type': 'application/json'};
    var jsonBody = jsonEncode(listPalletitem);
    final encoding = Encoding.getByName('utf-8');
    http.Response response = await http.post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode != 200) {
      await showProgressLoading(true);
      showErrorDialog('Error Http Requests finishReLabel1 ReLabel');
      return;
    }

    var data = json.decode(response.body);
    bool result = data;

    if (resultDocument!.documentStatus == "Created") {
      resultDocument!.documentStatus = "In Progress";
    }
    String tempAPI2 = configs + '/api/api/document/updatemobile';
    final uri2 = Uri.parse(tempAPI2);
    final headers2 = {'Content-Type': 'application/json'};
    var jsonBody2 = jsonEncode(resultDocument?.toJson());
    final encoding2 = Encoding.getByName('utf-8');
    http.Response response2 = await http.post(
      uri2,
      headers: headers2,
      body: jsonBody2,
      encoding: encoding2,
    );

    if (response.statusCode != 200) {
      await showProgressLoading(true);
      showErrorDialog('Error Http Requests finishReLabel2 ReLabel');
      return;
    }

    var data2 = json.decode(response2.body);
    setState(() {
      resultDocument = Document.fromJson(data2);
    });
    double totalpalletweight304 = 0;
    for (int i = 0; i < listPalletitem.length; i++) {
      if (listPalletitem[i]!.movementTypeId == 304) {
        double? tempWeight = listPalletitem[i]?.weight;
        totalpalletweight304 += tempWeight!;
      }
    }

    double? temp5 = resultValPallet?.remainingdocument;
    double remainingdocument = temp5!;
    if (remainingdocument - totalpalletweight304 <= 0) {
      setState(() {
        step = 0;
      });
      await showProgressLoading(true);
      showSuccessDialog('Scan Complete');
    } else {
      setState(() {
        step = 2;
      });
      await showProgressLoading(true);
      showSuccessDialog('Post Complete');
    }

    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
    setState(() {
      listPalletitem.clear();
    });
  }

  void back() {
    if (step == 3) {
      setState(() {
        step--;
        listPalletitem.removeLast();
      });
    } else if (step == 4) {
      if (listPalletitem.length == 1) {
        setState(() {
          step = step - 2;
          listPalletitem.removeLast();
        });
      } else if (listPalletitem.length == 2) {
        setState(() {
          step = step - 2;
          listPalletitem.removeLast();
          listPalletitem.removeLast();
        });
      }
    } else if (step == 6) {
      setState(() {
        step--;
        listPalletitem.removeLast();
      });
    } else if (step == 7) {
      if (listPalletitem.length == 2) {
        setState(() {
          step = step - 2;
          listPalletitem.removeLast();
          gradeLabel4Input = '';
        });
      } else if (listPalletitem.length == 4) {
        setState(() {
          step = step - 2;
          listPalletitem.removeLast();
          listPalletitem.removeLast();
          gradeLabel4Input = '';
        });
      }
    } else {
      setState(() {
        step--;
      });
    }
  }

  void skip() {
    setState(() {
      step++;
      gradeLabel2Input = '';
    });
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (step == 0) {
      setState(() {
        documentController.text = barcodeScanRes;
      });
      documentCheck();
    } else if (step == 1) {
      setState(() {
        locationFromController.text = barcodeScanRes;
      });
      locationFromCheck();
    } else if (step == 2) {
      setState(() {
        gradeLabel1Controller.text = barcodeScanRes;
      });
      grade1Check();
    } else if (step == 3) {
      setState(() {
        gradeLabel2Controller.text = barcodeScanRes;
      });
      grade2Check();
    } else if (step == 4) {
      setState(() {
        locationToController.text = barcodeScanRes;
      });
      locationToCheck();
    } else if (step == 5) {
      setState(() {
        gradeLabel3Controller.text = barcodeScanRes;
      });
      grade3Check();
    } else if (step == 6) {
      setState(() {
        gradeLabel4Controller.text = barcodeScanRes;
      });
      grade4Check();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          leading: BackButton(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'ReLabel',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.black,
                ),
                onPressed: scanQR)
          ],
        ),
        body: Container(
            child: SingleChildScrollView(
                child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Container(
                  padding: new EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 5,
                      right: MediaQuery.of(context).size.width / 5),
                  child: Visibility(
                      visible: documentVisible,
                      child: TextFormField(
                        focusNode: focusNodes[0],
                        style: TextStyle(fontSize: 12),
                        readOnly: documentReadonly,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) {
                          documentCheck();
                        },
                        decoration: InputDecoration(
                          //icon: const Icon(Icons.person),
                          fillColor: documentColor,
                          filled: true,
                          hintText: 'Enter Document No.',
                          labelText: 'Document No.',
                          labelStyle: TextStyle(fontSize: 12),
                          border: OutlineInputBorder(),
                          isDense: true, // Added this
                          contentPadding: EdgeInsets.all(12), //
                        ),
                        controller: documentController,
                      ))),
              SizedBox(
                height: 10,
              ),
              Container(
                  padding: new EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 5,
                      right: MediaQuery.of(context).size.width / 5),
                  child: Visibility(
                      visible: locationFromVisible,
                      child: TextFormField(
                        focusNode: focusNodes[1],
                        style: TextStyle(fontSize: 12),
                        readOnly: locationFromReadonly,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) {
                          locationFromCheck();
                        },
                        decoration: InputDecoration(
                          //icon: const Icon(Icons.person),
                          fillColor: locationFromColor,
                          filled: true,
                          hintText: 'Enter Location From',
                          labelText: 'Location From',
                          labelStyle: TextStyle(fontSize: 12),
                          border: OutlineInputBorder(),
                          isDense: true, // Added this
                          contentPadding: EdgeInsets.all(12), //
                        ),
                        controller: locationFromController,
                      ))),
              SizedBox(
                height: 10,
              ),
              Container(
                  padding: new EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 5,
                      right: MediaQuery.of(context).size.width / 5),
                  child: Visibility(
                      visible: gradeLabel1Visible,
                      child: TextFormField(
                        focusNode: focusNodes[2],
                        style: TextStyle(fontSize: 12),
                        readOnly: gradeLabel1Readonly,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) {
                          grade1Check();
                        },
                        decoration: InputDecoration(
                          //icon: const Icon(Icons.person),
                          fillColor: gradeLabel1Color,
                          filled: true,
                          hintText: 'Enter GradeLabel1',
                          labelText: 'GradeLabel1',
                          labelStyle: TextStyle(fontSize: 12),
                          border: OutlineInputBorder(),
                          isDense: true, // Added this
                          contentPadding: EdgeInsets.all(12), //
                        ),
                        controller: gradeLabel1Controller,
                      ))),
              SizedBox(
                height: 10,
              ),
              Container(
                  padding: new EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 5,
                      right: MediaQuery.of(context).size.width / 5),
                  child: Visibility(
                      visible: gradeLabel2Visible,
                      child: TextFormField(
                        focusNode: focusNodes[3],
                        style: TextStyle(fontSize: 12),
                        readOnly: gradeLabel2Readonly,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) {
                          grade2Check();
                        },
                        decoration: InputDecoration(
                          //icon: const Icon(Icons.person),
                          fillColor: gradeLabel2Color,
                          filled: true,
                          hintText: 'Enter GradeLabel2',
                          labelText: 'GradeLabel2',
                          labelStyle: TextStyle(fontSize: 12),
                          border: OutlineInputBorder(),
                          isDense: true, // Added this
                          contentPadding: EdgeInsets.all(12), //
                        ),
                        controller: gradeLabel2Controller,
                      ))),
              SizedBox(
                height: 10,
              ),
              Container(
                  padding: new EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 5,
                      right: MediaQuery.of(context).size.width / 5),
                  child: Visibility(
                      visible: locationToVisible,
                      child: TextFormField(
                        focusNode: focusNodes[4],
                        style: TextStyle(fontSize: 12),
                        readOnly: locationToReadonly,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) {
                          locationToCheck();
                        },
                        decoration: InputDecoration(
                          //icon: const Icon(Icons.person),
                          fillColor: locationToColor,
                          filled: true,
                          hintText: 'Enter Location To',
                          labelText: 'Location To',
                          labelStyle: TextStyle(fontSize: 12),
                          border: OutlineInputBorder(),
                          isDense: true, // Added this
                          contentPadding: EdgeInsets.all(12), //
                        ),
                        controller: locationToController,
                      ))),
              SizedBox(
                height: 10,
              ),
              Container(
                  padding: new EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 5,
                      right: MediaQuery.of(context).size.width / 5),
                  child: Visibility(
                      visible: gradeLabel3Visible,
                      child: TextFormField(
                        focusNode: focusNodes[5],
                        style: TextStyle(fontSize: 12),
                        readOnly: gradeLabel3Readonly,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) {
                          grade3Check();
                        },
                        decoration: InputDecoration(
                          //icon: const Icon(Icons.person),
                          fillColor: gradeLabel3Color,
                          filled: true,
                          hintText: 'Enter GradeLabel3',
                          labelText: 'GradeLabel3',
                          labelStyle: TextStyle(fontSize: 12),
                          border: OutlineInputBorder(),
                          isDense: true, // Added this
                          contentPadding: EdgeInsets.all(12), //
                        ),
                        controller: gradeLabel3Controller,
                      ))),
              SizedBox(
                height: 10,
              ),
              Container(
                  padding: new EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 5,
                      right: MediaQuery.of(context).size.width / 5),
                  child: Visibility(
                      visible: gradeLabel4Visible,
                      child: TextFormField(
                        focusNode: focusNodes[6],
                        style: TextStyle(fontSize: 12),
                        readOnly: gradeLabel4Readonly,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) {
                          grade4Check();
                        },
                        decoration: InputDecoration(
                          //icon: const Icon(Icons.person),
                          fillColor: gradeLabel4Color,
                          filled: true,
                          hintText: 'Enter GradeLabel4',
                          labelText: 'GradeLabel4',
                          labelStyle: TextStyle(fontSize: 12),
                          border: OutlineInputBorder(),
                          isDense: true, // Added this
                          contentPadding: EdgeInsets.all(12), //
                        ),
                        controller: gradeLabel4Controller,
                      ))),
              SizedBox(
                height: 4,
              ),
              new Center(
                child: new ButtonBar(
                  mainAxisSize: MainAxisSize
                      .min, // this will take space as minimum as posible(to center)
                  children: <Widget>[
                    new RaisedButton(
                      color: Colors.blue,
                      child: const Text('Back',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      onPressed: backEnabled
                          ? () {
                              back();
                              setVisible();
                              setReadOnly();
                              setColor();
                              setText();
                              setFocus();
                            }
                          : null,
                    ),
                    new RaisedButton(
                      color: Colors.blue,
                      child: const Text('Skip',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      onPressed: skipEnabled
                          ? () {
                              skip();
                              setVisible();
                              setReadOnly();
                              setColor();
                              setText();
                              setFocus();
                            }
                          : null,
                    ),
                    new RaisedButton(
                      focusNode: focusNodes[7],
                      color: step == 7 ? Colors.green : Colors.blue,
                      child: const Text('Finish',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      onPressed: finishEnabled
                          ? () {
                              finishReLabel();
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ))));
  }
}
