//
//  TimeConfigInfo.h
//  NVSDK
//
//  Created by caffe on 2019/2/22.
//  cetified by caffe on 20190322
//  Copyright © 2019 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeConfigInfo : NSObject

@property (assign) BOOL bTimeZoneEnable;
@property (assign) int nResult;
@property (assign) int nOPID;
@property (assign) int nDateType;
@property (assign) int nTimeZone;
@property (copy) NSString *strDateTime;
@property (assign) int overTime;// 支持半时区的时间偏移量

@end

NS_ASSUME_NONNULL_END
