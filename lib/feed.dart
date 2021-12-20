import 'package:flutter/material.dart';
import 'package:redditech/feed_list.dart';
import 'dart:convert';
import 'post_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>> getIndividualPost(String endpoint) async {
  List<dynamic> _postList;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("access_token");
  var rep = await http.get(
    Uri.https("oauth.reddit.com", "/" + endpoint),
    headers: {'Authorization': 'bearer $token'},
  );
  _postList = json.decode(rep.body)["data"]["children"];
  return _postList;
}

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  int _filterState = 0;
  int _selectedIndex = 0;
  List<dynamic> _postList = [0, 0];

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getIndividualPost("best").then((List<dynamic> res) {
        if (this.mounted == false) {
          return;
        }
        setState(() {
          _postList = res;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle notSelected = TextButton.styleFrom(
      backgroundColor: Colors.white,
      primary: Colors.orange,
      side: BorderSide(color: Colors.orange),
    );
    ButtonStyle selected = TextButton.styleFrom(
      backgroundColor: Colors.orange,
      primary: Colors.white,
      side: BorderSide(color: Colors.orange),
    );
    var encoded = base64.encode(utf8.encode("Lkuux4DnsUtkKP3s-LmFEw:"));

    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: _postList.length > 3
            ? Stack(children: [
                FeedList(postList: _postList),
                Column(children: [
                  Padding(padding: EdgeInsets.only(top: 15)),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    TextButton(
                      onPressed: () {
                        if (_filterState != 0) {
                          getIndividualPost("best").then((List<dynamic> res) {
                            setState(() {
                              _postList = res;
                            });
                          });
                        }
                        setState(() {
                          _filterState = 0;
                        });
                      },
                      child: Text("Best"),
                      style: (_filterState == 0) ? selected : notSelected,
                    ),
                    Padding(padding: EdgeInsets.only(right: 20)),
                    TextButton(
                        onPressed: () {
                          if (_filterState != 1) {
                            getIndividualPost("hot").then((List<dynamic> res) {
                              setState(() {
                                _postList = res;
                              });
                            });
                          }
                          setState(() {
                            _filterState = 1;
                          });
                        },
                        child: Text("Hot"),
                        style: (_filterState == 1) ? selected : notSelected),
                    Padding(padding: EdgeInsets.only(right: 20)),
                    TextButton(
                        onPressed: () {
                          if (_filterState != 2) {
                            getIndividualPost("rising")
                                .then((List<dynamic> res) {
                              setState(() {
                                _postList = res;
                              });
                            });
                          }
                          setState(() {
                            _filterState = 2;
                          });
                        },
                        child: Text("Rising"),
                        style: (_filterState == 2) ? selected : notSelected)
                  ])
                ]),
              ])
            : const Scaffold(
                body: Center(
                child: SizedBox(
                    child: CircularProgressIndicator(
                        strokeWidth: 8,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.deepOrange))),
              )));
  }
}
