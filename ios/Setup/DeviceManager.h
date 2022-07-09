//
//  DeviceManager.h
//  demo
//
//  Created by macrovideo on 18/01/23.
//  Copyright © 2017年 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResultCode.h"
#import "NVDeviceConfigHelper.h"
#import "LoginHelper.h"
//device manager

typedef void (^LoginBlock)(LoginHandle *loginResult);
//typedef void (^OnlineBlock)(OnlineResult *loginResult);NVDeviceStatus
typedef void (^OnlineBlock)(NVDeviceStatus *loginResult);
typedef void (^VoidBlock)(void);
//typedef void (^AccountBlock)(AccountInfo *account);AccountConfigInfo
typedef void (^AccountBlock)(AccountConfigInfo *account);
typedef void (^AlarmBlock)(AlarmConfigInfo *account);
typedef void (^RecordBlock)(RecordConfigInfo *recordInfo,LoginHandle *loginResult);
typedef void (^DateTimeBlock)(TimeConfigInfo *datetimeInfo);
typedef void (^IPConfigBlock)(IPConfigInfo *ipConfigInfo);
typedef void (^NetWorkBlock)(NetworkConfigInfo *networkInfo);
typedef void (^ArrayBlock)(NSArray *array);
typedef void (^VersionInfoBlock)(VersionInfo *versionInfo);
typedef void (^DeviceUpdateInfoBlock)(DeviceUpdateInfo *updateInfo);
typedef void (^OtherSettingInfoBlock)(OtherConfigInfo *lightInfo);
typedef void (^AlarmAudioSettingBlock)(int result);//add by qin 20200702

@interface DeviceManager : NSObject

+ (BOOL)handleResult:(int)result type:(int)type shouldShowTips:(BOOL)shouldShowTips;

#pragma mark - login
+(void)login:(NVDevice *)device withConnectType:(int)connectType succ:(LoginBlock)succBlock fail:(LoginBlock)failBlock;

#pragma mark - refresh state
+ (void) getDeviceOnlineStat:(NVDevice *)device succ:(OnlineBlock)succBlock fail:(OnlineBlock)failBlock;
    
#pragma mark - Device password information
+(void)GetAccountInfo:(NVDevice *)device succ:(AccountBlock)succBlock fail:(VoidBlock)failBlock;
+(void)SetAcountInfo:(NVDevice *)device account:(AccountConfigInfo *)account succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock;

#pragma mark - WIFI settings
+(void)GetNetworkInfo:(NVDevice *)device succ:(NetWorkBlock)succBlock fail:(VoidBlock)failBlock;
+(void)SetNetworkInfo:(NVDevice *)device account:(NetworkConfigInfo *)info succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock shouldShowTips:(BOOL)shouldShowTips;

#pragma mark - WIFI list
+(void)GetDeviceVisibleWifiList:(NVDevice *)device succ:(ArrayBlock)succBlock fail:(VoidBlock)failBlock;

#pragma mark - Alert settings
+(void)SetOneKeyAlarm:(NVDevice *)device isAlarm:(BOOL)isAlarm loginHandle:(LoginHandle*)handle succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock shouldShowTips:(BOOL)shouldShowTips;
+(void)GetAlarmPromptInfo:(NVDevice *)device  succ:(AlarmBlock)succBlock fail:(VoidBlock)failBlock;
+(void)SetAlarmPromptInfo:(NVDevice *)device account:(AlarmConfigInfo *)info succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock shouldShowTips:(BOOL)shouldShowTips;

#pragma mark - Recording settings
+(void)GetRecordInfo:(NVDevice *)device succ:(RecordBlock)succBlock fail:(VoidBlock)failBlock;
+(void)SetRecordInfo:(NVDevice *)device account:(RecordConfigInfo *)info succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock shouldShowTips:(BOOL)shouldShowTips;
+(void)StartFormatSDCard:(NVDevice *)device succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock;

#pragma mark - time setting
+(void)GetDateTimeInfo:(NVDevice *)device succ:(DateTimeBlock)succBlock fail:(VoidBlock)failBlock;
+(void)SetDateTimeInfo:(NVDevice *)device account:(TimeConfigInfo *)info succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock shouldShowTips:(BOOL)shouldShowTips;

#pragma mark - IP settings
+(void)GetIPConfigInfo:(NVDevice *)device succ:(IPConfigBlock)succBlock fail:(VoidBlock)failBlock;
+(void)SetIPConfigInfo:(NVDevice *)device info:(IPConfigInfo *)info succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock shouldShowTips:(BOOL)shouldShowTips;

#pragma mark - version update
+(void)GetVersionInfo:(NVDevice *)device succ:(VersionInfoBlock)succBlock fail:(VoidBlock)failBlock;
+(void )GetDeviceUpdateInfo:(NVDevice *)device succ:(DeviceUpdateInfoBlock)succBlock fail:(VoidBlock)failBlock;
+(void)StartDeviceUpdate:(NVDevice *)device succ:(VoidBlock)succBlock fail:(void(^)(int result))failBlock;

#pragma mark - Additional regulatory information settings
+(void )GetOtherSettingInfo:(NVDevice *)device succ:(OtherSettingInfoBlock)succBlock fail:(VoidBlock)failBlock;
+(void)SetOtherConfigInfo:(NVDevice *)device info:(OtherConfigInfo *)info shouldShowTips:(BOOL)show succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock;

#pragma mark - Set custom alarm sound
+(void)setAlarmAudioWithDevice:(NVDevice *)device fileType:(int)fType path:(NSString *)pathStr succ:(AlarmAudioSettingBlock)succBlock fail:(VoidBlock)failBlock;
+(void)initRecord;
+(BOOL)startRecordAlarmAudio:(NSString *)pathStr;
+(void)stopRecordAlarmAudio;
+(void)preparePlayAudio:(NSString *)pathStr;
+(void)playAudio;
+(void)stopPlayAudiio;

#pragma mark - temperature control alarm settings
+(void)setThermalInfo:(NVDevice *)device account:(ThermalConfigInfo *)info succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock shouldShowTips:(BOOL)shouldShowTips;

#pragma mark - Light control settings
+(void)setLightControlWithDevice:(NVDevice *)device defaultAction:(int)defaultAction timingAction:(int)timingAction startTime:(NSString *)startTime endTime:(NSString *)endTime succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock;

@end
