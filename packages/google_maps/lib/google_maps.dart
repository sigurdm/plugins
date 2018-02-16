import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

final MethodChannel _channel =
    const MethodChannel('plugins.flutter.io/google_maps')..invokeMethod('init');

class MapController {
  final Size size;
  int _textureId;
  MapController({@required this.size});
  Future<Null> initialize() async {
    _textureId = await _channel.invokeMethod(
      'create',
      {'width': size.width, 'height': size.height},
    );
  }

  static Future<Null> provideApiKey(String key) async {
    await _channel.invokeMethod("provideApiKey", {"key": key});
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
          : new Texture(
              textureId: controller._textureId,
            ),
    );
  }
}
