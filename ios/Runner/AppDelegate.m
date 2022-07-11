#import "AppDelegate.h"
#import "FLNativeView.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    NSObject<FlutterPluginRegistrar>* registrar = [self registrarForPlugin:@"plugin-name"];
    FLNativeViewFactory* factory = [[FLNativeViewFactory alloc] initWithMessenger:registrar.messenger];
    [[self registrarForPlugin:@"<plugin-name>"] registerViewFactory:factory withId:@"<platform-view-type>"];
    
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;

    FlutterMethodChannel* batteryChannel = [FlutterMethodChannel methodChannelWithName:@"samples.flutter.dev/battery" binaryMessenger:controller.binaryMessenger];
    [batteryChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      // This method is invoked on the UI thread.
        if ([@"getBatteryLevel" isEqualToString:call.method]) {
            int batteryLevel = [self getBatteryLevel];

            if (batteryLevel == -1) {
              result([FlutterError errorWithCode:@"UNAVAILABLE" message:@"Battery level not available." details:nil]);
            } else {
              result(@(batteryLevel));
            }
          } else if ([@"playMultimedia" isEqualToString:call.method]) {
            // play video here
//            vc = [[PreviewViewController alloc] initWithDevices:self.devices atDeviceIndex:0];
//            vc.hidesBottomBarWhenPushed = YES;
//              teststatic = teststatic + 1;
            
          } else {
            result(FlutterMethodNotImplemented);
          }
      // TODO
    }];
    
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (int)getBatteryLevel {
  UIDevice* device = UIDevice.currentDevice;
  device.batteryMonitoringEnabled = YES;
  if (device.batteryState == UIDeviceBatteryStateUnknown) {
    return -1;
  } else {
    return (int)(device.batteryLevel * 100);
  }
}

-(NSMutableArray *)devices{
    if (!_devices) {
        _devices = [NSMutableArray array];
        
        NVDevice *device1 = [[NVDevice alloc] init];
        [device1 setDevID:54110161];
        device1.strUsername = @"admin";
        device1.strPassword = @"Lamgicopass1234";
        device1.strName = @"";
        device1.nAddType = ADD_TYPE_HANDMAKE;
        device1.strServer = @"192.168.1.1";
        device1.nPort = 8800;
        
        NVDevice *device2 = [[NVDevice alloc] init];
        [device2 setDevID:55685723];
        device2.strUsername = @"admin";
        device2.strPassword = @"Lamgicopass1234";
        device2.strName = @"";
        device2.nAddType = ADD_TYPE_HANDMAKE;
        device2.strServer = @"192.168.1.1";
        device2.nPort = 8800;
        
        // [_devices addObject:device];
        [_devices addObject:device1];
        [_devices addObject:device2];
        
    }
    return _devices;
}
@end
