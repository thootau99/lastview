import 'dart:async';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_stackview/cupertino_stackview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:convert';
import 'package:overlay_support/overlay_support.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:photo_view/photo_view.dart';

final String SERVER = 'https://xiang.shirinmi.io';

var d = ["發現不明人物", "發現人物沒有戴口罩", "發現不明人物", "發現人物沒有戴口罩"];
CollectionReference newupload =
    FirebaseFirestore.instance.collection('newupload');
CollectionReference notThatPerson =
    FirebaseFirestore.instance.collection('notthatperson');

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
                  // itemBuilder: (_, int index) => noti[index],
                  itemBuilder: (context, index) {
                    return Dismissible(
                        key: Key(noti[index].id),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(2.0),
                          title: noti[index],
                          trailing: IconButton(
                            icon: Icon(Icons.delete_forever_rounded),
                            onPressed: () {
                              setState(() {
                                var id = noti[index].id;
                                final response =
                                    http.get(SERVER + "/del_noti?id=" + id);
                                noti.removeAt(index);
                              });
                            },
                          ),
                        ));
                  },
                ))),
          ),
        ],
      ),
    );
  }

  addDynamic(
      String id, String type, String time, String content, String imgURL) {
    var _content = jsonDecode(content.replaceAll("'", '"'));
    var c = [];
    var cp = [];
    _content.asMap().forEach((index, item) => {
          if (index % 2 == 0) {c.add(item)} else {cp.add(item)}
        });
    if (noti.length == 0) {
      noti.add(new NotificationEntity(id, type, time, c, cp, imgURL));
    } else {
      noti.insert(0, new NotificationEntity(id, type, time, c, cp, imgURL));
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
  List content = [];
  List contentpath = [];
  String imgURL =
      'https://www.polytec.com.au/img/products/960-960/white-magnetic.jpg';
  String timeString = '';
  String filen = '';
  var now = new DateTime.now();
  NotificationEntity(String id, String type, String time, List content,
      List contentpath, String imgURL) {
    this.type = type;
    this.time = time;
    this.id = id;
    this.timeList = this.time.split("/");
    for (var i = 0; i < this.timeList.length; i++) {
      this.timeToInt.add(int.tryParse(this.timeList[i]));
    }
    this.currentTime = [now.year, now.month, now.day];
    this.content = content;
    this.contentpath = contentpath;
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
          return DetailScreen(
              url: this.imgURL, n: this.content, np: this.contentpath);
        }))
      },
      child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 4, left: 4, right: 0, bottom: 4),
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
                                child: Text(this.content.join("\n"),
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
  final List n;
  final List np;
  DetailScreen({
    Key key,
    @required this.url,
    @required this.n,
    @required this.np,
  })  : assert(url != null),
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
    showCupertinoModalBottomSheet(
        expand: false,
        context: context,
        builder: (context) => new SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.n.length,
                      // itemBuilder: (_, int index) => noti[index],
                      itemBuilder: (context, index) {
                        return FlatButton(
                          child: new Text(widget.n[index] + widget.np[index]),
                          onPressed: () async {
                            final text = await showTextInputDialog(
                              context: context,
                              textFields: const [
                                DialogTextField(),
                              ],
                              title: 'Enter name',
                              message: 'the system will save the name in database',
                            );
                            notThatPerson.add({
                              "path": widget.np[index],
                              "name": widget.n[index],
                              "realname": text[0],
                            });
                            Navigator.pop(context);
                            // showCupertinoModalBottomSheet(
                            //     context: context,
                            //     builder: (_) => new Dialog(
                            //           child: Column(children: <Widget>[
                            //             new TextField(
                            //               decoration: new InputDecoration(
                            //                   hintText: "Update name"),
                            //               controller: _c,
                            //             ),
                            //             new FlatButton(
                            //               child: new Text("upload"),
                            //               onPressed: () {

                            //               },
                            //             )
                            //           ]),
                            //         ));
                          },
                        );
                      })
                ],
              ),
            ));
  }

  _showNotThePerson() {
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
          ),
        ],
      )),
      body: GestureDetector(
        child: Container(
          child: PhotoView(
              imageProvider: CachedNetworkImageProvider(
            widget.url,
          )),
        ),
      ),
    );
  }
}

void shownoti(s) {
  showSimpleNotification(Text(s), background: Colors.amber);
}
