import 'package:flutter/material.dart';
import 'package:google_maps/google_maps.dart';

MapController mapController;

void main() async {
  mapController = new MapController(size: new Size(200.0, 200.0));
  await MapController.provideApiKey("!!!!Replace with your API key!!!");
  await mapController.initialize();
  runApp(new MyApp());
}

Widget makeCard(String text) {
  return new Container(
    margin: const EdgeInsets.all(4.0),
    child: new Material(
      type: MaterialType.card,
      borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
      elevation: 2.0,
      child: new ListTile(
        title: new Text(
          text,
          style: new TextStyle(color: Colors.blue),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      //  debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: new ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("Google maps example"),
        ),
        drawer: new Drawer(child: new Text("Drawer")),
        body: new Column(
          children: <Widget>[
            new Expanded(
              child: new ListView(
                children: <Widget>[
                  makeCard("Google"),
                  makeCard("Maps"),
                  makeCard("Inline"),
                  makeCard("Widget"),
                  new Container(
                    margin: const EdgeInsets.all(4.0),
                    child: new Material(
                      type: MaterialType.card,
                      elevation: 2.0,
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(10.0)),
                      key: new GlobalKey(debugLabel: "mapcard"),
                      child: new SizedBox(
                        height: 250.0,
                        child: new Center(
                          child: new Stack(
                            fit: StackFit.loose,
                            children: <Widget>[
                              new MapView(mapController),
                              //         new Text("On top"),
//                                new Column(
//                                  children: <Widget>[
//                                    new Text("Hej"),
////                                    new Image(
////                                        repeat: ImageRepeat.noRepeat,
////                                        height: 200.0,
////                                        image: new NetworkImage(
////                                            'https://flutter.io/images/flutter-mark-square-100.png')),
//                                  ],
//                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  makeCard("flow::Layer -> CALayers"),
                  makeCard("Not"),
                  makeCard("Interactive"),
                  makeCard("Yet"),
                  makeCard("Though"),
                  makeCard("H"),
                  makeCard("H"),
                  makeCard("H"),
                ],
              ),
            ),
            new Card(
              child: new ListTile(
                title: new Text("Bottom bar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
