//
//  HVPTZView.h
//  iCamSee
//
//  Created by VINSON on 2020/3/12.
//  Copyright © 2020 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTZViewForMulti.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    PTZAxisHorizontal,
    PTZAxisVertical,
} PTZAxis;

@interface HVPTZView : UIView
@property (nonatomic,assign) PTZAxis axis;      // Default: Horizontal
@property (nonatomic,strong) NSArray *upImages;     // normal highlight disabled
@property (nonatomic,strong) NSArray *leftImages;
@property (nonatomic,strong) NSArray *downImages;
@property (nonatomic,strong) NSArray *rightImages;

@property (nonatomic,assign) CGFloat duration; // Default: 1s
@property (nonatomic,assign,readonly) BOOL isPressed;
@property (nonatomic,copy) void(^onUpdateDirection)(PTZDirection direction);
@property (nonatomic,assign) BOOL enabled;
@end

NS_ASSUME_NONNULL_END
