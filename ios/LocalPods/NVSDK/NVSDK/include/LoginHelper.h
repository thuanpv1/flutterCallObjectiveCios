//
//  LoginHelper.h
//  iCamSee
//
//  Created by macrovideo on 15/10/14.
//  Copyright © 2015年 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NVDevice.h"
#import "LoginHandle.h"
#import "NVDeviceStatus.h"
#import "SearchDeviceResult.h"
#import "LoginParam.h"
@interface LoginHelper : NSObject

+(void)loginDevice:(LoginParam *)loginParam;
+(NVDeviceStatus *)getDeviceStatus:(NVDevice *)device;
+(BOOL)cancel;
+(BOOL)finish;
+ (LoginHandle *)getDeviceParam:(NVDevice *)device withConnectType: (int8_t)connectType;

+(SearchDeviceResult*)searchDeviceFromServer:(NVDevice *)device;
+(SearchDeviceResult*)searchDeviceFromServer:(NVDevice *)device withStamp:(int)stamp;
@end
