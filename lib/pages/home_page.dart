import 'package:flutter/material.dart';

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
  aaaa() {
    setState(() {});
    for (var i in d) {
      addDynamic(i);
    }
    print(noti);
  }

  @override
  void initState() {
    this.aaaa();
  }

  @override
  Widget build(BuildContext context) {
    final _screenSize = MediaQuery.of(context).size;
    return Container(
      width: _screenSize.width,
      child: Row(
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

  addDynamic(String name) {
    noti.add(new NotificationEntity(name));
    setState(() {});
  }
}

class NotificationEntity extends StatelessWidget {
  String name = '';
  NotificationEntity(String s) {
    this.name = s;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () => {print(this.name)},
        child: Card(
            child: Padding(
                padding: EdgeInsets.only(top: 32, left: 16, bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(this.name),
                    Image(
                      image: NetworkImage(
                          'https://pbs.twimg.com/profile_images/504715443479670784/fauyuPDy_400x400.png'),
                      height: 50,
                    )
                  ],
                ))),
      ),
    );
  }
}
