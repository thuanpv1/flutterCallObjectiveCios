//
//  LibContext.h
//  NVSDK
//
//  Created by macrovideo on 15/10/21.
//  Copyright © 2015年 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibContext : NSObject

+(BOOL) initResuorce;
+(BOOL) releaseResuorce;

+(void)setZoneIndex:(int)nIndex;
+(int)getZoneIndex;
+(NSString*)sdkVersion;
@end
