//
//  BlePeripheral.h
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/7.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^BLEPeripheralConnectionBlock)(NSError *error);
typedef void(^BLEPeripheralDiscoverServicesBlock)(NSArray *services, NSError *error);
typedef void(^BLEPeripheralRSSIValueBlock)(NSNumber *RSSI, NSError *error);

@class BleCentralManager, CBPeripheral;
@interface BlePeripheral : NSObject

@property (weak, nonatomic) BleCentralManager *manager;

@property (nonatomic, strong, readonly) CBPeripheral *peripheral;

@property (nonatomic, copy, readonly) NSArray *includedServices;

@property (nonatomic, copy, readonly) NSNumber *RSSI;

@property (nonatomic, copy, readonly) NSDictionary *advertisementData;

@property (nonatomic, copy, readonly) NSString *name;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

- (void)discoverServicesWithCompletion:(BLEPeripheralDiscoverServicesBlock)completion;

- (void)discoverServices:(NSArray *)seriveUUIDs completion:(BLEPeripheralDiscoverServicesBlock)completion;

- (void)connectWithCompletion:(BLEPeripheralConnectionBlock)completion;

- (void)disconnectWithCompletion:(BLEPeripheralConnectionBlock)completion;

- (void)readRSSIValueWithCompletion:(BLEPeripheralRSSIValueBlock)completion;

@end
