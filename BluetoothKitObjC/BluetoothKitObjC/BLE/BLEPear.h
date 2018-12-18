//
//  BLEPear.h
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/18.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEPear : NSObject

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

@property(readonly, nonatomic, nullable) NSUUID *identifier;

@property(copy, readonly, nullable) NSString *name;

@property(copy, readonly, nullable) NSNumber *RSSI;

@property(readonly) CBPeripheralState state;

@end
