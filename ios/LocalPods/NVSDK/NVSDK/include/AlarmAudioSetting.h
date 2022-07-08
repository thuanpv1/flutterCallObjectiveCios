//
//  AlarmAudioSetting.h
//  NVSDK
//
//  Created by qin on 2020/6/9.
//  Copyright © 2020 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NVDevice.h"
#import "LoginHandle.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlarmAudioSetting : NSObject

+(void)cancelConfig;
+(int)SetAlarmAudio:(NVDevice *)device fileType:(int)fType path:(NSString *)pathStr handle:(LoginHandle *)lHandle;

+(void)initRecord;
+(BOOL)startRecordToADPCM:(NSString*)pathStr;
+(void)stopRecordToADPCM;

+(void)preparePlayAudio:(NSString *)pathStr;
+(void)playAudio;
+(void)stopPlayAudiio;
+(void)pausePlayAudio;
@end

NS_ASSUME_NONNULL_END
