//
//  BleCharacteristic.h
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/7.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BLECharacteristicReadBlock)(NSData *data, NSError *error);
typedef void (^BLECharacteristicNotifyBlock)(NSError *error);
typedef void (^BLECharacteristicWriteBlock)(NSError *error);

@class CBCharacteristic;
@interface BleCharacteristic : NSObject

/**
 * Core Bluetooth's CBCharacteristic instance
 */
@property (strong, nonatomic, readonly) CBCharacteristic *characteristic;

@property (nonatomic, copy) BLECharacteristicNotifyBlock notifyValueBlock;

@property (nonatomic, copy) BLECharacteristicWriteBlock writeValueBlock;

@property (nonatomic, copy) BLECharacteristicReadBlock readValueBlock;

/**
 * @return Wrapper object over Core Bluetooth's CBCharacteristic
 */
- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic;

/**
 * Enables or disables notifications/indications for the characteristic
 * value of characteristic.
 * @param isNotifying Enable/Disable notifications
 * @param completion Will be called after successfull/failure ble-operation
 */
- (void)setNotifyValue:(BOOL)isNotifying
            completion:(BLECharacteristicNotifyBlock)completion;

/**
 * Writes input data to characteristic
 * @param data NSData object representing bytes that needs to be written
 * @param completion Will be called after successfull/failure ble-operation
 */
- (void)writeValue:(NSData *)data
        completion:(BLECharacteristicWriteBlock)completion;

/**
 * Writes input byte to characteristic
 * @param aByte byte that needs to be written
 * @param completion Will be called after successfull/failure ble-operation
 */
- (void)writeByte:(int8_t)aByte
       completion:(BLECharacteristicWriteBlock)completion;

/**
 * Reads characteristic value
 * @param block Will be called after successfull/failure
 * ble-operation with response
 */
- (void)readValueWithBlock:(BLECharacteristicReadBlock)block;

@end
