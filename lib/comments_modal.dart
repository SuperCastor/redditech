import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//dynamic getCommentariesFromPost(dynamic redditPost) {
//  var rep = http.get(Uri.parse("https://www.reddit.com/r/" +
//      redditPost["subreddit"] +
//      "/comments/" +
//      redditPost[""]));
//}

class CommentsModal extends StatefulWidget {
  final dynamic redditPost;
  const CommentsModal({Key? key, required this.redditPost}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return CommentsModalState();
  }
}

class CommentsModalState extends State<CommentsModal> {
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return (Container(
        height: MediaQuery.of(context).size.height * 0.95,
        width: MediaQuery.of(context).size.width * 0.95,
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close),
            )
          ]),
          Text("Commentaires", style: TextStyle(fontSize: 40)),
        ])));
  }
}
