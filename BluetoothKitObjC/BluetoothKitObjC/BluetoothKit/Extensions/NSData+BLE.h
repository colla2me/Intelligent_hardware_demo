//
//  NSData+BLE.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/12/9.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (BLE)

- (NSInteger)packetIndex;

- (NSInteger)totalPackets;

- (NSData *)headerData:(int)packetIndex totalPackets:(int)totalPackets;

- (NSArray<NSData *> *)packetArrayWithMTUSize:(int16_t)mtuSize;

@end

NS_ASSUME_NONNULL_END
