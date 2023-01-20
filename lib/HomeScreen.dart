import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'DetailsScreen.dart';
import 'HomeListData.dart';
import 'Utils.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeScreenView();
}

class HomeScreenView extends State<HomeScreen> with TickerProviderStateMixin {
  List<Images> homeList = [];
  var img = Image.asset("assets/images/place.png", fit: BoxFit.cover);
  int offset = 1;
  bool isLoading = false;
  late ScrollController controller;

  @override
  void initState() {
    super.initState();
    callIImagesListList();
    controller = ScrollController()..addListener(scrollListener);
  }

  scrollListener() {
    double maxScroll = controller.position.maxScrollExtent;
    double currentScroll = controller.position.pixels;

    if (maxScroll == currentScroll && offset > 0) {
      //callIImagesListList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Home",
        home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.blue,
            centerTitle: true,
            title: Text(
              "Home",
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

  mainScreenView() {
    return Container(
        height: MediaQuery.of(context).size.height, child: getListData());
  }

  getListData() {
    if (homeList.length > 0) {
      return ListView.builder(
          controller: controller,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: homeList.length,
          itemBuilder: (BuildContext context, int index) {
            return buildItems(index);
          });
    } else {
      return Center(
        child: Text("No data found!!",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black,
                fontFamily: "Prompt",
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      );
    }
  }

  Widget buildItems(index) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
              margin: const EdgeInsets.only(
                  left: 15, right: 15, top: 10, bottom: 10),
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                        spreadRadius: 2,
                        offset: Offset.zero,
                        blurRadius: 2,
                        blurStyle: BlurStyle.inner)
                  ],
                  border: Border.all(color: Colors.black, width: 1)),
              child: Container(
                child: GestureDetector(
                    child: setImageData(homeList[index]),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration:
                              const Duration(milliseconds: 1000),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  DetailsScreen(homeList[index].xtImage!),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    }),
              )),
        ),
        GestureDetector(
          onTap: () {
            if (offset > 0) {
              callIImagesListList();
            }
          },
          child: Visibility(
              visible: index == homeList.length - 1 && offset > 0,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                    width: 200,
                    padding: EdgeInsets.all(10),
                    margin: const EdgeInsets.only(
                        left: 15, right: 15, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey,
                      boxShadow: const [
                        BoxShadow(
                            spreadRadius: 2,
                            offset: Offset.zero,
                            color: Colors.blueAccent,
                            blurRadius: 2,
                            blurStyle: BlurStyle.inner)
                      ],
                    ),
                    child: Text("Click here to load more..",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "Prompt",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.white))),
              )),
        )
      ],
    );
  }

  setImageData(Images data) {
    return (data != null && data.xtImage != null && data.xtImage!.isNotEmpty)
        ? Image.network(
            data.xtImage!,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitWidth,
          )
        : Container(
            color: Colors.red,
          );
  }

  callIImagesListList() async {
    showProgress();
    var _jsonEncode = jsonEncode(<String, String>{
      'user_id': "108",
      'offset': offset.toString(),
      'type': "popular",
    });
    debugPrint('loginToken: $_jsonEncode');
    var req = http.MultipartRequest(
        'POST', Uri.parse("http://dev3.xicom.us/xttest/getdata.php"));
    req.fields["user_id"] = "108";
    req.fields["offset"] = offset.toString();
    req.fields["type"] = "popular";

    var response = await req.send();
    if (response.statusCode == 200) {
      response.stream.transform(utf8.decoder).listen((value) {
        setAPIResponse(HomeListData.fromJson(jsonDecode(value)));
        hideProgress();
      });
    } else {
      hideProgress();
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      return "";
    }
  }

  setAPIResponse(HomeListData response) {
    hideProgress();
    if (response != null) {
      if (response.status != null && response.status == "success") {
        homeList.addAll(response.images!);
        /* if (offset > 0)
          controller!.position.scr = homeList.length - response.images.length;*/
        if (response.images!.length > 0)
          offset++;
        else
          offset = 0;
        refreshState();
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
}
