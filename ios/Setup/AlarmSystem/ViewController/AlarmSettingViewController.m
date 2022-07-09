//
//  AlarmSettingViewController.m
//  demo
//
//  Created by qin on 2020/9/24.
//  Copyright © 2020 Macrovideo. All rights reserved.
//

#import "AlarmSettingViewController.h"
#import "TimeAlarmTableViewController.h"
#import "AlarmZoonViewController.h"
#import "LoginDevice.h"
#import "DeviceSettingManager.h"
#define ARM_SWITCH @"ARM_SWITCH" //arm/disarm switch
#define ARM_TIME @"TIME" //Alarm period
#define ARM_AREA @"AREA" //Alarm area
#define ARM_VOICE @"VOICE" //Alarm sound switch
#define AI_SWITCH @"AI_SWITCH" //AI switch
#define ARM_VOICETYPE @"VOICE_TYPE" //Type of alarm sound
#define MOTION_SWITCH @"MOTION_SWITCH" //Motion detection switch
#define SMOKE_SWITCH @"SMOKE_SWITCH" //SMOKE ALARM SWITCH
#define SMOKE_CONTACT @"SMOKE_CONTACT" //SMOKE ALARM CONTACT

@interface AlarmSettingViewController ()<UITableViewDelegate,UITableViewDataSource,TimeAlarmTableViewControllerDelegate,AlarmZoonViewControllerDelegate,UITextFieldDelegate>

@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,strong)UISwitch *setSwitch; //arm/disarm switch
@property(nonatomic,strong)UISwitch *audioSwitch; //Alarm sound switch
@property(nonatomic,strong)UISwitch *AISwitch; //AI switch
@property(nonatomic,strong)UISwitch *motionSwitch; //Humanoid detection switch
@property(nonatomic,strong)UISwitch *smokeSwitch; //smoke alarm switch

@property(nonatomic,assign)int  threadId;
@property(nonatomic,assign)BOOL isAlarmAreaChange;
@property(nonatomic,assign)BOOL isAlarmTimeChange;
@property(nonatomic,strong)NSMutableArray *settingsArray;

@property(nonatomic,strong)NSMutableArray *typeArray;
@property(nonatomic,strong)NSMutableArray *normalSettingArray;
@property(nonatomic,strong)NSMutableArray *smokeArray;

@end

@implementation AlarmSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Alarm settings", @"Alarm settings");
    UIImage *leftImage=[[UIImage imageNamed:@"common_btn_back_gray"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:leftImage style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    
    if (self.alarmInfo == nil) {
        self.alarmInfo = self.info.alarmConfig;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.setSwitch.on = self.alarmInfo.bMainAlarmSwitch;

    self.audioSwitch.on = self.alarmInfo.bAlarmAudioSwitch;
    self.motionSwitch.on = self.alarmInfo.bMotionAlarmSwitch;
    self.smokeSwitch.on = self.info.otherConfig.smokeEnable == 1 ? YES : NO;
    
    self.settingsArray = [[NSMutableArray alloc]init];
    self.typeArray = [[NSMutableArray alloc]init];
    self.normalSettingArray = [[NSMutableArray alloc]init];
    self.smokeArray = [[NSMutableArray alloc]init];
    [self setupData];
    
    [self.view addSubview:self.tableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)setupData {
    [self.settingsArray removeAllObjects];
    NSMutableArray *armSwitchArr = [[NSMutableArray alloc]init];
    [armSwitchArr addObject:ARM_SWITCH];
    [self.settingsArray addObject:armSwitchArr];
    if (self.setSwitch.on) {
        if (self.alarmInfo.AIEnble) {
            [self.typeArray addObject:AI_SWITCH];
        }
        int count = 0;
        if (self.alarmInfo.AIEnble == YES){
            count++;
        }
        if (self.info.otherConfig.smokeEnable != 0) {
            count++;
        }
        if (self.info.thermalConfig.cryDetectionPri == YES &&
            self.info.thermalConfig.highTempPri == NO &&
            self.info.thermalConfig.lowTempPri == NO &&
            self.info.thermalConfig.FTemperaturePri == NO) {
            count++;
        }
        if (count > 0) {
            [self.typeArray addObject:MOTION_SWITCH];
        }
        
        if (self.alarmInfo.canSetAlarmArea) {
            [self.normalSettingArray addObject:ARM_TIME];
            [self.normalSettingArray addObject:ARM_AREA];
        }
        if(self.alarmInfo.hasSoundCtrl){
            [self.normalSettingArray addObject:ARM_VOICE];
        }
        if (self.loginResult.alarmAction == 1 || self.loginResult.alarmAction == 3) {
            if (self.audioSwitch.on == YES) {
                [self.normalSettingArray addObject:ARM_VOICETYPE];
            }
        }
        
        if (self.info.otherConfig.smokeEnable != 0) {
            [self.smokeArray addObject:SMOKE_SWITCH];
            if (self.smokeSwitch.on == YES) {
                [self.smokeArray addObject:SMOKE_CONTACT];
            }
        }
        
        if (self.typeArray.count > 0) {
            [self.settingsArray addObject:self.typeArray];
        }
        if (self.normalSettingArray.count > 0) {
            [self.settingsArray addObject:self.normalSettingArray];
        }
        if (self.smokeArray.count > 0) {
            [self.settingsArray addObject:self.smokeArray];
        }
    }else {
        [self.typeArray removeAllObjects];
        [self.normalSettingArray removeAllObjects];
        [self.smokeArray removeAllObjects];
    }
    
    [self.tableView reloadData];
}

-(void)backAction {

    if (self.setSwitch.on   == self.alarmInfo.bMainAlarmSwitch &&
        self.alarmInfo.bAlarmAudioSwitch == self.audioSwitch.on &&
        self.alarmInfo.AISwitch ==  self.AISwitch.on&&
        self.isAlarmAreaChange  ==  NO &&
        self.isAlarmTimeChange  ==  NO&&
        self.alarmInfo.bMotionAlarmSwitch == self.motionSwitch.on) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        
        self.alarmInfo.bMainAlarmSwitch     = self.setSwitch.on;
        self.alarmInfo.bAlarmAudioSwitch    = self.audioSwitch.on;
        self.alarmInfo.bMotionAlarmSwitch   = self.setSwitch.on; //Move alarm switch is synchronized with arm and disarm
        self.alarmInfo.AISwitch             = self.AISwitch.on;
        X_WeakSelf;
        
        [DeviceManager SetAlarmPromptInfo:self.device account:self.alarmInfo succ:^{
            X_StrongSelf
            if (strongSelf.setSwitch.on) {
                strongSelf.device.temporaryAlarmFlag = 2;
            }else{
                strongSelf.device.temporaryAlarmFlag = 0;
            }
            strongSelf.device.temporaryAlarmTimestamp = [[[NSDate alloc] init] timeIntervalSince1970] * 1000;
            
            if (strongSelf.info == nil) {
                strongSelf.info = [[NVDeviceConfigInfo alloc] init];
            }
            strongSelf.info.alarmConfig = strongSelf.alarmInfo;
            if (strongSelf.backBlock) {
                strongSelf.backBlock(strongSelf.info);
            }
        } fail:^{
            NSLog(@"Configuration saving failed");
        } shouldShowTips:NO];
    }
    
}

-(void)setAlarmTimeArr:(NSMutableArray *)timeArr isAllDay:(BOOL)isAllDay{
    if (timeArr != self.alarmInfo.alarmTimeArr || isAllDay != self.alarmInfo.isAlldayAlarm) {
        self.isAlarmTimeChange = YES;
    }
    self.alarmInfo.alarmTimeArr = timeArr;
    self.alarmInfo.isAlldayAlarm = isAllDay;
   
}

-(void)setAlarmAreaArr:(NSMutableArray *)AreaArr{
    if (AreaArr) {
        self.isAlarmAreaChange = YES;
        [self.alarmInfo.alarmAreaArr setArray:AreaArr];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settingsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = self.settingsArray[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.detailTextLabel.text = nil;
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (indexPath.section > self.settingsArray.count) {
        return nil;
    }
    NSMutableArray *array = self.settingsArray[indexPath.section];
    if (indexPath.row > array.count) {
        return nil;
    }
    cell.accessoryView = nil;
    NSString *setting = array[indexPath.row];
    if([setting isEqual:ARM_SWITCH]) {
cell.textLabel.text = NSLocalizedString(@"Open arm and disarm", nil);
        UIView *view = [[UIView alloc] initWithFrame:self.setSwitch.frame];
        [view addSubview:self.setSwitch];
        cell.accessoryView = view;
    }else if ([setting isEqual:ARM_SWITCH]) {
        cell.textLabel.text = NSLocalizedString(@"Human detection", @"Human detection");
        self.AISwitch.on = self.alarmInfo.AISwitch;
        UIView *view = [[UIView alloc] initWithFrame:self.AISwitch.frame];
        [view addSubview:self.AISwitch];
        cell.accessoryView = view;
    }else if ([setting isEqual:MOTION_SWITCH]) {
        cell.textLabel.text = NSLocalizedString(@"Motion Detection", @"Motion Detection");
        UIView *view = [[UIView alloc] initWithFrame:self.motionSwitch.frame];
        [view addSubview:self.motionSwitch];
        cell.accessoryView = view;
    }else if([setting isEqual:ARM_TIME]){
        cell.textLabel.text = NSLocalizedString(@"Alarm time period", @"Alarm time period");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if([setting isEqual:ARM_AREA]){
        cell.textLabel.text = NSLocalizedString(@"Alarm area", nil);
        cell.detailTextLabel.text = [NSString stringWithFormat:@""];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (self.alarmInfo.alarmAreaRow < 1 || self.alarmInfo.alarmAreaColumn < 1) {
            cell.hidden = YES;
        }
    }else if([setting isEqual:ARM_VOICE]){
        cell.textLabel.text = NSLocalizedString(@"Alarm tone", nil);
        UIView *view = [[UIView alloc] initWithFrame:self.audioSwitch.frame];
        [view addSubview:self.audioSwitch];
        cell.accessoryView = view;
    }else if ([setting isEqualToString:ARM_VOICETYPE]){
        cell.textLabel.text = NSLocalizedString(@"Beep Type", @"Beep Type");
        if (self.info.otherConfig.nSpeechPlayerType == 1) {
            cell.detailTextLabel.text = NSLocalizedString(@"default", @"default");
        }else {
            cell.detailTextLabel.text = NSLocalizedString(@"custom", @"custom");
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if ([setting isEqualToString:SMOKE_SWITCH]){
        cell.textLabel.text = NSLocalizedString(@"Smoke Detection", @"Smoke Detection");
        cell.detailTextLabel.text = nil;
        UIView *view = [[UIView alloc] initWithFrame:self.smokeSwitch.frame];
        [view addSubview:self.smokeSwitch];
        cell.accessoryView = view;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else if ([setting isEqualToString:SMOKE_CONTACT]){
        cell.textLabel.text = NSLocalizedString(@"Notification method", @"Notification method");
       
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section > self.settingsArray.count) {
        return;
    }
    NSMutableArray *array = self.settingsArray[indexPath.section];
    if (indexPath.row > array.count) {
        return;
    }
    NSString *setting = array[indexPath.row];
    if([setting isEqual:ARM_TIME]){
        TimeAlarmTableViewController *time = [[TimeAlarmTableViewController alloc]init];
        time.timeDelegate = self;
        time.alarmInfo = self.alarmInfo;
        time.device = self.device;
        [self.navigationController pushViewController:time animated:YES];
    }else if([setting isEqual:ARM_AREA]){
        if (!self.setSwitch.on) {
           //Turn on the alarm switch first
            return;
        }
        self.threadId ++;
        [self alarmZoonPlay:self.threadId];
    }if ([setting isEqualToString:ARM_VOICETYPE]){
       
    }if ([setting isEqualToString:SMOKE_CONTACT]){
      
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = self.settingsArray[indexPath.section];
    NSString *setting = array[indexPath.row];
    if([setting isEqual:ARM_AREA]) {
        if (self.alarmInfo.alarmAreaRow < 1 || self.alarmInfo.alarmAreaColumn < 1) {
            return 0.01; ;
        }
    }
    
    return 50;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.typeArray.count > 0 && section == 1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, 30)];
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, kWidth - 30, 30)];
        title.font = [UIFont systemFontOfSize:13];
        [view addSubview:title];
        title.text = NSLocalizedString(@"Alarm mode", @"Alarm mode");
        return view;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.typeArray.count > 0 && section == 1) {
        return 30;
    }
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, 0.01)];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    return YES;
}

#pragma mark - 报警区域登录
-(void)alarmZoonPlay:(int)thread{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[LoginDevice shareOperation]loginDeviceWithDevice:self.device addConnectType:2 completionHandler:^(LoginHandle *loginResult) {
            if (thread == self.threadId) {
                self.threadId ++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (loginResult.nResult == RESULT_CODE_SUCCESS) {
                        AlarmZoonViewController *alarmZoon = [[AlarmZoonViewController alloc]init];
                        alarmZoon.loginResult = loginResult;
                        alarmZoon.areaDelegate = self;
                        alarmZoon.device = self.device;
                        alarmZoon.config = self.alarmInfo;
                        [self.navigationController pushViewController:alarmZoon animated:YES];
                        
                    }else if (loginResult.nResult == NV_RESULT_DESC_NO_USER || loginResult.nResult == NV_RESULT_DESC_PWD_ERR){
                        // wrong account password
                    }else{
                       //fail
                    }
                });
            }else{
               
            }
        }];
    });
}


#pragma mark - Switch Action
-(void)changeAlarmState:(UISwitch *)switcher {
    [self setupData];
}

-(void)changeAudioState:(UISwitch *)switcher {
    if (switcher.on) {
        if (self.loginResult.alarmAction == 1 || self.loginResult.alarmAction == 3) {
            for (int i = 0; i < self.normalSettingArray.count; i++) {
                NSString *rowType = self.normalSettingArray[i];
                if ([rowType isEqualToString:ARM_VOICE]) {
                    [self.normalSettingArray insertObject:ARM_VOICETYPE atIndex:i + 1];
                }
            }
        }
    }else{
        if ([self.normalSettingArray containsObject:ARM_VOICETYPE]) {
            [self.normalSettingArray removeObject:ARM_VOICETYPE];
        }
    }
    [self.tableView reloadData];
}

-(void)changeSmokeSwitch{
    if (self.smokeSwitch.on) {
        for (int i = 0; i < self.smokeArray.count; i++) {
            NSString *rowType = self.smokeArray[i];
            if ([rowType isEqualToString:SMOKE_SWITCH]) {
                [self.smokeArray insertObject:SMOKE_CONTACT atIndex:i + 1];
            }
        }
    }else{
        if ([self.smokeArray containsObject:SMOKE_CONTACT]) {
            [self.smokeArray removeObject:SMOKE_CONTACT];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - 懒加载
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

-(UISwitch *)setSwitch{
    if (_setSwitch == nil) {
        _setSwitch = [[UISwitch alloc]init];
        [_setSwitch addTarget:self action:@selector(changeAlarmState:) forControlEvents:UIControlEventValueChanged];
    }
    return _setSwitch;
}

-(UISwitch *)audioSwitch{
    if (_audioSwitch == nil) {
        _audioSwitch = [[UISwitch alloc]init];
        [_audioSwitch addTarget:self action:@selector(changeAudioState:) forControlEvents:UIControlEventValueChanged];
    }
    return _audioSwitch;
}

- (UISwitch *)AISwitch{
    if (_AISwitch == nil) {
        _AISwitch = [[UISwitch alloc] init];
    }
    return _AISwitch;
}

- (UISwitch *)motionSwitch{
    if (_motionSwitch == nil) {
        _motionSwitch = [[UISwitch alloc] init];
    }
    return _motionSwitch;
}

- (UISwitch *)smokeSwitch{
    if (_smokeSwitch == nil) {
        _smokeSwitch = [[UISwitch alloc] init];
        [_smokeSwitch addTarget:self action:@selector(changeSmokeSwitch) forControlEvents:UIControlEventValueChanged];
    }
    return _smokeSwitch;
}

@end
