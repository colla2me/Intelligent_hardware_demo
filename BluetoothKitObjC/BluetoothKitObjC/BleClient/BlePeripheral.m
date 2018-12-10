//
//  BlePeripheral.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/7.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "BlePeripheral.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BlePeripheral () <CBPeripheralDelegate>

@end

@implementation BlePeripheral

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    NSAssert(peripheral && [peripheral isKindOfClass:[CBPeripheral class]], @"peripheral should be kind of CBPeripheral.class");
    self = [super init];
    if (!self) return nil;
    _peripheral = peripheral;
    _peripheral.delegate = self;
    return self;
}

- (void)discoverServicesWithCompletion:(BLEPeripheralDiscoverServicesBlock)completion {
    
}

- (void)discoverServices:(NSArray *)seriveUUIDs completion:(BLEPeripheralDiscoverServicesBlock)completion {
    
}

- (void)connectWithCompletion:(BLEPeripheralConnectionBlock)completion {
    
}

- (void)disconnectWithCompletion:(BLEPeripheralConnectionBlock)completion {
    
}

- (void)readRSSIValueWithCompletion:(BLEPeripheralRSSIValueBlock)completion {
    
}

@end
