//
//  LightSettingInfo.h
//  NVSDK
//
//  Created by qin on 2020/7/18.
//  Copyright © 2020 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LightSettingInfo : NSObject

@property (assign) int total;
@property (assign) int defaultAction;
@property (assign) int capability;
@property (assign) int action;
@property (assign) int sHour;
@property (assign) int sMinute;
@property (assign) int sSecond;
@property (assign) int eHour;
@property (assign) int eMinute;
@property (assign) int eSecond;

@end

NS_ASSUME_NONNULL_END
