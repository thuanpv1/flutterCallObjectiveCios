//
//  PTZCruiseConfigInfo.h
//  NVSDK
//
//  Created by VINSON on 2020/7/16.
//  Copyright © 2020 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PTZCruiseTimerItem : NSObject<NSCopying>
@property (nonatomic,assign) int ID;        // 定时巡航点对应预置位的id

@property (nonatomic,assign) int startHour; // 开始时间
@property (nonatomic,assign) int startMin;
@property (nonatomic,assign) int startSec;

@property (nonatomic,assign) int endHour;   // 结束时间
@property (nonatomic,assign) int endMin;
@property (nonatomic,assign) int endSec;
@end

@interface PTZCruiseAutoItemPoint : NSObject<NSCopying>
@property (nonatomic,assign) int ID;            // 自动巡航中节点对应预置位的id
@property (nonatomic,assign) int stayDuration;  // 自动巡航中节点的停留时长
@end

@interface PTZCruiseAutoItem : NSObject<NSCopying>
@property (nonatomic,assign) int startHour; // 自动巡航开始时间
@property (nonatomic,assign) int startMin;
@property (nonatomic,assign) int startSec;

@property (nonatomic,assign) int endHour;   // 自动巡航结束时间
@property (nonatomic,assign) int endMin;
@property (nonatomic,assign) int endSec;

@property (nonatomic,strong) NSArray<PTZCruiseAutoItemPoint*> *points;  // 巡航中节点
@end

@interface PTZCruiseAutoCheckTimeItem: NSObject<NSCopying>
//云台自动检测时间
@property (nonatomic,assign) int nHour;
@property (nonatomic,assign) int nMin;
@property (nonatomic,assign) int nSec;

@end

@interface PTZCruiseConfigInfo : NSObject<NSCopying>
@property (nonatomic,assign) int ptzxUseabledCount;     // 可用预置位数量
@property (nonatomic,assign) int autoMax;               // 自动巡航路线上限
@property (nonatomic,assign) int pointOfAutoMax;        // 自动巡航路线中可设置预置位上限
@property (nonatomic,assign) int actionType;            // 巡航优先级，1：定时优先，2：自动优先

@property (nonatomic,assign) BOOL autoEnabled;          // 启用自动巡航，1：开，10：关
@property (nonatomic,strong) NSArray<PTZCruiseAutoItem*> *autoItems;    // 自动巡航路线

@property (nonatomic,assign) BOOL timerEnabled;         // 是否启用定时巡航，1：开，10：关
@property (nonatomic,strong) NSArray<PTZCruiseTimerItem*> *timerItems;  // 定时巡航点

@property (nonatomic,assign) int ptzAutoCheckEnable;  // 云台自动检测开关，开关 01：开 10：关 （0：无效/不支持）
@property (nonatomic,strong) PTZCruiseAutoCheckTimeItem *checkItems;  // 云台自动检测时间


@end

NS_ASSUME_NONNULL_END
