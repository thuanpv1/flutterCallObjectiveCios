//
//  MainViewController.m
//  demo
//
//  Created by admin on 2022/3/28.
//  Copyright © 2022 Macrovideo. All rights reserved.
//

#import "MainViewController.h"
#import "PreviewViewController.h"
#import "DeviceSettingManager.h"
#import "DeviceSettingViewController.h"
#import "LoginHandle.h"
#import "AlarmMessageManager.h"
@interface MainViewController ()
@property (nonatomic ,strong) NSMutableArray *devices;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)preview:(id)sender {
    
    int indexOfArray = 0; //The index of the current device and the array
    
    PreviewViewController *vc = [[PreviewViewController alloc] initWithDevices:self.devices atDeviceIndex:indexOfArray];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)setting:(id)sender {
    
    NVDevice *device  =self.devices.firstObject;
    
    X_WeakSelf
    [DeviceSettingManager loadDeviceSetting:device completeHandel:^(LoginHandle * _Nonnull loginHandle, NVDeviceConfigInfo * _Nonnull info, loadDeviceSettingResultType result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            X_StrongSelf
            if (result == loadDeviceSettingResultTypeSuccess) {
                //success
               
                DeviceSettingViewController *deviceSetting = [DeviceSettingViewController new];
                deviceSetting.hidesBottomBarWhenPushed = YES;
                deviceSetting.device = device;
                deviceSetting.loginResult = loginHandle;
                deviceSetting.info = info;
                [strongSelf.navigationController pushViewController:deviceSetting animated:YES];

       
            }else if (result == loadDeviceSettingResultTypeEmptyPassword || result == loadDeviceSettingResultTypeLowPassword) {
                //device password is empty
                
                return;
            }else if (result == loadDeviceSettingResultTypeConnectFailed){
                //Connection failed

               
            }else{
                // other errors
                switch (loginHandle.nResult) {
                    case NV_RESULT_DESC_NO_USER:
                    case NV_RESULT_DESC_PWD_ERR:{
                    
                    }
                        break;
                    case NV_RESULT_DESC_NO_PRI:
                        break;

                    case NV_RESULT_DESC_TIME_ERR:
                        break;

                    case NV_RESULT_DESC_PWD_FMT_ERR_AP:
                        break;

                    case NV_RESULT_DESC_PWD_FMT_ERR_STATION:
                        break;

                    case NV_RESULT_DESC_PWD_FMT_ERR:
                        break;
                    default:{//Connection failed
                    }
                        break;
                }
            }
        });
    }];
    
    
}
- (IBAction)alarmMessage:(id)sender {
    NVDevice *device =self.devices.firstObject;
    //Get today's, the timestamp passes the timestamp in the early morning of this day
    long long lastGetLatestTime = [[self zeroOfDate:[NSDate date]] timeIntervalSince1970] * 1000;
    if (device.lLastGetTime>lastGetLatestTime) {
        lastGetLatestTime = device.lLastGetTime+1; //Get today's latest
    }
    AlarmMessageManager *manager = [AlarmMessageManager new];
    [manager loadLatestAlarmMessageWithCurrentTime:lastGetLatestTime device:device filterType:AlarmMessageFilterTypeAll];
    
    manager.loadLatestPicCallback = ^(NSMutableArray * _Nonnull array) {
        
    };
}
- (NSDate *)zeroOfDate:(NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:date];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [calendar dateFromComponents:components];
}

-(NSMutableArray *)devices{
    if (!_devices) {
        _devices = [NSMutableArray array];
        
        // NVDevice *device = [[NVDevice alloc] init];
        // [device setDevID:24430289];
        // device.strUsername = @"admin";
        // device.strPassword = @"aaaa1111.";
        // device.strName = @"";
        // device.nAddType = ADD_TYPE_HANDMAKE;
        // device.strServer = @"192.168.1.1";
        // device.nPort = 8800;
        
        NVDevice *device1 = [[NVDevice alloc] init];
        [device1 setDevID:54110161];
        device1.strUsername = @"admin";
        device1.strPassword = @"Lamgicopass1234";
        device1.strName = @"";
        device1.nAddType = ADD_TYPE_HANDMAKE;
        device1.strServer = @"192.168.1.1";
        device1.nPort = 8800;
        
        NVDevice *device2 = [[NVDevice alloc] init];
        [device2 setDevID:55685723];
        device2.strUsername = @"admin";
        device2.strPassword = @"Lamgicopass1234";
        device2.strName = @"";
        device2.nAddType = ADD_TYPE_HANDMAKE;
        device2.strServer = @"192.168.1.1";
        device2.nPort = 8800;
        
        // [_devices addObject:device];
        [_devices addObject:device1];
        [_devices addObject:device2];
        
    }
    return _devices;
}

@end
