//
//  BleCentralManager.h
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/7.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSInteger, BleManagerState) {
    BleManagerStateUnknown = 0,
    BleManagerStateResetting,
    BleManagerStateUnsupported,
    BleManagerStateUnauthorized,
    BleManagerStatePoweredOff,
    BleManagerStatePoweredOn,
};

NS_ASSUME_NONNULL_BEGIN

@interface BleCentralManager : NSObject

@property (nonatomic, copy, nullable) NSString *peripheralName;
@property (nonatomic, copy) NSString *serviceUUIDString;
@property (nonatomic, copy) NSString *characteristicUUIDString;

@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *managerOptions;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *scanOptions;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *connectionOptions;

@property (nonatomic, strong, readonly) CBCentralManager *centralManager;
@property (nonatomic, strong, readonly, nullable) CBPeripheral *peripheral;
@property (nonatomic, assign, readonly) BleManagerState state;
@property (nonatomic, assign, readonly) BOOL isScanning;

/** convenience init */
+ (instancetype)manager;

/** designated init */
- (instancetype)initWithOptions:(nullable NSDictionary<NSString *, id> *)options;

- (void)scanForPeripheralsWithOptions:(nullable NSDictionary<NSString *, id> *)options handler:(void(^ _Nullable)(NSArray<CBPeripheral *> *peripherals))handler;

- (void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options handler:(void(^ _Nullable)(NSArray<CBPeripheral *> *peripherals))handler;

- (void)connectPeripheral:(CBPeripheral *)peripheral options:(nullable NSDictionary<NSString *, id> *)options;

- (void)readValueForCharacteristic:(CBUUID *)UUID completion:(void(^)(NSData *data, NSError *error))completion;

- (void)writeValue:(NSData *)data forCharacteristic:(CBUUID *)UUID type:(CBCharacteristicWriteType)type completion:(void(^)(NSError *error))completion;

- (void)setCentralDidDiscoverPeripheralBlock:(void(^)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI))block;

- (void)setCentralDidDiscoverServicesBlock:(void(^)(CBPeripheral *peripheral, NSError *error))block;

- (void)setCentralDidDiscoverCharacteristicsBlock:(void(^)(CBPeripheral *peripheral, CBService *service, NSError *error))block;

- (void)setReadValueCompletionHandler:(void(^)(NSData *data, NSError *error))block;

/** 1. stop scan
    2. disconnect to peripheral
    3. clean up
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
