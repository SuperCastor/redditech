import 'package:flutter/material.dart';
import 'package:redditech/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'profile_container.dart';

Future<dynamic> getMe() async {
  dynamic _me;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("access_token");
  var rep = await http.get(
    Uri.https("oauth.reddit.com", "/api/v1/me"),
    headers: {'Authorization': 'bearer $token'},
  );
  print(token);
  _me = json.decode(rep.body);
  return _me;
}

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _selectedIndex = 0;
  dynamic _me = [0, 0];
  bool v1 = false;
  RegExp bannerParse = RegExp(r".*(?=\?)");

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getMe().then((dynamic res) {
        if (this.mounted == false) {
          return;
        }
        setState(() {
          _me = res;
          v1 = true;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (v1 == true) {
      return Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.orange,
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => (SettingsScreen())));
            },
            child: Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
          body: Column(children: [
            Stack(children: [
              _me["subreddit"]["is_default_banner"] == true
                  ? Image.asset("./images/default_banner.jpg")
                  : Image(
                      image: NetworkImage(bannerParse
                          .stringMatch(_me["subreddit"]["banner_img"])
                          .toString())),
              Column(children: [
                Padding(padding: EdgeInsets.only(bottom: 50)),
                Center(
                  child: CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.orangeAccent,
                    child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 70,
                        backgroundImage: NetworkImage(bannerParse
                            .stringMatch(_me["icon_img"])
                            .toString())),
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 10)),
                Text(
                  _me["name"].toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                Padding(padding: EdgeInsets.only(bottom: 10)),
                Text(
                  _me["subreddit"]["display_name_prefixed"].toString() +
                      " • " +
                      _me["total_karma"].toString() +
                      " karma",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                Padding(padding: EdgeInsets.only(bottom: 20)),
                Text(
                  _me["subreddit"]["public_description"].toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                ProfileBar(),
              ]),
            ])
          ]));
    } else {
      return const Scaffold(
          body: Center(
        child: SizedBox(
            child: CircularProgressIndicator(
                strokeWidth: 8,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue))),
      ));
    }
  }
}
