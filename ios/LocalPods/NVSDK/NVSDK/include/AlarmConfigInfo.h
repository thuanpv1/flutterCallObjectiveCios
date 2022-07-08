//
//  AlarmConfigInfo.h
//  NVSDK
//
//  Created by caffe on 2019/2/22.
//  certified by caffe on 20190323
//  Copyright © 2019 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AlarmTimeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlarmConfigInfo : NSObject
@property (copy) NSString *strSaveUsername;
@property (copy) NSString *strSavePassword;

@property (retain) NSDate *refreshTime;
@property (assign) int nResult;
@property (assign) int nServerID;
@property (assign) int nOPID;

@property (assign) BOOL hasSoundCtrl;
@property (assign) BOOL bSoundMainSwitch;
@property (assign) BOOL bAlarmAudioSwitch;
@property (assign) int nLanguage;

@property (assign) BOOL hasExternalIOCtrl;
@property (assign) int nIOMode;

@property (assign) BOOL hasAlarmCtrl;
@property (assign) BOOL bMotionAlarmSwitch;
@property (assign) BOOL bPRIAlarmSwitch;
@property (assign) BOOL bSmokeAlarmSwitch;
@property (assign) BOOL bMainAlarmSwitch;

@property(nonatomic,assign) BOOL canSetAlarmArea;
@property(nonatomic,assign) int alarmTimeCount;
@property(nonatomic,retain) NSMutableArray *alarmTimeArr;
@property(nonatomic,assign) int alarmAreaCount;
@property(nonatomic,assign) int alarmAreaRow;
@property(nonatomic,assign) int alarmAreaColumn;
@property(nonatomic,retain) NSMutableArray *alarmAreaArr;
@property(nonatomic,assign) BOOL isAlldayAlarm;

//AI使能、开关
@property(nonatomic,assign) BOOL AIEnble;
@property(nonatomic,assign) BOOL AISwitch;

// 新增温控报警和哭声报警
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

@property (nonatomic, assign) BOOL isShouldSaveTempAlarm;


-(BOOL)checkSaveAcount:(int)nDevID usr:(NSString *)strSUsername pwd:(NSString *)strSPassword;
@end

NS_ASSUME_NONNULL_END
