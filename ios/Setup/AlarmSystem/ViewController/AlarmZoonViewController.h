//
//  AlarmZoonViewController.h
//  demo
//
//  Created by MacroVideo on 2018/2/3.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//
//  re-write by xie yongsheng 20180911 Override the alarm area settings
#import <UIKit/UIKit.h>
#import "AlarmAreaView.h"
#import "AlarmAreaModel.h"

@protocol AlarmZoonViewControllerDelegate <NSObject>
- (void)setAlarmAreaArr:(NSMutableArray *)AreaArr;
@end
@interface AlarmZoonViewController : UIViewController
@property (nonatomic, strong) LoginHandle *loginResult;
@property (nonatomic, strong) NVDevice *device;
@property (nonatomic, strong) AlarmConfigInfo *config;


@property (nonatomic,weak) id<AlarmZoonViewControllerDelegate> areaDelegate;
@end


