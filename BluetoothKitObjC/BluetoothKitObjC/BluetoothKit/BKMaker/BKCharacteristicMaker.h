//
//  BKCharacteristicMaker.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/12/9.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKCharacteristicMaker : NSObject

@property (nonatomic, copy, readonly) NSString *UUIDString;

@property (nonatomic, strong, nullable) NSData *value;
@property (nonatomic, assign) BOOL packetsEnabled;
@property (nonatomic, assign) CBAttributePermissions permissions;
@property (nonatomic, assign) CBCharacteristicProperties properties;
@property (nonatomic, copy, nullable) void(^updateCallback)(NSData  * _Nullable, NSError * _Nullable);

- (instancetype)initWithUUIDString:(NSString *)UUIDString;

- (CBCharacteristic *)makeCharacteristic;

- (BKCharacteristicMaker *)onUpdate:(void(^)(NSData  * _Nullable data, NSError * _Nullable error))onUpdate;

@end

NS_ASSUME_NONNULL_END
