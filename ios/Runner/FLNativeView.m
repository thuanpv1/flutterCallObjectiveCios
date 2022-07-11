#import "FLNativeView.h"
#import "PreviewViewController.h"
static PreviewViewController *vc = nil;
#define PASSWORD_DEFAULT "Lamgicopass1234";
#define ACCOUNT_DEFAULT "admin";

@implementation FLNativeViewFactory {
  NSObject<FlutterBinaryMessenger>* _messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  self = [super init];
  if (self) {
    _messenger = messenger;
  }
  return self;
}
- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return FlutterStandardMessageCodec.sharedInstance;
}
- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
  return [[FLNativeView alloc] initWithFrame:frame
                              viewIdentifier:viewId
                                   arguments:args
                             binaryMessenger:_messenger];
}

@end

@implementation FLNativeView {
   UIView *_view;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  if (self = [super init]) {
         _view = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
         _view.backgroundColor = [UIColor redColor];
          NSLog(@"running to hre ok================");
          NSString *serial = [args objectForKey:@"serial"];
          NSArray *listItems = [serial componentsSeparatedByString:@"|"];
          if (!_devices) {
              _devices = [NSMutableArray array];
          }
          for (id object in listItems) {
              // do something with object
              NVDevice *device1 = [[NVDevice alloc] init];
              [device1 setDevID:[object integerValue]];
              device1.strUsername = @ACCOUNT_DEFAULT;
              device1.strPassword = @PASSWORD_DEFAULT;
              device1.strName = object;
              device1.nAddType = ADD_TYPE_HANDMAKE;
              device1.strServer = @"192.168.1.1";
              device1.nPort = 8800;
              [_devices addObject:device1];
          }
          NSLog(@"serial ===%@", serial);

          int indexOfArray = 0; //The index of the current device and the array
          
          vc = [[PreviewViewController alloc] initWithDevices:self.devices atDeviceIndex:indexOfArray];
          vc.hidesBottomBarWhenPushed = YES;
          //[self.navigationController pushViewController:vc animated:YES];
          [_view addSubview:vc.view];
  }
  return self;
}

- (UIView*)view {
  return vc.view;
}
@end
