//
//  DeviceSettingViewController.h
//  demo
//
//  Created by VINSON on 2020/7/29.
//  Copyright © 2020 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface DeviceSettingViewController : UIViewController
@property(nonatomic,strong)NVDevice *device;
@property(nonatomic,strong)NVDeviceConfigInfo *info;
@property(nonatomic,strong)LoginHandle *loginResult;
@end

NS_ASSUME_NONNULL_END
