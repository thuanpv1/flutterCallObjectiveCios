//
//  AlarmAreaView.h
//  collectview
//
//  Created by 视宏 on 17/2/25.
//  Copyright © 2017年 视宏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmAreaModel.h"

#define SELECTCOLOR [UIColor colorWithRed:255.0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.2]
//#define SELECTCOLOR [UIColor colorWithHex:0xF43F31 alpha:0.5]
#define UNSELECTCOLOR [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.2]
typedef void (^updateAlarmArea)(AlarmAreaModel *AlarmAreamodel);

@interface AlarmAreaView : UIView

@property(nonatomic,strong) AlarmAreaModel *alarmModel;
-(void)clearselect;
-(void)selectallArea;
-(void)updateAlarmArea:(updateAlarmArea)AlarmArea;

@property (nonatomic,copy) void(^updateAreaBlock)(NSMutableArray *array);
@end
