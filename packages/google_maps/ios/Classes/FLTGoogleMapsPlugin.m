#import "FLTGoogleMapsPlugin.h"
@import GoogleMaps;

@interface FLTMap : NSObject
-(instancetype)initWithSize:(CGSize)size
                   latitude:(double)latitude
                  longitude:(double)longitude
                       zoom:(double)zoom;
-(CALayer*)layer;
-(UIView*)view;
-(void)gotoLatitude:(double)latitude longitude:(double)longitude zoom:(double)zoom;
-(void)addMarkerAtLatitude:(double)latitude longitude:(double)longitude snippet:(NSString*)snippet;

@end

@implementation FLTMap
{
    GMSMapView *view;
  //  DrawDelegate *drawDelegate;
}

-(void)addMarkerAtLatitude:(double)latitude longitude:(double)longitude snippet:(NSString *)snippet {
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(latitude, longitude);
    marker.snippet = snippet;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = view;
    
}

-(void)gotoLatitude:(double)latitude longitude:(double)longitude zoom:(double)zoom {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                            longitude:longitude
                                                                 zoom:zoom];
    NSLog(@"Map superview %@", view.superview);
    [CATransaction begin];
    [CATransaction setAnimationDuration: 1];
    [view animateToCameraPosition:camera];
    [CATransaction commit];
}

- (instancetype)initWithSize:(CGSize)size latitude:(double)latitude longitude:(double)longitude zoom:(double)zoom{
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                            longitude:longitude
                                                                 zoom:zoom];
    view = [GMSMapView mapWithFrame:CGRectMake(-size.width, -size.height, size.width, size.height) camera:camera];
    view.preferredFrameRate = kGMSFrameRateMaximum;
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
{
    UILabel *v;
}

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
  } else if ([@"provideApiKey" isEqualToString:call.method]) {
      NSDictionary* argsMap = call.arguments;
      [GMSServices provideAPIKey:argsMap[@"key"]];
      result(nil);
  } else if ([@"create" isEqualToString:call.method]) {
      NSDictionary* argsMap = call.arguments;
      NSNumber* width = argsMap[@"width"];
      NSNumber* height = argsMap[@"height"];
      NSNumber *latitude = argsMap[@"latitude"];
      NSNumber *longitude = argsMap[@"longitude"];
      NSNumber *zoom = argsMap[@"zoom"];
      FLTMap *map = [[FLTMap alloc] initWithSize:CGSizeMake(width.floatValue, height.floatValue)
                     latitude:latitude.floatValue
                    longitude:longitude.floatValue
                         zoom:zoom.floatValue];
      v = [[UILabel alloc] initWithFrame: CGRectMake(10.0, 10.0, 100.0, 100.0)];
      v.text = @"Heh";
      int64_t textureId = [_registry registerUIView: [map view]];
      _maps[@(textureId)] = map;
      result(@(textureId));
  } else {
      NSDictionary* argsMap = call.arguments;
      int64_t textureId = ((NSNumber*)argsMap[@"textureId"]).unsignedIntegerValue;
      FLTMap* map = _maps[@(textureId)];
      
      if ([@"dispose" isEqualToString:call.method]) {
          // TODO
      } else if ([@"addMarker" isEqualToString:call.method]) {
          NSNumber *latitude = argsMap[@"latitude"];
          NSNumber *longitude = argsMap[@"longitude"];
          NSString *snippet = argsMap[@"snippet"];
          [map addMarkerAtLatitude:latitude.floatValue longitude:longitude.floatValue snippet:snippet];
      } else if ([@"goto" isEqualToString:call.method]) {
          NSNumber *latitude = argsMap[@"latitude"];
          NSNumber *longitude = argsMap[@"longitude"];
          NSNumber *zoom = argsMap[@"zoom"];
          [map gotoLatitude: latitude.doubleValue longitude:longitude.doubleValue zoom:zoom.doubleValue];
      } else {
          result(FlutterMethodNotImplemented);
      }
  }
}

@end
