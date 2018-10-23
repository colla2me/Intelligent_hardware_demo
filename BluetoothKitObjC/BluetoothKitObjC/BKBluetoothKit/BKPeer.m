//
//  BKPeer.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/22.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BKPeer.h"

@implementation BKPeer

- (NSMutableArray<BKSendDataTask *> *)sendDataTasks {
    if (!_sendDataTasks) {
        _sendDataTasks = [NSMutableArray array];
    }
    return _sendDataTasks;
}

- (NSMutableArray<BKRemotePeer *> *)connectedRemotePeers {
    if (!_connectedRemotePeers) {
        _connectedRemotePeers = [NSMutableArray array];
    }
    return _connectedRemotePeers;
}

- (void)sendData:(NSData *)data toRemotePeer:(BKRemotePeer *)remotePeer completionHandler:(BKSendDataCompletionHandler)completionHandler {
    if (![_connectedRemotePeers containsObject:remotePeer]) {
        if (completionHandler) {
            //TODO:
            NSError *error = [NSError errorWithDomain:@"com.bk.bluetooth" code:404 userInfo:@{}];
            completionHandler(data, remotePeer, error);
        }
        return;
    }
    
    BKSendDataTask *sendDataTask = [[BKSendDataTask alloc] initWithData:data destination:remotePeer completionHandler:completionHandler];
    [self.sendDataTasks addObject:sendDataTask];
    if (_sendDataTasks.count >= 1) {
        [self processSendDataTasks];
    }
}

- (void)processSendDataTasks {
    if (!_sendDataTasks.count) return;
    
    BKSendDataTask *nextTask = _sendDataTasks.firstObject;
    if (nextTask.sentAllData) {
        BOOL sentEndOfDataMask = [self sendData:_configuration.endOfDataMark toRemotePeer:nextTask.destination];
        if (!sentEndOfDataMask) {
            return;
        }
        
        [_sendDataTasks removeObjectAtIndex:[_sendDataTasks indexOfObject:nextTask]];
        nextTask.completionHandler(nextTask.data, nextTask.destination, nil);
        [self processSendDataTasks];
    }
}

- (void)failSendDataTasksForRemotePeer:(BKRemotePeer *)remotePeer {
    for (BKSendDataTask *sendDataTask in _sendDataTasks) {
        if (sendDataTask.destination == remotePeer) {
            //TODO:
        }
    }
}

- (BOOL)sendData:(NSData *)data toRemotePeer:(BKRemotePeer *)remotePeer {
    return NO;
}

@end
