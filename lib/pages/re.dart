import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  ImageProvider provider;
  bool loaded;
  bool error;

  @override
  void initState() {
    super.initState();

    loaded = false;
    error = false;
    provider = NetworkImage(
        'https://upload.wikimedia.org/wikipedia/commons/4/47/PNG_transparency_demonstration_1.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Image(image: provider),
            Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 77.0,
                  height: 77.0,
                  color: colorByState(),
                ))
          ],
        ),
      ),
    );
  }

  Color colorByState() {
    if (error) {
      return Colors.red;
    } else if (loaded) {
      return Colors.green;
    } else {
      return Colors.yellow;
    }
  }
}
