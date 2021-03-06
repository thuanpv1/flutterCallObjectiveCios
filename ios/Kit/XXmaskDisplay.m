//
//  XXMaskView.m
//
//
//  Created by VINSON on 2018/11/16.
//  Copyright © 2018 Macrovideo. All rights reserved.
//

#import "MaskDisplay.h"
#import "XXmacro.h"


@interface MaskDisplay()
@property (nonatomic) CGFloat alpha;
@property (nonatomic,copy) void(^onMaskTouch)(void);
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic,weak) UIWindow *keyWindow;

@property (nonatomic,strong) NSArray *layouts;
@end

@implementation MaskDisplay
#pragma mark - 构建和析构
- (instancetype)initWithContent:(UIView *)content alpha:(CGFloat)alpha{
    self = [super init];
    if(self){
        _alpha = alpha;
        
        _maskView = [UIView new];
        _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
        
        [_maskView addSubview:content];
    }
    return self;
}
- (instancetype)initWithContent:(UIView *)content{
    self = [self initWithContent:content alpha:0.5];
    if(self){
        
    }
    return self;
}

#pragma mark - public interface: <show> <hide>
-(void)showWithMaskTouch:(void(^)(void))block{
    _onMaskTouch = block;
    [self onShow];
}
-(void)show{
    [self onShow];
}
-(void)hide{
    [self onHide];
}

-(void)onShow{
    if(nil == self.keyWindow){
        if([NSThread currentThread].isMainThread){
            self.keyWindow = [UIApplication sharedApplication].keyWindow;
        }
        else{
            __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.keyWindow = [UIApplication sharedApplication].keyWindow;
                dispatch_semaphore_signal(semaphore);
            });
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    }
    
    if(!self.keyWindow){
        return;
    }
    CGRect to = self.keyWindow.frame;
    CGRect from = to;
    from.origin.y = to.size.height;
    _maskView.frame = from;
    [self.keyWindow addSubview:_maskView];
    AnchorFillSave(array, _maskView, self.keyWindow)
    self.layouts = array;
    
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.maskView.frame = to;
    } completion:^(BOOL finished) {
        [NSLayoutConstraint activateConstraints:weakSelf.layouts];
    }];
}
-(void)onHide{
    if(!self.keyWindow || self.maskView.isHidden) return;
    [NSLayoutConstraint deactivateConstraints:self.layouts];
    CGRect from = self.maskView.frame;
    CGRect to = from;
    to.origin.y = from.size.height;
    
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.maskView.frame = to;
    } completion:^(BOOL finished) {
        [weakSelf.maskView removeFromSuperview];
    }];
}
@end
