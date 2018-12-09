//
//  BKTransaction.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/12/9.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BKTransaction.h"
#import "NSData+BLE.h"

@interface BKTransaction ()

@property (nonatomic, assign) NSUInteger activeResponseCount;
@property (nonatomic, strong) NSMutableArray<NSData *> *dataPackets;

@end

@implementation BKTransaction

- (instancetype)initWithType:(BKTransactionType)type direction:(BKTransactionDirection)direction characteristic:(CBCharacteristic * _Nullable)characteristic mtuSize:(int16_t)mtuSize completion:(BKTransactionBlock _Nullable)completion {
    self = [super init];
    if (!self) return nil;
    
    self.direction = direction;
    self.type = type;
    self.mtuSize = mtuSize;
    self.characteristic = characteristic;
    self.completion = completion;
    self.totalPackets = 0;
    self.activeResponseCount = 0;
    self.dataPackets = [NSMutableArray array];
    
    if (type != BKTransactionWritePackets &&
        type != BKTransactionReadPackets) {
        self.totalPackets = 1;
    }
    
    return self;
}

- (void)setData:(NSData *)data {
    _data = data;
    if (_type == BKTransactionWritePackets || _type == BKTransactionReadPackets) {
        NSArray<NSData *> *packets = [data packetArrayWithMTUSize:self.mtuSize];
        self.dataPackets = packets ? [packets mutableCopy] : [NSMutableArray array];
        self.totalPackets = packets.count ?: 1;
    } else {
        if (data) {
            self.dataPackets = [@[data] mutableCopy];
        } else {
            self.dataPackets = [NSMutableArray array];
        }
    }
}


- (void)processTransaction {
    self.activeResponseCount += 1;
}

- (void)appendPacket:(NSData *)dataPacket {
    if (!dataPacket) return;
    
    if (_type == BKTransactionWritePackets ||
        _type == BKTransactionReadPackets) {
        
        self.totalPackets = dataPacket.totalPackets;
    }
    
    [self.dataPackets addObject:dataPacket];
}

- (BOOL)isComplete {
    if (_type == BKTransactionReadPackets ||
        _type == BKTransactionWritePackets) {
        return self.totalPackets == self.activeResponseCount;
    }
    return self.activeResponseCount == 1;
}

@end
