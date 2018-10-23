//
//  BKDiscovery.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/10/23.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "BKDiscovery.h"
#import <CoreBluetooth/CBAdvertisementData.h>

@implementation BKDiscovery

- (instancetype)initWithAdvertisementData:(NSDictionary *)advertisementData pheripheral:(CBPeripheral *)pheripheral RSSI:(NSNumber *)RSSI {
    self = [super init];
    if (self) {
        _advertisementData = advertisementData;
        _peripheral = pheripheral;
        _RSSI = RSSI;
        _localName = advertisementData[CBAdvertisementDataLocalNameKey];
    }
    return self;
}

@end
