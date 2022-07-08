//
//  SearchDeviceResult.h
//  NVSDK
//
//  Created by MacroVideo on 2018/6/28.
//  Copyright © 2018年 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchDeviceResult : NSObject
@property (assign) int nResult;
@property (assign) int nOnlineStatus;
@property (copy) NSString *strServerIP;
@end
