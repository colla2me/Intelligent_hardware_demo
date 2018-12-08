//
//  BleCharacteristic.h
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/7.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BleCharacteristicReadBlock)(NSData *data, NSError *error);
typedef void (^BleCharacteristicNotifyBlock)(NSError *error);
typedef void (^BleCharacteristicWriteBlock)(NSError *error);

@class CBCharacteristic;
@interface BleCharacteristic : NSObject

/**
 * Core Bluetooth's CBCharacteristic instance
 */
//@property (strong, nonatomic, readonly) CBCharacteristic *characteristic;

/**
 * NSString representation of 16/128 bit CBUUID
 */
//@property (copy, nonatomic, readonly) NSString *UUIDString;

/**
 * Enables or disables notifications/indications for the characteristic
 * value of characteristic.
 * @param notifyValue Enable/Disable notifications
 * @param completion Will be called after successfull/failure ble-operation
 */
//- (void)setNotifyValue:(BOOL)notifyValue
//            completion:(BleCharacteristicNotifyBlock)completion;

/**
 * Enables or disables notifications/indications for the characteristic
 * value of characteristic.
 * @param notifyValue Enable/Disable notifications
 * @param completion Will be called after successfull/failure ble-operation
 * @param callback Will be called after every new successful update
 */
//- (void)setNotifyValue:(BOOL)notifyValue
//            completion:(BleCharacteristicNotifyBlock)completion
//              onUpdate:(BleCharacteristicReadBlock)callback;

/**
 * Writes input data to characteristic
 * @param data NSData object representing bytes that needs to be written
 * @param completion Will be called after successfull/failure ble-operation
 */
//- (void)writeValue:(NSData *)data
//        completion:(BleCharacteristicWriteBlock)completion;

/**
 * Writes input byte to characteristic
 * @param aByte byte that needs to be written
 * @param completion Will be called after successfull/failure ble-operation
 */
//- (void)writeByte:(int8_t)aByte
//       completion:(BleCharacteristicWriteBlock)completion;

/**
 * Reads characteristic value
 * @param block Will be called after successfull/failure
 * ble-operation with response
 */
//- (void)readValueWithBlock:(BleCharacteristicReadBlock)block;


// ----- Used for input events -----/

//- (void)handleSetNotifiedWithError:(NSError *)error;
//
//- (void)handleReadValue:(NSData *)value error:(NSError *)error;
//
//- (void)handleWrittenValueWithError:(NSError *)error;


/**
 * @return Wrapper object over Core Bluetooth's CBCharacteristic
 */
//- (instancetype)initWithCharacteristic:(CBCharacteristic *)aCharacteristic;

@end
