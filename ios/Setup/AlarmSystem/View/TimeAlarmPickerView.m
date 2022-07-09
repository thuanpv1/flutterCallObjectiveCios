//
//  TimeAlarmPickerView.m
//  demo
//
//  Created by qin on 2020/10/14.
//  Copyright © 2020 Macrovideo. All rights reserved.
//

#import "TimeAlarmPickerView.h"

@interface TimeAlarmPickerView ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *startPickView;
@property (nonatomic, strong) UIPickerView *endPickView;

@property (strong, nonatomic) NSMutableArray *dataArray; //Data source
@property (copy, nonatomic) NSString *selectStr; //Selected time
@property (copy, nonatomic) NSString *selectEndStr; //Selected time

@property (strong, nonatomic) NSMutableArray *yearArr; //year array
@property (strong, nonatomic) NSMutableArray *monthArr; //month array
@property (strong, nonatomic) NSMutableArray *dayArr; //day array
@property (strong, nonatomic) NSMutableArray *hourArr; //hour array
@property (strong, nonatomic) NSMutableArray *minuteArr; //score array
@property (strong, nonatomic) NSMutableArray *secondArr; //score array
@property (strong, nonatomic) NSArray *timeArr; // current time array

@property (copy, nonatomic) NSString *year; //Select the year
@property (copy, nonatomic) NSString *month; //Select month
@property (copy, nonatomic) NSString *day; //Select day
//start
@property (copy, nonatomic) NSString *sHour; //when selected
@property (copy, nonatomic) NSString *sMinute; //Select minutes
@property (copy, nonatomic) NSString *sSecond; //Select points
//Finish
@property (copy, nonatomic) NSString *eHour; //when selected
@property (copy, nonatomic) NSString *eMinute; //Select minutes
@property (copy, nonatomic) NSString *eSecond; //Select points

@end

@implementation TimeAlarmPickerView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.timeArr = [NSArray array];
        self.dataArray = [NSMutableArray array];
        [self configData];
        [self configDoublePickerView];
    }
    return self;
}

- (void)configData {
    NSDate *date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setDateFormat:@"yyyy MM dd HH mm ss"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    self.timeArr = [dateStr componentsSeparatedByString:@" "];
    
    
    NSString *month = self.timeArr[1];
    if ([month intValue] < 10) {
        month = [month stringByReplacingOccurrencesOfString:@"0" withString:@""];
    }
    NSString *day = self.timeArr[2];
    if ([day intValue] < 10) {
        day = [day stringByReplacingOccurrencesOfString:@"0" withString:@""];
    }
    NSString *hour = self.timeArr[3];
    if ([hour intValue] < 10) {
        if ([hour isEqualToString:@"00"]) {
            hour = [NSString stringWithFormat:@"0"];
        }else {
          hour = [hour stringByReplacingOccurrencesOfString:@"0" withString:@""];
        }
    }
    NSString *minute= self.timeArr[4];
    if ([minute intValue] < 10) {
        if ([minute isEqualToString:@"00"]) {
            minute = [NSString stringWithFormat:@"0"];
        }else {
            minute = [minute stringByReplacingOccurrencesOfString:@"0" withString:@""];
        }
    }
    NSString *second= self.timeArr[5];
    if ([second intValue] < 10) {
        if ([second isEqualToString:@"00"]) {
            second = [NSString stringWithFormat:@"0"];
        }else {
            second = [second stringByReplacingOccurrencesOfString:@"0" withString:@""];
        }
    }
    
    self.year = [NSString stringWithFormat:@"%@", self.timeArr[0]];
    self.month = [NSString stringWithFormat:@"%@", month];
    self.day = [NSString stringWithFormat:@"%@", day];
    self.sHour = [NSString stringWithFormat:@"%@", hour];
    self.sMinute = [NSString stringWithFormat:@"%@", minute];
    self.sSecond = [NSString stringWithFormat:@"%@", second];
    
    self.eHour = [NSString stringWithFormat:@"%@", hour];
    self.eMinute = [NSString stringWithFormat:@"%@", minute];
    self.eSecond = [NSString stringWithFormat:@"%@", second];
    
    [self.dataArray addObject:self.hourArr];
    [self.dataArray addObject:self.minuteArr];
    
}

#pragma mark - 配置界面
- (void)configDoublePickerView {
    UIView *whiteView = [[UIView alloc]init];
    whiteView.frame = CGRectMake(10, self.frame.size.height/2, kWidth-20, self.frame.size.height/2 - 10);
    whiteView.layer.cornerRadius = 20;
    [self addSubview:whiteView];
    
    UILabel *startLab = [[UILabel alloc] init];
    startLab.frame = CGRectMake(0, 0, whiteView.frame.size.width/2, 50);
    startLab.text = NSLocalizedString(@"start time", nil);
    startLab.textAlignment = NSTextAlignmentCenter;
    startLab.numberOfLines = 0;
    startLab.font = [UIFont systemFontOfSize:15];
    [whiteView addSubview:startLab];
    
    UILabel *endLab = [[UILabel alloc] init];
    endLab.frame = CGRectMake(CGRectGetMaxX(startLab.frame), 0, whiteView.frame.size.width/2, 50);
    endLab.text = NSLocalizedString(@"end time", nil);
    endLab.textAlignment = NSTextAlignmentCenter;
    endLab.numberOfLines = 0;
    endLab.font = [UIFont systemFontOfSize:16];
    [whiteView addSubview:endLab];
    
    UIView *line = [[UIView alloc]init];
    line.frame = CGRectMake(0, CGRectGetMaxY(startLab.frame)-1, whiteView.frame.size.width, 1);
    [whiteView addSubview:line];
    
    self.startPickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(startLab.frame), whiteView.frame.size.width/2, whiteView.frame.size.height - CGRectGetMaxY(startLab.frame) - 50)];
    self.startPickView.dataSource = self;
    self.startPickView.delegate = self;
    self.startPickView.showsSelectionIndicator = YES;
    [whiteView addSubview:self.startPickView];
    
    self.endPickView = [[UIPickerView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.startPickView.frame), CGRectGetMaxY(startLab.frame), whiteView.frame.size.width/2, whiteView.frame.size.height - CGRectGetMaxY(startLab.frame) - 50)];
    self.endPickView.dataSource = self;
    self.endPickView.delegate = self;
    self.endPickView.showsSelectionIndicator = YES;
    [whiteView addSubview:self.endPickView];
    
    UIView *line1 = [[UIView alloc]init];
    line1.frame = CGRectMake(0, CGRectGetMaxY(self.startPickView.frame), whiteView.frame.size.width, 1);
    [whiteView addSubview:line1];
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(0, CGRectGetMaxY(self.startPickView.frame), whiteView.frame.size.width/2, 50);
    [cancelBtn setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
    cancelBtn.titleLabel.numberOfLines = 0;
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:cancelBtn];
    
    UIView *line2 = [[UIView alloc]init];
    line2.frame = CGRectMake(whiteView.frame.size.width/2, CGRectGetMaxY(self.startPickView.frame), 1, 50);
    [whiteView addSubview:line2];
    
    UIButton *saveBtn = [[UIButton alloc] init];
    saveBtn.frame = CGRectMake(whiteView.frame.size.width/2, CGRectGetMaxY(self.startPickView.frame), whiteView.frame.size.width/2, 50);
    [saveBtn setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateNormal];
    saveBtn.titleLabel.numberOfLines = 0;
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:saveBtn];
}

- (void)show {
    
    [self.startPickView selectRow:[self.hourArr indexOfObject:self.sHour] inComponent:0 animated:YES];
    [self.startPickView selectRow:[self.minuteArr indexOfObject:self.sMinute] inComponent:1 animated:YES];
    
    [self.endPickView selectRow:[self.hourArr indexOfObject:self.eHour] inComponent:0 animated:YES];
    [self.endPickView selectRow:[self.minuteArr indexOfObject:self.eMinute] inComponent:1 animated:YES];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3f animations:^{
//        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Click method
// save button click method
- (void)saveBtnClick {
    NSString *startHour = self.sHour.length == 2 ? [NSString stringWithFormat:@"%d",self.sHour.intValue] : [NSString stringWithFormat:@"0%d", self.sHour.intValue];
    NSString *startMinute = self.sMinute.length == 2 ? [NSString stringWithFormat:@"%d",self.sMinute.intValue] : [NSString stringWithFormat:@"0%d", self.sMinute.intValue];
    self.selectStr = [NSString stringWithFormat:@"%@:%@:00", startHour, startMinute];
    
    NSString *endHour = self.eHour.length == 2 ? [NSString stringWithFormat:@"%d",self.eHour.intValue] : [NSString stringWithFormat:@"0%d", self.eHour.intValue];
    NSString *endMinute = self.eMinute.length == 2 ? [NSString stringWithFormat:@"%d",self.eMinute.intValue] : [NSString stringWithFormat:@"0%d", self.eMinute.intValue];
    self.selectEndStr = [NSString stringWithFormat:@"%@:%@:00", endHour, endMinute];
    
    if ([self.selectStr isEqualToString:self.selectEndStr]) {
 
        return;
    }
    
    if (self.backBlock) {
        self.backBlock(self.selectStr,self.selectEndStr);
    }
    [self dismiss];
}

#pragma mark - UIPickerViewDelegate and UIPickerViewDataSource
// How many groups are returned by UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

// UIPickerView returns how many pieces of data per group
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.dataArray[component] count] * 200;
}

// Which row is selected by UIPickerView
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.startPickView == pickerView) {
        switch (component) {
            case 0: { // Time
                self.sHour = self.hourArr[row%[self.dataArray[component] count]];
                [self changePickerView:pickerView selectRow:row selectComponent:component changeText:[NSString stringWithFormat:NSLocalizedString(@"Time", @"nil"),self.sHour]];
                
            } break;
            case 1: { // Minute
                self.sMinute = self.minuteArr[row%[self.dataArray[component] count]];
                [self changePickerView:pickerView selectRow:row selectComponent:component changeText:[NSString stringWithFormat:NSLocalizedString(@"Minute", @"nil"),self.sMinute]];
                
            } break;
            default: break;
        }
    }else if (self.endPickView == pickerView) {
        switch (component) {
            case 0: { // Time
                self.eHour = self.hourArr[row%[self.dataArray[component] count]];
                [self changePickerView:pickerView selectRow:row selectComponent:component changeText:[NSString stringWithFormat:NSLocalizedString(@"Time", @"nil"),self.eHour]];
                
            } break;
            case 1: { // Minute
                self.eMinute = self.minuteArr[row%[self.dataArray[component] count]];
                [self changePickerView:pickerView selectRow:row selectComponent:component changeText:[NSString stringWithFormat:NSLocalizedString(@"Minute", @"nil"),self.eMinute]];
                
            } break;
            default: break;
        }
    }
    
}

// UIPickerView returns each row of data
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.dataArray[component] objectAtIndex:row%[self.dataArray[component] count]];
}
// UIPickerView returns the height of each row
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44;
}

// UIPickerView returns the View for each row
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *titleLbl;
    if (!view) {
        titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 44)];
        titleLbl.font = [UIFont systemFontOfSize:15];
        titleLbl.textAlignment = NSTextAlignmentCenter;
    } else {
        titleLbl = (UILabel *)view;
    }
    titleLbl.text = [self.dataArray[component] objectAtIndex:row%[self.dataArray[component] count]];
    return titleLbl;
}

- (void)pickerViewLoaded:(NSInteger)component row:(NSInteger)row{
    NSUInteger max = 16384;
    NSUInteger base10 = (max/2)-(max/2)%row;
    [self.startPickView selectRow:[self.startPickView selectedRowInComponent:component] % row + base10 inComponent:component animated:NO];
    [self.endPickView selectRow:[self.endPickView selectedRowInComponent:component] % row + base10 inComponent:component animated:NO];
}

//Change the color and Text of the row selected by pickerView
-(void)changePickerView:(UIPickerView *)pickerView selectRow:(NSInteger)row selectComponent:(NSInteger)component changeText:(NSString *)text {
    UILabel *lbl = (UILabel *)[pickerView viewForRow:row forComponent:component];
    lbl.text = [NSString stringWithFormat:@"%@", text];
}

#pragma mark -
// get the year
- (NSMutableArray *)yearArr {
    if (!_yearArr) {
        _yearArr = [NSMutableArray array];
        for (int i = 1970; i < 2099; i ++) {
            [_yearArr addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _yearArr;
}

// get the month
- (NSMutableArray *)monthArr {
    if (!_monthArr) {
        _monthArr = [NSMutableArray array];
        for (int i = 1; i <= 12; i++) {
            [_monthArr addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _monthArr;
}

// Get the number of days in the current month
- (NSMutableArray *)dayArr {
    if (!_dayArr) {
        _dayArr = [NSMutableArray array];
        for (int i = 1; i <= 31; i++) {
            [_dayArr addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _dayArr;
}

// get the hour
- (NSMutableArray *)hourArr {
    if (!_hourArr) {
        _hourArr = [NSMutableArray array];
        for (int i = 0; i < 24; i ++) {
            [_hourArr addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _hourArr;
}

// get minutes
-(NSMutableArray *)minuteArr{
    if (_minuteArr == nil) {
        _minuteArr = [NSMutableArray array];
        for (int i = 0; i<60; i++) {
            [_minuteArr addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return _minuteArr;
}

// get seconds
-(NSMutableArray *)secondArr{
    if (_secondArr == nil) {
        _secondArr = [NSMutableArray array];
        for (int i = 0; i<60; i++) {
            [_secondArr addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return _secondArr;
}

//- (void)refreshDay {
//    NSMutableArray *arr = [NSMutableArray array];
//    for (int i = 1; i < [self getDayNumber:self.year.intValue month:self.month.intValue].intValue + 1; i ++) {
//        [arr addObject:[NSString stringWithFormat:@"%d", i]];
//    }
//
//    [self.dataArray replaceObjectAtIndex:2 withObject:arr];
//    [self.pickerView reloadComponent:2];
//}
//
//- (NSString *)getDayNumber:(int)year month:(int)month{
//    NSArray *days = @[@"31", @"28", @"31", @"30", @"31", @"30", @"31", @"31", @"30", @"31", @"30", @"31"];
//    if (2 == month && 0 == (year % 4) && (0 != (year % 100) || 0 == (year % 400))) {
//        return @"29";
//    }
//    return days[month - 1];
//}

@end
