#import "FLTGoogleMapsPlugin.h"
@import GoogleMaps;

//@interface DrawDelegate : NSObject<CALayerDelegate>
//-(instancetype)initOnLayer:(CALayer*)layer;
//@end
//
//@implementation DrawDelegate
//{
//    NSObject<CALayerDelegate> *originalDelegate;
//}
//
//-(instancetype)initOnLayer:(CALayer*)layer {
//    self = [super init];
//    originalDelegate = layer.delegate;
//    layer.delegate = self;
//    return self;
//}
//
// -(void)layerWillDraw:(CALayer *)layer {
//   NSLog(@"layerWillDraw %@", layer);
//     [originalDelegate layerWillDraw: layer];
// }
//
//
//- (void)displayLayer:(CALayer *)layer {
//    NSLog(@"displayLayer %@", layer);
//    [originalDelegate displayLayer: layer];
//}
//
//- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
//    [originalDelegate drawLayer:layer inContext:ctx];
//}
//
//
//- (void)layoutSublayersOfLayer:(CALayer *)layer {
//    [originalDelegate layoutSublayersOfLayer:layer];
//}
//
//- (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
//    return [originalDelegate actionForLayer:layer forKey:event];
//}
//
//
//- (void)forwardInvocation:(NSInvocation *)anInvocation
//{
//    if ([originalDelegate respondsToSelector:
//         [anInvocation selector]])
//        [anInvocation invokeWithTarget:originalDelegate];
//    else
//        [super forwardInvocation:anInvocation];
//}
//@end

@interface FLTMap : NSObject
-(instancetype)initWithSize:(CGSize)size;
-(CALayer*)layer;
-(UIView*)view;
-(void)gotoLatitude:(double)latitude longitude:(double)longitude zoom:(double)zoom;
@end

@implementation FLTMap
{
    GMSMapView *view;
  //  DrawDelegate *drawDelegate;
}

-(void)gotoLatitude:(double)latitude longitude:(double)longitude zoom:(double)zoom {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                            longitude:longitude
                                                                 zoom:zoom];
    [CATransaction begin];
    [CATransaction setAnimationDuration: 1];
    [view animateToCameraPosition:camera];
    [CATransaction commit];
}

- (instancetype)initWithSize:(CGSize)size {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:56.172481
                                                            longitude:10.187329
                                                                 zoom:10];
    view = [GMSMapView mapWithFrame:CGRectMake(-size.width, -size.height, size.width, size.height) camera:camera];
    view.preferredFrameRate = kGMSFrameRateMaximum;
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.snippet = @"Hello World";
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = view;
  //  drawDelegate = [[DrawDelegate alloc] initOnLayer: view.layer];
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
  } else if ([@"provideApiKey" isEqualToString:call.method]) {
      NSDictionary* argsMap = call.arguments;
      [GMSServices provideAPIKey:argsMap[@"key"]];
      result(nil);
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
      NSDictionary* argsMap = call.arguments;
      int64_t textureId = ((NSNumber*)argsMap[@"textureId"]).unsignedIntegerValue;
      FLTMap* map = _maps[@(textureId)];
      
      if ([@"dispose" isEqualToString:call.method]) {
          // TODO
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
