#import "UIView+Zoomable.h"
#import <objc/runtime.h>

@interface UIView()
@property (nonatomic,assign) CGFloat totalScale; // current scale
@property (nonatomic,assign) CGFloat normalX; // origin.x without zooming and moving
@property (nonatomic,assign) CGFloat normalY; // origin.y without zooming and moving
@property (nonatomic,assign) CGFloat normalWidth; // size.width without zooming and moving
@property (nonatomic,assign) CGFloat normalHeight; // size.height without zooming and moving

@property (nonatomic,strong) UIPinchGestureRecognizer *pinchGesture; // pinch zoom gesture
@property (nonatomic,strong) UIPanGestureRecognizer *panGesture; // single finger move gesture
//@property (nonatomic,strong) UITapGestureRecognizer *tapGesture; // tap gesture
@end

@implementation UIView (Zoomable)
#pragma mark - build destructor
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    UIView *instance = [super allocWithZone:zone];
    if(instance){
        instance.zoomable = NO;
        instance.scaleMax = 4.0;
        instance.scaleMin = 1.0;
        instance.totalScale = 1.0;
    }
    return instance;
}

#pragma mark - public interface: <restores original scale and position>
- (void)zoomRestore{
    // Since the x/y/w/h information is recorded only when the gesture is triggered for the first time, it is necessary to judge the availability of the original information when restoring, to avoid exceptions caused by direct restoration without triggering the gesture
    if(self.normalHeight == 0 && self.normalWidth == 0){
        return;
    }
    self.totalScale = 1.0;
    self.transform = CGAffineTransformMakeScale(1, 1);
    self.frame = CGRectMake(self.normalX, self.normalY, self.normalWidth, self.normalHeight);
}
- (void)zoomReset{
    self.totalScale = 1.0;
    self.normalHeight = 0;
    self.normalWidth = 0;
}

#pragma mark - 属性读写: <Zoomable> <ScaleMax> <ScaleMin> <TotalScale>
- (void)setZoomable:(BOOL)zoomable{
    id obj = objc_getAssociatedObject(self, @"XXzoomable");
    if(nil != obj && [obj boolValue] == zoomable){
        return;
    }
    objc_setAssociatedObject(self, @"XXzoomable", @(zoomable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    zoomable ? [self installRecognizer] : [self uninstallRecognizer];
}
- (BOOL)zoomable{
    return [objc_getAssociatedObject(self, @"XXzoomable") boolValue];
}
- (void)setScaleMax:(CGFloat)scaleMax{
    objc_setAssociatedObject(self, @"XXscaleMax", @(scaleMax), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(CGFloat)scaleMax{
    return [objc_getAssociatedObject(self, @"XXscaleMax") floatValue];
}
- (void)setScaleMin:(CGFloat)scaleMin{
    objc_setAssociatedObject(self, @"XXscaleMin", @(scaleMin), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(CGFloat)scaleMin{
    return [objc_getAssociatedObject(self, @"XXscaleMin") floatValue];
}
- (void)setTotalScale:(CGFloat)totelScale{
    objc_setAssociatedObject(self, @"XXtotalScale", @(totelScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(CGFloat)totalScale{
    return [objc_getAssociatedObject(self, @"XXtotalScale") floatValue];
}

#pragma mark - 属性读写: <NormalX> <NormalY> <NormalHeight> <NormalWidth>
- (void)setNormalX:(CGFloat)normalX{
    objc_setAssociatedObject(self, @"XXnormalX", @(normalX), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGFloat)normalX{
    return [objc_getAssociatedObject(self, @"XXnormalX") floatValue];
}
- (void)setNormalY:(CGFloat)normalY{
    objc_setAssociatedObject(self, @"XXnormalY", @(normalY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGFloat)normalY{
    return [objc_getAssociatedObject(self, @"XXnormalY") floatValue];
}
- (void)setNormalWidth:(CGFloat)normalWidth{
    objc_setAssociatedObject(self, @"XXnormalWidth", @(normalWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGFloat)normalWidth{
    return [objc_getAssociatedObject(self, @"XXnormalWidth") floatValue];
}
- (void)setNormalHeight:(CGFloat)normalHeight{
    objc_setAssociatedObject(self, @"XXnormalHeight", @(normalHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGFloat)normalHeight{
    return [objc_getAssociatedObject(self, @"XXnormalHeight") floatValue];
}

#pragma mark - 属性读写: <PanRecognizer> <PinchRecognizer>
- (void)setPanGesture:(UIPanGestureRecognizer *)panGesture{
    objc_setAssociatedObject(self, @"XXpanGesture", panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIPanGestureRecognizer *)panGesture{
    return objc_getAssociatedObject(self, @"XXpanGesture");
}
- (void)setPinchGesture:(UIPinchGestureRecognizer *)pinchGesture{
    objc_setAssociatedObject(self, @"XXpinchGesture", pinchGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIPinchGestureRecognizer *)pinchGesture{
    return objc_getAssociatedObject(self, @"XXpinchGesture");
}

#pragma mark - 私有函数: <添加手势触发> <移除手势触发> <缩放手势> <移动手势>
- (void) saveRestoreRect{
    CGRect frame        = self.frame;
    self.normalWidth    = frame.size.width;
    self.normalHeight   = frame.size.height;
    self.normalX        = frame.origin.x;
    self.normalY        = frame.origin.y;
}
- (void) installRecognizer{
    if(nil == self.pinchGesture){
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinchEvent:)];
    }
    if(nil == self.panGesture){
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanEvent:)];
    }
//    if(nil == self.tapGesture){
//        //self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
//        //self.tapGesture.numberOfTapsRequired = 2;
//        //self.tapGesture.numberOfTouchesRequired = 1;
//    }

    [self addGestureRecognizer:self.pinchGesture];
    [self addGestureRecognizer:self.panGesture];
    //[self addGestureRecognizer:self.tapGesture];
}
- (void) uninstallRecognizer{
    if(nil != self.pinchGesture) [self removeGestureRecognizer:self.pinchGesture];
    if(nil != self.panGesture)   [self removeGestureRecognizer:self.panGesture];
    //if(nil != self.tapGesture)   [self removeGestureRecognizer:self.tapGesture];
}

- (void)onPinchEvent:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
    UIView *view    = pinchGestureRecognizer.view;
    CGFloat scale   = pinchGestureRecognizer.scale;
    if((scale>1&&self.totalScale >= self.scaleMax) || (scale<1&&self.totalScale < self.scaleMin)){
        return;
    }

    if(pinchGestureRecognizer.state == UIGestureRecognizerStateBegan){
        if(self.normalWidth == 0 && self.normalHeight == 0){
            [self saveRestoreRect];
        }
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.totalScale *= scale;
        if(self.totalScale > self.scaleMax) self.totalScale = self.scaleMax;
        if(self.totalScale < self.scaleMin) self.totalScale = self.scaleMin;

        CGPoint point   = view.frame.origin;
        CGSize size     = view.frame.size;
        CGPoint center  = view.center;
        if(point.x>self.normalX){
            center.x -= point.x-self.normalX;
        }
        else{
            CGFloat maxX = size.width + point.x;
            if(maxX< self.normalX+self.normalWidth){
                center.x += self.normalX+self.normalWidth - maxX;
            }
        }
        if(point.y>self.normalY){
            center.y -= point.y-self.normalY;
        }
        else{
            CGFloat maxY = size.height + point.y;
            if(maxY < self.normalY+self.normalHeight){
                center.y += self.normalY+self.normalHeight - maxY;
            }
        }
        pinchGestureRecognizer.scale = 1;   // reset the current scale

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        view.transform = CGAffineTransformMakeScale(self.totalScale, self.totalScale);
        view.center = center;
        [UIView commitAnimations];
    }
    else{
        
    }
}
- (void)onPanEvent:(UIPanGestureRecognizer *)panGestureRecognizer{
    UIView *view = panGestureRecognizer.view;
    
    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan){
        if(self.normalWidth == 0 && self.normalHeight == 0){
            [self saveRestoreRect];
        }
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        CGPoint center      = (CGPoint){view.center.x + translation.x, view.center.y + translation.y};
        CGFloat halfOfW     = view.frame.size.width * 0.5;
        CGFloat halfOfH     = view.frame.size.height * 0.5;

        if(center.x > halfOfW+self.normalX){
            center.x = halfOfW+self.normalX;
        }
        else{
            CGFloat maxX = center.x + halfOfW;
            if(maxX < self.normalX+self.normalWidth){
                center.x += self.normalX+self.normalWidth - maxX;
            }
        }

        if(center.y > halfOfH+self.normalY){
            center.y = halfOfH+self.normalY;
        }
        else{
            CGFloat maxY = center.y + halfOfH;
            if(maxY < self.normalY+self.normalHeight){
                center.y += self.normalY+self.normalHeight - maxY;
            }
        }
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [view setCenter:center];
        [UIView commitAnimations];
    }
    else{
        
    }
}
-(void)onTapGesture:(UITapGestureRecognizer*)tapGestureRecognizer{

}
@end
