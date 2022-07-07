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
@end
