//
//  PTZView.m
//  AppAuth
//
//  Created by VINSON on 2019/11/13.
//

#import "PTZViewForMulti.h"
#import "UIImageView+WebCache.h"
#import "SDImageCodersManager.h"
#import <Lottie/Lottie.h>

@interface PTZViewForMulti(){
    CGPoint pressedPoint;
}
@property(nonatomic,strong) UIPanGestureRecognizer *panGesture;
@property(nonatomic,strong) UITapGestureRecognizer *tapGesture;
@property(nonatomic,assign) BOOL isTimerRunning;
@property(nonatomic,strong) dispatch_source_t timer;
@property(nonatomic,assign) PTZDirection currentDirection;
@property(nonatomic,strong) LOTAnimationView *cruiseingView;

@property(nonatomic,assign) int radius;
@end

@implementation PTZViewForMulti
- (instancetype)init{
    self = [super init];
    if (self) {
        [self install];
    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    [self install];
}
- (void)install{
    self.userInteractionEnabled = YES;
    _currentDirection = PTZDirectionNormal;
    _duration = 0.1;
    _radius = self.frame.size.height * 0.5;
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    [self addGestureRecognizer:_panGesture];
    [self addGestureRecognizer:_tapGesture];
    
    _enabled = YES;
    
//    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"autoCruiseingForLight.json" ofType:nil];
//    if(@available(iOS 13.0,*)){
//        if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
//            path = [[NSBundle mainBundle] pathForResource:@"autoCruiseingForDark.json" ofType:nil];
//        }
//    }
//    NSURL *url = [NSURL fileURLWithPath:path];
//    
//    _cruiseingView = [[LOTAnimationView alloc] initWithContentsOfURL:url];
//    _cruiseingView.loopAnimation = YES;
//    [_cruiseingView play];
//    _cruiseingView.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    [self addSubview:_cruiseingView];
////    [XXocUtils view:_cruiseingView size:CGSizeMake(30, 30)];
////    [XXocUtils view:_cruiseingView centerAt:self];
//    _cruiseingView.hidden = YES;
}
- (void)dealloc{
    [self stopTimer];
    [_panGesture removeTarget:self action:@selector(onPanGesture:)];
    [_tapGesture removeTarget:self action:@selector(onPanGesture:)];
}

- (void)setImages:(NSArray *)images{
    _images = images;

    if(nil != _images && (_images.count == 5 || _images.count == 6)){
        self.image = _images[0];
    }
}
- (void)setEnabled:(BOOL)enabled{
    if(_enabled == enabled) return;
    _enabled = enabled;
    self.userInteractionEnabled = enabled;
    if(!enabled){
        [self stopTimer];
    }
    
    if(self.images.count > 5){
        if([NSThread currentThread].isMainThread){
            self.image = enabled ? _images.firstObject : _images.lastObject;
        }
        else{
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.image = enabled ? strongSelf.images.firstObject :strongSelf.images.lastObject;
            });
        }
    }
}
- (void)setCurrentDirection:(PTZDirection)currentDirection{
    if(_currentDirection == currentDirection) return;
    if(currentDirection != PTZDirectionNormal && self.onUpdateDirection){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.onUpdateDirection(currentDirection);
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.image = self.images[currentDirection];
    });
    _currentDirection = currentDirection;
}
- (void)setCruiseing:(BOOL)cruiseing{
    if(_cruiseing == cruiseing){
        return;
    }
    _cruiseing = cruiseing;
    if(cruiseing){
        _cruiseingView.hidden = NO;
    }
    else{
        _cruiseingView.hidden = YES;
    }
}

-(void)onTapGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:self];
   NSLog(@"[GWX] [Click to finish] x:%.3f y:%.3f", point.x, point.y);
    [self stopTimer];
    self.currentDirection = PTZDirectionNormal;
    _isPressed = NO;
}
-(void)onPanGesture:(UIPanGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:self];
    if(gesture.state == UIGestureRecognizerStateEnded){
        NSLog(@"[GWX] [Drag] End");
        [self stopTimer];
        self.currentDirection = PTZDirectionNormal;
        _isPressed = NO;
    }
    else{
        NSLog(@"[GWX] [drag] x:%.3f y:%.3f", point.x, point.y);
        self.currentDirection = [self judgeAreaWithX:point.x Y:point.y Radius:_radius];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    NSLog(@"[GWX] [click to start] x:%.3f y:%.3f", point.x, point.y);
    self.currentDirection = [self judgeAreaWithX:point.x Y:point.y Radius:_radius];
    [self startTimer:_duration];
    _isPressed = YES;
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    NSLog(@"[GWX] [Click to end] x:%.3f y:%.3f", point.x, point.y);
    [self stopTimer];
    self.currentDirection = PTZDirectionNormal;
    _isPressed = NO;
}
//-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSLog(@"[GWX] [touchesMoved]");
//}
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSLog(@"[GWX] [touchesEnded]");
//}

#pragma mark - Private functions: <start timer> <stop timer> <vector calculation>
-(void)startTimer:(int)duration{
    _isTimerRunning = YES;
    if(_timer){
        [self stopTimer];
    }
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_duration * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(_duration * NSEC_PER_SEC);
    dispatch_source_set_timer(_timer, start, interval, 0);
    
    dispatch_source_set_event_handler(_timer, ^{
        if(self.onUpdateDirection){
            self.onUpdateDirection(self.currentDirection);
        }
    });
    dispatch_resume(_timer);
}
-(void)stopTimer{
    _isTimerRunning = NO;
    if(_timer){
        dispatch_cancel(_timer);
        _timer = nil;
    }
}
-(PTZDirection)judgeAreaWithX:(CGFloat)x Y:(CGFloat)y Radius:(CGFloat)radius{
    int area = PTZDirectionNormal;
    if (x < radius && y < radius) {
        if (x > y) {
            area = PTZDirectionUp;
        } else {
            area = PTZDirectionLeft;
        }
    } else if (x > radius && y < radius) {
        if (radius * 2 - x > y) {
            area = PTZDirectionUp;
        } else {
            area = PTZDirectionRight;
        }

    } else if (x < radius && y > radius) {
        if (radius * 2 - y > x) {
            area = PTZDirectionLeft;
        } else {
            area = PTZDirectionDown;
        }
    } else if (x > radius && y > radius) {
        if (x > y) {
            area = PTZDirectionRight;
        } else {
            area = PTZDirectionDown;
        }
    }
    return area;
}
@end
