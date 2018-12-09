//
//  NSData+BLE.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/12/9.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "NSData+BLE.h"

const int16_t packetHeaderSize = 4;

@implementation NSData (BLE)

+ (NSData *)reconstructedDataWithArray:(NSArray<NSData *> *)dataArray {
    NSMutableData *reconstructedData = [NSMutableData data];
    for (NSData *dataItem in dataArray) {
        if (dataItem.length <= packetHeaderSize) continue;
        NSData *packetData = [dataItem subdataWithRange:NSMakeRange(packetHeaderSize, dataItem.length-packetHeaderSize)];
        [reconstructedData appendData:packetData];
    }
    return reconstructedData;
}

- (NSInteger)packetIndex {
    if (self.length < 4) {
        return 0;
    }
 
    return [self bytesFrom:0 length:2];
}

- (NSInteger)totalPackets {
    if (self.length < 4) {
        return 0;
    }
    
    return [self bytesFrom:2 length:2];
}

- (NSData *)headerData:(int)packetIndex totalPackets:(int)totalPackets {
    NSMutableData *messageData = [NSMutableData data];
    [messageData appendData:[NSData dataWithBytes:&packetIndex length:sizeof(packetIndex)]];
    [messageData appendData:[NSData dataWithBytes:&totalPackets length:sizeof(totalPackets)]];
    return messageData;
}

- (NSArray<NSData *> *)packetArrayWithMTUSize:(int16_t)mtuSize {
    int16_t packetSize = mtuSize - packetHeaderSize;
    int16_t length = self.length;
    int16_t offset = 0;
    
    int totalPackets = (length / packetSize) + (length % packetSize > 0 ? 1 : 0);
    int16_t currentCount = 0;
    NSMutableArray<NSData *> *packetArray = [NSMutableArray array];
    
    do {
        currentCount = currentCount + 1;

        int currentPacketSize = ((length - offset) > packetSize) ? packetSize : (length - offset);
        NSData *packet = [self subdataWithRange:NSMakeRange(offset, offset + currentPacketSize)];
        
        NSMutableData *messageData = [NSMutableData data];
        [messageData appendData:[self headerData:currentCount totalPackets:totalPackets]];
        [messageData appendData:packet];
        [packetArray addObject:messageData];
        
        offset += currentPacketSize;
        
    } while (offset < length);
    
    return packetArray;
}

- (int)bytesFrom:(int)start length:(int)length {
    int lowerBound = start * 8;
    int upperBound = length * 8;
    
    NSUInteger bytesLength = self.length;
    int8_t bytesArray[bytesLength];
    [self getBytes:&bytesArray length:bytesLength];
    
    int len = upperBound - lowerBound;
    int positions[len];
    int loc = lowerBound;
    for (int i = 0; i < len; i++) {
        positions[i] = loc++;
    }
    
    int total = 0;
    int byteSize = 8;
    for (int j = len - 1; j >= 0; j--) {
        int position = positions[j];
        int bytePosition = position / byteSize;
        int bitPosition = 7 - (position % byteSize);
        int byte = bytesArray[bytePosition];
        total = total + (((byte >> bitPosition) & 0x01) << j);
        NSLog(@"position: %d total: %d byte: %d", position, total, byte);
    }
    
    return total;
}

@end
