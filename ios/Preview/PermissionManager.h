//
//  PermissionManager.h
//  iCamSee
//
//  Created by Macro-Video on 2020/12/22.
//  Copyright © 2020 Macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PermissionBlock)(BOOL isPermission);

@interface PermissionManager : NSObject
//check microphone permission
+(void)checkRecordPermission:(PermissionBlock)callBackBlock;

// check for speech recognition
+(void)checkSpeechRecognizerPermission:(PermissionBlock)callBackBlock;
@end

NS_ASSUME_NONNULL_END
