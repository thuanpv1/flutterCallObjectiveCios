//
//  DeviceLoginer.h
//  NVSDK
//
//  Created by VINSON on 2019/7/16.
//  Copyright © 2019 macrovideo. All rights reserved.
//

/**
 FIXME: 优化
 对于这个Loginer，还是设计不太好，现在内部实现有点混乱，尤其在添加Multi重新登录的逻辑之后尤其明显；
 故提出以下优化点：
 1. 对外接口只保留multiLoginByLanIP；
 2. 内部DeviceLoginProcessMaster和DeviceLoginProcess这两个需要分离，设计初期是不考虑MultiLogin这个逻辑包含其中才有这个继承，
    需要外部多次调用loginByLanIP: NetIPArray: ，从而产生不同的process；
 */

#import <Foundation/Foundation.h>
#import "LoginHandle.h"

typedef enum : NSUInteger {
    DeviceLoginResultSucceed,
    DeviceLoginResultEmptyPassword,
    DeviceLoginResultMistakeUserNameOrPassword,
    DeviceLoginResultConnectFailure,
    DeviceLoginResultWeakPassword,
} DeviceLoginResult;

@class DeviceLoginProcess;
@interface DeviceLoginProcess : NSObject
@property (nonatomic,copy,nullable) __attribute__((deprecated("此回调即将私有，请使用onMultiFinished"))) void(^onFinished)(LoginHandle * _Nullable handle);
@property (nonatomic,copy,nullable) void(^onMultiFinished)(LoginHandle * _Nullable handle, DeviceLoginResult resule);
-(BOOL)cancel;
@end

NS_ASSUME_NONNULL_BEGIN
@interface DeviceLoginer : NSObject
+ (DeviceLoginProcess*) loginByLanIP:(NSString*)ip
                                Port:(int)port
                            DeviceID:(int)deviceID
                            UserName:(NSString*)userName
                            Password:(NSString*)password __attribute__((deprecated("此函数即将私有，请使用multiLoginByLanIP，包含了一些空密码、弱密码等多次登录")));

+ (DeviceLoginProcess*) loginByNetIPArray:(NSArray<NSString*>*)ipArray
                                     Port:(int)port
                                 DeviceID:(int)deviceID
                                 UserName:(NSString*)userName
                                 Password:(NSString*)password
                              ConnectType:(int)connectType __attribute__((deprecated("此函数即将私有，请使用multiLoginByLanIP，包含了一些空密码、弱密码等多次登录")));

+ (DeviceLoginProcess*) loginByLanIP:(NSString*)ip
                          NetIPArray:(NSArray<NSString*>*)netIPArray
                                Port:(int)port
                            DeviceID:(int)deviceID
                            UserName:(NSString*)userName
                            Password:(NSString*)password
                         ConnectType:(int)connectType
                           AccountID:(int)account
                           method:(NSString*)method
                          __attribute__((deprecated("此函数即将私有，请使用multiLoginByLanIP，包含了一些空密码、弱密码等多次登录")));

+ (DeviceLoginProcess*) multiLoginByLanIP:(NSString *)ip
                               NetIPArray:(NSArray<NSString *> *)netIPArray
                                     Port:(int)port
                                 DeviceID:(int)deviceID
                                 UserName:(NSString *)userName
                                 Password:(NSString *)password
                              ConnectType:(int)connectType
                                AccountID:(int)account
                                method:(NSString*)method;


@end

NS_ASSUME_NONNULL_END
