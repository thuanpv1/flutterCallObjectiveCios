//
//  PushUtils.h
//  NVSDK
//
//  Created by MacroVideo on 2017/9/18.
//  Copyright © 2017年 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlarmMessage.h"

typedef void(^PushUtilsResultBlock)(BOOL Success);

@interface PushUtils : NSObject

/*
 -------------------------------------------
 |       前台收到通知后将推送内容解析成模型       |
 -------------------------------------------
 
 userInfo:前台接收远程消息推送的内容
 return:AlarmMessage报警图片模型
 */
+(AlarmMessage*)recNotificationWithUserInfo:(NSDictionary*)userInfo;

/*
 ┏               ┓
    **极光推送**
 ┗               ┛
 
 --------------------------
 |        注册设备          |
 --------------------------
 param:{
 "app_id":      app id 整数,
 "phone_type":  手机类型 整数,
 "appname":     app名称 字符串,
 "appkey":      极光appkey 长整数,
 "clientid":    极光SDK注册后的registrationID 字符串,
 "sys_num":     系统版本 整数
 "enable":      是否接收推送 整数,
 "vibrate":     是否开启震动提示 整数,
 "sound":       声音是否开启 整数,
 "sound_file":  声音文件 字符串,
 "sys_lan":     手机系统语言 字符串 (cn , en .....)
 "env":         env: 0表示发布版，1 表示开发版
 "login":       login:   1：登录 0：未登录
 }
 Success:               注册成功回调
 */
+ (void)registDeviceToServerForJPush:(NSDictionary*)param Success:(PushUtilsResultBlock)Success;

/*
 --------------------------
 |       注册设备列表        |
 --------------------------
 deviceID:    获取本机的deviceId,[CloudPushSDK getDeviceId],若为空传"unknow";
 serverList:  设备列表数组
 Success:     上传成功回调
 */
+ (void)setClientWithDeviceParamForJPush:(NSString*)deviceID addDeviceArr:(NSArray*)serverList Success:(PushUtilsResultBlock)Success;

@end
