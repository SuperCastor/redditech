import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:simple_url_preview/simple_url_preview.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'video_player.dart' as hb;
import 'comments_modal.dart';

// Future<String> getSubredditIconUrl(String subname) async {
//   String res;

//   var rep = await http
//       .get(Uri.parse("https://www.reddit.com/r/" + subname + "/about.json"));
//   res = json.decode(rep.body)["data"]["icon_img"];
//   print(res);

//   return res;
// }

void sendVote(dynamic response, int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("access_token");
  var rep = await http.post(Uri.parse("https://oauth.reddit.com/api/vote"),
      headers: {'Authorization': 'bearer $token'},
      body: {"dir": value.toString(), "id": response["name"], "rank": "2"});
}

class Postviewer extends StatefulWidget {
  final dynamic redditPost;

  const Postviewer({Key? key, required this.redditPost}) : super(key: key);

  @override
  _PostviewerState createState() => _PostviewerState();
}

class _PostviewerState extends State<Postviewer> {
  var postData;
  var iconUrl;
  int upsValue = 0;
  int voteStatus = 0;
  late Widget videoPlayer;
  bool videoMounted = false;
  Color upvoteColor = Colors.grey;
  Color downvoteColor = Colors.grey;

  @override
  void initState() {
    print(widget.redditPost["title"]);
    iconUrl =
        "https://b.thumbs.redditmedia.com/Zb0wasror0ZgkhX_eZ6TztwTv_1UzUQ7HOnx_2wOJvA.png";
    upsValue = widget.redditPost["ups"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(children: [
      ListTile(
        leading:
            CircleAvatar(radius: 15, backgroundImage: NetworkImage(iconUrl)),
        title: Text(
          widget.redditPost["subreddit_name_prefixed"],
          style: TextStyle(fontSize: 10),
        ),
        subtitle: Text(
          "u/" + widget.redditPost["author_fullname"],
          style: TextStyle(fontSize: 10),
        ),
      ),
      Text(
        widget.redditPost["title"],
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Padding(padding: EdgeInsets.only(bottom: 5)),
      if (widget.redditPost["post_hint"] == "image" ||
          (widget.redditPost["post_hint"] == "link" &&
              widget.redditPost["url"].toString().contains(".gif") == true))
        if (widget.redditPost["url"].toString().contains(".gifv") == true)
          hb.VideoPlayer(redditPost: widget.redditPost)
        else
          Image(
            image: NetworkImage(widget.redditPost["url"]),
          )
      else if (widget.redditPost["post_hint"] == null ||
          widget.redditPost["post_hint"] == "self")
        Container(
            height: 200,
            child: Markdown(
              data: widget.redditPost["selftext"],
              onTapLink: (text, url, title) {
                if (url != null) launch(url);
              },
            ))
      else if (widget.redditPost["post_hint"] == "hosted:video" ||
          widget.redditPost["post_hint"] == "rich:video")
        hb.VideoPlayer(redditPost: widget.redditPost)
      else if (widget.redditPost["post_hint"] == "link" &&
          widget.redditPost["url"].toString().contains(".gif") == false)
        if (widget.redditPost["crosspost_parent_list"] != null)
          Text("CROSSPOST")
        else if (widget.redditPost["secure_media"] != null &&
            widget.redditPost["secure_media"]["oembed"]["provider_url"] ==
                "http://www.twitch.tv")
          hb.VideoPlayer(redditPost: widget.redditPost)
        else
          SimpleUrlPreview(
              bgColor: Colors.deepOrangeAccent,
              titleStyle:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              descriptionStyle: TextStyle(color: Colors.white),
              siteNameStyle: TextStyle(color: Colors.white),
              url: widget.redditPost["url_overridden_by_dest"]),
      if (widget.redditPost["is_gallery"] == true) Text("Gallery"),
      Padding(padding: EdgeInsets.only(bottom: 15)),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
            color: upvoteColor,
            icon: Icon(Icons.arrow_upward),
            onPressed: () {
              if (voteStatus == -1 || voteStatus == 0) {
                sendVote(widget.redditPost, 1);
                setState(() {
                  downvoteColor = Colors.grey;
                  upvoteColor = Colors.orange;
                  upsValue = upsValue + 1;
                  voteStatus = 1;
                });
              } else if (voteStatus == 1) {
                sendVote(widget.redditPost, 0);
                setState(() {
                  upvoteColor = Colors.grey;
                  upsValue = upsValue - 1;
                  voteStatus = 0;
                });
              }
            }),
        Padding(padding: EdgeInsets.only(right: 15)),
        Text(upsValue.toString()),
        Padding(padding: EdgeInsets.only(left: 15)),
        IconButton(
          color: downvoteColor,
          icon: Icon(Icons.arrow_downward),
          onPressed: () {
            if (voteStatus == 1 || voteStatus == 0) {
              sendVote(widget.redditPost, -1);
              setState(() {
                upvoteColor = Colors.grey;
                downvoteColor = Colors.orange;
                upsValue = upsValue - 1;
                voteStatus = -1;
              });
            } else if (voteStatus == -1) {
              sendVote(widget.redditPost, 0);
              setState(() {
                downvoteColor = Colors.grey;
                upsValue = upsValue + 1;
                voteStatus = 0;
              });
            }
          },
        ),
        Container(padding: EdgeInsets.only(right: 60)),
        IconButton(
            onPressed: () {
              showMaterialModalBottomSheet(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10))),
                  context: context,
                  builder: (BuildContext bc) {
                    return (CommentsModal(redditPost: widget.redditPost));
                  });
            },
            icon: Icon(
              Icons.insert_comment,
              color: Colors.grey,
            )),
      ]),
    ]));
  }
}
