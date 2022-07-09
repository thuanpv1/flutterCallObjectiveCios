/**
 * @author: GWX
 * @date: 20191026
 * @descirption: Use the view.frame before zooming and moving as the boundary limit, zoom and move the view
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Zoomable)
@property (nonatomic,assign) BOOL zoomable; // default: NO;
@property (nonatomic,assign) CGFloat scaleMax; // Maximum scaling, needs to be greater than 1.0, default: 4.0
@property (nonatomic,assign) CGFloat scaleMin; // Minimum scaling, needs to be greater than 0 and less than 1.0, default: 1.0

/** Resume zoom movement */
- (void) zoomRestore;
/** */
- (void) zoomReset;
@end

NS_ASSUME_NONNULL_END