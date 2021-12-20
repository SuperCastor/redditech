import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mini_subreddit_container.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> searchSubs(String query) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("access_token");
  http.Response rep;

  rep = await http.post(
      Uri.parse("https://oauth.reddit.com/api/search-subreddits"),
      headers: {'Authorization': 'bearer $token'},
      body: {"query": query, "exact": "false"});
  return json.decode(rep.body)["subreddits"];
}

class SearchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchScreenState();
  }
}

class SearchScreenState extends State<SearchScreen> {
  bool searchMade = false;
  FocusNode _formFocus = new FocusNode();
  List<dynamic> _subList = [0];

  void initState() {
    _formFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _formFocus.dispose();
    super.dispose();
  }

  void _requestFocus() {
    setState(() {
      FocusScope.of(context).requestFocus(_formFocus);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Padding(padding: EdgeInsets.only(top: 30)),
      Center(
          child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              child: TextFormField(
                  onFieldSubmitted: (String rep) async {
                    await searchSubs(rep).then((subList) {
                      setState(() {
                        _subList = subList;
                        searchMade = false;
                        searchMade = true;
                      });
                    });
                  },
                  onTap: _requestFocus,
                  focusNode: _formFocus,
                  cursorColor: Colors.orange,
                  decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: (_formFocus.hasFocus == true)
                              ? Colors.orange
                              : Colors.grey),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                      border: OutlineInputBorder(),
                      labelText: 'Search for a subreddit')))),
      if (searchMade == true && _subList.length > 1)
        Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: ListView(
              children: List.generate(_subList.length, (index) {
                return Padding(
                    child: MiniSubredditContainer(subInfo: _subList[index]),
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                      left: 4.0,
                      right: 4.0,
                    ));
              }),
            ))
    ]));
  }
}
