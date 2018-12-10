//
//  BleCharacteristic.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/7.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "BleCharacteristic.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BleCharacteristic ()

//@property (nonatomic, strong) NSMutableArray<void (^)(NSError *)> *queuedCompletionBlocks;

@end

@implementation BleCharacteristic

- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic {
    NSAssert(characteristic && [characteristic isKindOfClass:[CBCharacteristic class]], @"characteristic should be kind of CBCharacteristic.class");
    self = [super init];
    if (!self) return nil;
    
    _characteristic = characteristic;
    
    return self;
}

- (void)setNotifyValue:(BOOL)isNotifying completion:(BLECharacteristicNotifyBlock)completion {
    [self.characteristic.service.peripheral setNotifyValue:isNotifying forCharacteristic:self.characteristic];
}

- (void)writeValue:(NSData *)data completion:(BLECharacteristicWriteBlock)completion {
    CBCharacteristicWriteType type = completion ? CBCharacteristicWriteWithResponse : CBCharacteristicWriteWithoutResponse;
    [self.characteristic.service.peripheral writeValue:data forCharacteristic:self.characteristic type:type];
}

- (void)writeByte:(int8_t)aByte completion:(BLECharacteristicWriteBlock)completion {
    [self writeValue:[NSData dataWithBytes:&aByte length:1] completion:completion];
}

- (void)readValueWithBlock:(BLECharacteristicReadBlock)block {
    NSAssert(block != nil, @"if block is nil, assume you no need to read");
    [self.characteristic.service.peripheral readValueForCharacteristic:self.characteristic];
}

@end
