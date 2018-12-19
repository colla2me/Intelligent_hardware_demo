//
//  BLEPear.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/18.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "BLEPear.h"

@implementation BLEPear {
    CBPeripheral *_peripheral;
}

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (!self) return nil;
    _peripheral = peripheral;
    return self;
}

- (NSUUID *)identifier {
    return _peripheral.identifier;
}

- (NSString *)name {
    return _peripheral.name;
}

- (void)setRSSI:(NSNumber * _Nullable)RSSI {
    _RSSI = RSSI;
}

- (CBPeripheralState)state {
    return _peripheral.state;
}

@end
