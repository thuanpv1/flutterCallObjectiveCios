//
//  NVSDK.h
//  NVSDK
//
//  Created by caffe on 2019/8/1.
//  Copyright © 2019 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NVSDK : NSObject
/**
 * @brief    用于初始化NVSDK的通用的启动API
 *
 * 当前初始化 libNVSDK 涉及的内容 [后续请在这个函数添加功能]:
 *  #1. 使用单独的线程, 查询调度服务器获取转发地址表;
 *  #2. 使用独立的线程, 进行网络连通性检查;
 */

+(void) startup;
@end

NS_ASSUME_NONNULL_END
