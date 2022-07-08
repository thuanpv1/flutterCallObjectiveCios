//
//  PlaybackDelegate.h
//  iCamSee
//
//  Created by macrovideo on 15/10/14.
//  Copyright © 2015年 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlaybackDelegate <NSObject>

-(void)onProgressChange:(int) nProgress timeIndexID:(int)nTimeIndexID;//回放进度改变事件
@optional
-(void)lblTimeOSDChange:(int)timeStr;
@optional
-(void)ucloudPlaybackResultCode:(int)code; //云盘回放返回值
@optional
-(void)ucloudPlaybackPanoX:(int)panoX PanoY:(int)panoY Radius:(int)panoR; //报警小视频的全景参数只能这里获取
@end
