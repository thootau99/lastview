import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:localstorage/localstorage.dart';

final String SERVER = 'https://xiang.shirinmi.io/';

class ActionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String minutes = "";
  _fetchData() async {
    setState(() {});
    String result = '';
    final response = await http.get(SERVER + "get_face");
    if (response.statusCode == 200) {
      try {
        result = json.decode(response.body);
      } catch (e) {
        print(e);
      }
    }
    var listOfResult = result.split("_");
    facenameList.clear();
    for (final e in listOfResult) {
      addDynamic(e);
    }
  }

  List<DynamicFaceNameWidget> facenameList = [];

  addDynamic(String name) {
    facenameList.add(new DynamicFaceNameWidget(name));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: facenameList.length,
                  itemBuilder: (_, index) => facenameList[index]),
            ),
            new Flexible(
              flex: 1,
              child: FlatButton(
                onPressed: () {
                  var url = SERVER + "new_data?ins=takeoff";
                  http.get(url);
                },
                child: Text(
                  "TAKEOFF",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                var url = SERVER + "new_data?ins=land";
                http.get(url);
              },
              child: Text("LAND", style: TextStyle(fontSize: 20)),
            ),
            FlatButton(
              onPressed: () {
                var url = SERVER + "stopwork";
                http.get(url);
              },
              child: Text("STOP", style: TextStyle(fontSize: 20)),
            ),
            FlatButton(
              onPressed: () {
                var url = SERVER + "startwork";
                http.get(url);
              },
              child: Text("START", style: TextStyle(fontSize: 20)),
            ),
            FlatButton(
              onPressed: () async {
                final text = await showTextInputDialog(
                  context: context,
                  textFields: const [
                    DialogTextField(),
                  ],
                  title: 'Enter time in mintue',
                  message: 'The drone will fly after the time',
                );

                String setname = SERVER + "timer?time=" + text[0];
                http.get(setname);
              },
              child: Text("TIMER", style: TextStyle(fontSize: 20)),
            ),
            FlatButton(
              onPressed: () {
                String setname = SERVER + "normal";
                http.get(setname);
              },
              child: Text("NORMAL", style: TextStyle(fontSize: 20)),
            ),
            FlatButton(
              onPressed: _fetchData,
              child: new Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

class DynamicFaceNameWidget extends StatelessWidget {
  String name = '';
  DynamicFaceNameWidget(String s) {
    this.name = s;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: new FlatButton(
          onPressed: () {
            String setname = SERVER + "set_face_from_app?facename=" + name;
            http.get(setname);
          },
          child: Text("$name")),
    );
  }
}
