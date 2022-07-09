//
//  PresetViewPortrait.h
//  iCamSee
//
//  Created by VINSON on 2019/12/6.
//  Copyright © 2019 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTZXPicture.h"
NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    PresetActionReset,
    PresetActionCall,
    PresetActionDelete,
} PresetAction;

@interface PresetViewPortrait : UIView
@property (nonatomic,strong) NSArray *showingLayouts;
@property (nonatomic,strong) NSArray *hiddenLayouts;
@property (nonatomic,weak) UIViewController *viewController;
@property (nonatomic,copy) void(^onChanged)(int panoIndex, int deviceID, int ptzxID, PresetAction action); // 0:reset 1:call 2:delete
-(void)reset:(int)panoIndex deviceID:(int)deviceID ptzxCount:(int)ptzxCount ptzxs:(NSArray<PTZXPicture*>*)ptzxs;
-(void)reset:(UIImage*)image atIndex:(int)index;
@end

NS_ASSUME_NONNULL_END
