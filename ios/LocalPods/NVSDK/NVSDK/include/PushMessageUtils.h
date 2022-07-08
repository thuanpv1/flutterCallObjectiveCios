//
//  PushMessageUtils.h
//  NVSDK
//
//  Created by MacroVideo on 2017/9/18.
//  Copyright © 2017年 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlarmImageResult.h"
@class NVDevice;
@class AlarmMessage;

typedef void(^Myblock)(BOOL Success);

@interface PushMessageUtils: NSObject

//#define RESULT_CODE_SUCCESS 0
#define AMLG_RESULT_CODE_ERROR_REQUEST_SEND_ERROR   -1001   //请求发送异常
#define AMLG_RESULT_CODE_ERROR_SERVER_BUSY          -1002   //服务器正忙
#define AMLG_RESULT_CODE_ERROR_SERVER_NONE_RESPONE  -1003   //服务器没有回应
#define AMLG_RESULT_CODE_SUCCESS_NOMORE_MESSAGE     -1004   //没有更多的数据

/* 以下的返回结果已在resultCode.h中定义
 #define RESULT_CODE_SUCCESS_NEWMESSAGE 100            //成功，并且有新的报警信息
 #define RESULT_CODE_SUCCESS_NOTNEWMESSAGE 0           //成功，但是没有新的报警信息
 #define RESULT_CODE_FAIL_CONNECT_SERVER_FAIL -100     //失败，连接数据库失败
 #define RESULT_CODE_FAIL_USERNAME_NOEXIST -101        //失败，用户名不存在
 #define RESULT_CODE_FAIL_PASSWORD_ERROR -102          //失败，密码不正确
 #define RESULT_CODE_FAIL_PARM_ERROR -103              //失败，请求参数不正确
 */


typedef void (^getLatestResultBlock)(long long lLastGetTime,long long lBackFreshTime, NSMutableArray * messageArray ,NSError *error);
typedef void (^getMoreResultBlock)(long long lastFreshTime, NSMutableArray * messageArray ,NSError *error);


//获取某个时点之后的最新报警消息
+(void)getLatestAlarmMessage:(NVDevice *)deviceInfo lastGetTime:(long long)m_lLastGetTime resultBlock:(getLatestResultBlock)resultBlock;
//获取某个时间段的报警消息
+(void)getAlarmMessage:(NVDevice *)deviceInfo fromTime:(long long)lFromTime toTime:(long long)lToTime  resultBlock:(getMoreResultBlock)resultBlock;
//获取报警图片
+(AlarmImageResult *)getAlarmImage:(NVDevice *)deviceInfo alarmMessage:(AlarmMessage *)alarmMessageInfo thumbnail:(int)thumbnail;

+(void)cancel;


@end
