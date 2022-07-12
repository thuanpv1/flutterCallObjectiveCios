#import "FLNativeView.h"
#import "PreviewViewController.h"
#define PASSWORD_DEFAULT "Lamgicopass1234";
#define ACCOUNT_DEFAULT "admin";

PreviewViewController *vc = nil;
NSMutableArray *allDevices = nil;

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
          NSString *viewMode = [args objectForKey:@"viewMode"];
          NSString *isShowToolBtnsTemp = [args objectForKey:@"isShowToolBtns"];
          bool isShowToolBtns = false;
          if ([isShowToolBtnsTemp isEqualToString:@"true"]) {
              isShowToolBtns = true;
          }
          NSNumber *deviceIndexTemp = [args objectForKey:@"deviceIndex"];
          int deviceIndex = 0;
          if (![deviceIndexTemp isEqual:nil]) {
              deviceIndex = [deviceIndexTemp intValue];
          }
          NSString *isMultiViewTemp = [args objectForKey:@"isMultiView"];
          bool isMultiView = false;
          if ([isMultiViewTemp isEqualToString:@"true"]) {
              isMultiView = true;
          }
          NSArray *listItems = [serial componentsSeparatedByString:@"|"];
          if (!_devices) {
              _devices = [NSMutableArray array];
          }
          if (!allDevices) {
              allDevices = [NSMutableArray array];
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
              [allDevices addObject:device1];
          }
          NSLog(@"serial ===%@", serial);

          int indexOfArray = 0; //The index of the current device and the array
          if ([viewMode isEqualToString:@"multi"]) {
              vc = [[PreviewViewController alloc] initViewAllCamera:self.devices atDeviceIndex:deviceIndex isShowToolBtns:isShowToolBtns isMultiView:isMultiView];
          } else {
              vc = [[PreviewViewController alloc] initWithDevices:self.devices atDeviceIndex:indexOfArray];
          }
          vc.hidesBottomBarWhenPushed = YES;
          [_view addSubview:vc.view];
  }
  return self;
}

- (UIView*)view {
  return vc.view;
}
@end
