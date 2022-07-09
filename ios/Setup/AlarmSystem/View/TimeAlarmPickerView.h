//
//  TimeAlarmPickerView.h
//  demo
//
//  Created by qin on 2020/10/14.
//  Copyright © 2020 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeAlarmPickerView : UIView

@property (nonatomic,copy) void(^backBlock)(NSString *startTime, NSString *endTime);

- (void)show;

- (instancetype)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
