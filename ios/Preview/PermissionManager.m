//
//  PermissionManager.m
//  iCamSee
//
//  Created by Macro-Video on 2020/12/22.
//  Copyright © 2020 Macrovideo. All rights reserved.
//

#import "PermissionManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHPhotoLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <Speech/Speech.h>
#import "MVAlertController.h"
@interface PermissionManager()<MVAlertDelegate>
@property (nonatomic, assign) BOOL networkReachabilityFlag; // Have you checked network permissions?

@end

static PermissionManager *manager;

@implementation PermissionManager



#pragma mark - ----------------------------------------------检查麦克风权限----------------------------------------------
+(void)checkRecordPermission:(PermissionBlock)callBackBlock{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        //Rejected by the user or without permission, only a pop-up prompt can be popped up for the user to change by himself
        [self showGoToSettingAlert:NSLocalizedString(@"recordPermissionTips", @"Please go to \"Settings\"Open the microphone permission for the app and try again")];
        [self callBack:callBackBlock isAuthorized:NO];
        
    }else if (authStatus == AVAuthorizationStatusNotDetermined){
        // haven't requested yet
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if (granted) {
                // The user agrees to access the microphone for the first time
                [self callBack:callBackBlock isAuthorized:YES];
            } else {
                // User denied access to microphone for the first time
                [self callBack:callBackBlock isAuthorized:NO];
            }
        }];
        
    }else if (authStatus == AVAuthorizationStatusAuthorized){
        //allow
        [self callBack:callBackBlock isAuthorized:YES];
    }
}

#pragma mark - ----------------------------------------------检查语音识别----------------------------------------------
+(void)checkSpeechRecognizerPermission:(PermissionBlock)callBackBlock{
    
    if (@available(iOS 10.0, *)) {
        SFSpeechRecognizerAuthorizationStatus status =  [SFSpeechRecognizer authorizationStatus];
        
        if(status == SFSpeechRecognizerAuthorizationStatusNotDetermined ){
            
            [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
                switch (status) {
                    case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                    case SFSpeechRecognizerAuthorizationStatusDenied:
                    case SFSpeechRecognizerAuthorizationStatusRestricted:
                        [self showGoToSettingAlert:NSLocalizedString(@"cameraPermissionTips", @"Please go to \"Settings\"Open the voice recognition permission for the app and try again")];
                        [self callBack:callBackBlock isAuthorized:NO];
                        break;
                    case SFSpeechRecognizerAuthorizationStatusAuthorized: //Authorized
                        [self callBack:callBackBlock isAuthorized:YES];
                        break;
                    default:
                        break;
                }
            }];
            
        }else if(status == SFSpeechRecognizerAuthorizationStatusDenied || status == SFSpeechRecognizerAuthorizationStatusRestricted ){
            [self showGoToSettingAlert:NSLocalizedString(@"cameraPermissionTips", @"Please go to \"Settings\"Open the voice recognition permission for the app and try again")];
            [self callBack:callBackBlock isAuthorized:NO];
            
        }else if(status == SFSpeechRecognizerAuthorizationStatusAuthorized){
            [self callBack:callBackBlock isAuthorized:YES];
        }
    }
}


#pragma mark - ---------------------------------------------------其他------------------------------------------------
+(void)showGoToSettingAlert:(NSString *)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        MVAlertController *alert = [[MVAlertController alloc] init];
        [alert showAlertWithType:MVAlertControllerTypeOKAndCancel title:NSLocalizedString(@"noPromiss", @"Permission denied") message:message handel:^{
            [self toSetting];
        }];
    });
}

+(void)toSetting{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if( [[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
}

+(void)callBack:(PermissionBlock)callBackBlock isAuthorized:(BOOL)isAuthorized{
    dispatch_async(dispatch_get_main_queue(), ^{
        callBackBlock(isAuthorized);
    });
    
}

#pragma mark - ---------------------------------------------------MVAlertDelegate------------------------------------------------
-(void)alertAttributeStringDidTap:(NSString *)string range:(NSRange)range{
    [PermissionManager toSetting];
}

@end
