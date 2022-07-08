//
//  NVDeviceConfigHelper.h
//  NVSDK
//
//  Created by caffe on 2019/2/21.
//  certified by caffe 20190325
//  Copyright © 2019 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "AccountConfigInfo.h"
#import "RecordConfigInfo.h"
#import "VersionInfo.h"
#import "TimeConfigInfo.h"
#import "AlarmConfigInfo.h"
#import "NetworkConfigInfo.h"
#import "DeviceUpdateInfo.h"
#import "IPConfigInfo.h"
#import "OtherConfigInfo.h"
#import "ThermalConfigInfo.h"
#import "PTZCruiseConfigInfo.h"

@class NVDevice;
@class LoginHandle;
NS_ASSUME_NONNULL_BEGIN

@interface NVDeviceConfigHelper : NSObject

+(AccountConfigInfo *)getAccountConfigInfo:(NVDevice *)device handle:(LoginHandle *)lHandle;
+(int)setAcountConfigInfo:(NVDevice *)device account:(AccountConfigInfo *)account handle:(LoginHandle *)lHandle;

+(RecordConfigInfo *)getRecordConfigInfo:(NVDevice *)device handle:(LoginHandle *)lHandle;
+(int)setRecordConfigInfo:(NVDevice *)device account:(RecordConfigInfo *)info handle:(LoginHandle *)lHandle;
+(int)startFormatSDCard:(NVDevice *)device handle:(LoginHandle *)lHandle;

+(VersionInfo *)getVersionInfo:(NVDevice *)device handle:(LoginHandle *)lHandle;
+(DeviceUpdateInfo *)getDeviceVersionInfo:(NVDevice *)device handle:(LoginHandle *)lHandle;
+(int)startUpdateDeviceVersion:(NVDevice *)device handle:(LoginHandle *)lHandle;

+(TimeConfigInfo *)getTimeConfigInfo:(NVDevice *)device handle:(LoginHandle *)lHandle;
+(int)setTimeConfigInfo:(NVDevice *)device account:(TimeConfigInfo *)info handle:(LoginHandle *)lHandle;

+(AlarmConfigInfo *)getAlarmConfigInfo:(NVDevice *)device handle:(LoginHandle *)lHandle;
+(int)setAlarmConfigInfo:(NVDevice *)device account:(AlarmConfigInfo *)info handle:(LoginHandle *)lHandle;

+(int)setOneKeyAlarm:(NVDevice *)device isAlarm:(BOOL)isAlarm handle:(LoginHandle *)lHandle;

+(NetworkConfigInfo *)getNetworkConfigInfo:(NVDevice *)device handle:(LoginHandle *)lHandle;
+(int)setNetworkConfigInfo:(NVDevice *)device account:(NetworkConfigInfo *)info handle:(LoginHandle *)lHandle;
+(IPConfigInfo *)getIPConfigInfo:(NVDevice *)device handle:(LoginHandle *)lHandle;
+(int)setIPConfigInfo:(NVDevice *)device info:(IPConfigInfo *)info handle:(LoginHandle *)lHandle;
+(NSArray *)getVisibleWifiListFromDevice:(NVDevice *)device handle:(LoginHandle *)lHandle;

+(OtherConfigInfo *)getOtherConfigInfo:(NVDevice *)device handle:(LoginHandle *)lHandle;
+(int)setOtherConfigInfo:(NVDevice *)device account:(OtherConfigInfo *)info handle:(LoginHandle *)lHandle;

+(PTZCruiseConfigInfo*)getPTZXCruiseConfigInfo:(NVDevice*)device handle:(LoginHandle*)lHandle;
+(int)setPTZXCruiseConfigInfo:(NVDevice*)device info:(PTZCruiseConfigInfo*)info handle:(LoginHandle*)lHandle action:(int)action;

+(int)SetAlarmAudio:(NVDevice *)device fileType:(int)fType path:pathStr handle:(LoginHandle *)lHandle;
+(void)initRecord;
+(BOOL)startRecordAlarmAudio:(NSString*)pathStr;
+(void)stopRecordAlarmAudio;
+(void)preparePlayAudio:(NSString *)pathStr;
+(void)playAudio;
+(void)stopPlayAudiio;

+(int)setThermalInfo:(NVDevice *)device info:(ThermalConfigInfo *)info handle:(LoginHandle *)lHandle;

+(int)SetDeviceLightConfig:(NVDevice *)device defaultAction:(int)defaultAction timingAction:(int)timingAction startTime:(NSString *)startTime endTime:(NSString *)endTime handle:(LoginHandle *)lHandle;

+(int)setDeviceFocalConfig:(NVDevice *)device handle:(LoginHandle *)lHandle;

+(void)cancelConfig;

@end

NS_ASSUME_NONNULL_END
