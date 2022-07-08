//
//  NVDeviceStatus.h
//  NVSDK
//
//  Created by caffe on 2019/2/20.
//  certified by caffe on 20190322
//  Copyright © 2019 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NVDeviceStatus : NSObject
@property (assign) int nResult;
@property (assign) int nOnlineStatus; //在线状态 参考宏定义 STAT_ONLINE STAT_OFFLINE
@property (assign) int nAlarmStatus; //设备布撤防状态 2布放，1已撤防,0未知
@property(nonatomic,assign) int deviceSoftwareUpdateStatus;//设备升级状态 0 未知 1 不升级 2需要提示升级
@end

NS_ASSUME_NONNULL_END
