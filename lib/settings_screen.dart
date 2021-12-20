import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<dynamic> getPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("access_token");

  var rep = await http.get(Uri.parse("https://oauth.reddit.com/api/v1/prefs"),
      headers: {"Authorization": "Bearer $token"});
  return json.decode(rep.body);
}

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsScreenState();
  }
}

class SettingsScreenState extends State<SettingsScreen> {
  late dynamic prefs;
  bool isMounted = false;
  bool nsfw = false;
  bool allow_pm = false;
  bool nightmode = false;
  bool presence = false;
  bool show_up = false;
  bool show_down = false;

  void initState() {
    getPrefs().then((dynamic rep) {
      setState(() {
        prefs = rep;
        isMounted = true;
        nsfw = rep["over_18"];
        allow_pm = (rep["accept_pms"] == "everyone") ? true : false;
        nightmode = rep["nightmode"];
        show_up = rep["hide_ups"];
        show_down = rep["hide_downs"];
      });
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return (Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: FloatingActionButton(
          mini: true,
          backgroundColor: Colors.grey,
          child: Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        body: (isMounted == true)
            ? Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 30)),
                  Center(
                      child: Text("Settings",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.only(top: 30)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Show NSFW"),
                      Switch(
                          value: nsfw,
                          activeColor: Colors.orange,
                          onChanged: (bool res) {
                            setState(() {
                              nsfw = res;
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Accept PMs from everyone"),
                      Switch(
                          value: allow_pm,
                          activeColor: Colors.orange,
                          onChanged: (bool res) {
                            setState(() {
                              allow_pm = res;
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Nightmode on website"),
                      Switch(
                          value: nightmode,
                          activeColor: Colors.orange,
                          onChanged: (bool res) {
                            setState(() {
                              nightmode = res;
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Show Presence"),
                      Switch(
                          value: presence,
                          activeColor: Colors.orange,
                          onChanged: (bool res) {
                            setState(() {
                              presence = res;
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Hide upvotes"),
                      Switch(
                          value: show_up,
                          activeColor: Colors.orange,
                          onChanged: (bool res) {
                            setState(() {
                              show_up = res;
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Hide downvotes"),
                      Switch(
                          value: show_down,
                          activeColor: Colors.orange,
                          onChanged: (bool res) {
                            setState(() {
                              show_down = res;
                            });
                          }),
                    ],
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      var token = prefs.getString("access_token");
                      var _body = json.encode({
                        "over_18": nsfw.toString(),
                        "accept_pms":
                            (allow_pm == true) ? "everyone" : "whitelisted",
                        "nightmode": nightmode.toString(),
                        "hide_ups": show_up.toString(),
                        "hide_downs": show_down.toString()
                      });
                      var rep = await http.patch(
                          Uri.parse("https://oauth.reddit.com/api/v1/me/prefs"),
                          headers: {
                            "Authorization": "bearer $token",
                            "content-type": "application/json"
                          },
                          body: _body);
                      print(rep.statusCode);
                    },
                    child: Text("Submit"),
                    style: TextButton.styleFrom(
                      fixedSize:
                          Size(MediaQuery.of(context).size.width / 3.2535, 30),
                      backgroundColor: Colors.white,
                      primary: Colors.orange,
                      side: BorderSide(color: Colors.orange),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 30))
                ],
              )
            : Center(child: CircularProgressIndicator())));
  }
}
