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
 *  @discussion 已断开与蓝牙连接的回调
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
 *  @discussion 读取蓝牙RSSI值回调
 */
- (void)bleDidReadRSSI:(NSNumber *)rssi;

/*!
 *  @method bleDidReceiveData:length
 *
 *  @discussion 读取蓝牙指定特征值的value的回调
 */
- (void)bleDidReceiveData:(unsigned char *)data length:(NSUInteger)length;

/*!
 *  @method bleDidDiscoverPeripheral:advertisementData:RSSI:
 *
 *  @discussion 发现蓝牙外设，广播数据以及RSSI的回调
 */
- (void)bleDidDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
@end

NS_ASSUME_NONNULL_BEGIN

@interface BLECentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, weak) id<BLEDelegate> delegate;
/*!
 *  @property peripheralName
 *
 *  @discussion 蓝牙外设 name，可用来发现指定名称的蓝牙
 */
@property (nonatomic, copy, nullable) NSString *peripheralName;
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
 *  @method manager
 *
 *  @discussion 便利初始化方法
 */
+ (instancetype)manager;

/*!
 *  @method initWithOptions:queue:
 *
 *  @discussion 指定初始化方法
 */
- (instancetype)initWithOptions:(nullable NSDictionary<NSString *, id> *)options queue:(nullable dispatch_queue_t)queue NS_DESIGNATED_INITIALIZER;

/*!
 *  @method isConnected
 *
 *  @discussion 是否成功连接蓝牙
 */
- (BOOL)isConnected;

/*!
 *  @method read
 *
 *  @discussion 从已连接的蓝牙的服务中读取特征值
 */
- (void)read;

/*!
 *  @method readForCharacteristic:service
 *
 *  @discussion 指定服务和特征，从已连接的蓝牙的服务中读取特征值
 */
- (void)readForCharacteristic:(CBUUID *)characteristicUUID service:(CBUUID *)serviceUUID;

/*!
 *  @method write:
 *
 *  @discussion 写入数据到特征值
 */
- (void)write:(NSData *)data;

/*!
 *  @method readRSSI
 *
 *  @discussion 读取RSSI
 */
- (void)readRSSI;

/*!
 *  @method findBLEPeripherals:
 *  @param timeout 指定超时时间，超时后停止扫描
 *  @discussion 扫描发现外设
 */
- (int)findBLEPeripherals:(NSTimeInterval)timeout;

/*!
 *  @method connectPeripheral:
 *
 *  @discussion 连接到指定的蓝牙外设
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral;

/*!
 *  @method enableReadNotification:
 *
 *  @discussion 订阅蓝牙服务特征
 */
- (void)enableReadNotification:(CBPeripheral *)peripheral;

/*!
 *  @method cancelConnection
 *
 *  @discussion 断开连接
 */
- (void)cancelConnection;

@end

NS_ASSUME_NONNULL_END
