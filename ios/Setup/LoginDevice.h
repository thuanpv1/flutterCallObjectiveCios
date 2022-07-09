//
//  LoginDevice.h
//  demo
//
//  Created by MacroVideo on 2018/4/9.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginDevice : NSObject
typedef void(^LoginDeviceCompletionHandler)(LoginHandle *loginResult);
+ (instancetype)shareOperation;
-(void)loginDeviceWithDevice:(NVDevice*)device addConnectType:(int)type completionHandler:(LoginDeviceCompletionHandler)handler;

@end
