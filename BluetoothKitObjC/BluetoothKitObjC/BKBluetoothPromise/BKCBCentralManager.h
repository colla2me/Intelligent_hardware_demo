//
//  BKCBCentralManager.h
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/10/23.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <PromisesObjC/FBLPromises.h>
#import "BKConfiguration.h"
#import "BKDiscovery.h"

NS_ASSUME_NONNULL_BEGIN

@interface BKCBCentralManager : NSObject

@property (class, readonly, nonatomic, strong) BKCBCentralManager *manager;

@property (readonly, nonatomic, strong) CBCentralManager *centralManager;

@property (readonly, nonatomic, strong, nullable) CBPeripheral *connectedPeripheral;

@property (readonly, nonatomic, strong, nullable) BKConfiguration *configuration;

- (instancetype)initWithConfiguration:(nullable BKConfiguration *)configuration;

- (FBLPromise<BKDiscovery *> *)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs;

- (FBLPromise<CBPeripheral *> *)connectPeripheral:(CBPeripheral *)peripheral;

- (FBLPromise<NSArray<CBService *> *> *)discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs forPeripheral:(CBPeripheral *)peripheral;

- (FBLPromise<NSArray<CBCharacteristic *> *> *)discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service;

- (FBLPromise<NSData *> *)readValueForCharacteristic:(CBCharacteristic *)characteristic;

- (void)stopScan;

@end

NS_ASSUME_NONNULL_END
