//
//  BKCentralManager.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/12/9.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSUInteger, BKManagerState) {
    BKManagerStateUnknown,
    BKManagerStateResetting,
    BKManagerStateUnsupported,
    BKManagerStateUnauthorized,
    BKManagerStatePoweredOff,
    BKManagerStatePoweredOn
};

typedef void(^BKCentralManagerStateChangeBlock)(BKManagerState state);
typedef void(^BKCentralManagerDidDiscoverBlock)(CBPeripheral *peripheral, NSDictionary<NSString *, id> *advertisementData, NSNumber *RSSI);
typedef void(^BKCentralManagerPeripheralConnectionBlock)(BOOL connected, CBPeripheral *peripheral, NSError *error);

typedef void(^BKCharacteristicWriteBlock)(NSData *data, NSError *error);
typedef void(^BKCharacteristicUpdateBlock)(NSData *data, NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface BKCentralManager : NSObject

@end

NS_ASSUME_NONNULL_END
