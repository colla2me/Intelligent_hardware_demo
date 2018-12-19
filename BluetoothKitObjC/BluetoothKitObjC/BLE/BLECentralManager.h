//
//  BLECentralManager.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/11/10.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDefines.h"

@protocol BLEDelegate <NSObject>
@optional
/*!
 *  @method bleDidConnect:
 *
 *  @discussion 蓝牙已连接的回调
 */
- (void)bleDidConnect;

/*!
 *  @method bleDidDisconnect
 *
 *  @discussion 蓝牙已断开连接的回调
 */
- (void)bleDidDisconnect;

/*!
 *  @method bleDidChangeState:
 *
 *  @discussion 蓝牙可用状态改变的回调
 */
- (void)bleDidChangeState:(BOOL)isEnabled;

/*!
 *  @method bleDidReadRSSI:
 *
 *  @discussion 读取蓝牙RSSI值的回调
 */
- (void)bleDidReadRSSI:(NSNumber *)rssi;

/*!
 *  @method bleDidBeginScan
 *
 *  @discussion 开始扫描的回调
 */
- (void)bleDidBeginScan;

/*!
 *  @method bleDidEndScan
 *
 *  @discussion 已停止扫描的回调
 */
- (void)bleDidEndScan;

/*!
 *  @method bleDidReceiveData:length
 *
 *  @discussion 读取蓝牙指定特征值的value的回调
 */
- (void)ble:(CBCharacteristic *)characteristic didReceiveBytes:(unsigned char *)bytes length:(NSUInteger)length;

/*!
 *  @method bleDidDiscoverPeripheral:advertisementData:RSSI:
 *
 *  @discussion 发现蓝牙，广播数据以及RSSI的回调
 */
- (void)bleDidDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

/*!
 *  @method bleDidDiscoverServices:
 *
 *  @discussion 发现蓝牙服务列表的回调
 */
- (void)bleDidDiscoverServices:(NSArray<CBService *> *)services;

@end

NS_ASSUME_NONNULL_BEGIN

//typedef void(^BLEReceivedDataBlock)(NSData * _Nullable data);
//
//typedef void(^BLEReadValueBlock)(CBUUID * characteristicUUID, CBUUID *serviceUUID, void(^)(NSData * _Nullable value));

@interface BLECentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>


@property (nonatomic, weak) id<BLEDelegate> delegate;

/*!
 *  @property peripherals
 *
 *  @discussion 已发现的蓝牙外设数组
 */
@property (nonatomic, strong, readonly) NSMutableArray<CBPeripheral *> *peripherals;
/*!
 *  @property activePeripheral
 *
 *  @discussion 当前已连接的蓝牙
 */
@property (nonatomic, strong, readonly) CBPeripheral *activePeripheral;

/*!
 *  @property activeService
 *
 *  @discussion 当前已连接的蓝牙服务
 */
@property (nonatomic, strong, readonly, nullable) CBService *activeService;

/*!
 *  @method manager
 *
 *  @discussion 便利初始化方法
 */
+ (instancetype)manager;

/*!
 *  @method initWithOptions:queue:
 *  @param options 默认为空
 *  @param queue 默认为空，主线程
 *  @discussion 指定初始化方法
 */
- (instancetype)initWithServiceUUIDs:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options queue:(nullable dispatch_queue_t)queue NS_DESIGNATED_INITIALIZER;

/*!
 *  @method isConnected
 *
 *  @discussion 是否成功连接蓝牙
 */
- (BOOL)isConnected;

/*!
 *  @method readForCharacteristic:
 *
 *  @discussion 从已连接的蓝牙的服务中读取特征值，回调见bleDidReceiveData:方法
 */
- (void)readForCharacteristic:(CBUUID *)characteristicUUID inService:(CBUUID *)serviceUUID;

/*!
 *  @method write:forCharacteristic:
 *
 *  @discussion 写入数据到特征值
 */
- (void)write:(NSData *)data forCharacteristic:(CBUUID *)characteristicUUID inService:(CBUUID *)serviceUUID;

/*!
 *  @method notifyCharacteristic:enabled:
 *
 *  @discussion 订阅蓝牙服务特征
 */
- (void)notify:(BOOL)enabled forCharacteristic:(CBUUID *)characteristicUUID inService:(CBUUID *)serviceUUID;

/*!
 *  @method readRSSI
 *
 *  @discussion 读取RSSI
 */
- (void)readRSSI;

/*!
 *  @method findBLEPeripherals:
 *  @param timeout 超时时间，超时后停止扫描
 *  @discussion 扫描周围所有蓝牙
 */
- (void)scanBLEPeripherals:(NSTimeInterval)timeout;

/*!
 *  @method findBLEPeripherals:forPeripheral:
 *  @param timeout 超时时间，超时后停止扫描
 *  @param peripheralName 外设名，如果不为空，只回调包含该 name 的蓝牙
 *  @discussion 扫描周围所有蓝牙
 */
- (void)scanBLEPeripherals:(NSTimeInterval)timeout forPeripheral:(NSString * _Nullable)peripheralName;

/*!
 *  @method connectPeripheral:
 *
 *  @discussion 连接到指定的蓝牙
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral;

/*!
 *  @method cancelConnection
 *
 *  @discussion 断开连接
 */
- (void)cancelConnection;

@end

NS_ASSUME_NONNULL_END
