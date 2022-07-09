//
//  HVPTZView.m
//  iCamSee
//
//  Created by VINSON on 2020/3/12.
//  Copyright © 2020 Macrovideo. All rights reserved.
//

#import "HVPTZView.h"

@interface HVPTZView()
@property(nonatomic,assign) BOOL isTimerRunning;
@property(nonatomic,strong) dispatch_source_t timer;
@property(nonatomic,assign) PTZDirection currentDirection;
@property (nonatomic,strong) NSMutableDictionary *buttons;
@end

@implementation HVPTZView
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
- (void) install{
    _currentDirection = PTZDirectionNormal;
    _duration = 0.3;
    _buttons = [NSMutableDictionary new];
    
    NSArray *directions = @[@(PTZDirectionUp),@(PTZDirectionLeft),@(PTZDirectionDown),@(PTZDirectionRight)];
    
    for (id key in directions) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = [key intValue];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [_buttons setObject:button forKey:key];
        [self addSubview:button];
        
        [button addTarget:self action:@selector(onButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(onButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(onButtonTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
        
        if([key intValue] == PTZDirectionUp || [key intValue] == PTZDirectionDown){
            [button.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
            if([key intValue] == PTZDirectionUp){
                [button.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
            }
            else{
                [button.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
            }
        }
        if([key intValue] == PTZDirectionLeft || [key intValue] == PTZDirectionRight){
            [button.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
            if([key intValue] == PTZDirectionLeft){
                [button.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
            }
            else{
                [button.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
            }
        }
    }
    _enabled = YES;
    self.enabled = NO;
}
- (void)dealloc{
    [self stopTimer];
}

- (void)setAxis:(PTZAxis)axis{
    UIButton *button = nil;
    if(axis == PTZAxisHorizontal){
        button  = _buttons[@(PTZDirectionUp)];
        button.hidden = YES;
        button  = _buttons[@(PTZDirectionDown)];
        button.hidden = YES;
        
        button  = _buttons[@(PTZDirectionLeft)];
        button.hidden = NO;
        button  = _buttons[@(PTZDirectionRight)];
        button.hidden = NO;
    }
    else{
        button  = _buttons[@(PTZDirectionUp)];
        button.hidden = NO;
        button  = _buttons[@(PTZDirectionDown)];
        button.hidden = NO;
        
        button  = _buttons[@(PTZDirectionLeft)];
        button.hidden = YES;
        button  = _buttons[@(PTZDirectionRight)];
        button.hidden = YES;
    }
    
}
- (void)setButton:(PTZDirection)direction Images:(NSArray *)images{
    UIButton *button = _buttons[@(direction)];
    [button setImage:[UIImage imageNamed:[images objectAtIndex:0]]  forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:[images objectAtIndex:1]] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:[images objectAtIndex:2]] forState:UIControlStateDisabled];
}
- (void)setUpImages:(NSArray *)upImages{
    [self setButton:PTZDirectionUp Images:upImages];
}
- (void)setLeftImages:(NSArray *)leftImages{
    [self setButton:PTZDirectionLeft Images:leftImages];
}
- (void)setDownImages:(NSArray *)downImages{
    [self setButton:PTZDirectionDown Images:downImages];
}
- (void)setRightImages:(NSArray *)rightImages{
    [self setButton:PTZDirectionRight Images:rightImages];
}
- (void)setEnabled:(BOOL)enabled{
    if(_enabled == enabled) return;
    _enabled = enabled;
    self.userInteractionEnabled = enabled;
    if(!enabled){
        [self stopTimer];
        
        if(_currentDirection != PTZDirectionNormal){
            ((UIButton*)_buttons[@(_currentDirection)]).selected = NO;
        }
    }
    
    NSEnumerator *enumer = _buttons.objectEnumerator;
    UIButton *button = nil;
    while (nil != (button = enumer.nextObject)) {
        button.enabled = enabled;
    }
}

#pragma mark - 私有函数: <开始定时器> <停止定时器> <向量计算>
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

-(void)onButtonTouchDown:(id)sender{
    UIButton *button = sender;
    switch (button.tag) {
        case PTZDirectionUp: ((UIButton*)_buttons[@(PTZDirectionDown)]).enabled = NO; break;
        case PTZDirectionDown: ((UIButton*)_buttons[@(PTZDirectionUp)]).enabled = NO; break;
            
        case PTZDirectionLeft: ((UIButton*)_buttons[@(PTZDirectionRight)]).enabled = NO; break;
        case PTZDirectionRight: ((UIButton*)_buttons[@(PTZDirectionLeft)]).enabled = NO; break;
        default: return;
    }
    _currentDirection = button.tag;
    if(self.onUpdateDirection){
        self.onUpdateDirection(self.currentDirection);
    }
    [self startTimer:_duration];
}
-(void)onButtonTouchUp:(id)sender{
    UIButton *button = sender;
    
    switch (button.tag) {
        case PTZDirectionUp: ((UIButton*)_buttons[@(PTZDirectionDown)]).enabled = YES; break;
        case PTZDirectionDown: ((UIButton*)_buttons[@(PTZDirectionUp)]).enabled = YES; break;
            
        case PTZDirectionLeft: ((UIButton*)_buttons[@(PTZDirectionRight)]).enabled = YES; break;
        case PTZDirectionRight: ((UIButton*)_buttons[@(PTZDirectionLeft)]).enabled = YES; break;
        default: break;
    }
    _currentDirection = PTZDirectionNormal;
    [self stopTimer];
}
@end
