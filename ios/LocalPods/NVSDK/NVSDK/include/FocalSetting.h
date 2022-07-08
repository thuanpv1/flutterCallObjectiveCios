//
//  FocalSetting.h
//  NVSDK
//
//  Created by Yang on 2021/9/16.
//  Copyright © 2021 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NVDevice.h"
#import "LoginHandle.h"
NS_ASSUME_NONNULL_BEGIN

@interface FocalSetting : NSObject
+(void)cancelConfig;
+(int)setFocalConfig:(NVDevice *)device handle:(LoginHandle *)lHandle;
@end

NS_ASSUME_NONNULL_END
