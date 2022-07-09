//
//  AlarmMessageManager.h
//  iCamSee
//
//  Created by macro on 2021/3/9.
//  Copyright © 2021 Macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlarmImageResult.h"
#import "AlarmMessage.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, AlarmMessageFilterType) {
AlarmMessageFilterTypeUnknown, //The default value, indicating that the filter type has not been set
    AlarmMessageFilterTypeAll, //All alarm messages
    AlarmMessageFilterTypeMove, //Motion detection alarm
    AlarmMessageFilterTypeHuman, //Human detection alarm
    AlarmMessageFilterTypePIR, //PIR human detection
    AlarmMessageFilterTypeHighTemp, //High temperature abnormal alarm
    AlarmMessageFilterTypeLowTemp, //Low temperature abnormal alarm
    AlarmMessageFilterTypeCry, //Cry detection alarm
    AlarmMessageFilterTypeSmoke, //smoke detection alarm
};

@interface AlarmMessageManager : NSObject

@property(nonatomic, copy) void (^loadLatestPicCallback)(NSMutableArray *array); //Picture loading time point callback
@property(nonatomic, copy) void (^loadMorePicCallback)(NSMutableArray * _Nullable array); //Picture loading time period callback
@property(nonatomic, copy) void (^loadSmallPicCallback)(NSMutableArray *array); //Picture loading time period callback


@property(nonatomic, strong) NSMutableArray *alarmPicArray;
@property (nonatomic, assign) AlarmMessageFilterType filterType; //filter type

//The maximum and minimum time of the current message list
@property(nonatomic, assign) long long MAXTime;
@property(nonatomic, assign) long long MINTime;

@property(nonatomic, assign) NSInteger currentLoadThreadID;

- (void)loadLatestAlarmMessageWithCurrentTime:(long long)lastTime device:(NVDevice *)device filterType:(AlarmMessageFilterType)filterType;
- (void)loadAlarmMessageWithFromTime:(long long)fromTime toTime:(long long)toTime device:(NVDevice *)device filterType:(AlarmMessageFilterType)filterType;

- (AlarmImageResult *)getLargeAlarmImage:(NVDevice *)device alarmMessage:(AlarmMessage *)alarmMessageInfo thumbnail:(int)thumbnail;//Get the big picture
-(void)getSmallAlrmImage:(NVDevice *)device alarmMessage:(NSMutableArray *)alarmMessageArray;//Get thumbnail

- (BOOL)checkMessage:(AlarmMessage *)msg filter:(AlarmMessageFilterType)filterType;
- (void)reloadAlarmPicArray;

@end

NS_ASSUME_NONNULL_END
