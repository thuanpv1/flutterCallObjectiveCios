//
//  NVMediaPlayer.h
//  OpenGLES2ShaderRanderDemo
//
//  Created by cyh on 12. 11. 26..
//  Copyright (c) 2012년 cyh3813. All rights reserved.
//

#import <UIKit/UIKit.h>
//player
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioQueue.h>
#import "LoginHandle.h"
#import "RecordVideoInfo.h"
//#import "HYFisheyePanoView.h"
#import "NVPanoPlayer.h"
#import "PlaybackDelegate.h"

@protocol SingleGestureRecognizerDelegate <NSObject>
@optional
-(void)singleGestureRecognizer;
@end

@interface NVPanoPlayer : UIView
@property (nonatomic,weak) id <SingleGestureRecognizerDelegate> singleDelegate;
@property (nonatomic, retain) UILabel *lblTimeOSD;

@property (copy, nonatomic) void (^wifiSignalBlock)(int level, short db);
@property (copy, nonatomic) void (^batteryVolumeBlock)(short volume);

//player
@property (assign) id<PlaybackDelegate> playbackDelegate;
@property (nonatomic,assign) CGFloat speed; // 回放倍速控制，stop的时候重置为1.0
@property (nonatomic,assign) BOOL stretch;
@property (nonatomic,assign,readonly) int frametype;
@property (nonatomic,assign) BOOL notReleasePanoWhenDealloc;

//回放文件
-(BOOL)startPlayBack:(LoginHandle *)loginHandle file:(RecordVideoInfo *)recordVideo;
-(BOOL)startPlayBack:(LoginHandle *)loginHandle file:(RecordVideoInfo *)recordVideo speed:(CGFloat)speed;   // TF回放倍速播放接口
-(BOOL)stopPlayBack;
-(int)setPlayProgress:(int)progress;
-(BOOL)startRecord:(NSString *)strSavePath;
-(BOOL)isRecording;
-(BOOL)stopRecord;
-(void)setPriValueCTRL:(BOOL)bCTRL_PRI Playback:(BOOL)bPLAYBACK_PRI Receive:(BOOL)bRECEIVE_PRI Speak:(BOOL)bSpeak_PRI Audio:(BOOL)bAudio_PRI PTZ:(BOOL)bPTZ_PRI;
-(void)enableRender:(BOOL)IsEnable;
- (void)setPanoMode:(int) iMode;//add by luo 20160914

- (void)initFisheyeParam:(int)iFixType andCenterX:(int) xCenter andCenterY:(int)yCenter andRadius:(int)radius ;
- (void)setImageYUV:(int)RGBorYUV420 andImageBuffer:(Byte *) pData andWidth:(int) width andHeight:(int) height;
- (void)setMode:(int) iMode;
- (void)clearsurface;//RGB图片预览下一张加载过程的清屏工作
- (void)setActive: (BOOL) bActive;
- (void)resetDataFlag;
- (void)resetPanoBuffer;

- (void)InitFisheyeParam:(int)iFixType andCenterX:(int) xCenter andCenterY:(int)yCenter andRadius:(int)radius;
- (void)SetImageYUV:(int)RGBorYUV420 andImageBuffer:(Byte *) pData andWidth:(int) width andHeight:(int) height;

-(void)setIsOnback:(BOOL)onback; //预防有时候退出还能接收数据

-(UIImage *)screenShot;

-(void)onApplicationDidBecomeActive;
-(void)onApplicationWillResignActive;

-(void)putAudioDataToQueue:(char *)pData Size:(int)nSize Id:(int)nID type:(int) nType;

- (void)timeIndexWhenPause: (int)pauseTimeIndex;
- (void)resetPause;

-(void)setCamType:(int)CamType;

-(void)releaseAction;

@end
