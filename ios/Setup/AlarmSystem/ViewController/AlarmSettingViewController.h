//
//  AlarmSettingViewController.h
//  demo
//
//  Created by qin on 2020/9/24.
//  Copyright © 2020 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlarmSettingViewController : UIViewController

@property (nonatomic,copy)void(^backBlock)(NVDeviceConfigInfo *backInfo);

@property(nonatomic,strong) NVDevice *device;

@property(nonatomic,strong) AlarmConfigInfo *alarmInfo;

@property(nonatomic,strong)NVDeviceConfigInfo *info;

@property(nonatomic,strong)LoginHandle *loginResult;

@end

NS_ASSUME_NONNULL_END
