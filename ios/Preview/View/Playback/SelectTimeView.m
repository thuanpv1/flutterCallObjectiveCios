//
//  SelectTimeView.m
//  iCamSee
//
//  Created by MacroVideo on 2018/7/16.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import "SelectTimeView.h"
@interface SelectTimeView()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView *datePicker;
@property(nonatomic,strong)UILabel *timeLable;
@property(nonatomic,strong)NSMutableArray *array;
@property(nonatomic,assign)NSInteger selectedRow;
@end
@implementation SelectTimeView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
        UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300,250)];
        bgView.center=self.center;
        bgView.layer.masksToBounds=YES;
        bgView.layer.cornerRadius=5;
        bgView.backgroundColor=[UIColor whiteColor];
        
        //modify by qin 20190419
        CGFloat tipsLabHeight = [NSLocalizedString(@"Please select the video playback time period", nil) stringHeightWithFont:[UIFont systemFontOfSize:18] containSize:CGSizeMake(bgView.frame.size.width, MAXFLOAT)];
        if (tipsLabHeight < 40) {
            tipsLabHeight = 40;
        }
        UILabel *tipsLab=[[UILabel alloc]initWithFrame:CGRectMake(0, 5, bgView.frame.size.width, tipsLabHeight)];
        //end by qin 20190419
        tipsLab.text=NSLocalizedString(@"Please select the video playback time period", nil);
        tipsLab.textAlignment=NSTextAlignmentCenter;
        tipsLab.font=[UIFont systemFontOfSize:18];
        tipsLab.textColor=[UIColor grayColor];
        [bgView addSubview:tipsLab];
        
        UIView *line = [[UIView alloc]init];
        line.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.7];
        line.frame = CGRectMake(0, CGRectGetMaxY(tipsLab.frame), CGRectGetWidth(bgView.frame), 1);
        [bgView addSubview:line];
        
        
        _datePicker = [[UIPickerView alloc]init];
        _datePicker.frame = CGRectMake(0, CGRectGetMaxY(tipsLab.frame)+1, CGRectGetWidth(bgView.frame), 154);
        [bgView addSubview:_datePicker];
        _datePicker.dataSource = self;
        _datePicker.delegate = self;
        
        _timeLable = [[UILabel alloc]init];
        _timeLable.frame = CGRectMake(_datePicker.center.x+20, _datePicker.center.y-15, 100, 30);
        _timeLable.text = NSLocalizedString(@"Time", nil);
        _timeLable.textColor = [UIColor orangeColor];
        [bgView addSubview:_timeLable];
        
        CGFloat width = bgView.frame.size.width/2;
        UIButton *cancelBtn=[[UIButton alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(_datePicker.frame), width, 50)];
        [cancelBtn setTitle:NSLocalizedString(@"Time", nil) forState:UIControlStateNormal];
//        cancelBtn.layer.borderWidth = 0.5;
//        cancelBtn.layer.borderColor = LIGHT_GRAY_COLOR.CGColor;
        [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [bgView addSubview:cancelBtn];
        
        UIButton *confirmBtn=[[UIButton alloc]initWithFrame:CGRectMake(width,CGRectGetMaxY(_datePicker.frame), width, 50)];
        [confirmBtn setTitle:NSLocalizedString(@"Sure", nil) forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
//        confirmBtn.layer.borderWidth = 0.5;
//        confirmBtn.layer.borderColor = LIGHT_GRAY_COLOR.CGColor;
        [bgView addSubview:confirmBtn];
        [self addSubview:bgView];
        
        [cancelBtn addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
        [confirmBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

+ (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width{
    
    if (top) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (left) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (bottom) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, view.frame.size.height - width, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (right) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(view.frame.size.width - width, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
}

-(void)cancleAction{
    [self dismiss];
}

-(void)confirmAction{
    [self dismiss];
    NSString *str = self.array[_selectedRow];
    [self.delegate selectedTimeBlock:str];
}


- (void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}

- (void)dismiss{
    [self endEditing:YES];
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

// how many columns to return
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// return the number of rows per column
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 25;
}
// return the content of each row of pickerView
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED{
    NSString *str = self.array[row];
    return str;
}
// return the height of pickerView
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component __TVOS_PROHIBITED{
    return 50;
}

#pragma mark 给pickerview设置字体大小和颜色等

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    //Set the color of the dividing line
    for(UIView *singleLine in pickerView.subviews)
    {
        if (singleLine.frame.size.height < 1)
        {
            singleLine.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.5];
        }
    }
    /*Redefine row UILabel*/
    UILabel *pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setFont:[UIFont systemFontOfSize:18.0f]];
    }
    if (_selectedRow ==row) {
        [pickerLabel setTextColor:[UIColor orangeColor]];
    }else{
        [pickerLabel setTextColor:[UIColor blackColor]];
    }
    if (row==0) {
        _timeLable.hidden = YES;
    }else{
        _timeLable.hidden = NO;
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}


// select row
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED{
    _selectedRow = row;
    [pickerView reloadAllComponents];
}
-(NSMutableArray *)array{
    if (!_array) {
        _array = [NSMutableArray array];
        [_array addObject:NSLocalizedString(@"all day",nil)];
        
        for (int i = 0; i<24; i++) {
            if (i<10) {
                NSString *str = [NSString stringWithFormat:@"0%d",i];
                [_array addObject:str];
            }else{
                NSString *str = [NSString stringWithFormat:@"%d",i];
                [_array addObject:str];
            }
        }
    }
    return _array;
}
@end
