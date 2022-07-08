//
//  NVDevice+AtutoNetwork.h
//  NVSDK
//
//  Created by Macro-Video on 2020/7/31.
//  Copyright © 2020 macrovideo. All rights reserved.
//

#import "NVDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface NVDevice (AtutoNetwork)

-(void)setCamType:(int)camType;
-(int)camType;

-(void)setParentID:(int)parentID;
-(int)parentID;


-(void)setParentType:(int)parentType;
-(int)parentType;
@end

NS_ASSUME_NONNULL_END
