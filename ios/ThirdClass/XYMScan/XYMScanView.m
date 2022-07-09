//
//  XYMScanView.m
//
//  Created by jack xu on 16/11/16.
//  Copyright © 2016年 jack xu All rights reserved.
//

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height


#import "XYMScanView.h"
#import <AVFoundation/AVFoundation.h>


@interface XYMScanView ()<AVCaptureMetadataOutputObjectsDelegate>{
    AVCaptureSession * session;//Intermediate bridge between input and output
    int line_tag;
    UIView *highlightView;
    NSString *scanMessage;
    BOOL isRequesting;
}

@property (nonatomic,strong) UIView *leftView;
@property (nonatomic,strong) UIView *rightView;
@property (nonatomic,strong) UIView *upView;
@property (nonatomic,strong) UIView *downView;
@property (nonatomic,strong) UIImageView *centerView; //scan frame
@property (nonatomic,strong) UIImageView *line; //scan line
@property (nonatomic,strong) UILabel *tipLb;//Tips add by weibin 20181114

@end



@implementation XYMScanView

@synthesize delegate;

- (instancetype)init{
    
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

/**
 * No matter which init or initWithFrame is called, it will come here
 */
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self =[super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

/**
 * initialize
 */
- (void)setUp{
    [self instanceDevice];
}


/**
 * Set the width of the scan code box
 */
-(void)setScanW:(int)scanW{
    
    _scanW = scanW;
    
    [self layoutSubviews];
}

/**
 * Configure camera properties
 */
- (void)instanceDevice{
    
    line_tag = 10000 + 1116; //0-99 for the system

    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    session = [[AVCaptureSession alloc]init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if (input) {
        
        [session addInput:input];
    }
    if (output) {
        
        [session addOutput:output];
        NSMutableArray *a = [[NSMutableArray alloc] init];
        
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [a addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [a addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [a addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [a addObject:AVMetadataObjectTypeCode128Code];
        }
        output.metadataObjectTypes=a;
    }
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.layer.bounds;
    [self.layer insertSublayer:layer atIndex:0];
    
    [self setOverlayPickerView];
    
    [session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
    
    [session startRunning];
}

/**
 *  Monitor scan code status - modify scan animation
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    
    if ([object isKindOfClass:[AVCaptureSession class]]) {
        
        BOOL isRunning = ((AVCaptureSession *)object).isRunning;
        if (isRunning) {
            
            [self addAnimation];
        }else{
            [self removeAnimation];
        }
    }
}


/**
 *  Get scan result
 */
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {

        [self stopRunning];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex :0];
        
        //output scan string
        NSString *data = metadataObject.stringValue;
        
        if (data) {
//            NSLog(@"%@",data);

            scanMessage = data;
            
            if(delegate && [delegate respondsToSelector:@selector(getScanDataString:)])
            {
                [delegate getScanDataString:scanMessage];
            }
//            NSLog(@"%@",scanMessage);
        }
    }
}



/**
* Create scan code page
 */
- (void)setOverlayPickerView{
    //The view on the left was originally 30 wide
    UIView *leftView = [[UIView alloc]init];
    leftView.alpha = 0.5;
    leftView.backgroundColor = [UIColor blackColor];
//    [self addSubview:leftView];
    _leftView = leftView;
    
    // view on the right
    UIView *rightView = [[UIView alloc]init];
    rightView.alpha = 0.5;
    rightView.backgroundColor = [UIColor blackColor];
    [self addSubview:rightView];
//    _rightView = rightView;
    
// top view
    UIView *upView = [[UIView alloc]init];
    upView.alpha = 0.5;
    upView.backgroundColor = [UIColor blackColor];
// [self addSubview:upView];
    _upView = upView;
    
    // bottom view
    UIView *downView = [[UIView alloc]init];
    downView.alpha = 0.5;
    downView.backgroundColor = [UIColor blackColor];
//    [self addSubview:downView];
    _downView = downView;
    
    UIImageView *centerView = [[UIImageView alloc]init];
//The stretching of the scan frame picture, stretching the middle area
    UIImage *scanImage = [UIImage imageNamed:@"hs_img_scanbox"];
    CGFloat top = 34*0.5-1; // top cap height
    CGFloat bottom = top ; // Bottom end cap height
    CGFloat left = 34*0.5-1; // left end cap width
    CGFloat right = left; // right end cap width
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    scanImage = [scanImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    
    centerView.image = scanImage;
    centerView.contentMode = UIViewContentModeScaleAspectFit;
    centerView.backgroundColor = [UIColor clearColor];
//    [self addSubview:centerView];
    _centerView = centerView;
    
    //scan line
    UIImageView *line = [[UIImageView alloc]init];
    line.tag = line_tag;
    line.image = [UIImage imageNamed:@"scanline"];
    line.contentMode = UIViewContentModeScaleAspectFill;
    line.backgroundColor = [UIColor clearColor];
    line.clipsToBounds = YES;
    [self addSubview:line];
    _line = line;
    
    if (!_hiddenTipLb) {
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.backgroundColor = [UIColor clearColor];
        // tipLabel.text = NSLocalizedString(@"lbTipAlignQRCode", @"Put the QR code in the box to scan automatically");
        tipLabel.text = NSLocalizedString(@"Scan QR code", @"Scan QR code");
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = [UIFont systemFontOfSize:16];
        tipLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:tipLabel];
        _tipLb = tipLabel;
    }
    
    [self layoutSubviews];
}


- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    if(self.scanW){
        
    }else{
        
        self.scanW = 250;
    }
    
    //扫描框的宽
    CGFloat scanViewW = self.scanW;
    
    //The view on the left was originally 30 wide
    _leftView.frame = CGRectMake(0, 0, (ScreenWidth - scanViewW) * 0.5, self.frame.size.height);
    // view on the right
    _rightView.frame = CGRectMake(self.frame.size.width-((ScreenWidth - scanViewW) * 0.5), 0, (ScreenWidth - scanViewW) * 0.5, self.frame.size.height);
    // top view
    _upView.frame = CGRectMake((ScreenWidth - scanViewW) * 0.5, 0, scanViewW, 150);
    // bottom view
    _downView.frame = CGRectMake((ScreenWidth - scanViewW) * 0.5, CGRectGetMaxY(_upView.frame) + scanViewW, scanViewW, ScreenHeight - (CGRectGetMaxY(_upView.frame) + scanViewW));
    // scan code box
    _centerView.frame = CGRectMake(CGRectGetMaxX(_leftView.frame), CGRectGetMaxY(_upView.frame), scanViewW, scanViewW);
    //scan line
    _line.frame = CGRectMake((ScreenWidth - scanViewW) * 0.5, CGRectGetMaxY(_upView.frame), scanViewW, 2);
    //add by weibin 20181114
    _tipLb.frame = CGRectMake(0, ScreenHeight - 200, ScreenWidth, 35);
    //add end by weibin 20181114
}

/**
flash switch
*/
-(void)openFlash{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    if ([captureDevice hasTorch]) {
        BOOL locked = [captureDevice lockForConfiguration:&error];
        if (locked) {
            captureDevice.torchMode = AVCaptureTorchModeOn;
            [captureDevice unlockForConfiguration];
        }
    }
}

-(void)closeFlash{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

/**
 *  Add scan code animation
 */
- (void)addAnimation{
    
    UIView *line = [self viewWithTag:line_tag];
    line.hidden = NO;
    CABasicAnimation *animation = [XYMScanView moveYTime:2 fromY:[NSNumber numberWithFloat:4] toY:[NSNumber numberWithFloat:self.scanW -2] rep:OPEN_MAX];
    [line.layer addAnimation:animation forKey:@"LineAnimation"];
}

+ (CABasicAnimation *)moveYTime:(float)time fromY:(NSNumber *)fromY toY:(NSNumber *)toY rep:(int)rep{
    
    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [animationMove setFromValue:fromY];
    [animationMove setToValue:toY];
    animationMove.duration = time;
    animationMove.delegate = self;
    animationMove.repeatCount  = rep;
    animationMove.fillMode = kCAFillModeForwards;
    animationMove.removedOnCompletion = NO;
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animationMove;
}


/**
 *  Remove scan code animation
 */
- (void)removeAnimation{
    
    UIView *line = [self viewWithTag:line_tag];
    [line.layer removeAnimationForKey:@"LineAnimation"];
    line.hidden = YES;
}

/**
 * Start scanning
 */
- (void)startRunning{

    [session startRunning];
}

/**
 * End scan code
 */
- (void)stopRunning{
    
    [session stopRunning];
}


/**
 * remove monitor
 */
- (void)dealloc{
    
    [session removeObserver:self forKeyPath:@"running"];
}


@end
