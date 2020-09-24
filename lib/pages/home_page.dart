import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final String SERVER = 'http://35.201.162.120:5000';

var d = ["發現不明人物", "發現人物沒有戴口罩", "發現不明人物", "發現人物沒有戴口罩"];

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 32, left: 16, bottom: 16),
                    child: Text(
                      "最近通知",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              Expanded(child: NotificationContainer())
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationContainer extends StatefulWidget {
  NotificationContainer({Key key}) : super(key: key);
  @override
  _NotificationContainer createState() => _NotificationContainer();
}

class _NotificationContainer extends State<NotificationContainer> {
  List<NotificationEntity> noti = [];
  _fetchData() async {
    setState(() {});
    Map result = {};
    print(SERVER + "/show_noti");
    final response = await http.get(SERVER + "/show_noti");
    if (response.statusCode == 200) {
      try {
        result = jsonDecode(response.body);
      } catch (e) {
        print(e);
      }
    }
    for (var item in result['notification']) {
      if (item['imageURL'] == '') {
        item['imageURL'] =
            "https://storage.googleapis.com/superb-binder-287603.appspot.com/test/ar00.png";
      }
      if (item['imageURL'][0] == '"') {
        item['imageURL'] =
            item['imageURL'].substring(1, item['imageURL'].length - 1);
      }
      addDynamic(item['type'], item['time'], item['content'], item['imageURL']);
    }
  }

  @override
  void initState() {
    this._fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final _screenSize = MediaQuery.of(context).size;
    return Container(
      width: _screenSize.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
              child: ListView.builder(
            shrinkWrap: true,
            itemCount: noti.length,
            itemBuilder: (_, int index) => noti[index],
          ))
        ],
      ),
    );
  }

  addDynamic(String type, String time, String content, String imgURL) {
    noti.add(new NotificationEntity(type, time, content, imgURL));
    setState(() {});
  }
}

class NotificationEntity extends StatelessWidget {
  String type = '';
  String time = '';
  String content = '';
  String imgURL =
      'https://www.polytec.com.au/img/products/960-960/white-magnetic.jpg';
  NotificationEntity(String type, String time, String content, String imgURL) {
    this.type = type;
    this.time = time;
    this.content = content;
    this.imgURL = imgURL;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () => {print(this.content)},
        child: Card(
            child: Padding(
                padding: EdgeInsets.only(top: 32, left: 16, bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(this.content),
                    Image(
                      image: NetworkImage(this.imgURL),
                      height: 50,
                    )
                  ],
                ))),
      ),
    );
  }
}
