//
//  DeviceManager.m
//  demo
//
//  Created by macrovideo on 18/01/23.
//  Copyright © 2017年 macrovideo. All rights reserved.
//

#import "DeviceManager.h"
#import "LoginDevice.h"
#import "DeviceSettingManager.h"
@interface DeviceManager()
@property(nonatomic,strong)NSMutableArray *toUploadDeviceList;
@property(nonatomic,strong)NSMutableArray *alarmServerList;

@end

@implementation DeviceManager

static LoginHandle *sharedLoginResult = nil;


#pragma mark - login
+(void)login:(NVDevice *)device withConnectType:(int)connectType succ:(LoginBlock)succBlock  fail:(LoginBlock)failBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [device setNAddType:ADD_TYPE_SEARCH_FROM_LAN];
        NSString *domain = [NSString stringWithFormat:@"%ld.nvdvr.net",(long)device.NDevID];
        [device setStrDomain:domain];
        LoginHandle *loginResult = [LoginHelper getDeviceParam:device withConnectType:connectType];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
                succBlock(loginResult);
            }else{
                failBlock(loginResult);
            }
        });
    });
}

#pragma mark - Get device online status
+ (void) getDeviceOnlineStat:(NVDevice *)device succ:(OnlineBlock)succBlock  fail:(OnlineBlock)failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [device setNAddType:ADD_TYPE_SEARCH_FROM_LAN];
        NSString *domain = [NSString stringWithFormat:@"%ld.nvdvr.net",(long)device.NDevID];
        [device setStrDomain:domain];
        //OnlineResult *onlineResult = [LoginHelper getDeviceStatus:device];
        NVDeviceStatus *onlineResult = [LoginHelper getDeviceStatus:device];
        if (onlineResult && [onlineResult nResult]==RESULT_CODE_SUCCESS) {
            dispatch_async(dispatch_get_main_queue(), ^{
                succBlock(onlineResult);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                failBlock(onlineResult);
                NSLog(@"failure");
            });
        }
    });
    
}


+ (BOOL)handleResult:(int)result type:(int)type shouldShowTips:(BOOL)shouldShowTips{  //type = 1 get configuration type = 2 set
    if (result == RESULT_CODE_SUCCESS){
        return  YES;
    }else{
        NSString *strMsg = @"";
        if (type == 1) {
        strMsg = NSLocalizedString(@"noticeGetConfigFail", @"Get Config Fail: ");//Failed to get configuration information
        }else if (type == 2){
          strMsg = NSLocalizedString(@"noticeSetConfigFail", @"Set Config Fail: ");//Failed to save configuration information
        }

        if (result == NV_RESULT_DESC_NO_USER) { // 1011 User does not exist
            strMsg = [NSString stringWithFormat:@"%@%@", strMsg, NSLocalizedString(@"noticeNOUser", @"accont error")];
        }else if (result == NV_RESULT_DESC_PWD_ERR){ // 1012 Password error
            strMsg = [NSString stringWithFormat:@"%@%@", strMsg, NSLocalizedString(@"noticePWDErr", @"password error")];
        }else if (result == RESULT_CODE_FAIL_USER_NOEXIST){ // -0x104 -260 Username does not exist
            strMsg = [NSString stringWithFormat:@"%@%@", strMsg, NSLocalizedString(@"noticePWDErr", @"password error")];
        }else if (result == NV_RESULT_DESC_NO_PRI){ // 1013 Insufficient permissions
            strMsg = [NSString stringWithFormat:@"%@%@", strMsg, NSLocalizedString(@"noticeNOPRI", @"no priority")];
        }else if (result == NV_RESULT_DESC_TIME_ERR){ // 1014 Time format is incorrect
            strMsg = [NSString stringWithFormat:@"%@%@", strMsg, NSLocalizedString(@"noticeTimeFMTErr", @"time format error")];
        }else if (result == NV_RESULT_DESC_PWD_FMT_ERR_AP){ // 1015 ap password format is incorrect
            strMsg = [NSString stringWithFormat:@"%@%@", strMsg, NSLocalizedString(@"noticeAPPWDFMTErr", @"AP password format error")];
        }else if (result == NV_RESULT_DESC_PWD_FMT_ERR_STATION){ // 1016 station password format is incorrect
            strMsg = [NSString stringWithFormat:@"%@%@", strMsg, NSLocalizedString(@"noticeStationPWDFMTErr", @"Station password format error")];
        }else if (result == NV_RESULT_DESC_PWD_FMT_ERR){ // 1017 The password format is incorrect
            strMsg = [NSString stringWithFormat:@"%@%@", strMsg, NSLocalizedString(@"noticePWDFMTErr", @"password format error")];
        }else if (result == NV_RESULT_NO_NEW_VERSION){
            strMsg = [NSString stringWithFormat:@"%@",  NSLocalizedString(@"noticeDeviceNOUpdate", @"Device no updates")];
        }else if (result == NV_RESULT_NET_NO_SUPORT){
             strMsg = [NSString stringWithFormat:@"%@%@", strMsg, NSLocalizedString(@"noticeAPCanNotUpdate", @"Updating can not run in AP mode")];
        }else{                                                           // Other cases. All return connection failed
            strMsg = [NSString stringWithFormat:@"%@%@", strMsg, NSLocalizedString(@"noticeCNNFail", @"connect fail")];
        }
        if (shouldShowTips) {
//            iToast *toast = [iToast makeToast:strMsg];
//            [toast setToastPosition:kToastPositionCenter];
//            [toast setToastDuration:kToastDurationShort];
//            [toast show];
        }
        return  NO;
    }
}



#pragma mark - Device password information
+(void)GetAccountInfo:(NVDevice *)device succ:(AccountBlock)succBlock fail:(VoidBlock)failBlock;{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    AccountConfigInfo *accountInfo  =  [NVDeviceConfigHelper getAccountConfigInfo:device handle:loginResult];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if( [self handleResult:accountInfo.nResult type:1 shouldShowTips:YES]) {
                            
                            succBlock(accountInfo);
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//                    AccountConfigInfo *accountInfo  =  [NVDeviceConfigHelper getAccountConfigInfo:device handle:loginResult];
//
//                    dispatch_async(dispatch_get_main_queue(), ^{
//
//                        if( [self handleResult:accountInfo.nResult type:1 shouldShowTips:YES]) {
//
//                            succBlock(accountInfo);
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];

}


+(void)SetAcountInfo:(NVDevice *)device account:(AccountConfigInfo *)account succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:YES]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    int result  =  [NVDeviceConfigHelper setAcountConfigInfo:device account:account handle:loginResult];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if( [self handleResult:result type:2 shouldShowTips:YES]) {
                            
                            succBlock();
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:YES]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//                    int result  =  [NVDeviceConfigHelper setAcountConfigInfo:device account:account handle:loginResult];
//
//                    dispatch_async(dispatch_get_main_queue(), ^{
//
//                        if( [self handleResult:result type:2 shouldShowTips:YES]) {
//
//                            succBlock();
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
    
}

#pragma mark - WIFI settings
+(void)GetNetworkInfo:(NVDevice *)device succ:(NetWorkBlock)succBlock fail:(VoidBlock)failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NetworkConfigInfo *networkInfo  =  [NVDeviceConfigHelper getNetworkConfigInfo:device handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if( [self handleResult:networkInfo.nResult type:1 shouldShowTips:YES]) {
                            succBlock(networkInfo);
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                   NetworkConfigInfo *networkInfo  =  [NVDeviceConfigHelper getNetworkConfigInfo:device handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if( [self handleResult:networkInfo.nResult type:1 shouldShowTips:YES]) {
//                            succBlock(networkInfo);
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
    
    
}


+(void)SetNetworkInfo:(NVDevice *)device account:(NetworkConfigInfo *)info succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock shouldShowTips:(BOOL)shouldShowTips{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self handleResult:loginResult.nResult type:2 shouldShowTips:shouldShowTips]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    int result  =  [NVDeviceConfigHelper setNetworkConfigInfo:device account:info handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if( [self handleResult:result type:2 shouldShowTips:shouldShowTips]) {
                            
                            succBlock();
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:shouldShowTips]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//                    int result  =  [NVDeviceConfigHelper setNetworkConfigInfo:device account:info handle:loginResult];
//                    NSLog(@"[wb] SetNetworkInfo result:%d", result);
//                    dispatch_async(dispatch_get_main_queue(), ^{
//
//                        if( [self handleResult:result type:2 shouldShowTips:shouldShowTips]) {
//
//                            succBlock();
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
}

+(void)GetDeviceVisibleWifiList:(NVDevice *)device succ:(ArrayBlock)succBlock fail:(VoidBlock)failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                  NSArray *wifiList  =  [NVDeviceConfigHelper getVisibleWifiListFromDevice:device handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (wifiList!=nil && wifiList.count>0){
                            succBlock(wifiList);
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                  NSArray *wifiList  =  [NVDeviceConfigHelper getVisibleWifiListFromDevice:device handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if (wifiList!=nil && wifiList.count>0){
//                            succBlock(wifiList);
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
    
    
}


#pragma mark - Alert settings
// One key to arm and disarm -- new method
+(void)SetOneKeyAlarm:(NVDevice *)device isAlarm:(BOOL)isAlarm loginHandle:(LoginHandle*)handle succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock shouldShowTips:(BOOL)shouldShowTips{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int result  =  [NVDeviceConfigHelper setOneKeyAlarm:device isAlarm:isAlarm handle:handle];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:result type:2 shouldShowTips:shouldShowTips]) {
                succBlock();
            }else{
                failBlock();
            }
        });
    });
}

// get warning information
+(void)GetAlarmPromptInfo:(NVDevice *)device  succ:(AlarmBlock)succBlock fail:(VoidBlock)failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    AlarmConfigInfo  *alarm =  [NVDeviceConfigHelper getAlarmConfigInfo:device handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if( [self handleResult:alarm.nResult type:1 shouldShowTips:YES]) {
                            succBlock(alarm);
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    AlarmConfigInfo  *alarm =  [NVDeviceConfigHelper getAlarmConfigInfo:device handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if( [self handleResult:alarm.nResult type:1 shouldShowTips:YES]) {
//                            succBlock(alarm);
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
    
}

//Set the warning information
+(void)SetAlarmPromptInfo:(NVDevice *)device account:(AlarmConfigInfo *)info succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock shouldShowTips:(BOOL)shouldShowTips{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:shouldShowTips]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    int result  =  [NVDeviceConfigHelper setAlarmConfigInfo:device account:info handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if( [self handleResult:result type:2 shouldShowTips:shouldShowTips]) {
                            succBlock();
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:shouldShowTips]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    int result  =  [NVDeviceConfigHelper setAlarmConfigInfo:device account:info handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if( [self handleResult:result type:2 shouldShowTips:shouldShowTips]) {
//                            succBlock();
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
}

#pragma mark - Recording settings
+(void)GetRecordInfo:(NVDevice *)device succ:(RecordBlock)succBlock fail:(VoidBlock)failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    RecordConfigInfo  *recordInfo =  [NVDeviceConfigHelper getRecordConfigInfo:device handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if( [self handleResult:recordInfo.nResult type:1 shouldShowTips:YES]) {
                            succBlock(recordInfo,loginResult);
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    RecordConfigInfo  *recordInfo =  [NVDeviceConfigHelper getRecordConfigInfo:device handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//
//                        if( [self handleResult:recordInfo.nResult type:1 shouldShowTips:YES]) {
//                            succBlock(recordInfo,loginResult);
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];

    
}

+(void)SetRecordInfo:(NVDevice *)device account:(RecordConfigInfo *)info succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock shouldShowTips:(BOOL)shouldShowTips{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:shouldShowTips]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    int result  =  [NVDeviceConfigHelper setRecordConfigInfo:device account:info handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if( [self handleResult:result type:2 shouldShowTips:shouldShowTips]) {
                            succBlock();
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:shouldShowTips]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    int result  =  [NVDeviceConfigHelper setRecordConfigInfo:device account:info handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if( [self handleResult:result type:2 shouldShowTips:shouldShowTips]) {
//                            succBlock();
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
    
    
}


+(void)StartFormatSDCard:(NVDevice *)device succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:YES]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    int result  =  [NVDeviceConfigHelper startFormatSDCard:device handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if( [self handleResult:result type:2 shouldShowTips:YES]) {
                            succBlock();
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:YES]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    int result  =  [NVDeviceConfigHelper startFormatSDCard:device handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if( [self handleResult:result type:2 shouldShowTips:YES]) {
//                            succBlock();
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
    
}

#pragma mark - time setting
+(void)GetDateTimeInfo:(NVDevice *)device succ:(DateTimeBlock)succBlock fail:(VoidBlock)failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    TimeConfigInfo  *datetimeInfo =  [NVDeviceConfigHelper getTimeConfigInfo:device handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if( [self handleResult:datetimeInfo.nResult type:1 shouldShowTips:YES]) {
                            succBlock(datetimeInfo);
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
//
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    TimeConfigInfo  *datetimeInfo =  [NVDeviceConfigHelper getTimeConfigInfo:device handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//
//                        if( [self handleResult:datetimeInfo.nResult type:1 shouldShowTips:YES]) {
//                            succBlock(datetimeInfo);
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
    
}


+(void)SetDateTimeInfo:(NVDevice *)device account:(TimeConfigInfo *)info succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock shouldShowTips:(BOOL)shouldShowTips{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:shouldShowTips]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    int result  =  [NVDeviceConfigHelper setTimeConfigInfo:device account:info handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if( [self handleResult:result type:2 shouldShowTips:shouldShowTips]) {
                            succBlock();
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:shouldShowTips]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    int result  =  [NVDeviceConfigHelper setTimeConfigInfo:device account:info handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if( [self handleResult:result type:2 shouldShowTips:shouldShowTips]) {
//                            succBlock();
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
    
    
}

#pragma mark - IP settings
+(void)GetIPConfigInfo:(NVDevice *)device succ:(IPConfigBlock)succBlock fail:(VoidBlock)failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    IPConfigInfo  *ipConfigInfo =  [NVDeviceConfigHelper getIPConfigInfo:device handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if( [self handleResult:ipConfigInfo.nResult type:1 shouldShowTips:YES]) {
                            succBlock(ipConfigInfo);
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    IPConfigInfo  *ipConfigInfo =  [NVDeviceConfigHelper getIPConfigInfo:device handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//
//                        if( [self handleResult:ipConfigInfo.nResult type:1 shouldShowTips:YES]) {
//                            succBlock(ipConfigInfo);
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
    
}

+(void)SetIPConfigInfo:(NVDevice *)device info:(IPConfigInfo *)info succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock shouldShowTips:(BOOL)shouldShowTips{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:shouldShowTips]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    int result  =  [NVDeviceConfigHelper setIPConfigInfo:device info:info handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if( [self handleResult:result type:2 shouldShowTips:shouldShowTips]) {
                            succBlock();
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
//    X_WeakSelf;
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            X_StrongSelf;
//            if( [strongSelf handleResult:loginResult.nResult type:2 shouldShowTips:shouldShowTips]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    int result  =  [NVDeviceConfigHelper setIPConfigInfo:device info:info handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if( [strongSelf handleResult:result type:2 shouldShowTips:shouldShowTips]) {
//                            succBlock();
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
    
}



#pragma mark - version update

+(void)GetVersionInfo:(NVDevice *)device  succ:(VersionInfoBlock)succBlock fail:(VoidBlock)failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    VersionInfo  *versionInfo =  [NVDeviceConfigHelper getVersionInfo:device handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if( [self handleResult:versionInfo.nResult type:1 shouldShowTips:YES]) {
                            succBlock(versionInfo);
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    VersionInfo  *versionInfo =  [NVDeviceConfigHelper getVersionInfo:device handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//
//                        if( [self handleResult:versionInfo.nResult type:1 shouldShowTips:YES]) {
//                            succBlock(versionInfo);
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
    
}


+(void )GetDeviceUpdateInfo:(NVDevice *)device succ:(DeviceUpdateInfoBlock)succBlock fail:(VoidBlock)failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            //modified by weibin 20190328
            //Prevent unnecessary weak prompts from happening. If you need to troubleshoot problems, you can enter the SDK to find them
            if( loginResult.nResult == RESULT_CODE_SUCCESS) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    DeviceUpdateInfo  *updateInfo =  [NVDeviceConfigHelper getDeviceVersionInfo:device handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //NSLog(@"caffe updateInfo.nResult=%d", updateInfo.nResult);
                        if( updateInfo.nResult == RESULT_CODE_SUCCESS) {
                            succBlock(updateInfo);
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
            //modified end by weibin 20190328
        });
    });
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //modified by weibin 20190328
//            //防止不必要的弱提示提示发生，如果需要排查问题，可以进入SDK进行查找
//            if( loginResult.nResult == RESULT_CODE_SUCCESS) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    DeviceUpdateInfo  *updateInfo =  [NVDeviceConfigHelper getDeviceVersionInfo:device handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        //NSLog(@"caffe updateInfo.nResult=%d", updateInfo.nResult);
//                        if( updateInfo.nResult == RESULT_CODE_SUCCESS) {
//                            succBlock(updateInfo);
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//            //modified end by weibin 20190328
//        });
//    }];
    
}


+(void)StartDeviceUpdate:(NVDevice *)device succ:(VoidBlock)succBlock fail:(void(^)(int result))failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:YES]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    int result  =  [NVDeviceConfigHelper startUpdateDeviceVersion:device handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(result == NV_RESULT_LOWPOWER_NOTSUPPORT){
//                            iToast *toast = [iToast makeToast:NSLocalizedString(@"notSupportWhenLowPower", nil)];
//                            [toast setToastPosition:kToastPositionCenter];
//                            [toast setToastDuration:kToastDurationNormal];
//                            [toast show];
                            failBlock(result);
                        }
                        else if( [self handleResult:result type:2 shouldShowTips:YES]) {
                            succBlock();
                        }else{
                            failBlock(result);
                        }
                    });
                });
            }else{
                failBlock(loginResult.nResult);
            }
        });
    });
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:YES]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    int result  =  [NVDeviceConfigHelper startUpdateDeviceVersion:device handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if( [self handleResult:result type:2 shouldShowTips:YES]) {
//                            succBlock();
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
    
}

#pragma mark - temperature control alarm settings
+(void)setThermalInfo:(NVDevice *)device account:(ThermalConfigInfo *)info succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock shouldShowTips:(BOOL)shouldShowTips{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self handleResult:loginResult.nResult type:2 shouldShowTips:shouldShowTips]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    int result  =  [NVDeviceConfigHelper setThermalInfo:device info:info handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([self handleResult:result type:2 shouldShowTips:shouldShowTips]) {
                            succBlock();
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
            
        });
    });
    
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            if([self handleResult:loginResult.nResult type:2 shouldShowTips:shouldShowTips]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    int result  =  [NVDeviceConfigHelper setThermalInfo:device info:info handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if( [self handleResult:result type:2 shouldShowTips:shouldShowTips]) {
//                            succBlock();
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
}


#pragma mark - get additional regulatory information
+(void )GetOtherSettingInfo:(NVDevice *)device succ:(OtherSettingInfoBlock)succBlock fail:(VoidBlock)failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    OtherConfigInfo  *info =  [NVDeviceConfigHelper getOtherConfigInfo:device handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if( [self handleResult:info.nResult type:1 shouldShowTips:YES]) {
                            succBlock(info);
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:1 shouldShowTips:YES]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    LightConfigInfo  *info =  [NVDeviceConfigHelper getLightConfigInfo:device handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//
//                        if( [self handleResult:info.nResult type:1 shouldShowTips:YES]) {
//                            succBlock(info);
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
    
}

#pragma mark - set additional control information
+(void)SetOtherConfigInfo:(NVDevice *)device info:(OtherConfigInfo *)info shouldShowTips:(BOOL)show succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( /*[self handleResult:loginResult.nResult type:2 shouldShowTips:show]*/ loginResult.nResult == RESULT_CODE_SUCCESS) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    int result  =  [NVDeviceConfigHelper setOtherConfigInfo:device account:info handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if( /*[self handleResult:result type:2 shouldShowTips:show]*/ result == RESULT_CODE_SUCCESS) {
                            succBlock();
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:YES]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    int result  =  [NVDeviceConfigHelper setLightConfigInfo:device account:info handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if( [self handleResult:result type:2 shouldShowTips:YES]) {
//                            succBlock();
//                        }else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
}

#pragma mark - Set custom alarm sound
+(void)setAlarmAudioWithDevice:(NVDevice *)device fileType:(int)fType path:(NSString *)pathStr succ:(AlarmAudioSettingBlock)succBlock fail:(VoidBlock)failBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:YES]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    int result  =  [NVDeviceConfigHelper SetAlarmAudio:device fileType:fType path:pathStr handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(result == RESULT_CODE_SUCCESS) {
                            succBlock(result);
                        }else if (result == 2003) {
                    		succBlock(result);
                        } else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
    
    
//    [[LoginDevice shareOperation]loginDeviceWithDevice:device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:YES]) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    int result  =  [NVDeviceConfigHelper SetAlarmAudio:device fileType:fType path:pathStr handle:loginResult];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if(result == RESULT_CODE_SUCCESS) {
//                            succBlock();
//                        }else if (result == 2003) {
//                            iToast *toast = [iToast makeToast:@"Please add application custom sound first"];
//                            [toast setToastPosition:kToastPositionCenter];
//                            [toast setToastDuration:kToastDurationShort];
//                            [toast show];
//                            failBlock();
//                        } else{
//                            failBlock();
//                        }
//                    });
//                });
//            }else{
//                failBlock();
//            }
//        });
//    }];
}

+(void)initRecord{
    [NVDeviceConfigHelper initRecord];
}

+(BOOL)startRecordAlarmAudio:(NSString *)pathStr{
    return [NVDeviceConfigHelper startRecordAlarmAudio:pathStr];
}

+(void)stopRecordAlarmAudio{
    [NVDeviceConfigHelper stopRecordAlarmAudio];
}

+(void)preparePlayAudio:(NSString *)pathStr{
    [NVDeviceConfigHelper preparePlayAudio:pathStr];
}

+(void)playAudio{
    [NVDeviceConfigHelper playAudio];
}

+(void)stopPlayAudiio{
    [NVDeviceConfigHelper stopPlayAudiio];
}

+(void)setLightControlWithDevice:(NVDevice *)device defaultAction:(int)defaultAction timingAction:(int)timingAction startTime:(NSString *)startTime endTime:(NSString *)endTime succ:(VoidBlock)succBlock fail:(VoidBlock)failBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LoginHandle *loginResult = [DeviceSettingManager loginDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( [self handleResult:loginResult.nResult type:2 shouldShowTips:YES]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    int result  =  [NVDeviceConfigHelper SetDeviceLightConfig:device defaultAction:defaultAction timingAction:timingAction startTime:startTime endTime:endTime handle:loginResult];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(result == RESULT_CODE_SUCCESS) {
                            succBlock();
                        }else{
                            failBlock();
                        }
                    });
                });
            }else{
                failBlock();
            }
        });
    });
}

@end

