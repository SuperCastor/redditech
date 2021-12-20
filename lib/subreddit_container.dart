import 'package:flutter/material.dart';
import 'package:redditech/subreddit_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void changeSubStatus(dynamic subInfo, int status) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("access_token");
  http.Response rep;

  if (status == 1) {
    rep = await http.post(Uri.parse("https://oauth.reddit.com/api/subscribe"),
        headers: {'Authorization': 'bearer $token'},
        body: {"action": "sub", "sr_name": subInfo["display_name"]});
  } else {
    rep = await http.post(Uri.parse("https://oauth.reddit.com/api/subscribe"),
        headers: {'Authorization': 'bearer $token'},
        body: {"action": "unsub", "sr_name": subInfo["display_name"]});
  }
}

class SubredditContainer extends StatefulWidget {
  final dynamic subInfo;

  const SubredditContainer({Key? key, required this.subInfo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SubredditContainerState();
  }
}

class SubredditContainerState extends State<SubredditContainer> {
  String hexColor = "";
  int bannerColor = 0;
  bool subscribed = false;

  void initState() {
    setState(() {
      hexColor =
          widget.subInfo["primary_color"].toUpperCase().replaceAll("#", "");
      hexColor = "FF" + hexColor;
      bannerColor = int.parse(hexColor, radix: 16);
    });

    if (widget.subInfo["user_is_subscriber"] == true) {
      setState(() {
        subscribed = true;
      });
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => (SubViewer(
                  subName: widget.subInfo["display_name_prefixed"]
                      .toString()
                      .substring(2)))));
        },
        child: Card(
            child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Color(bannerColor),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(5))),
              height: 40,
              width: MediaQuery.of(context).size.width - 8,
            ),
            Column(children: [
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(5))),
                trailing: (subscribed == true)
                    ? TextButton(
                        onPressed: () {
                          changeSubStatus(widget.subInfo, -1);
                          setState(() {
                            subscribed = false;
                          });
                        },
                        child: Text("Unsubscribe"),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          primary: Colors.orange,
                          side: BorderSide(color: Colors.orange),
                        ))
                    : TextButton(
                        onPressed: () {
                          changeSubStatus(widget.subInfo, 1);
                          setState(() {
                            subscribed = true;
                          });
                        },
                        child: Text("Subscribe"),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.orange[300],
                            primary: Colors.white,
                            side: BorderSide(color: Colors.orange))),
                leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        (widget.subInfo["icon_img"]) == null
                            ? widget.subInfo["community_icon"]
                            : widget.subInfo["icon_img"])),
                title: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(widget.subInfo["title"].toString())),
                subtitle: Text(widget.subInfo["display_name_prefixed"]),
              ),
              Text(widget.subInfo["subscribers"].toString() + " subscribers"),
              Container(
                  height: 150,
                  child: Markdown(
                      physics: NeverScrollableScrollPhysics(),
                      data: (widget.subInfo["public_description"]
                                  .toString()
                                  .length >
                              300)
                          ? widget.subInfo["public_description"]
                                  .toString()
                                  .substring(0, 300) +
                              "..."
                          : widget.subInfo["public_description"].toString())),
            ])
          ],
        )));
  }
}
