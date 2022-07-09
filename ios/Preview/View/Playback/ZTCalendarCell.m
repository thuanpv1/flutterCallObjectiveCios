//
//  ZTCalendarCell.m
//  iCamSee
//
//  Created by hs_mac on 2018/3/19.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import "ZTCalendarCell.h"

@implementation ZTCalendarCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    self.textLabel = [[UILabel alloc] initWithFrame:self.bounds];
    CGRect frame = self.textLabel.frame;
    frame.size.width = frame.size.width * 0.8;
    frame.size.height = frame.size.height * 0.8;
    frame.origin.x = (self.textLabel.frame.size.width - frame.size.width) / 2.0;
    frame.origin.y = (self.textLabel.frame.size.height - frame.size.height) / 2.0;
    self.textLabel.frame = frame;
    self.textLabel.font = [UIFont systemFontOfSize:15.0];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.textLabel];
}

@end
