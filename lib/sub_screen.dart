import 'package:flutter/material.dart';
import 'package:redditech/subreddit_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> getSubbedSubreddit() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  var token = await prefs.getString("access_token");
  var params = {"raw_json": "1"};
  var rep = await http.get(
    Uri.https("oauth.reddit.com", "/subreddits/mine/subscriber", params),
    headers: {"Authorization": "Bearer $token"},
  );
  var _subList = json.decode(rep.body)["data"]["children"];
  return _subList;
}

class SubScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SubScreenState();
  }
}

class SubScreenState extends State<SubScreen> {
  List<dynamic> _subList = [0, 0];
  bool isMounted = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getSubbedSubreddit().then((List<dynamic> res) {
        if (this.mounted == false) {
          return;
        }
        setState(() {
          _subList = res;
          isMounted = true;
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: (isMounted == true)
            ? Center(
                child: ListView(
                children: List.generate(_subList.length, (index) {
                  return Padding(
                      child:
                          SubredditContainer(subInfo: _subList[index]["data"]),
                      padding: const EdgeInsets.only(
                        bottom: 8.0,
                        left: 4.0,
                        right: 4.0,
                      ));
                }),
              ))
            : Center(
                child: CircularProgressIndicator(
                    color: Colors.deepOrange, strokeWidth: 8)));
  }
}
