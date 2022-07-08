//
//  AlarmMessage.h
//  macroSEE
//
//  Created by macrovideo on 14-9-17.
//  Copyright (c) 2014年 cctv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlarmMessage : NSObject

@property (assign) int nID;
@property (assign) long long nSaveID;
@property (assign) int nDevID;
@property (assign) int nAlarmType;
@property (assign) int nAlarmLevel;
@property (assign) long long llAlarmTime;
@property (copy) NSString *strAlarmContent;
@property (copy) NSString *strAccureTime;
@property (retain) UIImage *imageData;
@property (assign) BOOL hasPosition;//是否带人工智能
@property (copy) NSString *strImageIP;  //获取图片大图ip
@property (copy) NSString *imageDomain;//获取图片大图域名
@property (assign) long oss_id;
@property (assign) int ctype;
@property (assign) long cx;
@property (assign) long cy;
@property (assign) long cr;
@property (assign) int vtype;  //录像类型
@property (assign) long long vid;   //录像ID
@property (assign) long long vts;   //录像时间

/** 报警图片关联云盘录像新增*/
@property (assign) int uid;  //userID
@property (assign) int vrand; //videoRandNumber 随机数
@property (assign) int bidx;  // BucketIndex
@property (assign) int channel;  // channel

@property (assign) BOOL isThumbnail;  //是否缩略图


@end
