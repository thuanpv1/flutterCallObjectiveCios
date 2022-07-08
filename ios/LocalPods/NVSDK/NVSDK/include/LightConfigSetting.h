//
//  LightConfigSetting.h
//  NVSDK
//
//  Created by qin on 2020/7/18.
//  Copyright © 2020 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NVDevice.h"
#import "LoginHandle.h"
NS_ASSUME_NONNULL_BEGIN

@interface LightConfigSetting : NSObject

+(void)cancelConfig;
+(int)SetDeviceLightConfig:(NVDevice *)device defaultAction:(int)defaultAction timingAction:(int)timingAction startTime:(NSString *)nStartTime endTime:(NSString *)nEndTime handle:(LoginHandle *)lHandle;

@end

NS_ASSUME_NONNULL_END
