//
//  BKRemotePeer.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/22.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKConfiguration.h"

@class BKRemotePeer;
@protocol BKRemotePeerDelegate <NSObject>
@optional
- (void)remotePeer:(BKRemotePeer *)remotePeer didSendArbitraryData:(NSData *)data;

@end

NS_ASSUME_NONNULL_BEGIN

@interface BKRemotePeer : NSObject

@property (nonatomic, strong) NSUUID *identifier;

@property (nonatomic, weak, nullable) id<BKRemotePeerDelegate> delegate;

@property (nonatomic, strong, nullable) BKConfiguration *configuration;

@property (nonatomic, strong, nullable) NSMutableData *data;

@property (nonatomic, assign, readonly) NSUInteger maximumUpdateValueLength;

- (instancetype)initWithIdentifier:(NSUUID *)identifier;

- (void)handleReceivedData:(NSData *)receivedData;

@end

NS_ASSUME_NONNULL_END
