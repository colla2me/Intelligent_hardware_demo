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

@interface BleCentralManager : NSObject

@property (nonatomic, copy) NSString *peripheralName;
@property (nonatomic, copy) NSString *serviceUUIDString;
@property (nonatomic, copy) NSString *characteristicUUIDString;
@property (nonatomic, assign, readonly) BleManagerState state;

//@property (nonatomic, strong, readonly) NSMutableSet<CBPeripheral *> *discoveredPeripherals;
//@property (nonatomic, strong, readonly) NSMutableSet<CBService *> *discoveredServices;
//@property (nonatomic, strong, readonly) NSMutableSet<CBCharacteristic *> *discoveredCharacteristics;

/** convinience init */
+ (instancetype)manager;

/** designated init */
- (instancetype)initWithOptions:(NSDictionary<NSString *, id> *)options;

- (void)connectPeripheralName:(NSString *)peripheralName options:(NSDictionary<NSString *, id> *)options;

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
