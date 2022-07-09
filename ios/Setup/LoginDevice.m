//
//  LoginDevice.m
//  demo
//
//  Created by MacroVideo on 2018/4/9.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import "LoginDevice.h"
#import "DeviceLoginer.h"
#import "GlobleVar.h"

@implementation LoginDevice{
    
    int currentId;
}



+ (instancetype)shareOperation {
    return [[self alloc] init];
}

-(void)loginDeviceWithDevice:(NVDevice *)device addConnectType:(int)type completionHandler:(LoginDeviceCompletionHandler)handler{
    static int loginId = 0;
    currentId = ++loginId;
    
    int userID =0;
    NSString *method = @"login_local";

    NSString *password = device.strPassword;
    if (password.length>28) {
        password = [[device.strPassword MD5_EX] base64Encode];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        DeviceLoginProcess *loginprocess = [DeviceLoginer loginByLanIP:device.strServer
                                                            NetIPArray:[GlobleVar getPanoIPs]
                                                                  Port:device.nPort
                                                              DeviceID:device.NDevID
                                                              UserName:device.strUsername
                                                              Password:password
                                                           ConnectType:type
                                                             AccountID:userID method:method];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        loginprocess.onFinished = ^(LoginHandle * _Nonnull loginHandle) {
            if (self->currentId != loginId) {
                NSLog(@"[LoginDevice] [New Login] Discard is not the current operation (current:%d latest:%d)", self->currentId, loginId);
                return;
            }
            dispatch_semaphore_signal(semaphore);
            handler(loginHandle);
            
        };
        //Set up a blocking semaphore to prevent the object from being released early
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    });

}
//end modify by GWX 20190118
@end
