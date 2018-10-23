//
//  BKSendDataTask.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/22.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKRemotePeer.h"
#import "BKDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface BKSendDataTask : NSObject

@property (nonatomic, copy) NSData *data;

@property (nonatomic, strong) BKRemotePeer *destination;

@property (nonatomic, copy, nullable) BKSendDataCompletionHandler completionHandler;

@property (nonatomic, assign) NSUInteger offset;

@property (nonatomic, assign, readonly) NSUInteger maximumPayloadLength;

@property (nonatomic, assign, readonly) NSInteger lengthOfRemainingData;

@property (nonatomic, assign, readonly) BOOL sentAllData;

@property (nonatomic, assign, readonly) NSRange rangeForNextPayload;

@property (nonatomic, copy, readonly) NSData *nextPayload;

- (instancetype)initWithData:(NSData *)data destination:(BKRemotePeer *)destination completionHandler:(BKSendDataCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
