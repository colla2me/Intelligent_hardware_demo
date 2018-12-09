//
//  BKCharacteristicMaker.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/12/9.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BKCharacteristicMaker.h"

@implementation BKCharacteristicMaker

- (instancetype)initWithUUIDString:(NSString *)UUIDString {
    self = [super init];
    if (!self) return nil;
    
    _UUIDString = UUIDString;
    self.packetsEnabled = NO;
    self.permissions = CBAttributePermissionsReadable | CBAttributePermissionsWriteable;
    self.properties = CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify;
    
    return self;
}

- (CBCharacteristic *)makeCharacteristic {
    return [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:self.UUIDString] properties:self.properties value:self.value permissions:self.permissions];
}

- (BKCharacteristicMaker *)onUpdate:(void(^)(NSData  * _Nullable, NSError * _Nullable))updateCallback {
    self.updateCallback = updateCallback;
    return self;
}

@end
