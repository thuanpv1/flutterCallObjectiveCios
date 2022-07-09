//
//  PreviewChannelUIManager.m
//  demo
//
//  Created by VINSON on 2019/11/27.
//  Copyright © 2019 Macrovideo. All rights reserved.
//

#import "PreviewComponentManager.h"
#import "../Kit/XXtimer.h"
#import "../Kit/XXmacro.h"
#import "../Kit/ButtonSelectShell.h"

#import "XXocUtils.h"
#import <Lottie/Lottie.h>

typedef enum : NSUInteger {
    BatteryStateLongPower,
    BatteryStateUnchargedPowerFull,
    BatteryStateUnchargedPowerHigh,
    BatteryStateUnchargedPowerMiddle,
    BatteryStateUnchargedPowerLow,
    BatteryStateUnchargedPowerLower,
    BatteryStateChargedPowerFull,
    BatteryStateChargedPowerHigh,
    BatteryStateChargedPowerMiddle,
    BatteryStateChargedPowerLow,
    BatteryStateChargedPowerLower,
} BatteryState;

#define FirstRow(number)    (0==index||1==index)
#define FirstColumn(number) (0==index||2==index)

#define ActiveConstraint(array,constraint,temp) \
    temp = constraint; \
    temp.active = YES; \
    [array addObject:temp];

#define CenterAtIndex(single,multi,view,superview,i,temp) \
    [single addObject:[view.centerXAnchor constraintEqualToAnchor:superview.centerXAnchor]];\
    [single addObject:[view.centerYAnchor constraintEqualToAnchor:superview.centerYAnchor]];\
    \
    temp = [NSLayoutConstraint constraintWithItem:view \
                                        attribute:NSLayoutAttributeCenterX \
                                        relatedBy:NSLayoutRelationEqual \
                                           toItem:superview \
                                        attribute:NSLayoutAttributeCenterX \
                                       multiplier:(FirstColumn(i)?0.5:1.5) \
                                         constant:0]; \
    [superview addConstraint:temp]; \
    [multi addObject:temp]; \
    temp.active = YES;\
    temp = [NSLayoutConstraint constraintWithItem:view \
                                        attribute:NSLayoutAttributeCenterY \
                                        relatedBy:NSLayoutRelationEqual \
                                           toItem:superview \
                                        attribute:NSLayoutAttributeCenterY \
                                       multiplier:(FirstRow(i)?0.5:1.5) \
                                         constant:0]; \
    [superview addConstraint:temp]; \
    [multi addObject:temp]; \
    temp.active = YES;\

#define CenterConstantAtIndex(single,multi,view,superview,i,temp,xc,yc) \
    [single addObject:[view.centerXAnchor constraintEqualToAnchor:superview.centerXAnchor]];\
    [single addObject:[view.centerYAnchor constraintEqualToAnchor:superview.centerYAnchor]];\
    \
    temp = [NSLayoutConstraint constraintWithItem:view \
                                        attribute:NSLayoutAttributeCenterX \
                                        relatedBy:NSLayoutRelationEqual \
                                           toItem:superview \
                                        attribute:NSLayoutAttributeCenterX \
                                       multiplier:(FirstColumn(i)?0.5:1.5) \
                                         constant:xc]; \
    [superview addConstraint:temp]; \
    [multi addObject:temp]; \
    temp.active = YES;\
    temp = [NSLayoutConstraint constraintWithItem:view \
                                        attribute:NSLayoutAttributeCenterY \
                                        relatedBy:NSLayoutRelationEqual \
                                           toItem:superview \
                                        attribute:NSLayoutAttributeCenterY \
                                       multiplier:(FirstRow(i)?0.5:1.5) \
                                         constant:yc]; \
    [superview addConstraint:temp]; \
    [multi addObject:temp]; \
    temp.active = YES;

#define LRContains(single,multi,view,superview,i,temp,c) \
    temp = [view.leadingAnchor constraintGreaterThanOrEqualToAnchor:superview.leadingAnchor constant:c]; \
    temp.priority = 500; \
    [single addObject:temp]; \
    temp = [view.trailingAnchor constraintGreaterThanOrEqualToAnchor:superview.trailingAnchor constant:-c]; \
    temp.priority = 500; \
    [single addObject:temp]; \
    \
    temp = [view.leadingAnchor constraintGreaterThanOrEqualToAnchor:(FirstColumn(i)?superview.leadingAnchor:superview.centerXAnchor) constant:c];    \
    temp.priority = 500; \
    [multi addObject:temp]; \
    temp.active = YES;\
    temp = [view.trailingAnchor constraintGreaterThanOrEqualToAnchor:(FirstColumn(i)?superview.centerXAnchor:superview.trailingAnchor) constant:-c]; \
    temp.priority = 500; \
    [multi addObject:temp]; \
    temp.active = YES;\
    \
    [view setContentHuggingPriority:501 forAxis:UILayoutConstraintAxisHorizontal]; \
    [view setContentCompressionResistancePriority:499 forAxis:UILayoutConstraintAxisHorizontal];

@interface PreviewComponentManager()
@property (nonatomic,strong) NSMutableArray *views;
@property (nonatomic,strong) NSMutableDictionary *numberToView;
@property (nonatomic,strong) NSMutableDictionary *numberToVisiable;
@property (nonatomic,strong) NSMutableArray *singleConstraints;
@property (nonatomic,strong) NSMutableArray *multiConstraints;

@property (nonatomic,strong) NSMutableArray *landscapeConstraints;
@property (nonatomic,strong) NSMutableArray *portraitConstraints;

@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) LOTAnimationView *logoView;
@property (nonatomic,strong) UILabel *connectingLabel;
@property (nonatomic,strong) UIButton *connectFailureButton;
@property (nonatomic,strong) UIButton *incorrectButton;

@property (nonatomic, strong) UILabel *thermalMaxTempLabel;
@property (nonatomic,strong) UIButton *flowLabel; // This button cannot be clicked, use the button to facilitate the use of contentEdgeInsets
@property (nonatomic,strong) UILabel *flowOverLabel;
@property (nonatomic,strong) UIButton *flowRechargeButton;

@property (nonatomic,strong) UILabel *offlineLabel;
@property (nonatomic,strong) UIButton *emptyPasswordButton;
@property (nonatomic,strong) UILabel *timestampLabel;
@property (nonatomic,strong) UIButton *wifiButton; // This button cannot be clicked, use the button to facilitate the use of image and text
@property (nonatomic,strong) UIButton *recordButton; // This button cannot be clicked, use button to facilitate the use of image and text

@property (nonatomic,strong) UIButton *cruiseingButton; // This button cannot be clicked, use the button to facilitate the use of image and text

@property (nonatomic,strong) UIView *limitView;

@property (nonatomic,strong) XXtimer *timer;
@property (nonatomic,strong) NSDateFormatter *formatter;
@property (nonatomic,weak) UIView *superview;
@property (nonatomic,assign) int index;
@property (nonatomic,strong) UIView *bottomBar;

@property (nonatomic,assign) BOOL isUninstalled;
@property (nonatomic,strong) UIImageView *batteryRemainingImageView;    // battery capacity
@property (nonatomic,assign) BatteryState batteryState;

@property (nonatomic,strong) NSMutableArray *activeWhenWifiVisabled;
@property (nonatomic,strong) NSMutableArray *activeWhenWifiHidden;
@end

@implementation PreviewComponentManager
-(instancetype)initWithSuperview:(UIView*)superview index:(int)index fitscreenButton:(UIButton*)fitscreenButton bottomBar:(UIView*)bottomBar{
    self = [super init];
    if(self){
        _index = index;
        NSLayoutConstraint *constraintTemp = nil;
        _views = [NSMutableArray new];
        _numberToView = [NSMutableDictionary new];
        _numberToVisiable = [NSMutableDictionary new];
        _singleConstraints = [NSMutableArray new];
        _multiConstraints = [NSMutableArray new];
        _landscapeConstraints = [NSMutableArray new];
        _portraitConstraints = [NSMutableArray new];
        //[bottomBar addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
        
//        // MARK:播放按键
//        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_playButton setImage:[UIImage imageNamed:@"preview_btn_play_white"] forState:UIControlStateNormal];
//        [self addView:_playButton control:PreviewComponentPlay toSuperview:superview];
//        [_playButton addTarget:self action:@selector(onButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
//        CenterAtIndex(_singleConstraints,_multiConstraints,_playButton,superview,index,constraintTemp);
//        [_playButton.widthAnchor constraintEqualToConstant:40].active = YES;
//        [_playButton.heightAnchor constraintEqualToConstant:40].active = YES;
//        _playButton.layer.cornerRadius = 20;
//        _playButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];

        // MARK: icon
        NSString *path = [[NSBundle mainBundle] pathForResource:@"preview_connecting.json" ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:path];
        _logoView = [[LOTAnimationView alloc] initWithContentsOfURL:url];
        _logoView.loopAnimation = YES;
        [_logoView play];
        [self addView:_logoView control:PreviewComponentLogo toSuperview:superview];
        [_logoView.widthAnchor constraintEqualToConstant:28].active = YES;
        [_logoView.heightAnchor constraintEqualToConstant:32].active = YES;
        CenterAtIndex(_singleConstraints, _multiConstraints, _logoView, superview, index, constraintTemp)

        // MARK: Connecting
        _connectingLabel = [self createLabel:@"connecting"];
        [self addView:_connectingLabel control:PreviewComponentConnecting toSuperview:superview];
        [_connectingLabel.topAnchor constraintEqualToAnchor:_logoView.bottomAnchor constant:5].active = YES;
        [_connectingLabel.centerXAnchor constraintEqualToAnchor:_logoView.centerXAnchor].active = YES;
        
        // MARK: connection failed
        _connectFailureButton = [self createButton:@"connection failed"];
        [self addView:_connectFailureButton control:PreviewComponentConnectFaliure toSuperview:superview];
        [_connectFailureButton addTarget:self action:@selector(onButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        CenterAtIndex(_singleConstraints,_multiConstraints,_connectFailureButton,superview,index,constraintTemp)
        LRContains(_singleConstraints, _multiConstraints, _connectFailureButton, superview, index, constraintTemp, 10);

        // MARK: wrong password
        _incorrectButton = [self createButton:@"Incorrect password"];
        [self addView:_incorrectButton control:PreviewComponentIncorrect toSuperview:superview];
        [_incorrectButton addTarget:self action:@selector(onButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        CenterAtIndex(_singleConstraints,_multiConstraints,_incorrectButton,superview,index,constraintTemp);
        LRContains(_singleConstraints, _multiConstraints, _incorrectButton, superview, index, constraintTemp, 10);

        // MARK: Offline
        _offlineLabel = [self createLabel:@"device offline"];
        [self addView:_offlineLabel control:PreviewComponentOffline toSuperview:superview];
        CenterAtIndex(_singleConstraints,_multiConstraints,_offlineLabel,superview,index,constraintTemp)
        LRContains(_singleConstraints, _multiConstraints, _offlineLabel, superview, index, constraintTemp, 10);

       // MARK: empty password
        _emptyPasswordButton = [self createButton:@"empty password"];
        [self addView:_emptyPasswordButton control:PreviewComponentEmptyPassword toSuperview:superview];
        [_emptyPasswordButton addTarget:self action:@selector(onButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        CenterAtIndex(_singleConstraints,_multiConstraints,_emptyPasswordButton,superview,index,constraintTemp)
        LRContains(_singleConstraints, _multiConstraints, _emptyPasswordButton, superview, index, constraintTemp, 10);
        
        // MARK: The highest temperature for thermal imaging
        _thermalMaxTempLabel = [[UILabel alloc] init];
        _thermalMaxTempLabel.font = [UIFont systemFontOfSize:10];
        _thermalMaxTempLabel.textColor = UIColor.whiteColor;
        _thermalMaxTempLabel.textAlignment = NSTextAlignmentCenter;
        [self addView:_thermalMaxTempLabel control:PreviewComponentThermalMaxTemp toSuperview:superview];
        _thermalMaxTempLabel.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        _thermalMaxTempLabel.layer.cornerRadius = 4;
        
        [_thermalMaxTempLabel.widthAnchor constraintEqualToConstant:40].active = YES;
        [_thermalMaxTempLabel.heightAnchor constraintEqualToConstant:20].active = YES;
        
        [_singleConstraints addObject:[_thermalMaxTempLabel.topAnchor constraintEqualToAnchor:superview.topAnchor constant:3]];
        if (@available(iOS 11.0, *)) {
            [_singleConstraints addObject:[_thermalMaxTempLabel.leadingAnchor constraintEqualToAnchor:superview.safeAreaLayoutGuide.leadingAnchor constant:5]];
        } else {
            [_singleConstraints addObject:[_thermalMaxTempLabel.leadingAnchor constraintEqualToAnchor:superview.leadingAnchor constant:5]];
        }
        
        
        
        // MARK: timestamp
        _timestampLabel = [self createLabel:[NSString stringWithFormat:@"%d", index]];
        [self addView:_timestampLabel control:PreviewComponentTimestamp toSuperview:superview];
        _timestampLabel.font = [UIFont systemFontOfSize:10];
        _timestampLabel.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        _timestampLabel.layer.cornerRadius = 4;

        [_singleConstraints addObject:[_timestampLabel.widthAnchor constraintEqualToConstant:136]];
        [_singleConstraints addObject:[_timestampLabel.heightAnchor constraintEqualToConstant:20]];
        [_singleConstraints addObject:[_timestampLabel.topAnchor constraintEqualToAnchor:superview.topAnchor constant:3]];
        if (@available(iOS 11.0, *)) {
            [_singleConstraints addObject:[_timestampLabel.trailingAnchor constraintEqualToAnchor:superview.safeAreaLayoutGuide.trailingAnchor constant:-5]];
        } else {
            [_singleConstraints addObject:[_timestampLabel.trailingAnchor constraintEqualToAnchor:superview.trailingAnchor constant:-5]];
        }

        [_multiConstraints addObject:[_timestampLabel.widthAnchor constraintEqualToConstant:110]];
        [_multiConstraints addObject:[_timestampLabel.heightAnchor constraintEqualToConstant:16]];
        /// Since the timestamp of the fourth channel in the multi-screen appears inexplicably, it will run to the upper left corner. When viewing the constraints at the breakpoint, it is found that there are only constraints of height and width, so add special processing [1]
        constraintTemp = [_timestampLabel.topAnchor constraintEqualToAnchor:(FirstRow(index)?superview.topAnchor:superview.centerYAnchor) constant:3];
        constraintTemp.active = YES;
        [_multiConstraints addObject:constraintTemp];
        constraintTemp = [_timestampLabel.trailingAnchor constraintEqualToAnchor:(FirstColumn(index)?superview.centerXAnchor:superview.trailingAnchor) constant:-5];
        constraintTemp.active = YES;
        [_multiConstraints addObject:constraintTemp];
        /// [1]
        
        // MARK: wifi
        _wifiButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addView:_wifiButton control:PreviewComponentWifi toSuperview:superview];
        _wifiButton.titleLabel.font = [UIFont systemFontOfSize:10];
        _wifiButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _wifiButton.layer.cornerRadius = 8;
        _wifiButton.contentEdgeInsets = UIEdgeInsetsMake(2, 5, 2, 10);
        _wifiButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        
        [_singleConstraints addObject:[_wifiButton.heightAnchor constraintEqualToConstant:16]];
        [_singleConstraints addObject:[_wifiButton.topAnchor constraintEqualToAnchor:superview.topAnchor constant:3]];
        [_singleConstraints addObject:[_wifiButton.leadingAnchor constraintEqualToAnchor:superview.leadingAnchor constant:5]];
        
        [_multiConstraints addObject:[_wifiButton.heightAnchor constraintEqualToConstant:16]];
        [_multiConstraints addObject:[_wifiButton.topAnchor constraintEqualToAnchor:(FirstRow(index)?superview.topAnchor:superview.centerYAnchor) constant:3]];
        [_multiConstraints addObject:[_wifiButton.leadingAnchor constraintEqualToAnchor:(FirstColumn(index)?superview.leadingAnchor:superview.centerXAnchor) constant:5]];
        
       // MARK: battery
        _batteryRemainingImageView = [UIImageView new];
        [self addView:_batteryRemainingImageView control:PreviewComponentBattery toSuperview:superview];
        
        [_singleConstraints addObject:[_batteryRemainingImageView.centerYAnchor constraintEqualToAnchor:_wifiButton.centerYAnchor]];
        [_singleConstraints addObject:[_batteryRemainingImageView.leadingAnchor constraintEqualToAnchor:_wifiButton.trailingAnchor constant:11]];
        
        // Multi-screen is not displayed
//        [_multiConstraints addObject:[_batteryRemainingImageView.centerYAnchor constraintEqualToAnchor:_wifiButton.centerYAnchor]];
//        [_multiConstraints addObject:[_batteryRemainingImageView.leadingAnchor constraintEqualToAnchor:_wifiButton.trailingAnchor constant:8]];
        _batteryState = -1;
        
        self.activeWhenWifiVisabled = [NSMutableArray new];
        [self.activeWhenWifiVisabled addObject:[_batteryRemainingImageView.leadingAnchor constraintEqualToAnchor:_wifiButton.trailingAnchor constant:10]];
        self.activeWhenWifiHidden = [NSMutableArray new];
        [self.activeWhenWifiHidden addObject:[_batteryRemainingImageView.leadingAnchor constraintEqualToAnchor:superview.leadingAnchor constant:10]];
        [NSLayoutConstraint activateConstraints:self.activeWhenWifiHidden];

        // MARK: cruiseing
        _cruiseingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addView:_cruiseingButton control:PreviewComponentCruiseing toSuperview:superview];
//        _cruiseingButton.translatesAutoresizingMaskIntoConstraints = NO;
//        [superview addSubview:_cruiseingButton];
        _cruiseingButton.titleLabel.font = [UIFont systemFontOfSize:9];
        _cruiseingButton.contentEdgeInsets = UIEdgeInsetsMake(2, 5, 2, 5);
       [_cruiseingButton setTitle: @"cruising" forState:UIControlStateNormal];
        [_cruiseingButton setImage:[UIImage imageNamed:@"preview_icon_crusing"] forState:UIControlStateNormal];
        
        [_singleConstraints addObject:[_cruiseingButton.heightAnchor constraintEqualToConstant:16]];
        [_singleConstraints addObject:[_cruiseingButton.trailingAnchor constraintEqualToAnchor:superview.trailingAnchor constant:-3]];
        [_singleConstraints addObject:[_cruiseingButton.bottomAnchor constraintEqualToAnchor:superview.bottomAnchor constant:-50]];
        
        [_multiConstraints addObject:[_cruiseingButton.heightAnchor constraintEqualToConstant:16]];
        [_multiConstraints addObject:[_cruiseingButton.trailingAnchor constraintEqualToAnchor:(FirstColumn(index)?superview.centerXAnchor:superview.trailingAnchor) constant:-3]];
        [_multiConstraints addObject:[_cruiseingButton.bottomAnchor constraintEqualToAnchor:(FirstRow(index)?superview.centerYAnchor:superview.bottomAnchor) constant:-5]];

        // MARK: remaining flow
        _flowLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addView:_flowLabel control:PreviewComponentFlow toSuperview:superview];
        _flowLabel.titleLabel.font = [UIFont systemFontOfSize:10];
        _flowLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _flowLabel.layer.cornerRadius = 4;
        _flowLabel.contentEdgeInsets = UIEdgeInsetsMake(2, 5, 2, 5);

        [_singleConstraints addObject:[_flowLabel.heightAnchor constraintEqualToConstant:20]];
        [_singleConstraints addObject:[_flowLabel.topAnchor constraintEqualToAnchor:_timestampLabel.bottomAnchor constant:3]];
        [_singleConstraints addObject:[_flowLabel.topAnchor constraintGreaterThanOrEqualToAnchor:superview.topAnchor constant:23]];
        if (@available(iOS 11.0, *)) {
            [_singleConstraints addObject:[_flowLabel.trailingAnchor constraintEqualToAnchor:superview.safeAreaLayoutGuide.trailingAnchor constant:-5]];
        } else {
            [_singleConstraints addObject:[_flowLabel.trailingAnchor constraintEqualToAnchor:superview.trailingAnchor constant:-5]];
        }

        [_multiConstraints addObject:[_flowLabel.heightAnchor constraintEqualToConstant:16]];
        [_multiConstraints addObject:[_flowLabel.topAnchor constraintEqualToAnchor:_timestampLabel.bottomAnchor constant:3]];
//        [_multiConstraints addObject:[_flowLabel.topAnchor constraintGreaterThanOrEqualToAnchor:(FirstRow(index)?superview.topAnchor:superview.centerYAnchor) constant:19]];
//        [_multiConstraints addObject:[_flowLabel.trailingAnchor constraintEqualToAnchor:(FirstColumn(index)?superview.centerXAnchor:superview.trailingAnchor) constant:-5]];
        ActiveConstraint(_multiConstraints, [_flowLabel.topAnchor constraintGreaterThanOrEqualToAnchor:(FirstRow(index)?superview.topAnchor:superview.centerYAnchor) constant:19], constraintTemp)
        ActiveConstraint(_multiConstraints, [_flowLabel.trailingAnchor constraintEqualToAnchor:(FirstColumn(index)?superview.centerXAnchor:superview.trailingAnchor) constant:-5], constraintTemp)

       // MARK: The traffic has been used up or expired
        _flowOverLabel = [UILabel new];
        [self addView:_flowOverLabel control:PreviewComponentFlowTip toSuperview:superview];
        _flowOverLabel.numberOfLines = 0;
        _flowOverLabel.textColor = UIColor.whiteColor;
        _flowOverLabel.text = @"Flow has run out or expired";
        _flowOverLabel.font = [UIFont systemFontOfSize:15];
        _flowOverLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _flowOverLabel.textAlignment = NSTextAlignmentCenter;
        CenterConstantAtIndex(_singleConstraints, _multiConstraints, _flowOverLabel, superview, index, constraintTemp,0,-20)
        LRContains(_singleConstraints, _multiConstraints, _flowOverLabel, superview, index, constraintTemp, 10);
        
        // MARK: Traffic recharge button
        _flowRechargeButton = [self createButton:@"Recharge"];
        [self addView:_flowRechargeButton control:PreviewComponentFlowRecharge toSuperview:superview];
        _flowRechargeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_flowRechargeButton addTarget:self action:@selector(onButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_flowRechargeButton.topAnchor constraintEqualToAnchor:_flowOverLabel.bottomAnchor constant:10].active = YES;
        [_flowRechargeButton.centerXAnchor constraintEqualToAnchor:_flowOverLabel.centerXAnchor].active = YES;
        
       // MARK: preview limit
        _limitView = [[UIView alloc]init];
        [self addView:_limitView control:PreviewComponentLimit toSuperview:superview];
        CenterAtIndex(_singleConstraints,_multiConstraints,_limitView,superview,index,constraintTemp);
        [_limitView.widthAnchor constraintEqualToConstant:80].active = YES;
        [_limitView.heightAnchor constraintEqualToConstant:80].active = YES;
        _limitView.backgroundColor = [UIColor blackColor];
        
        // MARK: date
        _formatter = [NSDateFormatter new];
        _formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        _formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        // parent control
        _superview = superview;
        // all controls
        _bottomBar = bottomBar;
        
        [NSLayoutConstraint activateConstraints:_portraitConstraints];
    }
    return self;
}


- (void)dealloc{
    NSEnumerator *enumer = self.views.reverseObjectEnumerator;
    UIView *view = nil;
    while (nil != (view = enumer.nextObject)) {
        [self removeViewConstraints:view];
        [view removeFromSuperview];
    }
}

- (void)setBatteryState:(BatteryState)batteryState{
    if(_batteryState == batteryState) return;
    _batteryState = batteryState;
    
    UIImage *image = nil;
    switch (batteryState) {
        case BatteryStateLongPower: image = [UIImage imageNamed:@"preview_icon_longpower"]; break;
            
        case BatteryStateUnchargedPowerFull: image = [UIImage imageNamed:@"preview_icon_electriy1"]; break;
        case BatteryStateUnchargedPowerHigh: image = [UIImage imageNamed:@"preview_icon_electriy2"]; break;
        case BatteryStateUnchargedPowerMiddle: image = [UIImage imageNamed:@"preview_icon_electriy3"]; break;
        case BatteryStateUnchargedPowerLow: image = [UIImage imageNamed:@"preview_icon_electriy4"]; break;
        case BatteryStateUnchargedPowerLower: image = [UIImage imageNamed:@"preview_icon_electriy5"]; break;

        case BatteryStateChargedPowerFull: image = [UIImage imageNamed:@"preview_icon_charging1"]; break;
        case BatteryStateChargedPowerHigh: image = [UIImage imageNamed:@"preview_icon_charging2"]; break;
        case BatteryStateChargedPowerMiddle: image = [UIImage imageNamed:@"preview_icon_charging3"]; break;
        case BatteryStateChargedPowerLow: image = [UIImage imageNamed:@"preview_icon_charging4"]; break;
        case BatteryStateChargedPowerLower: image = [UIImage imageNamed:@"preview_icon_charging5"]; break;
        default: break;
    }
    
    if(image && self.batteryRemainingImageView){
        self.batteryRemainingImageView.image = image;
    }
}
- (void)setShamHiddenAll:(BOOL)shamHiddenAll{
    if(shamHiddenAll == _shamHiddenAll) return;
    
    NSEnumerator *enumer = _numberToView.keyEnumerator;
    NSNumber *number = nil;
    while (nil != (number = enumer.nextObject)) {
        UIView *view = _numberToView[number];
        BOOL isVisiable = !shamHiddenAll;
        if(isVisiable){
            isVisiable =  nil != _numberToVisiable[number] ? [_numberToVisiable[number] boolValue] : NO;
        }
        view.hidden = !isVisiable;
    }
    
    _shamHiddenAll = shamHiddenAll;
}


-(BOOL)isHidden:(PreviewComponent)control{
    if(self.isUninstalled){
        return YES;
    }
    if(control == PreviewComponentConnectingGif){
        return [self isHidden:PreviewComponentConnecting];
    }
    else if(control == PreviewComponentFlowOver){
        return [self isHidden:PreviewComponentFlowTip];
    }
    else{
        UIView *view = _numberToView[@(control)];
        if(nil == view){
            return YES;
        }
        
        if(self.shamHiddenAll){
            return nil == _numberToVisiable[@(control)] ? YES : [_numberToVisiable[@(control)] boolValue];
        }
        else{
            return view.isHidden;
        }
    }
}


-(void)hidden:(BOOL)hidden control:(PreviewComponent)control{
    if(self.isUninstalled){
        return;
    }
    if(control == PreviewComponentConnectingGif){
        UIView *logo        = _numberToView[@(PreviewComponentLogo)];
        UIView *connecting  = _numberToView[@(PreviewComponentConnecting)];
        if(nil == logo || nil == connecting){
            return;
        }
        
        self.numberToVisiable[@(PreviewComponentLogo)] = @(!hidden);
        self.numberToVisiable[@(PreviewComponentConnecting)] = @(!hidden);
        if([NSThread currentThread].isMainThread){
            if(!self.shamHiddenAll){
                logo.hidden = hidden;
                connecting.hidden = hidden;
            }
        }
        else{
             __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                if(!strongSelf.shamHiddenAll){
                    logo.hidden = hidden;
                    connecting.hidden = hidden;
                }
            });
        }
    }
    else if(control == PreviewComponentFlowOver){
        UIView *tip = _numberToView[@(PreviewComponentFlowTip)];
        UIView *recharge = _numberToView[@(PreviewComponentFlowRecharge)];
        if(nil == tip || nil == recharge){
            return;
        }
        
        self.numberToVisiable[@(PreviewComponentFlowTip)] = @(!hidden);
        self.numberToVisiable[@(PreviewComponentFlowRecharge)] = @(!hidden);
        if([NSThread currentThread].isMainThread){
            if(!self.shamHiddenAll){
                tip.hidden = hidden;
                recharge.hidden = hidden;
            }
        }
        else{
             __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                if(!strongSelf.shamHiddenAll){
                    tip.hidden = hidden;
                    recharge.hidden = hidden;
                }
            });
        }
    }
    else{
        UIView *view = _numberToView[@(control)];
        if(nil == view){
            return;
        }
        
        XXOC_WS;
        [XXocUtils mainThreadProcess:^{
            XXOC_SS;
            ss.numberToVisiable[@(control)] = @(!hidden);
            if(!ss.shamHiddenAll && view.isHidden != hidden){
                view.hidden = hidden;
                if(view == ss.recordButton){
                    hidden ? [ss.timer stop] : [ss.timer start];
                }
                else if(view == ss.wifiButton){
                    if(hidden){
                        [NSLayoutConstraint deactivateConstraints:ss.activeWhenWifiVisabled];
                        [NSLayoutConstraint activateConstraints:ss.activeWhenWifiHidden];
                    }
                    else{
                        [NSLayoutConstraint deactivateConstraints:ss.activeWhenWifiHidden];
                        [NSLayoutConstraint activateConstraints:ss.activeWhenWifiVisabled];
                    }
                }
                else{
                    
                }
            }
        }];

    }
}


-(void)hiddenAll{
    if(self.isUninstalled){
        return;
    }
    if([NSThread currentThread].isMainThread){
        [self.numberToVisiable removeAllObjects];
        if(!self.shamHiddenAll){
            NSEnumerator *enumer = self.numberToView.keyEnumerator;
            NSNumber *number = nil;
            while (nil != (number = enumer.nextObject)) {
                UIView *view = self.numberToView[number];
                view.hidden = YES;
            }
        }
    }
    else{
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf.numberToVisiable removeAllObjects];
            if(!strongSelf.shamHiddenAll){
                NSEnumerator *enumer = strongSelf.numberToView.keyEnumerator;
                NSNumber *number = nil;
                while (nil != (number = enumer.nextObject)) {
                    UIView *view = strongSelf.numberToView[number];
                    view.hidden = YES;
                }
            }
        });
    }
}
-(void)removeAll{
    if(self.isUninstalled){
        return;
    }
    self.isUninstalled = YES;
    XXOC_WS
    [XXocUtils mainThreadProcess:^{
        XXOC_SS
        NSEnumerator *objectEnumer = [ss.numberToView objectEnumerator];
        UIView *view = nil;
        while (nil != (view=objectEnumer.nextObject)) {
            [self removeViewConstraints:view];
            [view removeFromSuperview];
        }
    }];
}

- (void)removeViewConstraints:(UIView *)view{
    
    UIView *superview = view.superview;
    while (superview != nil) {
        for (NSLayoutConstraint *c in superview.constraints) {
            if (c.firstItem == view || c.secondItem == view) {
                [superview removeConstraint:c];
            }
        }
        superview = superview.superview;
    }

    [view removeConstraints:view.constraints];
    view.translatesAutoresizingMaskIntoConstraints = YES;
}

-(void)shamHidden:(BOOL)hidden control:(PreviewComponent)control{
    if(self.isUninstalled){
        return;
    }
    NSArray *numbers = @[@(control)];
    if(control == PreviewComponentConnectingGif){
        numbers = @[@(PreviewComponentLogo),@(PreviewComponentConnecting)];
    }
    else if(control == PreviewComponentFlowOver){
        numbers = @[@(PreviewComponentFlowTip),@(PreviewComponentFlowRecharge)];
    }
    else{
        
    }
    
    NSEnumerator *enumer = numbers.objectEnumerator;
    NSNumber *number = nil;
    while (nil != (number = enumer.nextObject)) {
        UIView *view = _numberToView[number];
        BOOL isVisiable = !hidden;
        if(isVisiable){
            isVisiable =  nil != _numberToVisiable[number] ? [_numberToVisiable[number] boolValue] : NO;
        }
        view.hidden = !isVisiable;
    }    
}


-(void)updateConstraints:(BOOL)single{
    if(self.isUninstalled){
        return;
    }
    NSArray *active = single ? self.singleConstraints : self.multiConstraints;
    NSArray *deacitve = single ? self.multiConstraints : self.singleConstraints;
    [NSLayoutConstraint deactivateConstraints:deacitve];
    [NSLayoutConstraint activateConstraints:active];
    self.timestampLabel.font = single ? [UIFont systemFontOfSize:12] : [UIFont systemFontOfSize:10];
    self.cruiseingButton.titleLabel.font = single ? [UIFont systemFontOfSize:12] : [UIFont systemFontOfSize:9];
    [self.superview updateConstraints];
}


-(void)timestamp:(NSTimeInterval)timestamp{
    if(self.isUninstalled){
        return;
    }
    if([NSThread currentThread].isMainThread){
        _timestampLabel.text = [_formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
    }
    else{
        WeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongSelf
            strongSelf.timestampLabel.text = [strongSelf.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
        });
    }
}


-(void)wifiWithStrength:(int)strength db:(int)db type:(int)type{
    if(self.isUninstalled){
        return;
    }
    
    NSString *imageName = nil;
    if(0 == type){
        imageName = @"previw_icon_wifi5";
        if(strength>0 && strength <5){
            imageName = [NSString stringWithFormat:@"previw_icon_wifi%d", 5-strength];
        }
    }
    else{
        if(db >= -75)   imageName = @"previw_icon_wifi1_multi";
        else if(db >= -85)   imageName = @"previw_icon_wifi2_multi";
        else if(db >= -100)   imageName = @"previw_icon_wifi3_multi";
        else imageName = @"previw_icon_wifi4_multi";
    }
    UIImage *image = [UIImage imageNamed:imageName];
    NSString *text = [NSString stringWithFormat:@"%d dBm", db];
    
    if([NSThread currentThread].isMainThread){
        [_wifiButton setImage:image forState:UIControlStateNormal];
        [_wifiButton setTitle:text forState:UIControlStateNormal];
    }
    else{
        WeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongSelf
            [strongSelf.wifiButton setImage:image forState:UIControlStateNormal];
            [strongSelf.wifiButton setTitle:text forState:UIControlStateNormal];
        });
    }
}
-(void)residualFlow:(NSString*)flow{
    if(self.isUninstalled){
        return;
    }
    if([NSThread currentThread].isMainThread){
        if ([flow isEqualToString:@"999999"]) {
            [_flowLabel setTitle: @"Unlimited flow" forState:UIControlStateNormal];
        }else{
            [_flowLabel setTitle:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"remaining", @"remaining"),flow] forState:UIControlStateNormal];
        }
    }
    else{
        WeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongSelf
            if ([flow isEqualToString:@"999999"]) {
                [strongSelf.flowLabel setTitle: @"Unlimited flow" forState:UIControlStateNormal];
            }else{
                [strongSelf.flowLabel setTitle:[NSString stringWithFormat:@"Remaining%@",flow] forState:UIControlStateNormal];
            }
        });
    }
}
-(void)batteryRemaining:(int)remaining{
    if(self.isUninstalled){
        return;
    }
    
    XXOC_WS;
    [XXocUtils mainThreadProcess:^{
        XXOC_SS;
        if(ss.isUninstalled){
            return;
        }
        
        if(255 == remaining){
            ss.batteryState = BatteryStateLongPower;
        }
        
        else if(remaining>90&&remaining<=100){
            ss.batteryState = BatteryStateUnchargedPowerFull;
        }
        else if(remaining>70&&remaining<=90){
            ss.batteryState = BatteryStateUnchargedPowerHigh;
        }
        else if(remaining>50&&remaining<=70){
            ss.batteryState = BatteryStateUnchargedPowerMiddle;
        }
        else if(remaining>20&&remaining<=50){
            ss.batteryState = BatteryStateUnchargedPowerLow;
        }
        else if(remaining>0&&remaining<=20){
            ss.batteryState = BatteryStateUnchargedPowerLower;
        }
        
        else if(remaining>190&&remaining<=200){
            ss.batteryState = BatteryStateChargedPowerFull;
        }
        else if(remaining>170&&remaining<=190){
            ss.batteryState = BatteryStateChargedPowerHigh;
        }
        else if(remaining>150&&remaining<=170){
            ss.batteryState = BatteryStateChargedPowerMiddle;
        }
        else if(remaining>120&&remaining<=150){
            ss.batteryState = BatteryStateChargedPowerLow;
        }
        else if(remaining>100&&remaining<=120){
            ss.batteryState = BatteryStateChargedPowerLower;
        }
        else{
            
        }
    }];
}

-(UIView*)view:(PreviewComponent)component{
    if(self.isUninstalled){
        return nil;
    }
    return _numberToView[@(component)];
}

- (void)setIsLandscape:(BOOL)isLandscape{
    if(isLandscape == _isLandscape) return;
    _isLandscape = isLandscape;
    [self didLandscape:isLandscape];
}


-(void)didLandscape:(BOOL)landscape{
    NSLog(@"[PreviewComponentManager] didLandscape:%d", landscape);
    NSArray *deactive = landscape ? _portraitConstraints : _landscapeConstraints;
    NSArray *active = landscape ? _landscapeConstraints : _portraitConstraints;
    [NSLayoutConstraint deactivateConstraints:deactive];
    [NSLayoutConstraint activateConstraints:active];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

}


-(void)addView:(UIView*)view control:(PreviewComponent)control toSuperview:(UIView*)superview{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.hidden = YES;
    [superview addSubview:view];
    [_numberToView setObject:view forKey:@(control)];
    [_views addObject:view];
}


-(UIButton*)createButton:(NSString*)title{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    button.layer.cornerRadius = 15;
    button.layer.borderWidth = 1;
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.titleLabel.textColor = UIColor.whiteColor;
    button.contentEdgeInsets = UIEdgeInsetsMake(4, 8, 4, 8);
    [button.heightAnchor constraintGreaterThanOrEqualToConstant:30].active = YES;
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setNumberOfLines:0];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [button.titleLabel.topAnchor constraintEqualToAnchor:button.topAnchor constant:4].active = YES;
    [button.titleLabel.leadingAnchor constraintEqualToAnchor:button.leadingAnchor constant:8].active = YES;
    [button.titleLabel.bottomAnchor constraintEqualToAnchor:button.bottomAnchor constant:-4].active = YES;
    [button.titleLabel.trailingAnchor constraintEqualToAnchor:button.trailingAnchor constant:-8].active = YES;
    return button;
}


-(UILabel*)createLabel:(NSString*)title{
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = UIColor.whiteColor;
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}


-(void)onButtonTouchUpInside:(UIButton*)button{
    if(!_onButtonClicked) return;
    if(button == _playButton) { _onButtonClicked(_index, PreviewComponentPlay); }
    else if(button == _emptyPasswordButton) { _onButtonClicked(_index, PreviewComponentEmptyPassword); }
    else if(button == _connectFailureButton) { _onButtonClicked(_index, PreviewComponentConnectFaliure); }
    else if(button == _incorrectButton) { _onButtonClicked(_index, PreviewComponentIncorrect); }
    else if(button == _flowRechargeButton) {_onButtonClicked(_index,PreviewComponentFlowRecharge);}
    else{}
}
@end
