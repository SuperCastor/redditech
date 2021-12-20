import 'package:flutter/material.dart';
import 'dart:convert';
import 'post_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FeedList extends StatefulWidget {
  final List<dynamic> postList;

  @override
  _FeedListState createState() => _FeedListState();

  const FeedList({Key? key, required this.postList}) : super(key: key);
}

class _FeedListState extends State<FeedList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: List.generate(widget.postList.length, (index) {
        return Padding(
            child: Postviewer(redditPost: widget.postList[index]["data"]),
            padding: const EdgeInsets.only(
              bottom: 8.0,
              left: 4.0,
              right: 4.0,
            ));
      }),
    );
  }
}
