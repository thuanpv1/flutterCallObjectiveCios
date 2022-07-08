//
//  AccountConfigInfo.h
//  NVSDK
//
//  Created by caffe on 2019/2/22.
//  certified by caffe on 20190322
//  Copyright © 2019 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AccountConfigInfo : NSObject
@property (assign) int nResult;
@property (assign) int nUID;
@property (retain) NSDate *refreshTime;
@property (copy) NSString *strUsername;
@property (copy) NSString *strPassword;
@end

NS_ASSUME_NONNULL_END
