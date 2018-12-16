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
- (void)bleDidConnect;
- (void)bleDidDisconnect;
- (void)bleDidChangeState:(BOOL)isEnabled;
- (void)bleDidReadRSSI:(NSNumber *)rssi;
- (void)bleDidReceiveData:(unsigned char *)data length:(NSUInteger)length;
- (void)bleDidDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
@end

NS_ASSUME_NONNULL_BEGIN

@interface BLECentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, weak) id<BLEDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableArray<CBPeripheral *> *peripherals;
@property (nonatomic, strong, readonly) CBCentralManager *centralManager;
@property (nonatomic, strong, readonly) CBPeripheral *activePeripheral;

+ (instancetype)manager;

- (instancetype)initWithOptions:(nullable NSDictionary<NSString *, id> *)options queue:(nullable dispatch_queue_t)queue NS_DESIGNATED_INITIALIZER;

- (BOOL)isConnected;
- (void)read;
- (void)write:(NSData *)data;
- (void)readRSSI;

- (int)findBLEPeripherals:(NSTimeInterval)timeout;
- (void)connectPeripheral:(CBPeripheral *)peripheral;
- (void)enableReadNotification:(CBPeripheral *)peripheral;
- (void)cancelConnection;

- (const char *)centralManagerStateToString:(int)state;
- (void)getAllServicesFromPeripheral:(CBPeripheral *)peripheral;
- (void)getAllCharacteristicsFromPeripheral:(CBPeripheral *)peripheral;
- (CBService *)findServiceFromUUID:(CBUUID *)UUID peripheral:(CBPeripheral *)peripheral;
- (CBCharacteristic *)findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service;

- (NSString *)CBUUIDToString:(CBUUID *)UUID;
- (UInt16)CBUUIDToInt:(CBUUID *)UUID;

@end

NS_ASSUME_NONNULL_END
