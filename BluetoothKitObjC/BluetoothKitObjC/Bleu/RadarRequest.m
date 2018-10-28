//
//  RadarRequest.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/28.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "RadarRequest.h"

@implementation RadarRequest

- (instancetype)initWithServiceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID {
    if (self = [super init])  {
        _serviceUUID = serviceUUID;
        _characteristicUUID = characteristicUUID;
        _characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify value:_value permissions:CBAttributePermissionsReadable];
    }
    return self;
}

@end
