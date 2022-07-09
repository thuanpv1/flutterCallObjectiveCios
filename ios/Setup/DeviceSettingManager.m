//
//  DeviceSettingManager.m
//  demo
//  xys
//  Created by Macro-Video on 2019/12/23.
//  Copyright © 2019 Macrovideo. All rights reserved.
//

#import "DeviceSettingManager.h"
#import "DeviceLoginer.h"
#import "GlobleVar.h"
#import "DeviceManager.h"
static int loginCount = 0;

@interface DeviceSettingManager()

@end


@implementation DeviceSettingManager

#pragma mark - 加载设置
+(void)loadDeviceSetting:(NVDevice *)device completeHandel:(void(^)(LoginHandle *loginHandle, NVDeviceConfigInfo *info,loadDeviceSettingResultType result))loadSettingResultHandel{
    loginCount = 0;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // execute serially
        LoginHandle *handle = [self loginDevice:device];
        
        if (handle.nResult == RESULT_CODE_SUCCESS) {
            if (handle.strPassword.length == 0 && device.nAddType != ADD_TYPE_SHARE){
               NSLog(@"device setting device direct connection password is empty");
                loadSettingResultHandel(handle,nil,loadDeviceSettingResultTypeEmptyPassword);
            }else if ([handle.strPassword isEqualToString:@"123456"] && device.nAddType != ADD_TYPE_SHARE){
                NSLog(@"Device Settings Device Direct Connection Weak Password");
                loadSettingResultHandel(handle,nil,loadDeviceSettingResultTypeLowPassword);
            }else if (handle.nVersion >2) {
                BOOL succeed = NO;
                NVDeviceConfigInfo *info = nil;
                for (int index=0; index<2; index++) {
                    info = [[NVDeviceConfigInfo alloc]init];
                    [info getDeviceConfigInfo:device handle:handle];
                    if (info.nResult == RESULT_CODE_SUCCESS) {
                        NSLog(@"Device settings, the device is directly connected, the new protocol obtains configuration information successfully");
                        succeed = YES;
                        break;
                    }else{
                        NSLog(@"Device settings, device direct connection, new protocol failed to obtain configuration information");
                        continue;
                    }
                }
                if(succeed){
                    loadSettingResultHandel(handle,info,loadDeviceSettingResultTypeSuccess);
                }
                else{
                    loadSettingResultHandel(nil,nil,loadDeviceSettingResultTypeConnectFailed);
                }
            }else{
            NSLog(@"Device settings device is directly connected to the old protocol to obtain configuration information successfully");
                loadSettingResultHandel(handle,nil,loadDeviceSettingResultTypeSuccess);
            }
        }else{
            NSLog(@"Device settings, device direct connection, failure to obtain configuration information, other failures");
            loadSettingResultHandel(handle,nil,loadDeviceSettingResultTypeOtherError);
        }
    });
}

#pragma mark - logging into the device
//Log in to the device and return the login information
+(LoginHandle *)loginDevice:(NVDevice *)device{
    __block LoginHandle *handle;
    int userID =0;
    NSString *method = nil;
     if (0) {
     
     }else{
         userID = 0;
         method = @"login_local";
     }
    NSString *password = device.strPassword;
    if (password.length>28) {
   
        password = [[device.strPassword MD5_EX] base64Encode];
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    DeviceLoginProcess *loginProcess = [DeviceLoginer loginByLanIP:device.strServer
                                                        NetIPArray:[GlobleVar getPanoIPs]
                                                              Port:device.nPort
                                                          DeviceID:device.NDevID
                                                          UserName:device.strUsername
                                                          Password:password
                                                       ConnectType:2
                                                        AccountID:userID
                                                            method:method
                                        ];
    loginProcess.onFinished = ^(LoginHandle * _Nonnull loginHandle) {
        handle = loginHandle;
        if ((loginHandle.nResult == NV_RESULT_DESC_NO_USER || loginHandle.nResult == NV_RESULT_DESC_PWD_ERR) && loginCount == 0) {
           // Re-login with an empty password
            NSLog(@"Device settings re-login with empty password");
            loginCount++;
            NVDevice *defaultDev = [[NVDevice alloc]init];
            [defaultDev copyDeviceInfo:device];
            [defaultDev setStrPassword:@""];
            [defaultDev setStrUsername:@"admin"];
            handle = [self loginDevice:defaultDev];
        }else if ((loginHandle.nResult == NV_RESULT_DESC_NO_USER || loginHandle.nResult == NV_RESULT_DESC_PWD_ERR) && loginCount == 1) {
            // Re-login with an empty password
            NSLog(@"Device settings re-use default password to log in");
            loginCount ++;
            NVDevice *defaultDev = [[NVDevice alloc]init];
            [defaultDev copyDeviceInfo:device];
            [defaultDev setStrPassword:@"123456"];
            [defaultDev setStrUsername:@"admin"];
            handle = [self loginDevice:defaultDev];
        }else{
            handle.strPassword = device.strPassword;
            handle.strUsername = device.strUsername;
        }
        dispatch_semaphore_signal(semaphore);
    };
    dispatch_wait(semaphore, DISPATCH_TIME_FOREVER);
    return handle;
}

@end

