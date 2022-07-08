//
//  ThermalConfigInfo.h
//  NVSDK
//
//  Created by Macro-Video on 2020/6/9.
//  Copyright © 2020 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThermalConfigInfo : NSObject
@property (nonatomic, assign) BOOL highTempPri;
@property (nonatomic, assign) BOOL highTempEnable;
@property (nonatomic, assign) BOOL highTempAlarmSoundEnable;
@property (nonatomic, assign) int  highTemp;

@property (nonatomic, assign) BOOL lowTempPri;
@property (nonatomic, assign) BOOL lowTempEnable;
@property (nonatomic, assign) BOOL lowTempAlarmSoundEnable;
@property (nonatomic, assign) int  lowTemp;

@property (nonatomic, assign) BOOL cryDetectionPri;
@property (nonatomic, assign) BOOL cryDetectionEnable;
@property (nonatomic, assign) int  tempDifference; //精度

@property (nonatomic, assign) BOOL FTemperaturePri;
@property (nonatomic, assign) BOOL FTemperatureEnable;


@end

NS_ASSUME_NONNULL_END
