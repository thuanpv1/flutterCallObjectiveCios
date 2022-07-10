#import "FLNativeView.h"
#import "PreviewViewController.h"
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
          UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
          textView.text = @"HIHI";
          textView.textColor = [UIColor blueColor];
          textView.font = [UIFont systemFontOfSize:12.0];
          textView.backgroundColor = [UIColor yellowColor];
//          [_view addSubview:textView];
      
      
          int indexOfArray = 0; //The index of the current device and the array
          
          PreviewViewController *vc = [[PreviewViewController alloc] initWithDevices:self.devices atDeviceIndex:indexOfArray];
          vc.hidesBottomBarWhenPushed = YES;
//          [self.navigationController pushViewController:vc animated:YES];
          [_view addSubview:vc.view];
  }
  return self;
}

- (UIView*)view {
//    textView.scrollEnabled = YES;
//    textView.alwaysBounceVertical = YES;
//    textView.editable = YES;
//    textView.clipsToBounds = YES;
//    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
//    textView.keyboardType = UIKeyboardTypeDefault;
//    [textView setText:@"hihihihihihi"];
//    [textView setFont:[UIFont fontWithName:@"ArialMT" size:16]];
//    textView.text = @"hihi";
//    textView.font = [[UIFont alloc] init];
  return _view;
}
-(NSMutableArray *)devices{
    if (!_devices) {
        _devices = [NSMutableArray array];
        
        // NVDevice *device = [[NVDevice alloc] init];
        // [device setDevID:24430289];
        // device.strUsername = @"admin";
        // device.strPassword = @"aaaa1111.";
        // device.strName = @"";
        // device.nAddType = ADD_TYPE_HANDMAKE;
        // device.strServer = @"192.168.1.1";
        // device.nPort = 8800;
        
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
