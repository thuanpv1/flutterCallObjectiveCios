//
//  NetworkConfigInfo.h
//  NVSDK
//
//  Created by caffe on 2019/2/22.
//  certified by caffe on 20190323
//  Copyright © 2019 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkConfigInfo : NSObject
@property (strong) NSDate *refreshTime;
@property (copy) NSString *strSaveUsername;
@property (copy) NSString *strSavePassword;
@property (assign) BOOL isMRMode;
@property (assign) int nServerInfoID;
@property (assign) int nDeviceAppVersion;
@property (assign) int nWifiMode;
//@property (assign) BOOL isAPCheck;
//@property (assign) BOOL isStationCheck;
//@property (assign) NetworkConfigWifiMode wifiMode;
@property (assign) int nResult;
@property (assign) int nOPID;
@property (assign) BOOL isStationWifiSet;
@property (copy) NSString *strAPName;
@property (copy) NSString *strAPPassword;

@property (copy) NSString *strStationName;
@property (copy) NSString *strStationPassword;

-(BOOL)checkSaveAcount:(int)nDevID usr:(NSString *)strSUsername pwd:(NSString *)strSPassword;
@end

NS_ASSUME_NONNULL_END
