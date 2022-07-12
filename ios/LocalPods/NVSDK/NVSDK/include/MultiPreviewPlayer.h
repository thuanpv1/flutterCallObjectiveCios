//
//  MultiPlayer.h
//  NVSDK
//
//  Created by VINSON on 2019/11/27.
//  Copyright © 2019 macrovideo. All rights reserved.
//

/**
 FIXME: Interface design error
  previewWifiStrength, previewBatteryRemaining, previewThermalMinTemperature, previewPTZXCruiseType in PreviewEvents,
  All are based on the event callback analysis of "playerBase: name: info:". In fact, this layer of analysis should not be done here, and should be returned directly to the upper layer.
  In order to avoid subsequent expansion and additional analysis
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
- (void) previewInfoName:(NSString*)name data:(NSDictionary*)data userInfo:(nullable id)userInfo atIndex:(int)index;//Normalized extra information returned
- (void) previewStream:(int)stream atIndex:(int)index;

@optional
- (void) previewWifiStrength:(int)strength wifiDB:(int)db userInfo:(nullable id)userInfo atIndex:(int)index __attribute__((deprecated("Obsolete, please use previewInfoName")));
@optional
- (void) previewBatteryRemaining:(int)remaining userInfo:(nullable id)userInfo atIndex:(int)index __attribute__((deprecated("Obsolete, please use previewInfoName")));
@optional
- (void) previewThermalMinTemperature:(int)min maxTemperature:(int)max FTempEnable:(BOOL)FTempEnable userInfo:(nullable id)userInfo atIndex:(int)index __attribute__((deprecated("Obsolete, please use previewInfoName")));
@optional
- (void) previewPTZXCruiseType:(int)type state:(int)state ptzxid:(int)ptzxid userInfo:(nullable id)userInfo atIndex:(int)index __attribute__((deprecated("Obsolete, please use previewInfoName")));
@optional
- (void) previewLensControl:(int)scaleCount scaleValue:(int)scaleValue scaleCurrent:(int)scaleCurrent userInfo:(nullable id)userInfo atIndex:(int)index __attribute__((deprecated("Obsolete, please use previewInfoName")));//add by qin 20201210
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

-(void)resetRowColumn:(BOOL)multi;      // Reset the number of rows and columns YES: 2x2 NO: 1*1 (please use it with caution, try not to call it multiple times)
-(void)resetData:(int)index;            // Display data reset to the panorama library
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
-(void)clearSurface; //Qing dynasty
-(void)refix;
-(void)resetPanoBuffer;

-(void)allStretch:(BOOL)stretch;
-(void)stretch:(BOOL)stretch atIndex:(int)index;
-(void)mute:(BOOL)mute atIndex:(int)index;
-(void)reverse:(int)index;
-(void)light:(int)light atIndex:(int)index; //Turn the lights on and off
-(void)alarm:(int)action value:(int)value atIndex:(int)index; //Active alarm

-(void)imgset:(int)imgset atIndex:(int)index; //Black and white full color
-(void)zoom:(int)zoom atIndex:(int)index; //Focus zoom settings
-(void)moveTrack:(int)track state:(int)state atIndex:(int)index; //mobile tracking
-(void)ptzWithUp:(BOOL)up left:(BOOL)left down:(BOOL)down right:(BOOL)right atIndex:(int)index;
-(BOOL)resetPTZX:(int)ptzxID atIndex:(int)index action:(int)action;
-(void)callPTZX:(int)ptzxID action:(int)action atIndex:(int)index;
-(UIImage*)srceenShot:(int)index;
-(UIImage*)srceenShotFromView;
-(void)thermal:(BOOL)thermal atIndex:(int)index; //Thermal Imaging

-(BOOL)startRecord:(int)index videoPath:(NSString*)videoPath imagePath:(NSString*)imagePath;
-(BOOL)stopRecord:(BOOL)save atIndex:(int)index;
-(nullable NSError*)startTalk:(int)index;
-(void)stopTalk:(int)index;

-(void)pano:(BOOL)pano;
-(void)panoMode:(int)mode atIndex:(int)index; //Panorama Display Mode Settings
-(void)panoType:(int)type atIndex:(int)index;  // 0: Ceiling 1: Wall hanging

-(void)updatePanoParamWithConvert:(BOOL)convert atIndex:(int)index;

-(void)panoRectZoom;
-(void)panoRectResetZoom;
-(CGFloat)panoRectGetZoom;

-(void)changeStreamID:(int)stream index:(int)index; //Some devices support

-(void)panoRectSetZoom:(CGFloat)scale;

@end

NS_ASSUME_NONNULL_END
