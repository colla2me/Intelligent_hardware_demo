//
//  BKRemotePeer.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/22.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BKRemotePeer.h"

@implementation BKRemotePeer

- (instancetype)initWithIdentifier:(NSUUID *)identifier {
    self = [super init];
    if (self) {
        _identifier = identifier;
    }
    return self;
}

- (NSUInteger)maximumUpdateValueLength {
    return 20;
}

- (void)handleReceivedData:(NSData *)receivedData {
    if (receivedData == _configuration.endOfDataMark) {
        if (_data &&
            _delegate &&
            [_delegate respondsToSelector:@selector(remotePeer:didSendArbitraryData:)]) {
            [_delegate remotePeer:self didSendArbitraryData:_data];
        }
        self.data = nil;
        return;
    }
    
    if (_data) {
        [_data appendData:receivedData];
        return;
    }
    
    self.data = receivedData.mutableCopy;
}

@end
