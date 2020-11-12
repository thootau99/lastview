import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_stackview/cupertino_stackview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:overlay_support/overlay_support.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

final String SERVER = 'http://35.201.162.120:5000';

var d = ["發現不明人物", "發現人物沒有戴口罩", "發現不明人物", "發現人物沒有戴口罩"];
CollectionReference newupload =
    FirebaseFirestore.instance.collection('newupload');

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: SafeArea(
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Row(
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
              ),
              Expanded(child: NotificationContainer())
            ],
          ),
        ],
      ),
    ));
  }
}

class NotificationContainer extends StatefulWidget {
  NotificationContainer({Key key}) : super(key: key);
  @override
  _NotificationContainer createState() => _NotificationContainer();
}

class NotificationItem {
  String id;

  NotificationItem({this.id});

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();

    m['title'] = id;

    return m;
  }
}

class NotificationItems {
  List<NotificationItem> items = [];
  NotificationsItems() {
    items = new List();
  }

  toJSONEncodable() {
    return items.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }
}

class _NotificationContainer extends State<NotificationContainer> {
  final LocalStorage storage = new LocalStorage('notification');
  final NotificationItems list = new NotificationItems();
  List<NotificationEntity> noti = [];
  Future<Null> _refresh() async {
    await _fetchData();
    setState(() {});
    return;
  }

  _saveToStorage() {
    storage.setItem('notification', list.toJSONEncodable());
  }

  _addItem(String id) {
    setState(() {
      final item = new NotificationItem(id: id);
      list.items.add(item);
      _saveToStorage();
    });
  }

  _fetchData() async {
    Map result = {};
    List<NotificationEntity> _noti = this.noti;
    final response = await http.get(SERVER + "/show_noti");
    if (response.statusCode == 200) {
      try {
        result = jsonDecode(response.body);
      } catch (e) {
        print(e);
      }
    }
    var ids = [];
    var alreadyIntities = [];
    var newnoti = false;
    for (var i in list.items) {
      ids.add(i.id);
    }
    for (var intity in _noti) {
      alreadyIntities.add(intity.id);
    }
    // result['notification'] = result['notification'].reversed.toList();
    for (var item in result['notification']) {
      if (alreadyIntities.contains(item['id'])) {
        continue;
      }
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
      addDynamic(item['id'], item['type'], item['time'], item['content'],
          item['imageURL']);
      if (ids.contains(item['id'])) {
        newnoti = false;
      } else {
        newnoti = true;
        _addItem(item['id']);
      }
    }
    setState(() {});

    if (newnoti) {
      shownoti("有新通知");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Timer timer;
  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) {
      _refresh();
    });

    var items = storage.getItem('notification');
    if (items != null) {
      list.items = List<NotificationItem>.from(
        (items as List).map(
          (item) => NotificationItem(
            id: item['title'],
          ),
        ),
      );
    }
    this._fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final _screenSize = MediaQuery.of(context).size;
    return Container(
      width: _screenSize.width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: RefreshIndicator(
                onRefresh: _refresh,
                child: Container(
                    child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: noti.length,
                  itemBuilder: (_, int index) => noti[index],
                ))),
          ),
        ],
      ),
    );
  }

  addDynamic(
      String id, String type, String time, String content, String imgURL) {
    if (noti.length == 0) {
      noti.add(new NotificationEntity(id, type, time, content, imgURL));
    } else {
      noti.insert(0, new NotificationEntity(id, type, time, content, imgURL));
    }
    setState(() {});
  }
}

class NotificationEntity extends StatelessWidget {
  String type = '';
  String time = '';
  String id = '';
  List timeList = [];
  var timeToInt = [];
  List currentTime = [];
  String content = '';
  String imgURL =
      'https://www.polytec.com.au/img/products/960-960/white-magnetic.jpg';
  String timeString = '';
  String filen = '';
  var now = new DateTime.now();
  NotificationEntity(
      String id, String type, String time, String content, String imgURL) {
    this.type = type;
    this.time = time;
    this.id = id;
    this.timeList = this.time.split("/");
    for (var i = 0; i < this.timeList.length; i++) {
      this.timeToInt.add(int.tryParse(this.timeList[i]));
    }
    this.currentTime = [now.year, now.month, now.day];
    this.content = content;
    this.imgURL = imgURL;
    if (this.imgURL.split("/").length != 0) {
      var r = this.imgURL.split("/");
      String result = "";
      result = r[r.length - 1];
      result = result.split("?")[0];
      this.filen = result;
    }
    this.imgURL =
        "https://storage.googleapis.com/superb-binder-287603.appspot.com/test/save/" +
            this.filen;
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
      onTap: () => {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return DetailScreen(url: this.imgURL);
        }))
      },
      child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          child: Card(
            child: Padding(
                padding: EdgeInsets.only(top: 32, left: 16, bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 16, right: 16, bottom: 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: CachedNetworkImage(
                                    imageUrl: this.imgURL,
                                    height: 80,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(this.content,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                      fontSize: 15,
                                    )),
                              ),
                            ],
                          ),
                          Text(
                            this.timeString,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            elevation: 4,
          ),
        )
      ]),
    ));
  }
}

class DetailScreen extends StatefulWidget {
  final String url;
  DetailScreen({Key key, @required this.url})
      : assert(url != null),
        super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  ui.Image image;
  bool isImageloaded = false;
  TextEditingController _c;
  String name = "";
  @override
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    _c = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  _showCupertinoDialog() {
    showDialog(
        context: context,
        builder: (_) => new Dialog(
              child: Column(
                children: <Widget>[
                  new TextField(
                    decoration: new InputDecoration(hintText: "Update Info"),
                    controller: _c,
                  ),
                  new FlatButton(
                    child: new Text("Save"),
                    onPressed: () {
                      setState(() {
                        this.name = _c.text;
                      });
                      newupload.add({"url": widget.url, "name": this.name});
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FlatButton(
            child: Icon(Icons.upload_rounded),
            onPressed: () {
              _showCupertinoDialog();
            },
          )
        ],
      )),
      body: GestureDetector(
        child: Container(
          child: Center(
              child: CachedNetworkImage(
            imageUrl: widget.url,
          )),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

void shownoti(s) {
  showSimpleNotification(Text(s), background: Colors.amber);
}
