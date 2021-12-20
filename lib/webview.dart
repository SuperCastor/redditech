import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'homescreen.dart';

void saveKeysLocaly(dynamic response) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("refresh_token", response["refresh_token"]);
  await prefs.setString("access_token", response["access_token"]);
  print(response["access_token"]);
}

class LoginWebview extends StatefulWidget {
  @override
  _LoginWebviewState createState() => _LoginWebviewState();
}

class _LoginWebviewState extends State<LoginWebview> {
  RegExp veryfyUri = RegExp("http://localhost:8080/*");
  RegExp tokenParse = RegExp("(?<=code=).*(?=#_)");
  String tempToken = "";

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(builder: (BuildContext context) {
      return WebView(
        initialUrl:
            'https://www.reddit.com/api/v1/authorize.compact?client_id=Lkuux4DnsUtkKP3s-LmFEw&response_type=code&state=RANDOM_STRING&redirect_uri=http://localhost:8080&duration=permanent&scope=identity,edit,flair,history,modconfig,modflair,modlog,modposts,modwiki,mysubreddits,privatemessages,read,report,save,submit,subscribe,vote,wikiedit,wikiread,account',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        navigationDelegate: (NavigationRequest request) async {
          if (veryfyUri.hasMatch(request.url) &&
              tokenParse.hasMatch(request.url)) {
            tempToken = tokenParse.stringMatch(request.url).toString();
            var encoded = base64.encode(utf8.encode("Lkuux4DnsUtkKP3s-LmFEw:"));
            var rep = await http.post(
                Uri.parse("https://www.reddit.com/api/v1/access_token"),
                headers: {
                  HttpHeaders.authorizationHeader: 'Basic $encoded'
                },
                body: {
                  'grant_type': 'authorization_code',
                  'code': tempToken,
                  'redirect_uri': "http://localhost:8080"
                });
            var jsonRep = json.decode(rep.body);
            saveKeysLocaly(jsonRep);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => (HomeScreen())));
          }
          return NavigationDecision.navigate;
        },
      );
    }));
  }
}
