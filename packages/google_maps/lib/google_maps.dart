import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

final MethodChannel _channel =
    const MethodChannel('plugins.flutter.io/google_maps')..invokeMethod('init');

class Location {
  final double latitude;
  final double longitude;
  Location({this.latitude, this.longitude});
}

class CameraPosition {
  final Location location;
  final double zoom;

  CameraPosition({this.location, this.zoom});
}

class MapValue {
  final CameraPosition position;
  MapValue({this.position});
  MapValue copyWith({CameraPosition location}) {
    return new MapValue(
      position: location ?? this.position,
    );
  }
}

class MapController extends ValueNotifier<MapValue> {
  final Size size;
  int _textureId;

  MapController(
      {@required this.size,
      @required CameraPosition initialPosition})
      : super(new MapValue(position: initialPosition));
  Future<Null> initialize() async {
    _textureId = await _channel.invokeMethod(
      'create',
      <dynamic, dynamic>{
        'width': size.width,
        'height': size.height,
        'latitude': value.position.location.latitude,
        'longitude': value.position.location.longitude,
        'zoom': value.position.zoom
      },
    );
  }

  void goto(CameraPosition position) {
    _channel.invokeMethod("goto", <dynamic, dynamic>{
      "latitude": position.location.latitude,
      "longitude": position.location.longitude,
      "zoom": position.zoom
    });
  }

  void addMarker(
      {Location location, String snippet: ""}) {
    _channel.invokeMethod("addMarker", <dynamic, dynamic>{
      "latitude": location.latitude,
      "longitude": location.longitude,
      "snippet": snippet
    });
  }

  static Future<Null> provideApiKey(String key) async {
    await _channel
        .invokeMethod("provideApiKey", <dynamic, dynamic>{"key": key});
  }
}

class MapView extends StatelessWidget {
  final MapController controller;

  MapView(this.controller);

  @override
  Widget build(BuildContext context) {
    return new SizedBox.fromSize(
      size: controller.size,
      child: (controller._textureId == null)
          ? new Container()
          : new NativeWidget(
              textureId: controller._textureId,
            ),
    );
  }
}
