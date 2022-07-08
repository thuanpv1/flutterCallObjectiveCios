//
//  LoginHandle.h
//  NVPlayer
//
//  Created by luo king on 12-9-21.
//  Copyright (c) 2012年 cctv. All rights reserved.
//

#import <Foundation/Foundation.h>
/* 以下类型可以组合 */
#define DTYPE_UNKNOWN 0
    /* 个位数可选 */
#define DTYPE_PTZ 1
#define DTYPE_MINI 2
#define DTYPE_NVR 3
#define DTYPE_OUTDOOR 4
    
    /* 十位数可选 */
#define DTYPE_4G 1
#define DTYPE_LOWPOWER 2

@interface LoginHandle : NSObject

@property (assign) int nResult;
@property (assign) long lHandle;
@property (assign) long lTokenSession;
@property (assign) int nPTZXCount;
@property (assign) BOOL bPTZX_PRI;
@property (assign) int nID;
@property (assign) int nDevID;
@property (assign) long long nSaveID;
@property (assign) int nServerType;//服务器类型
@property (assign) int nAddType; 
@property (assign) BOOL isMRMode;
@property (copy) NSString *strMRServer;
@property (copy) NSString *strDomain;
@property (assign) int nMRPort;
@property (assign) int nMaxChn;
@property (assign) BOOL bNO_PRI, bCTRL_PRI, bPLAYBACK_PRI, bRECEIVE_PRI, bSpeak_PRI, bAudio_PRI, bPTZ_PRI, bReverse_PRI;
@property (copy) NSString *strName;
@property (copy) NSString *strServer;
@property (assign) int nPort;
@property (copy) NSString *strUsername;
@property (copy) NSString *strPassword;
@property (assign) BOOL isSameLan;
@property (copy) NSString *strIP, *strLanIP;
@property(assign) int nDeviceType;
@property(assign) int nCamType;
@property(assign) int nPanoX;
@property(assign) int nPanoY;
@property(assign) int nPanoRad;
@property(assign) int nVersion;
@property(nonatomic,assign) int deviceSoftwareUpdateStatus;

// add by GWX 20190909 添加部分字段
@property (assign) int nNetwork;    // 网络设置
@property (assign) int nRecord;     // 录像设置
@property (assign) int nTime;       // 时间设置
@property (assign) int nAlarm;      // 报警设置
@property (assign) int nUser;       // 用户管理
@property (assign) int nStaticIP;   // 静态IP设置
@property (assign) int nUpdate;     // 设备升级设置
// end add by GWX 20190909

@property(assign) int nLightStatus;
@property(assign) int nLightBrightness;
@property(assign) int nSoundPTZCount;
@property(assign) int nFullColorPTZCount; //全彩黑白
@property(assign) int nMoveTrack; //移动跟踪
@property(assign) int nLightSensitivityStatus; //灯光灵敏度
@property(assign) int nZoomCtrl; //变焦功能 (0:不支持 1：支持 2:新版本)

@property(assign) int topo;
@property(assign) int ptzType; // 1:上下左右云台 2：左右；3：上下；4：支持云台校准复位 (按位取值 value&0x01)
@property(assign) int thermalData; //带热成像数据，0：无；1：有
@property(assign) int alarmAction; //是否支持0：无；1：支持自定义报警语音；2：支持主动报警；3：两个都支持
@property(assign) int dtype;    // 设备的复合类型，详见DefineVars.h的复合类型定义，等同NVDevice.nDeviceModel，当两值不等时，需要及时更新NVDevice

@property(assign) int personalizedTimer; // 自定义时间段能力，0：无，1：支持云台自动巡航，2：支持云台定时巡航，4：支持定时开关灯
@property(assign) int extMsSupport;     // 扩展媒体传输协议能力 0：不支持； 1：声网；
@property(assign) int electricity; // 电量值，1-100：未充电电量，101-200：正在充电电量，255：长供电
@property (nonatomic, assign) int networkFreqPoint;//网络模块支持频率 0x0: default 2.4G; 0x1:5.0G; 0x2:5.2G; 0x4:5.8G;


@property(nonatomic,assign) int agora; //是否支持声网
@property(nonatomic,assign) int agoraUid;

@property(nonatomic,assign) BOOL decrypt; //是否需要解密
@property(nonatomic,strong) NSData *decryptKey; //解密key


- (BOOL)has4G;
-(void)setAgoraParam:(NSDictionary*)info;
- (BOOL)hasLowPower;
@end
