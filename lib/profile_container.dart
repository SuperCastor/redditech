import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ProfileBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ButtonBarState();
  }
}

class ButtonBarState extends State<ProfileBar> {
  void initState() {
    super.initState();
  }

  bool print_publication = false;
  bool print_commentaire = false;
  bool print_propos = false;

  Widget build(BuildContext context) {
    ButtonStyle notSelected = TextButton.styleFrom(
      fixedSize: Size(MediaQuery.of(context).size.width / 3.2535, 30),
      backgroundColor: Colors.white,
      primary: Colors.orange,
      side: BorderSide(color: Colors.orange),
    );
    ButtonStyle selected = TextButton.styleFrom(
      fixedSize: Size(MediaQuery.of(context).size.width / 3.2535, 30),
      backgroundColor: Colors.orange,
      primary: Colors.white,
      side: BorderSide(color: Colors.orange),
    );

    return Container(
      child: Column(children: [
        ButtonBar(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  print_publication = true;
                  print_commentaire = false;
                  print_propos = false;
                });
              },
              style: (print_publication == true) ? selected : notSelected,
              child: Text("Publications"),
            ),
            TextButton(
              child: Text("Commentaires", style: TextStyle(fontSize: 13)),
              style: (print_commentaire == true) ? selected : notSelected,
              onPressed: () {
                setState(() {
                  print_publication = false;
                  print_commentaire = true;
                  print_propos = false;
                });
              },
            ),
            TextButton(
              child: Text("À propos"),
              style: (print_propos == true) ? selected : notSelected,
              onPressed: () {
                setState(() {
                  print_publication = false;
                  print_commentaire = false;
                  print_propos = true;
                });
              },
            ),
          ],
        ),
        Stack(
          children: [
            print_publication == true
                ? Text("mets les publications")
                : Text(""), // je savais pas quoi mettre
            print_commentaire == true ? Text("mets les coms") : Text(""),
            print_propos == true ? Text("mets le a propos") : Text(""),
          ],
        )
      ]),
    );
  }
}
