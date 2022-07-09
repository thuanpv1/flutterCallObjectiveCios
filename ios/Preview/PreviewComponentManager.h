//
//  PreviewChannelUIManager.h
//  demo
//
//  Created by VINSON on 2019/11/27.
//  Copyright © 2019 Macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    PreviewComponentPlay, // play button
    PreviewComponentLogo, // connecting logo
    PreviewComponentConnecting, // connect Chinese characters
    PreviewComponentConnectFaliure, // connection failed
    PreviewComponentIncorrect, // wrong password
    
    PreviewComponentOffline, // offline
    PreviewComponentEmptyPassword, // empty password
    PreviewComponentTimestamp, // timestamp
    PreviewComponentWifi, // wifi strength
    //PreviewComponentRecording,
// PreviewComponentSleeping, // sleeping
    
    PreviewComponentConnectingGif, // logo+text in connection
    
    PreviewComponentThermalMaxTemp, //The maximum temperature of thermal imaging
    PreviewComponentFlow, // remaining flow
    
    PreviewComponentFlowOver, // Flow expired or used up, including Tip and Recharge buttons
    PreviewComponentFlowTip, // Flow expired/used up prompt
    PreviewComponentFlowRecharge, // to recharge button
    PreviewComponentCruiseing, // in cruise
    
    PreviewComponentBattery, // battery
    PreviewComponentLimit, // preview limit

} PreviewComponent;

@interface PreviewComponentManager : NSObject
@property (nonatomic,assign) BOOL shamHiddenAll;
@property (nonatomic,copy) void(^onButtonClicked)(int index, PreviewComponent component);
@property (nonatomic,copy) void(^onTimeout)(int index);
@property (nonatomic,assign) BOOL isLandscape;

-(instancetype)initWithSuperview:(UIView*)superview index:(int)index fitscreenButton:(UIButton*)fitscreenButton bottomBar:(UIView*)bottomBar;
-(BOOL)isHidden:(PreviewComponent)control;
-(void)hidden:(BOOL)hidden control:(PreviewComponent)control;
-(void)hiddenAll;
-(void)removeAll;

-(void)shamHidden:(BOOL)hidden control:(PreviewComponent)control;

-(void)updateConstraints:(BOOL)single;
-(void)timestamp:(NSTimeInterval)timestamp;
-(void)wifiWithStrength:(int)strength db:(int)db type:(int)type;
-(void)residualFlow:(NSString*)flow;
-(void)batteryRemaining:(int)remaining;

-(void)setThermalMaxTemp:(int)temp FTempEnable:(BOOL)FTempEnable;
-(UIView*)view:(PreviewComponent)component;
//-(void)setOSDTime:(NSString *)osdTime;
@end

NS_ASSUME_NONNULL_END
