//
//  TimeAlarmTableViewController.h
//  demo
//
//  Created by MacroVideo on 2018/1/18.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeAlarmTableViewControllerDelegate <NSObject>
- (void)setAlarmTimeArr:(NSMutableArray *)timeArr isAllDay:(BOOL)isAllDay;
@end

@interface TimeAlarmTableViewController : UITableViewController
@property(nonatomic,strong) AlarmConfigInfo *alarmInfo;
@property(nonatomic,strong) NVDevice *device;

@property (nonatomic,weak) id<TimeAlarmTableViewControllerDelegate> timeDelegate;
@end
