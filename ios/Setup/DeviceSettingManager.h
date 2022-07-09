//
//  DeviceSettingManager.h
//  demo
//  xys
//  Created by Macro-Video on 2019/12/23.
//  Copyright © 2019 Macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NVDeviceConfigInfo.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,loadDeviceSettingResultType){
loadDeviceSettingResultTypeSuccess, //success
    loadDeviceSettingResultTypeEmptyPassword, //Empty password
    loadDeviceSettingResultTypeLowPassword, //Weak password
    loadDeviceSettingResultTypePasswordError, //Password error
    loadDeviceSettingResultTypeConnectFailed, //Connection failed
    loadDeviceSettingResultTypeOtherError //Other errors
};

typedef NS_ENUM(NSInteger,deviceSettingType){ //Support using | to pass in multiple types that need to be set at one time
    deviceSettingTypeAlarm = 1 << 0, //Alarm message
    deviceSettingTypeTimeZone = 1 << 1, //time zone
    deviceSettingTypeRecord = 1 << 2, //Record setting
    deviceSettingTypeLanguage = 1 << 3, //language setting
    deviceSettingTypeIP = 1 << 4, //IP setting
    deviceSettingTypeVoice = 1 << 5, //Voice setting
    deviceSettingTypeNetWork = 1 << 6, //Network settings
    deviceSettingTypeVersion = 1 << 7, //version information
    deviceSettingTypeAlarmSwitch = 1 << 8, //version information
    deviceSettingTypeAll = ~(1 << 63) //All //All bits are inverted to 1
};

@interface DeviceSettingManager : NSObject
+(void)loadDeviceSetting:(NVDevice *)device completeHandel:(void(^)(LoginHandle *loginHandle, NVDeviceConfigInfo *info, loadDeviceSettingResultType result))loadSettingResultHandel;

////登录设备(同步)
+(LoginHandle *)loginDevice:(NVDevice *)device;
@end

NS_ASSUME_NONNULL_END
