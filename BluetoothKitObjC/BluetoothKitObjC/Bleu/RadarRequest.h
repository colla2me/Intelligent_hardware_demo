//
//  RadarRequest.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/28.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void(^ResponseHandler)(CBPeripheral*, CBCharacteristic*, NSError*);

NS_ASSUME_NONNULL_BEGIN

@interface RadarRequest : NSObject

@property (nonatomic, strong) CBUUID *serviceUUID;

@property (nonatomic, strong) CBUUID *characteristicUUID;

@property (nonatomic, strong, nullable) NSData *value;

@property (nonatomic, copy, nullable) NSDictionary *options;

@property (nonatomic, strong) CBMutableCharacteristic *characteristic;

@property (nonatomic, copy) ResponseHandler response;

- (instancetype)initWithServiceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID;

@end

NS_ASSUME_NONNULL_END
