import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Utils {
  Future<bool> CheckUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<String> callApi(
      var _jsonEncode, String api, BuildContext context) async {
    String URL = api;

    var req = http.MultipartRequest('POST', Uri.parse(api));
    req.fields["user_id"] = "108";
    req.fields["offset"] = "1";
    req.fields["type"] = "popular";

    var response = await req.send();
    if (response.statusCode == 200) {
      response.stream.transform(utf8.decoder).listen((value) {});
      return response.reasonPhrase!;
    } else {
      return "";
    }
  }
}
