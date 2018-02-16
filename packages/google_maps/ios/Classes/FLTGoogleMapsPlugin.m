#import "FLTGoogleMapsPlugin.h"
@import GoogleMaps;

@interface FLTMap : NSObject
-(instancetype)initWithSize:(CGSize)size;
-(CALayer*)layer;
-(UIView*)view;
@end

@implementation FLTMap
{
    GMSMapView *view;
}

- (instancetype)initWithSize:(CGSize)size {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-56.1691902
                                                            longitude:10.1939624
                                                                 zoom:10];
    view = [GMSMapView mapWithFrame:CGRectMake(-size.width, -size.height, size.width, size.height) camera:camera];
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.snippet = @"Hello World";
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = view;
    return self;
}

- (CALayer *)layer {
    return view.layer;
}

-(UIView *)view {
    return view;
}

@end


@interface FLTGoogleMapsPlugin ()
@property(readonly, nonatomic) NSObject<FlutterTextureRegistry>* registry;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger>* messenger;
@property(readonly, nonatomic) NSMutableDictionary* maps;
@end


@implementation FLTGoogleMapsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.flutter.io/google_maps"
            binaryMessenger:[registrar messenger]];
    FLTGoogleMapsPlugin* instance = [[FLTGoogleMapsPlugin alloc] initWithRegistry:[registrar textures] messenger:
                                     [registrar messenger]];

  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry>*)registry
                       messenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    _registry = registry;
    _messenger = messenger;
    _maps = [NSMutableDictionary dictionaryWithCapacity:1];
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
      for (NSNumber* textureId in _maps) {
          [_registry unregisterTexture:[textureId unsignedIntegerValue]];
         // [[_maps objectForKey:textureId] dispose];
      }
      [_maps removeAllObjects];
      result(nil);
  } else if ([@"provideAPIKey" isEqualToString:call.method]) {
      NSDictionary* argsMap = call.arguments;
      [GMSServices provideAPIKey:argsMap[@"key"]];
      result(nil)
  } else if ([@"create" isEqualToString:call.method]) {
      NSDictionary* argsMap = call.arguments;
      NSNumber* width = argsMap[@"width"];
      NSNumber* height = argsMap[@"height"];
      FLTMap *map = [[FLTMap alloc] initWithSize:CGSizeMake(width.floatValue, height.floatValue)];
      int64_t textureId = [_registry registerLayer: [map layer]];
      _maps[@(textureId)] = map;
      UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
      [rootView addSubview: [map view]];
      result(@(textureId));
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
