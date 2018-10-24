//
//  BKPeer.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/22.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKConfiguration.h"
#import "BKRemotePeer.h"
#import "BKSendDataTask.h"

typedef void(^BKSendDataCompletionHandler)(NSData *data, BKRemotePeer *remotePeer, NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface BKPeer : NSObject

@property (nonatomic, strong, nullable) BKConfiguration *configuration;

@property (nonatomic, strong) NSMutableArray<BKRemotePeer *> *connectedRemotePeers;

@property (nonatomic, strong) NSMutableArray<BKSendDataTask *> *sendDataTasks;

- (void)sendData:(NSData *)data toRemotePeer:(BKRemotePeer *)remotePeer completionHandler:(BKSendDataCompletionHandler)completionHandler;

- (void)processSendDataTasks;

- (void)failSendDataTasksForRemotePeer:(BKRemotePeer *)remotePeer;

- (BOOL)sendData:(NSData *)data toRemotePeer:(BKRemotePeer *)remotePeer;

@end

NS_ASSUME_NONNULL_END
