//
//  ZTPlaySlider.m
//  iCamSee
//
//  Created by hs_mac on 2018/3/10.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import "ZTPlaySlider.h"

@implementation ZTPlaySlider


- (CGRect)trackRectForBounds:(CGRect)bounds{
    
    bounds = [super trackRectForBounds:bounds];
    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, self.frame.size.height * 0.25);
}


@end
