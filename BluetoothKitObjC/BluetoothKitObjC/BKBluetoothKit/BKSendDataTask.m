//
//  BKSendDataTask.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/22.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BKSendDataTask.h"

@implementation BKSendDataTask

- (NSUInteger)maximumPayloadLength {
    return _destination.maximumUpdateValueLength;
}

- (NSInteger)lengthOfRemainingData {
    return _data.length - _offset;
}

- (BOOL)sentAllData {
    return self.lengthOfRemainingData == 0;
}

- (NSRange)rangeForNextPayload {
    NSUInteger lenghtOfNextPayload = self.maximumPayloadLength <= self.lengthOfRemainingData ? self.maximumPayloadLength : self.lengthOfRemainingData;
    return NSMakeRange(_offset, lenghtOfNextPayload);
}

- (NSData *)nextPayload {
    NSRange range = self.rangeForNextPayload;
    if (range.location != NSNotFound && range.length > 0) {
        return [_data subdataWithRange:range];
    }
    return nil;
}

- (instancetype)initWithData:(NSData *)data destination:(BKRemotePeer *)destination completionHandler:(BKSendDataCompletionHandler)completionHandler {
    self = [super init];
    if (self) {
        _offset = 0;
        _data = data;
        _destination = destination;
        _completionHandler = completionHandler;
    }
    return self;
}

@end
