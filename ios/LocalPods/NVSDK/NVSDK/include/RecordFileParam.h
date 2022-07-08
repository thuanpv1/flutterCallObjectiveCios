//
//  RecordFileParam.h
//  NVSDK
//
//  Created by caffe on 2019/2/21.
//  certified by caffe 20190325
//  Copyright © 2019 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecordFileParam : NSObject
@property (nonatomic, assign) int nSearchChn;
@property (nonatomic, assign) int nSearchType;
@property (nonatomic, strong) NSDate * beginDate;
@property (nonatomic, strong) NSDate * endDate;
@end

NS_ASSUME_NONNULL_END
