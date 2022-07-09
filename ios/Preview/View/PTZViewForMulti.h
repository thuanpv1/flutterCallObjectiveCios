//
//  PTZView.h
//  AppAuth
//
//  Created by VINSON on 2019/11/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    PTZDirectionNormal,
    PTZDirectionUp,
    PTZDirectionLeft,
    PTZDirectionDown,
    PTZDirectionRight,
} PTZDirection;

@interface PTZViewForMulti : UIImageView
@property (nonatomic,strong) NSArray *images;   // images = [noraml,top,left,bottom,right] or images = [noraml,top,left,bottom,right,disabled]
@property (nonatomic,assign) CGFloat duration; // Default: 1s
//@property (nonatomic,assign) BOOL active;
@property (nonatomic,assign,readonly) BOOL isPressed;
@property (nonatomic,copy) void(^onUpdateDirection)(PTZDirection direction);
@property (nonatomic,assign) BOOL enabled;
@property (nonatomic,assign) BOOL cruiseing;
@end

NS_ASSUME_NONNULL_END
