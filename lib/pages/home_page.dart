import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:overlay_support/overlay_support.dart';

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
  Future<Null> _refresh() async {
    setState(() {});
    await _fetchData();
    return;
  }

  _fetchData() async {
    setState(() {});
    Map result = {};
    List<NotificationEntity> _noti = this.noti;
    this.noti = [];
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
      if (item['time'] == null) {
        continue;
      }
      if (item['imageURL'] == '' || item['imageURL'] == null) {
        item['imageURL'] =
            "https://storage.googleapis.com/superb-binder-287603.appspot.com/test/ar00.png";
      }
      if (item['imageURL'][0] == '"') {
        item['imageURL'] =
            item['imageURL'].substring(1, item['imageURL'].length - 1);
      }
      addDynamic(item['type'], item['time'], item['content'], item['imageURL']);
    }

    if (_noti.length == noti.length) {
      return;
    } else {
      shownoti("有新通知");
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
            child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: noti.length,
                  itemBuilder: (_, int index) => noti[index],
                )),
          ),
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
  List timeList = [];
  var timeToInt = [];
  List currentTime = [];
  String content = '';
  String imgURL =
      'https://www.polytec.com.au/img/products/960-960/white-magnetic.jpg';
  String timeString = '';
  var now = new DateTime.now();
  NotificationEntity(String type, String time, String content, String imgURL) {
    this.type = type;
    this.time = time;
    this.timeList = this.time.split("/");
    for (var i = 0; i < this.timeList.length; i++) {
      this.timeToInt.add(int.tryParse(this.timeList[i]));
    }
    this.currentTime = [now.year, now.month, now.day];
    this.content = content;
    this.imgURL = imgURL;
    if (this.currentTime[0] == this.timeToInt[0] &&
        this.currentTime[1] == this.timeToInt[1] &&
        this.currentTime[2] == this.timeToInt[2]) {
      this.timeString = "Today " +
          this.timeToInt[3].toString() +
          ":" +
          this.timeToInt[4].toString();
    } else {
      this.timeString = this.timeToInt[1].toString() +
          '/' +
          this.timeToInt[2].toString() +
          " " +
          this.timeToInt[3].toString() +
          ":" +
          this.timeToInt[4].toString();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
          onTap: () => {shownoti("123")},
          child: Padding(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
            child: Card(
              child: Padding(
                  padding: EdgeInsets.only(top: 32, left: 16, bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 16, right: 16, bottom: 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: Image(
                                    image: NetworkImage(this.imgURL),
                                    height: 80,
                                  ),
                                ),
                              ),
                              Text(this.content,
                                  style: TextStyle(
                                    fontSize: 20,
                                  )),
                            ],
                          ),
                          Text(
                            this.timeString,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  )),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              elevation: 4,
            ),
          )),
    );
  }
}

void shownoti(s) {
  showSimpleNotification(Text(s), background: Colors.amber);
}
