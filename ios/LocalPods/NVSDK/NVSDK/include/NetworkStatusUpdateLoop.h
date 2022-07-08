//
//  NVNetworkStatus.h
//  NVSDK
//
//  Created by caffe on 2019/8/1.
//  Copyright © 2019 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief    检查前网络的连接状态
 *
 *  使用独立的线程, 后台去轮询各个公网DNS服务器, 使用ping的方式, 检查网络的连通性.
 */

@interface NetworkStatusUpdateLoop : NSObject

/**
 * @brief    启动独立线程
 *
 * 开启独立线程, 进行ping连通性检查.
 */
+ (void) start;

/**
 * @brief    停止独立线程
 *
 * [# 不建议停止 #]  停止ping线程, 停止内部网络连通性检查.
 */
+ (void) stop;

/**
 * @brief    获取当前网络的连通性
 * @return   YES: 当前连接到互联网;  NO: 当前无法连接到互联网.
 *
 * 内部使用定时轮询的方式进行网络连通性检查, 能够根据国内外的公网DNS的 ping 情况进行网络检查.
 */
+ (BOOL) currentNetworkConnection;
@end

NS_ASSUME_NONNULL_END
