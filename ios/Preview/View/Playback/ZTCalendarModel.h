//
//  ZTCalendarModel.h
//  iCamSee
//
//  Created by hs_mac on 2018/3/19.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^dateBlock)(NSUInteger,NSUInteger);

@interface ZTCalendarModel : NSObject

@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, copy) dateBlock block;

- (instancetype)initWithDate:(NSDate *)date;

- (NSArray *)setDayArr;

- (NSInteger) lastMonthLestDays;

- (NSInteger) nextMonthLestDays;

- (NSInteger) monthDays;

- (NSArray *)nextMonthDataArr; // next month

- (NSArray *)lastMonthDataArr; // last month

@end
