//
//  ZTPointInsideButton.m
//  iCamSee
//
//  Created by hs_mac on 2018/2/26.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import "ZTPointInsideButton.h"

@implementation ZTPointInsideButton

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    CGRect bounds = self.bounds;
// expand the value
    CGFloat widthDelta = 50 - bounds.size.width;
    CGFloat heightDelta = 50 - bounds.size.height;

    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
    
}

@end
