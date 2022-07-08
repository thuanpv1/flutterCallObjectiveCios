//
//  LANDeviceUpdateLoop.h
//  NVSDK
//
//  Created by caffe on 2019/8/9.
//  Copyright © 2019 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief    使用独立的线程去发现局域网的设备
 *
 * 因为局域网的设备搜索 和 局域网的设备状态更新, 都是通过UDP广播的方式去实现的.
 * 同时, 因为局域网设备的状态更新是通过定时轮询的方式进行, 这就很适合使用独立的线程去实现, 外部不再需要考虑获取问题
 *
 */

@interface LANDeviceUpdateLoop : NSObject

/**
 * @brief    开启独立的线程去搜索本地的设备
 * @param    无
 * @return   无
 *
 * 开启一个独立的UDP广播线程去搜索本地设备, 根据搜索结果可以用于: 添加设备 / 更新设备状态.
 */

+ (void) start;

/**
 * @brief    停止局域网搜索本地设备的线程
 * @param    无
 * @return   无
 *
 * 停止发UDP广播的独立线程. 可根据需要, 在以下情况下. 可以停止UDP独立线程:
 *  a) 可以确信, 用户正在使用蜂窝移动数据( 5G / 4G / 3G / 2G )等, 没必要进行局域网搜索;
 *  b) 用户的设备列表为空, 此时没有必要更新设备信息, 可以停止本线程;
 */

+ (void) stop;

/**
 * @brief    获取本地局域网内的设备
 * @param    无
 * @return   NVDevice 模型数组 (可空nil), 本地局域网内的设备
 *
 * 根据设备对UDP广播的应答, 返回本地局域网内的搜索设备.
 */

+ (NSArray* _Nullable) getLANDevicesByUpdateLoop;

/**
 * @brief    立即获取本地局域网内的设备
 * @param    无
 * @return  NVDevice 模型数组 (可空nil), 本地局域网内的设备
 *
 * #因为紧急需要, 需要马上搜索局域网内的设备#
 *  需要立即得到本地局域网内设备信息的情况, 例如:
 *  a) 正在进行设备配网, 需要立即搜索设备信息;
 *  b) 强制刷新局域网设备信息, 需要立即从局域网内搜索设备
 */

+ (NSArray* _Nullable) getLANDevicesImmediately;

//MARK: - 自组网设备搜索
/**
 * @brief    搜索自组网设备
 * @return   自组网设备
 *
 * 本地搜索自组网设备.
 */

+ (NSArray* _Nullable) getAutoNetworkingDevice;



//MARK: - 开始单品基站设备搜索
/**
 * @brief    开启指定单品基站的配网流程
 * @return   -1:失败   >0:configID,代表成功开始
 *
 * 本地连接指定单品基站设备，并发送指令让基站开始配网流程.
 */
+ (int)startAutoNetworkingSearchForStation:(int)stationID;

//MARK: - 关闭单品基站设备搜索
/**
 * @brief    关闭指定单品基站的配网流程
 * @return   YES:关闭成功 NO:关闭失败(设备一定时间后会自动关闭)
 *
 * 本地连接指定单品基站设备，并发送指令让基站停止配网流程.
 */
+ (BOOL)stopAutoNetworkingSearchForStation:(int)stationID configID:(int)configID;
@end

NS_ASSUME_NONNULL_END
