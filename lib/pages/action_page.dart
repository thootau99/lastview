import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final String SERVER = 'http://35.201.162.120:5000/';

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
                child: Text("TAKEOFF"),
              ),
            ),
            FlatButton(
              onPressed: () {
                var url = SERVER + "new_data?ins=land";
                http.get(url);
              },
              child: Text("LAND"),
            ),
            FlatButton(
              onPressed: () {
                var url = SERVER + "stopwork";
                http.get(url);
              },
              child: Text("STOP"),
            ),
            FlatButton(
              onPressed: () {
                var url = SERVER + "startwork";
                http.get(url);
              },
              child: Text("START"),
            ),
            FlatButton(
              onPressed: () {
                String setname = SERVER + "mask";
                http.get(setname);
              },
              child: Text("MASK"),
            ),
            FlatButton(
              onPressed: () {
                String setname = SERVER + "normal";
                http.get(setname);
              },
              child: Text("NORMAL"),
            ),
            FlatButton(
              onPressed: _fetchData,
              child: new Icon(Icons.add),
            ),
          ],
        ),
      ),
      floatingActionButton:
          new FloatingActionButton(onPressed: null, child: new Icon(Icons.add)),
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
