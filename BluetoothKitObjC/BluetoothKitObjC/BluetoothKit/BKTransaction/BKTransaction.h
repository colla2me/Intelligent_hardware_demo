//
//  BKTransaction.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/12/9.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void(^BKTransactionBlock)(NSData *data, NSError *error);

typedef NS_ENUM(NSUInteger, BKTransactionDirection) {
    BKTransactionCentralToPeripheral,
    BKTransactionPeripheralToCentral
};

typedef NS_ENUM(NSUInteger, BKTransactionType) {
    BKTransactionRead,
    BKTransactionReadPackets,
    BKTransactionWrite,
    BKTransactionWritePackets
};

NS_ASSUME_NONNULL_BEGIN

@interface BKTransaction : NSObject

@property (nonatomic, strong, nullable) CBCharacteristic *characteristic;
@property (nonatomic, assign) BKTransactionDirection direction;
@property (nonatomic, assign) BKTransactionType type;
@property (nonatomic, assign) int16_t mtuSize;
@property (nonatomic, assign) int64_t totalPackets;
@property (nonatomic, copy, nullable) BKTransactionBlock completion;
@property (nonatomic, strong, nullable) NSData *data;

- (instancetype)initWithType:(BKTransactionType)type direction:(BKTransactionDirection)direction characteristic:(CBCharacteristic * _Nullable)characteristic mtuSize:(int16_t)mtuSize completion:(BKTransactionBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
