//
//  DeviceSettingViewController.m
//  demo
//
//  Created by VINSON on 2020/7/29.
//  Copyright © 2020 Macrovideo. All rights reserved.
//

#import "DeviceSettingViewController.h"
#import "../Kit/XXtableViewShell.h"
#import "NetworkConfigInfo.h"
#import "../Kit/XXocUtils.h"
#import "DeviceSettingManager.h"
#import "AlarmSettingViewController.h"

typedef enum : NSUInteger {
    TableRowTypeDetail = 1, // device information
    TableRowTypeNetwork, // device network
    TableRowTypePassword, // device password
    TableRowTypeTime, // device time
    TableRowTypeDeviceVersion, // firmware detection version detection
    
    TableRowTypeAlarm, // device alarm
    TableRowTypeRecord, // device recording
    TableRowTypePIR, // PIR sensitivity
    TableRowTypePTZXCruise, // preset cruise
    TableRowTypeLightControl, // Light control settings
    TableRowTypeTempOrCryAlarm, // temperature control alarm or cry alarm
    TableRowTypeLightSensitivity, // lamp sensitivity
    TableRowTypeTopology, // Cascading Diagram
    TableRowTypePTZSpeed, // PTZ speed
    TableRowTypeVoice, // device volume
    TableRowTypePwoerMode, // power mode

    TableRowTypeAdvancedSetting, // advanced settings
    
} TableRowType;

@interface DeviceSettingViewController ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *buttonShowingConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *buttonHiddenConstraints;

@property (nonatomic,strong) XXtableViewShell *shell;

@end

@implementation DeviceSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActiveHandle:) name:@"ON_BECOME_ACTIVE" object:nil];
    
    self.title = NSLocalizedString(@"Settings", @"Settings");
    UIImage *leftImage=[[UIImage imageNamed:@"common_btn_back_gray"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:leftImage style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    
    self.resetButton.layer.cornerRadius = 23;
    [self.resetButton setTitle:NSLocalizedString(@"Reset to factory settings", @"Reset to factory settings") forState:UIControlStateNormal];
    [self.resetButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.resetButton.hidden = YES;

    _shell = [XXtableViewShell new];
    [_shell shell:self.tableView];
    [_shell configRowType:nil loadType:0 systemStyle:UITableViewCellStyleValue1 height:50];
    __weak typeof(self) ws = self;
    _shell.onRowClicked = ^(XXtableViewShell * _Nonnull shell, NSIndexPath * _Nonnull indexPath, id  _Nonnull data) {
        NSDictionary *info = data;
        int ID = [info[@"ID"] intValue];
        [ws onClicked:ID];
    };
    

    
    [self setupRow];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 0.1)];
    if (self.device.deviceSoftwareUpdateStatus == 2) {
        _shell.haveRedDot = YES;
    }else {
        _shell.haveRedDot = NO;
    }
    _tableView.sectionHeaderHeight = 30;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark - 添加新的row请在此函数添加
-(void)setupRow{
    [self setSection1];
    [self setSection2];
}



-(void)setSection1{
    NSMutableArray *rowData = [NSMutableArray new];
    /// Device Information
    NSString *deviceName = @"";
    if (self.device.strName) {
        deviceName = self.device.strName;
    }
    
    NSMutableDictionary *deviceMessage = [[NSMutableDictionary alloc] init];
    [deviceMessage setObject:NSLocalizedString(@"device information", @"device information") forKey:@"Title"];
    [deviceMessage setObject:deviceName forKey:@"Detail"];
    [deviceMessage setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"AccessoryType"];
    [deviceMessage setObject:@(TableRowTypeDetail) forKey:@"ID"];
    UIImage *deviceMessageImage = [UIImage imageNamed:@"set_icon_information"];
    if (deviceMessageImage) {
        [deviceMessage setObject:deviceMessageImage forKey:@"Image"];
    }
    [rowData addObject:deviceMessage];
    
    /// Device network
    NSString *detail = @"";
    if (self.info) {
        if (self.info.networkconfig.nWifiMode == NV_WIFI_MODE_AP) { //ap model
            detail = self.info.networkconfig.strAPName;
        }else if (self.info.networkconfig.nWifiMode == NV_WIFI_MODE_STATION){
            detail = self.info.networkconfig.strStationName;
        }else if (self.info.networkconfig.nWifiMode == NV_WIFI_MODE_MESHLINK){
        }
    }

        NSMutableDictionary *deviceNetwork = [[NSMutableDictionary alloc] init];
        [deviceNetwork setObject:NSLocalizedString(@"Replace device network", @"Replace device network") forKey:@"Title"];
        [deviceNetwork setObject:detail forKey:@"Detail"];
        [deviceNetwork setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"AccessoryType"];
        [deviceNetwork setObject:@(TableRowTypeNetwork) forKey:@"ID"];
        [deviceNetwork setObject:@(NO) forKey:@"CellDisable"];
        deviceMessageImage = [UIImage imageNamed:@"set_icon_network"];
        if (deviceMessageImage) {
            [deviceNetwork setObject:deviceMessageImage forKey:@"Image"];
        }
        [rowData addObject:deviceNetwork];
    
    /// Device password
    NSMutableDictionary *PWD = [[NSMutableDictionary alloc] init];
    [PWD setObject:NSLocalizedString(@"device password", @"device password") forKey:@"Title"];
    [PWD setObject:@"" forKey:@"Detail"];
    [PWD setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"AccessoryType"];
    [PWD setObject:@(TableRowTypePassword) forKey:@"ID"];
    UIImage *PWDImage = [UIImage imageNamed:@"set_icon_password"];
    if (PWDImage) {
        [PWD setObject:PWDImage forKey:@"Image"];
    }
    [rowData addObject:PWD];

   /// Device time
    NSMutableDictionary *deviceTime = [[NSMutableDictionary alloc] init];
    [deviceTime setObject:NSLocalizedString(@"device time", @"device time") forKey:@"Title"];
    [deviceTime setObject:@"" forKey:@"Detail"];
    [deviceTime setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"AccessoryType"];
    [deviceTime setObject:@(TableRowTypeTime) forKey:@"ID"];
    UIImage *deviceTimeImage = [UIImage imageNamed:@"set_icon_time"];
    if (deviceTimeImage) {
        [deviceTime setObject:deviceTimeImage forKey:@"Image"];
    }
    [rowData addObject:deviceTime];
    
    /// Firmware version detection
    NSMutableDictionary *deviceVersion = [[NSMutableDictionary alloc] init];
    [deviceVersion setObject:NSLocalizedString(@"Firmware version detection", @"Firmware version detection") forKey:@"Title"];
    [deviceVersion setObject:@"" forKey:@"Detail"];
    [deviceVersion setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"AccessoryType"];
    [deviceVersion setObject:@(TableRowTypeDeviceVersion) forKey:@"ID"];
    UIImage *deviceVersionImage = [UIImage imageNamed:@"set_icon_check"];
    if (deviceVersionImage) {
        [deviceVersion setObject:deviceVersionImage forKey:@"Image"];
    }
    [rowData addObject:deviceVersion];
    
   [_shell insertSectionWithHeader:NSLocalizedString(@"General Settings", @"General Settings") row:rowData footer:@"" atIndex:0];
}

-(void)setSection2{
    NSMutableArray *secondRowData = [NSMutableArray new];
    /// Device alarm
    NSMutableDictionary *alarm = [[NSMutableDictionary alloc] init];
    [alarm setObject:NSLocalizedString(@"alarm setting", @"alarm setting") forKey:@"Title"];
    [alarm setObject:@"" forKey:@"Detail"];
    [alarm setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"AccessoryType"];
    [alarm setObject:@(TableRowTypeAlarm) forKey:@"ID"];
    UIImage *deviceTimeImage = [UIImage imageNamed:@"set_icon_alarm"];
    if (deviceTimeImage) {
        [alarm setObject:deviceTimeImage forKey:@"Image"];
    }
    [secondRowData addObject:alarm];
    
   /// Device recording
    NSMutableDictionary *video = [[NSMutableDictionary alloc] init];
    [video setObject:NSLocalizedString(@"Video settings", @"Video settings") forKey:@"Title"];
    [video setObject:@"" forKey:@"Detail"];
    [video setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"AccessoryType"];
    [video setObject:@(TableRowTypeRecord) forKey:@"ID"];
    UIImage *videoImage = [UIImage imageNamed:@"set_icon_video"];
    if (videoImage) {
        [video setObject:videoImage forKey:@"Image"];
    }
    [secondRowData addObject:video];
    
    /// PIR sensitivity
    if([self isPirable]){
        NSMutableDictionary *pirAlarm = [[NSMutableDictionary alloc] init];
        [pirAlarm setObject:NSLocalizedString(@"PIR sensitivity", @"PIR sensitivity") forKey:@"Title"];
        [pirAlarm setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"AccessoryType"];
        [pirAlarm setObject:@(TableRowTypePIR) forKey:@"ID"];
        UIImage *pirAlarmImage = [UIImage imageNamed:@"set_icon_pir"];
        if (pirAlarmImage) {
            [pirAlarm setObject:pirAlarmImage forKey:@"Image"];
        }
        [secondRowData addObject:pirAlarm];
        
    }
    
   /// Preset cruise
    if([self isPTZXCreisable]){
        NSMutableDictionary *PTZXCruise = [[NSMutableDictionary alloc] init];
        [PTZXCruise setObject:NSLocalizedString(@"PTZ cruise", @"PTZ cruise") forKey:@"Title"];
        [PTZXCruise setObject:@"" forKey:@"Detail"];
        [PTZXCruise setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"AccessoryType"];
        [PTZXCruise setObject:@(TableRowTypePTZXCruise) forKey:@"ID"];
        UIImage *PTZXCruiseImage = [UIImage imageNamed:@"set_icon_cruise"];
        if (PTZXCruiseImage) {
            [PTZXCruise setObject:PTZXCruiseImage forKey:@"Image"];
        }
        [secondRowData addObject:PTZXCruise];
        
    }
    
    /// Light control settings
    int8_t value = self.loginResult.personalizedTimer;
    if ((value&0x04)) {
        NSMutableDictionary *whiteLight = [[NSMutableDictionary alloc] init];
        [whiteLight setObject:NSLocalizedString(@"Light control settings", @"Light control settings") forKey:@"Title"];
        [whiteLight setObject:@"" forKey:@"Detail"];
        [whiteLight setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"AccessoryType"];
        [whiteLight setObject:@(TableRowTypeLightControl) forKey:@"ID"];
        UIImage *whiteLightImage = [UIImage imageNamed:@"set_icon_light"];
        if (whiteLightImage) {
            [whiteLight setObject:whiteLightImage forKey:@"Image"];
        }
        [secondRowData addObject:whiteLight];
        
    }
    
    /// Temperature control alarm or cry alarm
    if(!(self.info.thermalConfig.highTempPri == NO && self.info.thermalConfig.lowTempPri == NO && self.info.thermalConfig.cryDetectionPri == NO)){
        NSString *title = @"";
        if (self.info.thermalConfig.highTempPri == YES || self.info.thermalConfig.lowTempPri == YES) {
            title = NSLocalizedString(@"Temperature control alarm", @"Temperature control alarm");
        }else if (self.info.thermalConfig.cryDetectionPri == YES){
            title = NSLocalizedString(@"Crying Alarm", @"Crying Alarm");
        }
        NSMutableDictionary *tempAlarm = [[NSMutableDictionary alloc] init];
        [tempAlarm setObject:title forKey:@"Title"];
        [tempAlarm setObject:@"" forKey:@"Detail"];
        [tempAlarm setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"AccessoryType"];
        [tempAlarm setObject:@(TableRowTypeTempOrCryAlarm) forKey:@"ID"];
        UIImage *tempAlarmImage = [UIImage imageNamed:@"set_icon_temperature"];
        if (tempAlarmImage) {
            [tempAlarm setObject:tempAlarmImage forKey:@"Image"];
        }
        [secondRowData addObject:tempAlarm];
        
    }
        
    if (self.info.otherConfig.ptzVSensitivity != 0 || self.info.otherConfig.ptzHSensitivity != 0) {
        
        NSMutableDictionary *PTZSpeed = [[NSMutableDictionary alloc] init];
        [PTZSpeed setObject:NSLocalizedString(@"PTZ speed setting", @"PTZ speed setting") forKey:@"Title"];
        [PTZSpeed setObject:@"" forKey:@"Detail"];
        [PTZSpeed setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"AccessoryType"];
        [PTZSpeed setObject:@(TableRowTypePTZSpeed) forKey:@"ID"];
        UIImage *PTZSpeedImage = [UIImage imageNamed:@"set_icon_ytset"];
        if (PTZSpeedImage) {
            [PTZSpeed setObject:PTZSpeedImage forKey:@"Image"];
        }
        [secondRowData addObject:PTZSpeed];
    }
    if (self.info.otherConfig.speakerVol > 0) {
        /// Device volume settings
        NSMutableDictionary *video = [[NSMutableDictionary alloc] init];
        [video setObject:NSLocalizedString(@"Volume setting", @"Volume setting") forKey:@"Title"];
        [video setObject:@"" forKey:@"Detail"];
        [video setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"AccessoryType"];
        [video setObject:@(TableRowTypeVoice) forKey:@"ID"];
        UIImage *videoImage = [UIImage imageNamed:@"set_icon_volumeset"];
        if (videoImage) {
            [video setObject:videoImage forKey:@"Image"];
        }
        [secondRowData addObject:video];
    }

    if (self.info.otherConfig.powerMode > 0) {
        /// Smart Power Mode Settings
        NSMutableDictionary *powerMode = [[NSMutableDictionary alloc] init];
        [powerMode setObject:NSLocalizedString(@"Smart power supply mode setting", @"Smart power supply mode setting") forKey:@"Title"];
        [powerMode setObject:@"" forKey:@"Detail"];
        [powerMode setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"AccessoryType"];
        [powerMode setObject:@(TableRowTypePwoerMode) forKey:@"ID"];
        UIImage *powerModeImage = [UIImage imageNamed:@"set_icon_poweredby"];
        if (powerModeImage) {
            [powerMode setObject:powerModeImage forKey:@"Image"];
        }
        [secondRowData addObject:powerMode];
    }
    
    [_shell insertSectionWithHeader:NSLocalizedString(@"function setting", @"function setting") row:secondRowData footer:@"" atIndex:1];
}
-(BOOL)isPTZXCreisable{
    int8_t value = self.loginResult.personalizedTimer;
    return value&0x01 || value&0x02;
}
-(BOOL)isPirable{
    return 0 != self.info.otherConfig.nSensitivity_PRI;
}
#pragma mark - row的点击请在函数处理
- (void)onClicked:(TableRowType)type{
    switch (type) {
           //Device Information
        case TableRowTypeDetail:{
        
            break;
        }
            //replace the device network
        case TableRowTypeNetwork:{
            
            break;
        }
            //device password
        case TableRowTypePassword: {
          
            break;
        }
            //device time
        case TableRowTypeTime:{
            
            break;
        }
            //Firmware version detection
        case TableRowTypeDeviceVersion:{
         
            break;
        }
            //Alarm system
        case TableRowTypeAlarm:{
           
                AlarmSettingViewController *alarmSetting  =[[AlarmSettingViewController alloc]init];
                alarmSetting.device = self.device;
                alarmSetting.info = self.info;
                alarmSetting.loginResult = self.loginResult;
                X_WeakSelf;
                alarmSetting.backBlock = ^(NVDeviceConfigInfo *backInfo){
                    X_StrongSelf;
                    strongSelf.info = backInfo;
                };
                [self.navigationController pushViewController:alarmSetting animated:YES];
            break;
        }
            // record settings
        case TableRowTypeRecord:{
           
            break;
        }
            // PIR settings
        case TableRowTypePIR:{
           
            break;
        }
            // gimbal cruise
        case TableRowTypePTZXCruise:{
           
            break;
        }
            //Light control settings
        case TableRowTypeLightControl:{
         
            break;
        }
            //Temperature control, cry alarm
        case TableRowTypeTempOrCryAlarm:{
            
            break;
        }
            //light sensitivity
        case TableRowTypeLightSensitivity:{
            break;
        }
            //Cascade relationship diagram
        case TableRowTypeTopology:{
           
            break;
        }
            
        case TableRowTypePTZSpeed:{
           
            break;
        }
        case TableRowTypeVoice:{
           
        }
            break;
            
            //advanced settings
        case TableRowTypeAdvancedSetting:
    
            break;
        
        case TableRowTypePwoerMode:{
           
            break;
        }
        default:
            break;
    }
}


-(void)backAction{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)restartAndResetDevice:(UIButton *)sender {
    int type = 1;
   
    self.info.otherConfig.resetEnable = type; //type==1 factory reset, type==2 device restart
    [DeviceManager SetOtherConfigInfo:self.device info:self.info.otherConfig shouldShowTips:NO succ:^{
        
    } fail:^{
        
    }];

}

@end
