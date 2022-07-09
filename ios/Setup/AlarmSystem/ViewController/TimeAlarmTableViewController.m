//
//  TimeAlarmTableViewController.m
//  demo
//
//  Created by MacroVideo on 2018/1/18.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import "TimeAlarmTableViewController.h"
#import "TimeAlarmTableViewCell.h"
#import "AlarmTimeModel.h"
#import "TimeAlarmPickerView.h"
#import "NSDate+Formatter.h"
@interface TimeAlarmTableViewController ()
@property(nonatomic,assign)BOOL isShow;
@property(nonatomic,strong)NSMutableArray *timeArr;
@property(nonatomic,strong)UIView *pickerView;
@property(nonatomic,strong)UIDatePicker *startDatePicker;
@property(nonatomic,strong)UIDatePicker *endDatePicker;

@property(nonatomic,assign)BOOL isDuringDaySeleted;
@property(nonatomic,assign)BOOL isNightDaySeleted;

@property(nonatomic,assign)NSInteger selectRow;
@property(nonatomic,strong)NSMutableArray *originalTimeArr;
@property(nonatomic,strong)TimeAlarmPickerView *pickTimeView;
@property(nonatomic,strong)NSMutableArray *selectModelArr;

@end

@implementation TimeAlarmTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Alarm time period", @"Alarm time period");
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeAlarmTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"alarmCell"];

    UIImage *leftImage=[[UIImage imageNamed:@"common_btn_back_gray"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:leftImage style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    
    [self isDayAndNight];
    self.originalTimeArr = [NSMutableArray array];
    self.selectModelArr = [NSMutableArray array];
    for (AlarmTimeModel *model in self.timeArr) {
        [self.originalTimeArr addObject:model];
        [self.selectModelArr addObject:[NSNumber numberWithBool:model.isSelect]];
    }
    self.isDuringDaySeleted = [self isDuringDay];
    self.isNightDaySeleted = [self isNightDay];
    if (self.timeArr.count > 0) {
        self.isShow = YES;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *nowDate = [dateFormatter stringFromDate:[NSDate date]];
    NSArray *dateArr = [nowDate componentsSeparatedByString:@" "];
    
    if (!self.isNightDaySeleted && !self.isDuringDaySeleted &&!self.alarmInfo.isAlldayAlarm) {
        self.selectRow = 3;
    }else {
        if (self.alarmInfo.isAlldayAlarm) {
            self.selectRow = 0;
        }else if (self.isDuringDaySeleted) {
            self.selectRow = 1;
            AlarmTimeModel *durningDay = [[AlarmTimeModel alloc]init];
//            durningDay.beginTime = [[NSString alloc]dataWithString:@"08:00:00"];
//            durningDay.endTime = [[NSString alloc]dataWithString:@"20:00:00"];
            durningDay.beginTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 08:00:00",dateArr.firstObject]];
            durningDay.endTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 20:00:00",dateArr.firstObject]];
            durningDay.isSelect = self.isDuringDaySeleted;
            [self.originalTimeArr addObject:durningDay];
        }else if (self.isNightDaySeleted) {
            self.selectRow = 2;
            AlarmTimeModel *nightDay = [[AlarmTimeModel alloc]init];
//            nightDay.beginTime = [[NSString alloc]dataWithString:@"20:00:00"];
//            nightDay.endTime = [[NSString alloc]dataWithString:@"08:00:00"];
            nightDay.beginTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 20:00:00",dateArr.firstObject]];
            nightDay.endTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 08:00:00",dateArr.firstObject]];
            nightDay.isSelect = self.isNightDaySeleted;
            [self.originalTimeArr addObject:nightDay];
        }
    }
    
    self.tableView.tableFooterView = [self footerView];
}


-(void)backAction{
    
    //select all day
    if (self.alarmInfo.isAlldayAlarm) {
        [self.timeArr removeAllObjects];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *nowDate = [dateFormatter stringFromDate:[NSDate date]];
    NSArray *dateArr = [nowDate componentsSeparatedByString:@" "];
    
    //select day
    if (self.isDuringDaySeleted) {
        [self.timeArr removeAllObjects];
        AlarmTimeModel *durningDay = [[AlarmTimeModel alloc]init];
//        durningDay.beginTime = [[NSString alloc]dataWithString:@"08:00:00"];
//        durningDay.endTime = [[NSString alloc]dataWithString:@"20:00:00"];
        durningDay.beginTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 08:00:00",dateArr.firstObject]];
        durningDay.endTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 20:00:00",dateArr.firstObject]];
        durningDay.isSelect = self.isDuringDaySeleted;
        [self.timeArr addObject:durningDay];

    }
    
   //select night
    if (self.isNightDaySeleted) {
        [self.timeArr removeAllObjects];
        AlarmTimeModel *nightDay = [[AlarmTimeModel alloc]init];
//        nightDay.beginTime = [[NSString alloc]dataWithString:@"20:00:00"];
//        nightDay.endTime = [[NSString alloc]dataWithString:@"08:00:00"];
        nightDay.beginTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 20:00:00",dateArr.firstObject]];
        nightDay.endTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 08:00:00",dateArr.firstObject]];
        nightDay.isSelect = self.isNightDaySeleted;
        [self.timeArr addObject:nightDay];
    }
    
    //When the time period is set but not checked at all
    if (self.timeArr.count > 0) {
        int selectModelCount = 0;
        for (AlarmTimeModel *model in self.timeArr) {
            if (model.isSelect) {
                selectModelCount ++;
            }
        }
        if (selectModelCount == 0) {
          
            return;
        }
    }
    
    BOOL isChangeTime = NO;
    if (self.timeArr.count == self.originalTimeArr.count) {
        AlarmTimeModel *model = nil;
        AlarmTimeModel *originalModel = nil;
        for (int i = 0; i < self.timeArr.count; i++) {
            model = self.timeArr[i];
            originalModel = self.originalTimeArr[i];
            if (!([[model.beginTime timeStringNoSecond] isEqualToString:[originalModel.beginTime timeStringNoSecond]] && [[model.endTime timeStringNoSecond] isEqualToString:[originalModel.endTime timeStringNoSecond]])) {
                isChangeTime = YES;
            }else {
                if (i < self.selectModelArr.count) {
                    if (self.selectModelArr[i] != [NSNumber numberWithBool:model.isSelect]) {
                        isChangeTime = YES;
                    }
                }
            }
        }
    }else {
        isChangeTime = YES;
    }
    if (!isChangeTime) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self.timeDelegate setAlarmTimeArr:self.timeArr isAllDay:(BOOL)self.alarmInfo.isAlldayAlarm];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    TimeAlarmTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"alarmCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.seletedImageView.hidden = YES;
    if (indexPath.row == 0) {
       cell.titleLable.text =NSLocalizedString(@"Alarm all day", nil);
        cell.detailLable.text = NSLocalizedString(@"24 hours, alert when strangers break in or objects move", nil);
        if (self.alarmInfo.isAlldayAlarm) {
        // cell.seletedImageView.image = SETTING_SELECT_IMG;
            cell.seletedImageView.hidden = NO;
            cell.seletedImageView.image = [UIImage imageNamed:@"common_btn_tick"];
        }/*else{
            cell.seletedImageView.image = SETTING_UNSELECT_IMG;
        }*/
    }else if(indexPath.row == 1){
        cell.titleLable.text = NSLocalizedString(@"Alarm during the day", nil);
        cell.detailLable.text = NSLocalizedString(@"8:00-20:00, alert when strangers break in or objects move", nil);
        if (self.isDuringDaySeleted) {
        //            cell.seletedImageView.image = SETTING_SELECT_IMG;
            cell.seletedImageView.hidden = NO;
            cell.seletedImageView.image = [UIImage imageNamed:@"common_btn_tick"];
        }/*else{
            cell.seletedImageView.image = SETTING_UNSELECT_IMG;
        }*/
    }else if (indexPath.row == 2){
       cell.titleLable.text = NSLocalizedString(@"Alarm at night", nil);
        cell.detailLable.text = NSLocalizedString(@"20:00-8:00, alert when strangers break in or objects move", nil);
        if (self.isNightDaySeleted) {
        // cell.seletedImageView.image = SETTING_SELECT_IMG;
            cell.seletedImageView.hidden = NO;
            cell.seletedImageView.image = [UIImage imageNamed:@"common_btn_tick"];
        }/*else{
            cell.seletedImageView.image = SETTING_UNSELECT_IMG;
        }*/
    }else if (indexPath.row == 3){
        cell.titleLable.text = NSLocalizedString(@"Custom Alarm", nil);
        cell.detailLable.text = NSLocalizedString(@"Limited time, remind when strangers break in or objects move", nil);
        if (!self.isNightDaySeleted && !self.isDuringDaySeleted &&!self.alarmInfo.isAlldayAlarm) {
//            cell.seletedImageView.image = SETTING_SELECT_IMG;
            cell.seletedImageView.hidden = NO;
            cell.seletedImageView.image = [UIImage imageNamed:@"common_btn_tick"];
        }/*else{
            cell.seletedImageView.image = SETTING_UNSELECT_IMG;
        }*/
    }
    cell.detailLable.adjustsFontSizeToFitWidth = YES;

    return cell;

}

-(BOOL)isDuringDay{
    if (self.alarmInfo.alarmTimeArr.count > 0) {
        for (AlarmTimeModel *model in self.alarmInfo.alarmTimeArr) {
            if (self.alarmInfo.alarmTimeArr.count == 1) {
                if (model.isSelect && [[model.beginTime timeStringNoSecond] isEqualToString:@"08:00"] &&[[model.endTime timeStringNoSecond]isEqualToString:@"20:00"]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(BOOL)isNightDay{
    if (self.alarmInfo.alarmTimeArr.count > 0) {
        for (AlarmTimeModel *model in self.alarmInfo.alarmTimeArr) {
            if (self.alarmInfo.alarmTimeArr.count == 1) {
                if (model.isSelect && [[model.beginTime timeStringNoSecond] isEqualToString:@"20:00"] &&[[model.endTime timeStringNoSecond]isEqualToString:@"08:00"]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(void)isDayAndNight{
    if (self.alarmInfo.alarmTimeArr.count > 0) {
        for (AlarmTimeModel *model in self.alarmInfo.alarmTimeArr) {
            if (self.alarmInfo.alarmTimeArr.count == 1) {
                if (!([[model.beginTime timeStringNoSecond] isEqualToString:@"20:00"] && [[model.endTime timeStringNoSecond] isEqualToString:@"08:00"])) {
                    if (!([[model.beginTime timeStringNoSecond] isEqualToString:@"08:00"] && [[model.endTime timeStringNoSecond] isEqualToString:@"20:00"])) {
                        [self.timeArr addObject:model];
                    }
                }
            }else {
                [self.timeArr addObject:model];
            }
        }
    }
}

-(UIView*)footerView{
    UIView *bgView = [[UIView alloc]init];

    if (self.isShow) {
        bgView.frame = CGRectMake(0, 0, kWidth, 45 + 45 * self.timeArr.count);
        for(int i = 0;i < self.timeArr.count ; i ++) {
            
            AlarmTimeModel *model = self.timeArr[i];
            UILabel *timeLable = [[UILabel alloc]initWithFrame:CGRectMake(30, 44*i, 200, 44)];
            timeLable.text = [NSString stringWithFormat:@"%@ - %@",[model.beginTime timeStringNoSecond],[model.endTime timeStringNoSecond]];
            UIButton *deleBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(bgView.frame) - 40 - 30, 12+44*i+i, 20, 20)];
            [deleBtn setBackgroundImage:[UIImage imageNamed:@"common_btn_cancle_nor"] forState:UIControlStateNormal];
            deleBtn.tag = i;
            UIButton *seleBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(bgView.frame) - 40, 12+44*i+i, 20, 20)];
            seleBtn.tag = i;
            if (model.isSelect) {
                [seleBtn setImage:[UIImage imageNamed:@"common_btn_select_nor"] forState:UIControlStateNormal];
            }else{
                [seleBtn setImage:[UIImage imageNamed:@"common_btn_unselect_nor"] forState:UIControlStateNormal];
            }
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(30, 44+44*i+i, kWidth - 30, 1)];
            [bgView addSubview:line];
            [bgView addSubview:timeLable];
            [bgView addSubview:deleBtn];
            [bgView addSubview:seleBtn];
            
            [deleBtn addTarget:self action:@selector(deleAction:) forControlEvents:UIControlEventTouchUpInside];
            [seleBtn addTarget:self action:@selector(seleAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        NSString *addStr = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Add time period", @""),NSLocalizedString(@"(up to three can be added)", @"")];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:addStr];
        
        UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectMake( 20, 45 * self.timeArr.count  + 2,kWidth-20, 40)];
//        [addBtn setTitle:NSLocalizedString(@"lblAddAlarmTime", nil) forState:UIControlStateNormal];
        [addBtn setAttributedTitle:attributedStr forState:UIControlStateNormal];
        addBtn.titleLabel.numberOfLines = 0;
        [addBtn setImage:[UIImage imageNamed:@"set_alarm_icon_addtime"] forState:UIControlStateNormal];
        addBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        addBtn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
        addBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [addBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [bgView addSubview:addBtn];
        [addBtn addTarget:self action:@selector(addTimeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.timeArr.count == 3) {
             bgView.frame = CGRectMake(0, 0, kWidth, 45 * self.timeArr.count);
            [addBtn removeFromSuperview];
        }
    }
    
    return bgView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 70;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 15;
    }
    return 0.01;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.alarmInfo.canSetAlarmArea) {
        //The device is not supported and needs to be updated
        return;
    }
    if (self.selectRow == indexPath.row) {
        return;
    }
    if (indexPath.row == 0) {
        self.alarmInfo.isAlldayAlarm = YES;
        self.isNightDaySeleted = NO;
        self.isDuringDaySeleted = NO;
        self.isShow = NO;
    }else if (indexPath.row == 1){
        self.alarmInfo.isAlldayAlarm = NO;
        self.isNightDaySeleted = NO;
        self.isDuringDaySeleted = YES;
        self.isShow = NO;
    }else if (indexPath.row == 2){
        self.alarmInfo.isAlldayAlarm = NO;
        self.isNightDaySeleted = YES;
        self.isDuringDaySeleted = NO;
        self.isShow = NO;
    }else if (indexPath.row == 3) {
        self.isShow = !self.isShow;
        self.alarmInfo.isAlldayAlarm = NO;
        self.isNightDaySeleted = NO;
        self.isDuringDaySeleted = NO;
    }
    self.tableView.tableFooterView = [self footerView];
    [self.tableView reloadData];
    self.selectRow = indexPath.row;
}




-(void)deleAction:(UIButton*)sender{
    AlarmTimeModel *model = self.timeArr[sender.tag];
    [self.timeArr removeObject:model];
    self.tableView.tableFooterView = [self footerView];
}

-(void)seleAction:(UIButton*)sender{
    AlarmTimeModel *model = self.timeArr[sender.tag];
    if (model.isSelect) {
        model.isSelect = NO;
        [sender setImage:[UIImage imageNamed:@"common_btn_unselect_nor"] forState:UIControlStateNormal];
    }else{
        model.isSelect = YES;
        self.alarmInfo.isAlldayAlarm = NO;
        [sender setImage:[UIImage imageNamed:@"common_btn_select_nor"] forState:UIControlStateNormal];
    }
    self.timeArr[sender.tag] = model;
    [self.tableView reloadData];
}

-(void)addTimeAction:(UIButton*)sender{
    if (self.timeArr.count ==3) {
        //up to 3
        return;
    }
    [self setupPickView];
}

-(NSMutableArray *)timeArr{
    if (!_timeArr) {
        _timeArr = [[NSMutableArray alloc]init];
    }
    return _timeArr;
}

-(void)setupPickView{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *nowDate = [dateFormatter stringFromDate:[NSDate date]];
    NSArray *dateArr = [nowDate componentsSeparatedByString:@" "];

    if (self.pickTimeView) {
        self.pickTimeView = nil;
    }
    self.pickTimeView = [[TimeAlarmPickerView alloc]initWithFrame:self.view.frame];
    [self.pickTimeView show];
    X_WeakSelf;
    self.pickTimeView.backBlock = ^(NSString * _Nonnull startTime, NSString * _Nonnull endTime) {
        X_StrongSelf;
        NSDate *startDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",dateArr.firstObject, startTime]];
        NSDate *endDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",dateArr.firstObject, endTime]];
        AlarmTimeModel *model = [[AlarmTimeModel alloc]init];
        model.isSelect = YES;
        model.beginTime = startDate;
        model.endTime = endDate;
        [strongSelf.timeArr addObject:model];
        strongSelf.tableView.tableFooterView = [strongSelf footerView];
    };
}

- (void)startDateChange:(UIDatePicker *)datePicker {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //set time format
    formatter.dateFormat = @" hh : mm";
    NSString *dateStr = [formatter  stringFromDate:datePicker.date];

    NSLog(@"%@",dateStr);
}

- (void)endDateChange:(UIDatePicker *)datePicker {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //set time format
    formatter.dateFormat = @" hh : mm";
    NSString *dateStr = [formatter  stringFromDate:datePicker.date];
    
    NSLog(@"%@",dateStr);
}

-(void)clickAction:(UIButton*)sender{
    if (sender.tag == 1) {
        //Sure
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        //set time format
        formatter.dateFormat = @"HH:mm:ss";
        NSString *startDateStr = [formatter  stringFromDate:self.startDatePicker.date];
        NSString *endDateStr = [formatter  stringFromDate:self.endDatePicker.date];
        NSLog(@"%@ - %@",startDateStr,endDateStr);
        if([startDateStr isEqualToString:endDateStr]){
//            iToast *toast = [iToast makeToast:NSLocalizedString(@"Start time and end time cannot be the same", nil)];
//            [toast setToastPosition:kToastPositionCenter];
//            [toast setToastDuration:kToastDurationShort];
//            [toast show];
        }else{
            AlarmTimeModel *model = [[AlarmTimeModel alloc]init];
            model.isSelect = YES;
            model.beginTime = self.startDatePicker.date;
            model.endTime = self.endDatePicker.date;
            [self.timeArr addObject:model];
            self.tableView.tableFooterView = [self footerView];
            [self.pickerView removeFromSuperview];
        }//end
    }else{
        //Cancel
        [self.pickerView removeFromSuperview];
    }
    
}

-(UIView *)pickerView{
    if (!_pickerView) {
        _pickerView = [[UIView alloc]init];
    }
    return _pickerView;
}

-(UIDatePicker *)startDatePicker{
    if (!_startDatePicker) {
        _startDatePicker = [[UIDatePicker alloc]init];
        _startDatePicker.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    return _startDatePicker;
}

-(UIDatePicker *)endDatePicker{
    if (!_endDatePicker) {
        _endDatePicker = [[UIDatePicker alloc]init];
        _endDatePicker.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    return _endDatePicker;
}
@end
