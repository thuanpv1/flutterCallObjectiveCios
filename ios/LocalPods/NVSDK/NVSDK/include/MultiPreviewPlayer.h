//
//  MultiPlayer.h
//  NVSDK
//
//  Created by VINSON on 2019/11/27.
//  Copyright © 2019 macrovideo. All rights reserved.
//

/**
 FIXME: 接口设计有误
 PreviewEvents中的previewWifiStrength、previewBatteryRemaining、previewThermalMinTemperature、previewPTZXCruiseType，
 都是基于「playerBase: name: info:」的事件回调解析的，其实不应该在这里做这层解析，应该直接返回上层，
 以免后续有扩展还要新增解析
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LoginHandle.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    MultiPlayerErrorEmptyPassword,
    MultiPlayerErrorUsernameOrPasswordIncorrect,
    MultiPlayerErrorLoginFailure,
    MultiPlayerErrorWeakPassword,
} MultiPlayerErrorCode;

typedef enum : NSUInteger {
    MultiPlayerState_Playing,
    MultiPlayerState_Stopped,
    MultiPlayerState_Paused,
    MultiPlayerState_Buffering,
    MultiPlayerState_Connecting,
} MultiPlayerState;

@protocol PreviewEvents <NSObject>
- (void) previewIdle:(BOOL)isIdle userInfo:(nullable id)userInfo atIndex:(int)index;
- (void) previewCameraType:(int)cameraType timestamp:(int64_t)timestamp userInfo:(nullable id)userInfo atIndex:(int)index;
- (void) previewLoginHandle:(LoginHandle*)handle loginError:(NSError*)error userInfo:(nullable id)userInfo atIndex:(int)index;
- (void) previewOldState:(MultiPlayerState)oldState newState:(MultiPlayerState)newState userInfo:(nullable id)userInfo atIndex:(int)index;
- (void) previewInfoName:(NSString*)name data:(NSDictionary*)data userInfo:(nullable id)userInfo atIndex:(int)index;// 归一化额外信息返回
- (void) previewStream:(int)stream atIndex:(int)index;

@optional
- (void) previewWifiStrength:(int)strength wifiDB:(int)db userInfo:(nullable id)userInfo atIndex:(int)index __attribute__((deprecated("已废弃，请使用previewInfoName")));
@optional
- (void) previewBatteryRemaining:(int)remaining userInfo:(nullable id)userInfo atIndex:(int)index __attribute__((deprecated("已废弃，请使用previewInfoName")));
@optional
- (void) previewThermalMinTemperature:(int)min maxTemperature:(int)max FTempEnable:(BOOL)FTempEnable userInfo:(nullable id)userInfo atIndex:(int)index __attribute__((deprecated("已废弃，请使用previewInfoName")));
@optional
- (void) previewPTZXCruiseType:(int)type state:(int)state ptzxid:(int)ptzxid userInfo:(nullable id)userInfo atIndex:(int)index __attribute__((deprecated("已废弃，请使用previewInfoName")));
@optional
- (void) previewLensControl:(int)scaleCount scaleValue:(int)scaleValue scaleCurrent:(int)scaleCurrent userInfo:(nullable id)userInfo atIndex:(int)index __attribute__((deprecated("已废弃，请使用previewInfoName")));//add by qin 20201210
@end

@protocol MultiPreviewEvents <NSObject>
- (BOOL) multiPreviewCanSelectedAtIndex:(int)index;
- (BOOL) multiPreviewCanPanoONAtIndex:(int)index;
- (BOOL) multiPreviewCanPanoOFFAtIndex:(int)index;
- (void) multiPreviewCurrentSelected:(int)current previousSelected:(int)previous;
- (void) multiPreviewPanoON:(BOOL)on atIndex:(int)index;
@end

@interface MultiPreviewPlayer : NSObject
@property (nonatomic,assign) int currentSelected;
@property (nonatomic,assign) int currentPano;
@property (nonatomic,strong,readonly) UIView *view;
@property (nonatomic,weak,nullable) id<PreviewEvents> previewEvents;
@property (nonatomic,weak,nullable) id<MultiPreviewEvents> multiPreviewEvents;

-(void)resetRowColumn:(BOOL)multi;      // 重置行数和列数 YES:2x2 NO:1*1(请慎用,尽量不要多次重复调用)
-(void)resetData:(int)index;            // 对全景库显示数据reset
-(void)resetDataAll;
-(void)start:(int)index
       lanIP:(NSString*)lanIP
      netIPs:(NSArray<NSString*>*)netIPArray
        port:(int)port
    deviceID:(int)deviceID
    username:(NSString*)userName
    password:(NSString*)password
     channel:(int)channel
  streamType:(int)streamType
        mute:(BOOL)mute
     stretch:(BOOL)stretch
    userInfo:(nullable id)userInfo
      method:(NSString*)method
     accountId:(int)accountId;
-(BOOL)stop:(int)index;
-(void)stopAll;
-(void)active:(BOOL)active;
-(void)repaint;
-(void)clearSurface; //清屏
-(void)refix;
-(void)resetPanoBuffer;

-(void)allStretch:(BOOL)stretch;
-(void)stretch:(BOOL)stretch atIndex:(int)index;
-(void)mute:(BOOL)mute atIndex:(int)index;
-(void)reverse:(int)index;
-(void)light:(int)light atIndex:(int)index; //开灯关灯
-(void)alarm:(int)action value:(int)value atIndex:(int)index; //主动报警

-(void)imgset:(int)imgset atIndex:(int)index; //黑白全彩
-(void)zoom:(int)zoom atIndex:(int)index; //聚焦变倍设置
-(void)moveTrack:(int)track state:(int)state atIndex:(int)index; //移动跟踪
-(void)ptzWithUp:(BOOL)up left:(BOOL)left down:(BOOL)down right:(BOOL)right atIndex:(int)index;
-(BOOL)resetPTZX:(int)ptzxID atIndex:(int)index action:(int)action;
-(void)callPTZX:(int)ptzxID action:(int)action atIndex:(int)index;
-(UIImage*)srceenShot:(int)index;
-(UIImage*)srceenShotFromView;
-(void)thermal:(BOOL)thermal atIndex:(int)index; //热成像

-(BOOL)startRecord:(int)index videoPath:(NSString*)videoPath imagePath:(NSString*)imagePath;
-(BOOL)stopRecord:(BOOL)save atIndex:(int)index;
-(nullable NSError*)startTalk:(int)index;
-(void)stopTalk:(int)index;

-(void)pano:(BOOL)pano;
-(void)panoMode:(int)mode atIndex:(int)index; //全景显示模式设置
-(void)panoType:(int)type atIndex:(int)index;  // 0:吊顶 1:壁挂

-(void)updatePanoParamWithConvert:(BOOL)convert atIndex:(int)index;

-(void)panoRectZoom;
-(void)panoRectResetZoom;
-(CGFloat)panoRectGetZoom;

-(void)changeStreamID:(int)stream index:(int)index; //部分设备支持

-(void)panoRectSetZoom:(CGFloat)scale;

@end

NS_ASSUME_NONNULL_END
