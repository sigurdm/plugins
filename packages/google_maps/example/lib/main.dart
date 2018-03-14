import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps/google_maps.dart';
import 'api_key.dart';

MapController mapController;

Location aarhus = new Location(
  latitude: 56.172481,
  longitude: 10.187329,
);

Location mountainView = new Location(
  latitude: 37.420924,
  longitude: -122.083666,
);

List<Location> locations = [aarhus, mountainView];

void main() async {
  mapController = new MapController(
      size: const Size(200.0, 200.0),
      initialPosition: new CameraPosition(location: locations[0], zoom: 10.0));
  await MapController.provideApiKey(api_key);
  await mapController.initialize();
  mapController.addMarker(location: aarhus, snippet: "Aarhus");
  mapController.addMarker(location: mountainView, snippet: "Mountain View");
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
          style: const TextStyle(color: Colors.blue),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  int locationIndex = 0;

  _MyAppState();

  @override
  Widget build(BuildContext context) {
    final Matrix4 scale = new Matrix4.identity()
//    ..scale(2.0, 1.0)
        // ..rotateZ(PI * .1)
        ; //..rotateZ(PI);;//..rotateZ(PI);//..scale(2.0);

    return new MaterialApp(
      //  debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Scaffold(
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            final Location oldLocation = locations[locationIndex];
            locationIndex = (locationIndex + 1) % locations.length;

            final Location newLocation = locations[locationIndex];
            mapController.goto(new CameraPosition(
              location: oldLocation,
              zoom: 4.0,
            ));
            new Future<Null>.delayed(const Duration(milliseconds: 1000))
                .then((_) {
              mapController.goto(new CameraPosition(
                location: newLocation,
                zoom: 4.0,
              ));
            });
            new Future<Null>.delayed(const Duration(milliseconds: 2000))
                .then((_) {
              mapController.goto(new CameraPosition(
                location: newLocation,
                zoom: 11.0,
              ));
            });
          },
          child: new Icon(Icons.airplanemode_active),
        ),
        appBar: new AppBar(
          title: const Text("Google maps example"),
        ),
        drawer: const Drawer(
            child: const Center(
                child: const Text(
          "Drawer",
          style: const TextStyle(fontSize: 18.0),
        ),),),
        body: new Column(
          children: <Widget>[
            new Expanded(
              child: new ListView(
                children: <Widget>[
                  makeCard("Google"),
                  makeCard("Maps"),
                  makeCard("Inline"),
                  makeCard("Widget"),
                  new Transform(
                    transform: scale,
                    child: new Container(
                      margin: const EdgeInsets.all(4.0),
                      child: new Material(
                        type: MaterialType.card,
                        elevation: 2.0,
                        borderRadius:
                            const BorderRadius.all(const Radius.circular(10.0)),
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
                  ),
                  makeCard("flow::Layer -> CALayers"),
                  makeCard("Now"),
                  makeCard("Interactive"),
                  new Transform(transform: scale, child: makeCard("!!")),
                  makeCard("H"),
                  makeCard("H"),
                  makeCard("H"),
                  makeCard("H"),
                ],
              ),
            ),
            const Card(
              child: const ListTile(
                title: const Text("Bottom bar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
