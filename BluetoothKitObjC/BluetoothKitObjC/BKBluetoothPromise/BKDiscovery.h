//
//  BKDiscovery.h
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/10/23.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import <CoreBluetooth/CBPeripheral.h>

@interface BKDiscovery : NSObject

@property (readonly, nonatomic, strong) CBPeripheral *peripheral;

@property (readonly, nonatomic, copy, nullable) NSString *localName;

@property (readonly, nonatomic, copy) NSDictionary *advertisementData;

@property (readonly, nonatomic, copy) NSNumber *RSSI;

- (instancetype)initWithAdvertisementData:(NSDictionary *)advertisementData
                              pheripheral:(CBPeripheral *)pheripheral
                                     RSSI:(NSNumber *)RSSI;

@end
