//
//  BLEClient.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/12/15.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLECentralManager.h"

typedef NS_ENUM(NSUInteger, BLEWriteEncodingType) {
    BLEWriteEncodingUTF8,
    BLEWriteEncodingBase64,
    BLEWriteEncodingHex,
};

NS_ASSUME_NONNULL_BEGIN

@interface BLEClient : NSObject <BLEDelegate>

- (BOOL)isConnected;

- (void)connect:(NSString *)uuid;

- (void)disconnect;

- (void)readValueWithBlock:(void(^)(NSString *))block;

- (void)writeValue:(NSData *)data;

- (void)writeText:(NSString *)text type:(BLEWriteEncodingType)type;

- (void)findPeripheralsWithBlock:(void(^)(NSArray<CBPeripheral *>*))block;

@end

NS_ASSUME_NONNULL_END
