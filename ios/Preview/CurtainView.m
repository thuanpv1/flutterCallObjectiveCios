//
//  DisplayMode.m
//  iCamSee
//
//  Created by VINSON on 2019/11/25.
//  Copyright © 2019 Macrovideo. All rights reserved.
//

#import "CurtainView.h"
#import "../Kit/ButtonStackViewShell.h"
#import "../Kit/UIButton+StateSettings.h"
#import "../Kit/XXmacro.h"

@interface CurtainView()
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackWidth;

@property (nonatomic,strong) UIStackView *stackView;
@property (nonatomic,strong) ButtonStackViewShell *stackShell;
@end

@implementation CurtainView

- (void)awakeFromNib{
    [super awakeFromNib];
}

-(void)configWithClose:(UIImage*)image title:(NSString*)title color:(UIColor*)color font:(UIFont*)font axis:(UILayoutConstraintAxis)axis{
    _stackView = [UIStackView new];
    _stackView.axis = axis;
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.distribution = UIStackViewDistributionEqualCentering;
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_stackView];
    [_stackView.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:40].active = YES;
    [_stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20].active = YES;
    [_stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-40].active = YES;
    [_stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20].active = YES;

    _stackShell = [ButtonStackViewShell new];
    [_stackShell shell:_stackView];
    _stackShell.selectShell.exclusive = self.exclusive;
    
    [_closeButton setImage:image forState:UIControlStateNormal];
    _titleLabel.text = title;
    _titleLabel.textColor = color;
    _titleLabel.font = font;
}
- (void)reset:(NSArray *)array{
    [_stackShell removeAll];
//    name:
//    normalImage
//    selectedImage
//    normalColor
//    selectedColor
//    normalBackground
//    selectedBackground
//    width:
//    height:
    int count = (int)array.count;
    for (int index = 0; index < count; index++) {
        NSDictionary *info = array[index];
        
        CGSize size = CGSizeMake(40, 40);
        if(info[@"width"])  size.width = [info[@"width"] floatValue];
        if(info[@"height"]) size.height = [info[@"height"] floatValue];
        BOOL selectable = info[@"selectedColor"] || info[@"selectedImage"] || info[@"selectedBackground"];
        
        UIButton *button = [_stackShell addButton:info[@"name"] size:size selectable:selectable];
        [button setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        if(info[@"text"])               [button setTitle:info[@"text"] forState:UIControlStateNormal];
        if(info[@"radius"])             button.layer.cornerRadius = [info[@"radius"] floatValue];
        if(info[@"normalImage"])        [button setImage:[UIImage imageNamed:info[@"normalImage"]] forState:UIControlStateNormal];
        if(info[@"selectedImage"])      [button setImage:[UIImage imageNamed:info[@"selectedImage"]] forState:UIControlStateSelected];
        if(info[@"normalColor"])        [button setTitleColor:[UIColor colorWithHexString:info[@"normalColor"]] forState:UIControlStateNormal];
        if(info[@"selectedColor"])      [button setTitleColor:[UIColor colorWithHexString:info[@"selectedColor"]] forState:UIControlStateSelected];
        if(info[@"normalBackground"])   [button setBackgroundColor:[UIColor colorWithHexString:info[@"normalBackground"]] forState:UIControlStateNormal];
        if(info[@"selectedBackground"]) [button setBackgroundColor:[UIColor colorWithHexString:info[@"selectedBackground"]] forState:UIControlStateSelected];
        NSLog(@"[BUTTON] %p", button);
    }
}
- (void)setOnClicked:(void (^)(NSString * _Nonnull, BOOL))onClicked{
    _stackShell.onClicked = onClicked;
}
- (void (^)(NSString * _Nonnull, BOOL))onClicked{
    return _stackShell.onClicked;
}
- (void)setOn:(BOOL)on{
    if(_on == on) return;
    if(self.onConstraints && self.offConstraints){
        WeakSelf
        NSArray *active = _on ? self.offConstraints : self.onConstraints;
        NSArray *deactive = _on ? self.onConstraints : self.offConstraints;

        [UIView animateWithDuration:0.3 animations:^{
            StrongSelf
            [NSLayoutConstraint deactivateConstraints:deactive];
            [NSLayoutConstraint activateConstraints:active];
            [strongSelf updateConstraints];
        } completion:^(BOOL finished) {
            StrongSelf
            strongSelf.hidden = !strongSelf.on;
        }];
    }
    _on = on;
}
- (void)setExclusive:(BOOL)exclusive{
    if(_stackShell){
        _stackShell.selectShell.exclusive = exclusive;
    }
}

- (IBAction)onClose:(id)sender {
    NSLog(@"[CurtainView] close");
    self.on = NO;
}
@end
