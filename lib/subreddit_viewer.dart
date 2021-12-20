import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'post_container.dart';

Future<List<dynamic>> getSubPosts(String subName, String endpoint) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  print(subName);
  var params = {"raw_json": "1"};
  var token = await prefs.getString("access_token");
  var rep = await http
      .get(Uri.https("www.reddit.com", "/r/$subName/$endpoint.json", params));
  var _subList = json.decode(rep.body);
  return _subList["data"]["children"];
}

class SubViewer extends StatefulWidget {
  final String subName;

  const SubViewer({Key? key, required this.subName}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SubViewerState();
  }
}

class SubViewerState extends State<SubViewer> {
  bool isMounted = false;
  late List<dynamic> _subPosts;
  int _filterState = 0;

  void initState() {
    getSubPosts(widget.subName, "best").then((List<dynamic> subPosts) {
      setState(() {
        _subPosts = subPosts;
        isMounted = true;
      });
    });
    super.initState();
  }

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

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          child: Icon(Icons.clear),
          mini: true,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        body: (isMounted == true)
            ? Stack(children: [
                ListView(
                  children: List.generate(_subPosts.length, (index) {
                    return Padding(
                        child: Postviewer(redditPost: _subPosts[index]["data"]),
                        padding: const EdgeInsets.only(
                          bottom: 8.0,
                          left: 4.0,
                          right: 4.0,
                        ));
                  }),
                ),
                Column(children: [
                  Padding(padding: EdgeInsets.only(top: 15)),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    TextButton(
                      onPressed: () {
                        if (_filterState != 0) {
                          getSubPosts(widget.subName, "best")
                              .then((List<dynamic> res) {
                            setState(() {
                              _subPosts = res;
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
                            getSubPosts(widget.subName, "hot")
                                .then((List<dynamic> res) {
                              setState(() {
                                _subPosts = res;
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
                            getSubPosts(widget.subName, "rising")
                                .then((List<dynamic> res) {
                              setState(() {
                                _subPosts = res;
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
                ])
              ])
            : Center(child: CircularProgressIndicator()));
  }
}
