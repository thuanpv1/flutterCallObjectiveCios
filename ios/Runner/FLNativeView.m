#import "FLNativeView.h"

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
          [_view addSubview:textView];
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

@end
