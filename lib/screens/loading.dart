import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart' as http;
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image/image.dart' as img;
import 'package:location/location.dart';
import 'package:test/class/containerdocument.dart';
import 'package:test/class/createimage.dart';
import 'package:test/class/getsequnce.dart';
import 'package:test/class/imagesequence.dart';
import 'package:test/class/transportationdocument.dart';
import 'package:test/class/uploadimage.dart';
import 'package:test/screens/register.dart';
import 'package:image/image.dart' as img;

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  TextEditingController documentController = TextEditingController();
  bool documentVisible = false;
  bool documentReadonly = false;
  Color documentColor = Color(0xFFFFFFFF);
  bool takePhotoEnabled = false;
  bool uploadEnabled = false;
  bool finishEnabled = false;
  bool backEnabled = false;

  String documentIdInput = '';
  String eventType = '';
  String statusUpload = '';
  String fileInBase64 = '';
  bool documentWillUpload = false;
  bool documentWillUploadOrWillFinish = false;
  bool documentWillFinish = false;

  int step = 0;
  final ImagePicker _picker = ImagePicker();
  late File? _image = null;
  late List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());
  late Timer timer;
  String configs = '';
  String accessToken = '';
  int quality = 30;
  int sequence = 0;
  int min = 0;
  int max = 0;
  String deviceId = "";
  String deviceInfo = "";
  String osVersion = "";
  LocationData? _currentPosition;
  Location location = Location();
  String gps = "";
  String documentType = "";

  String username = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      step = 0;
      documentType = 'Transportation';
      eventType = 'Loading';
    });
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  Future<void> getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    /*print('' +
        _currentPosition!.latitude.toString() +
        ',' +
        _currentPosition!.longitude.toString());*/
    setState(() {
      gps = (_currentPosition!.latitude.toString() +
          ',' +
          _currentPosition!.longitude.toString());
    });
  }

  Future<void> getDeviceInfo() async {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    setState(() {
      deviceId = androidInfo.androidId;
      osVersion = 'Android(' + androidInfo.version.release + ')';
      deviceInfo = androidInfo.manufacturer + '(' + androidInfo.model + ')';
    });
  }

  Future<void> showProgressImageFromCamera() async {
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

    await pr.show();
    timer = Timer(Duration(seconds: 3), () async {
      await pr.hide();
    });
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

  void setVisible() {
    if (step == 0) {
      setState(() {
        documentVisible = true;
      });
    }
  }

  void setReadOnly() {
    if (step == 0) {
      setState(() {
        documentReadonly = false;
        backEnabled = false;
        takePhotoEnabled = false;
        uploadEnabled = false;
        finishEnabled = false;
        documentWillUpload = false;
        documentWillUploadOrWillFinish = false;
        documentWillFinish = false;
      });
    } else if (step == 1) {
      setState(() {
        documentReadonly = true;
        backEnabled = true;
        takePhotoEnabled = true;
        uploadEnabled = false;
        finishEnabled = false;
      });
    } else if (step == 2) {
      setState(() {
        documentReadonly = true;
        backEnabled = true;
        takePhotoEnabled = false;
        uploadEnabled = true;
        finishEnabled = false;
      });
    } else if (step == 3) {
      if (documentWillUploadOrWillFinish) {
        setState(() {
          documentReadonly = true;
          backEnabled = true;
          takePhotoEnabled = true;
          uploadEnabled = false;
          finishEnabled = true;
        });
      } else if (documentWillFinish) {
        setState(() {
          documentReadonly = true;
          backEnabled = true;
          takePhotoEnabled = false;

          uploadEnabled = false;
          finishEnabled = true;
        });
      }
    }
  }

  void setColor() {
    if (step == 0) {
      setState(() {
        documentColor = Color(0xFFFFFFFF);
      });
    } else if (step == 1) {
      setState(() {
        documentColor = Color(0xFFEEEEEE);
      });
    }
  }

  void setText() {
    if (step == 0) {
      setState(() {
        documentController.text = "";
        statusUpload = "No image Previews";
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
    }
  }

  void back() {
    if (step == 1 || step == 2) {
      setState(() {
        step--;
        _image = null;
      });
    } else if (step == 3) {
      setState(() {
        step = 0;
        _image = null;
      });
    }
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
    //MyWidget.showMyAlertDialog(context, "Error", error);
    alertDialog(error, 'Error');
  }

  void showSuccessDialog(String success) {
    //MyWidget.showMyAlertDialog(context, "Success", success);
    alertDialog(success, 'Success');
  }

  Future<void> documentIDCheck() async {
    setState(() {
      documentIdInput = documentController.text;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        configs = prefs.getString('configs');
        accessToken = prefs.getString('accessToken');
      });

      var url = Uri.parse('https://' +
          configs +
          '/api/TransportationDocument/Get/' +
          documentIdInput);

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      http.Response response = await http.get(url, headers: headers);
      if (response.statusCode == 204) {
        setState(() {
          documentController.text = '';
          documentIdInput = '';
        });
        showErrorDialog('DocumentID Not Found!');
        setVisible();
        setReadOnly();
        setColor();
        setText();
        setFocus();
        return;
      }
      var data = json.decode(response.body);
      TransportationDocument checkAns = TransportationDocument.fromJson(data);
      if (response.statusCode == 200) {
        if (checkAns.isCompletedPhotoLoad!) {
          showSuccessDialog('Document Complete!');
        } else {
          await getImageSequenceAfterDocCheck();
        }
      } else {
        setState(() {
          documentController.text = '';
          documentIdInput = '';
        });
        showErrorDialog('DocumentID Not Found!');
      }
    } catch (e) {
      setState(() {
        documentController.text = '';
        documentIdInput = '';
      });
      showErrorDialog('Error occured while documentIDCheck');
    }
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  Future<void> getImageSequenceAfterUpload() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        configs = prefs.getString('configs');
        accessToken = prefs.getString('accessToken');
      });

      var url = Uri.parse('https://' +
          configs +
          '/api/Image/GetSequnce/' +
          documentIdInput +
          '/' +
          documentType +
          '/' +
          eventType);

      /*var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      http.Response response = await http.get(url, headers: headers);*/
      http.Response response = await http.get(url);
      var data = json.decode(response.body);
      GetSequnce checkAns = GetSequnce.fromJson(data);

      if (response.statusCode == 200) {
        setState(() {
          sequence = checkAns.sequence!;
          min = checkAns.min!;
          max = checkAns.max!;
        });
        print('-----------getImageSequenceAfterUpload------------');
        print('canUpload : ' + checkAns.canUpload.toString());
        print('canComplete : ' + checkAns.canComplete.toString());
        print('sequence : ' + sequence.toString());
        print('min : ' + min.toString());
        print('max : ' + max.toString());
        if (!checkAns.canUpload! && checkAns.canComplete!) {
          setState(() {
            documentWillUpload = false;
            documentWillUploadOrWillFinish = false;
            documentWillFinish = true;
            _image = null;
            int tempSeq = sequence - 1;
            statusUpload = 'upload successful';
            step++;
          });
        } else if (checkAns.canUpload! && !checkAns.canComplete!) {
          setState(() {
            documentWillUpload = true;
            documentWillUploadOrWillFinish = false;
            documentWillFinish = false;
            _image = null;
            int tempSeq = sequence - 1;
            statusUpload = 'upload successful but not enough : ' +
                tempSeq.toString() +
                ' / ' +
                min.toString();
            step--;
          });
        } else if (checkAns.canUpload! && checkAns.canComplete!) {
          setState(() {
            documentWillUpload = false;
            documentWillUploadOrWillFinish = true;
            documentWillFinish = false;
            _image = null;
            int tempSeq = sequence - 1;
            statusUpload = 'upload successful but can add more : ' +
                tempSeq.toString() +
                ' / ' +
                min.toString();
            step++;
          });
        }
      } else {
        showErrorDialog('Error occured while getImageSequenceAfterUpload');
      }
    } catch (e) {
      showErrorDialog('Error occured while getImageSequenceAfterUpload');
    }
  }

  Future<void> getImageSequenceAfterDocCheck() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        configs = prefs.getString('configs');
        accessToken = prefs.getString('accessToken');
      });

      var url = Uri.parse('https://' +
          configs +
          '/api/Image/GetSequnce/' +
          documentIdInput +
          '/' +
          documentType +
          '/' +
          eventType);

      /*var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      http.Response response = await http.get(url, headers: headers);*/
      http.Response response = await http.get(url);
      var data = json.decode(response.body);
      GetSequnce checkAns = GetSequnce.fromJson(data);

      if (response.statusCode == 200) {
        setState(() {
          sequence = checkAns.sequence!;
          min = checkAns.min!;
          max = checkAns.max!;
        });
        print('-----------getImageSequenceAfterDocCheck------------');
        print('canUpload : ' + checkAns.canUpload.toString());
        print('canComplete : ' + checkAns.canComplete.toString());
        print('sequence : ' + sequence.toString());
        print('min : ' + min.toString());
        print('max : ' + max.toString());
        if (!checkAns.canUpload! && checkAns.canComplete!) {
          setState(() {
            documentWillUpload = false;
            documentWillUploadOrWillFinish = false;
            documentWillFinish = true;
            _image = null;
            statusUpload = 'Upload Finish';
            step = 3;
            documentReadonly = true;
            documentColor = Color(0xFFEEEEEE);
          });
        } else if (checkAns.canUpload! && !checkAns.canComplete!) {
          setState(() {
            documentWillUpload = true;
            documentWillUploadOrWillFinish = false;
            documentWillFinish = false;
            _image = null;
            statusUpload = 'Images Not Enough';
            step++;
          });
        } else if (checkAns.canUpload! && checkAns.canComplete!) {
          setState(() {
            documentWillUpload = false;
            documentWillUploadOrWillFinish = true;
            documentWillFinish = false;
            _image = null;
            statusUpload = 'Add More Images Or Finish';
            step = 3;
            documentReadonly = true;
            documentColor = Color(0xFFEEEEEE);
          });
        }
      } else {
        showErrorDialog('Error occured while getImageSequenceAfterDocCheck');
      }
    } catch (e) {
      showErrorDialog('Error occured while getImageSequenceAfterDocCheck');
    }
  }

  Future<void> imageFromCamera() async {
    setState(() {
      step = 1;
    });
    //open camera device
    PickedFile? selectedImage = await _picker.getImage(
        source: ImageSource.camera,
        imageQuality: quality,
        maxHeight: 2000,
        maxWidth: 2000);

    //set image from camera
    File? temp;
    if (selectedImage != null) {
      temp = File(selectedImage.path);
      if (selectedImage.path.isNotEmpty) {
        setState(() {
          _image = temp;
          final encodedBytes = _image!.readAsBytesSync();
          fileInBase64 = base64Encode(encodedBytes);
        });

        /*//print size file image
        double news = fileInBase64.length / (1024 * 1024);
        print('Base64 : ' + news.toString() + ' MB');

        //print size width, height image
        var decoded = await decodeImageFromList(_image!.readAsBytesSync());
        print('Original Width : ' + decoded.width.toString());
        print('Original Height : ' + decoded.height.toString());

        //resize image
        img.Image? image = img.decodeImage(temp.readAsBytesSync());
        var resizedImage = img.copyResize(image!, height: 120, width: 120);

        //Get a path to save the resized file
        final directory = await getApplicationDocumentsDirectory();
        String path = directory.path;

        // Save file
        File resizedFile = File('$path/resizedImage.jpg')
          ..writeAsBytesSync(img.encodePng(resizedImage));

        //encode image to base64
        final encodedBytes2 = resizedFile.readAsBytesSync();
        String fileResizeInBase64 = base64Encode(encodedBytes2);

        //print size file image
        double news2 = fileResizeInBase64.length / (1024 * 1024);
        print('Base64 : ' + news2.toString() + ' MB');

        //print size width, height image
        var decoded2 = await decodeImageFromList(resizedFile.readAsBytesSync());
        print('Resize Width : ' + decoded2.width.toString());
        print('Resize Height : ' + decoded2.height.toString());

        setState(() {
          fileInBase64 = fileResizeInBase64;
        });*/
      }
    }
    if (_image != null) {
      showProgressImageFromCamera();
      setState(() {
        step++;
      });
      setVisible();
      setReadOnly();
      setColor();
      setText();
      setFocus();
    }
  }

  Future<void> upload() async {
    setState(() {
      uploadEnabled = false;
    });
    await showProgressLoading(false);
    await getDeviceInfo();
    await getLocation();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        configs = prefs.getString('configs');
        accessToken = prefs.getString('accessToken');
        username = prefs.getString('username');
      });

      var url = Uri.parse('https://' + configs + '/api/Image/Create');

      /*var headers = { 
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };*/

      var headers = {'Content-Type': 'application/json'};
      late CreateImage? imageupload = new CreateImage();

      setState(() {
        imageupload.documentType = documentType;
        imageupload.eventType = eventType;
        imageupload.documentID = int.parse(documentIdInput);
        imageupload.sequence = sequence;
        imageupload.deviceInfo = deviceInfo;
        imageupload.osInfo = osVersion;
        imageupload.gps = gps;
        imageupload.isDeleted = false;
        imageupload.createdBy = username;
        imageupload.imageBase64 = fileInBase64;
      });
      print(imageupload.toJson());

      var jsonBody = jsonEncode(imageupload);
      final encoding = Encoding.getByName('utf-8');

      http.Response response = await http.post(
        url,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        await getImageSequenceAfterUpload();
      } else {
        await showProgressLoading(true);
        showErrorDialog('Error occured while upload');
      }
    } catch (e) {
      await showProgressLoading(true);
      showErrorDialog('Error occured while upload');
    }

    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
    showProgressLoading(true);
  }

  Future<void> finish() async {
    setState(() {
      finishEnabled = false;
    });
    await showProgressLoading(false);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        configs = prefs.getString('configs');
        accessToken = prefs.getString('accessToken');
      });

      var url = Uri.parse('https://' +
          configs +
          '/api/TransportationDocument/Complete?transportationdocumentid=' +
          documentIdInput +
          '&type=' +
          eventType);

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      http.Response response = await http.post(url, headers: headers);
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        await showProgressLoading(true);
        setState(() {
          _image = null;
          step = 0;
        });
        showSuccessDialog('Scan Finish!');
      } else {
        showErrorDialog('Error occured while finish');
      }
    } catch (e) {
      showErrorDialog('Error occured while finish');
    }
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
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
      documentIDCheck();
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
            'Loading',
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
        body: SafeArea(
            child: Column(children: [
          SizedBox(height: 20),
          Container(
              padding: new EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 5,
                  right: MediaQuery.of(context).size.width / 5),
              child: Visibility(
                  visible: documentVisible,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    focusNode: focusNodes[0],
                    readOnly: documentReadonly,
                    textInputAction: TextInputAction.go,
                    onFieldSubmitted: (value) {
                      documentIDCheck();
                    },
                    decoration: InputDecoration(
                      //icon: const Icon(Icons.person),
                      fillColor: documentColor,
                      filled: true,
                      hintText: 'Enter Document No.',
                      labelText: 'Document Number',
                      border: OutlineInputBorder(),
                      isDense: true, // Added this
                      contentPadding: EdgeInsets.all(15), //
                    ),
                    controller: documentController,
                  ))),
          SizedBox(height: 10),
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
                  focusNode: focusNodes[1],
                  color: step == 1 ? Colors.green : Colors.blue,
                  child: Column(
                    children: <Widget>[Icon(Icons.add_a_photo_outlined)],
                  ),
                  onPressed: takePhotoEnabled
                      ? () {
                          imageFromCamera();
                        }
                      : null,
                ),
                new RaisedButton(
                  focusNode: focusNodes[2],
                  color: step == 2 ? Colors.green : Colors.blue,
                  child: const Text('Upload',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  onPressed: uploadEnabled
                      ? () {
                          upload();
                          setVisible();
                          setReadOnly();
                          setColor();
                          setText();
                          setFocus();
                        }
                      : null,
                ),
                new RaisedButton(
                  focusNode: focusNodes[3],
                  color: step == 3 ? Colors.green : Colors.blue,
                  child: const Text('Finish',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  onPressed: finishEnabled
                      ? () {
                          finish();
                          setVisible();
                          setReadOnly();
                          setColor();
                          setText();
                          setFocus();
                        }
                      : null,
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Center(
              child: _image != null
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: 225,
                        height: 225,
                        child: Image.file(
                          _image!,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(statusUpload),
                    ),
            )
          ]),
        ])));
  }
}
