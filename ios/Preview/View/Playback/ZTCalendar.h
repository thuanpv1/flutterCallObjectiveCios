//
//  ZTCalendar.h
//  iCamSee
//
//  Created by hs_mac on 2018/3/19.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZTCalendar : UIView

@property(nonatomic, strong) void(^itemClickAction)(NSDate *date);

@end
