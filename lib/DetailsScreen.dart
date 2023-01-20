import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'HomeListData.dart';
import 'Utils.dart';
import 'package:http/http.dart' as http;

class DetailsScreen extends StatefulWidget {
  String imageUrl = "";

  @override
  State<StatefulWidget> createState() => DetailsScreenView();

  DetailsScreen(this.imageUrl);
}

class DetailsScreenView extends State<DetailsScreen>
    with TickerProviderStateMixin {
  List<Images> homeList = [];
  var img = Image.asset("assets/images/place.png", fit: BoxFit.cover);
  bool isLoading = false;
  Image? _image;
  GlobalKey<FormState> _key = new GlobalKey();

  @override
  void initState() {
    super.initState();
    urlToFile(widget.imageUrl);
  }

  String? get _errorText {
    final text = fNameController.value.text;

    if (text.isEmpty) {
      return 'Can\'t be empty';
    }
    if (text.length < 4) {
      return 'Too short';
    }
    // return null if the text is valid
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Details",
        home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.blue,
            centerTitle: true,
            title: Text(
              "Details",
              style: TextStyle(
                  fontFamily: "Prompt", fontSize: 16, color: Colors.white),
            ),
          ),
          body: SafeArea(
            bottom: false,
            top: false,
            child: ModalProgressHUD(
              opacity: 0.0,
              inAsyncCall: isLoading,
              child: mainScreenView(),
            ),
          ),
        ),
      ),
    );
  }

  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!))
      return 'Enter Valid Email';
    else
      return null;
  }

  String? validateMobile(String? value) {
    if (value!.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  String? validateName(String? value) {
    if (value!.isEmpty)
      return """First Name can't be empty""";
    else
      return null;
  }

  String? validateLastName(String? value) {
    if (value!.isEmpty)
      return """Last Name can't be empty""";
    else
      return null;
  }

  mainScreenView() {
    return Form(
        key: _key,
        child: Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    margin: EdgeInsets.only(
                        top: 15, left: 15, right: 15, bottom: 20),
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey, width: 0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    //elevation: 10.0,
                    child: GestureDetector(
                      onTap: () {
                        getImage().then((value) => {setImage(value)});
                      },
                      child: Column(
                        children: <Widget>[
                          AspectRatio(
                            aspectRatio: 4 / 3,
                            child: _image == null
                                ? (widget.imageUrl.isNotEmpty
                                    ? Image.network(
                                        widget.imageUrl,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        fit: BoxFit.fitWidth,
                                      )
                                    : img)
                                : _image,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, bottom: 15),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: Text("First Name")),
                        Expanded(
                          flex: 2,
                          child: Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: TextFormField(
                                controller: fNameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'First Name',
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.name,
                                validator: validateName,
                              )),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, bottom: 15),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: Text("Last Name")),
                        Expanded(
                          flex: 2,
                          child: Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: TextFormField(
                                controller: lNameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Last Name',
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.name,
                                validator: validateLastName,
                              )),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, bottom: 15),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: Text("Email")),
                        Expanded(
                          flex: 2,
                          child: Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Email',
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: validateEmail,
                              )),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, bottom: 15),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: Text("Phone number")),
                        Expanded(
                          flex: 2,
                          child: Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: TextFormField(
                                maxLength: 10,
                                maxLengthEnforcement:
                                    MaxLengthEnforcement.enforced,
                                controller: phoneController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Phone Number',
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.phone,
                                validator: validateMobile,
                              )),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    child: Container(
                        margin: const EdgeInsets.only(
                            top: 20, left: 15.0, right: 15.0),
                        width: MediaQuery.of(context).size.width,
                        height: 40.0,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            border: Border.all(
                                color: Colors.blueAccent, width: 1.0),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4.0))),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                  fontFamily: "Prompt",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white),
                            ))),
                    onTap: () {
                      if (_key.currentState!.validate()) {
                        callIImagesListList();
                      }
                    },
                  )
                ],
              ),
            )));
  }

  Future getImage() async {
    var image = await ImagePickerGC.pickImage(
        enableCloseButton: true,
        closeIcon: const Icon(
          Icons.close,
          color: Colors.red,
          size: 12,
        ),
        context: context,
        source: ImgSource.Gallery,
        barrierDismissible: true,
        cameraIcon: const Icon(
          Icons.camera_alt,
          color: Colors.red,
        ),
        cameraText: const Text(
          "From Camera",
          style: TextStyle(color: Colors.red),
        ),
        galleryText: const Text(
          "From Gallery",
          style: TextStyle(color: Colors.blue),
        ));
    return image;
  }

  File? setImageFile;
  Future<File> urlToFile(String imageUrl) async {
    var rng = new Random();

    Directory? tempDir = await getTemporaryDirectory();

    String tempPath = tempDir.path;

    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');

    http.Response response = await http.get(Uri.parse(imageUrl));

    await file.writeAsBytes(response.bodyBytes);
    setState(() {
      setImageFile = File(file.path);
    });
    print(setImageFile);
    print(file);

    return file;
  }

  callIImagesListList() async {
    showProgress();
    var req = http.MultipartRequest(
        'POST', Uri.parse("http://dev3.xicom.us/xttest/savedata.php"));
    req.fields["first_name"] = fNameController.text;
    req.fields["last_name"] = lNameController.text;
    req.fields["email"] = emailController.text;
    req.fields["phone"] = phoneController.text;

    req.files.add(http.MultipartFile.fromBytes(
        'user_image', setImageFile!.readAsBytesSync(),
        filename: setImageFile!.path.split("/").last));
    var response = await req.send();
    if (response.statusCode == 200) {
      response.stream.transform(utf8.decoder).listen((value) {
        setAPIResponse(HomeListData.fromJson(jsonDecode(value)));
        hideProgress();
      });
    } else {
      hideProgress();

      return "";
    }
  }

  setAPIResponse(HomeListData response) {
    hideProgress();
    if (response != null) {
      if (response.status != null && response.status == "success") {
        Utils().showToast("Uploaded successfully!!");
      } else {
        Utils().showToast("Something went wrong");
      }
    } else {
      Utils().showToast("Something went wrong");
    }
  }

  showProgress() {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
  }

  refreshState() {
    if (mounted) {
      setState(() {});
    }
  }

  hideProgress() {
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  File? file;
  setImage(value) {
    file = File(value.path);
    _image = Image(
      image: FileImage(file!),
      fit: BoxFit.cover,
    );
    setState(() {});
  }

  bool checkValidation() {
    if (fNameController.text == "") {
      Utils().showToast("Please enter first name.");
      return false;
    }
    if (lNameController.text == "") {
      Utils().showToast("Please enter last name.");
      return false;
    }
    if (emailController.text == "") {
      Utils().showToast("Please enter email address.");
      return false;
    }
    if (phoneController.text == "") {
      Utils().showToast("Please enter phone number.");
      return false;
    } else
      return true;
  }
}
