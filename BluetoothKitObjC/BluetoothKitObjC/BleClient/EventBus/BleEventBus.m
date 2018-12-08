//
//  BleEventBus.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/8.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "BleEventBus.h"

@interface BleEventBus ()

@property (nonatomic, strong, readonly) NSMutableDictionary *cache;
@property (nonatomic, strong, readonly) dispatch_queue_t queue;

@end

@implementation BleEventBus

+ (instancetype)getInstance {
    static BleEventBus *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BleEventBus alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("com.yilos.eventBus", DISPATCH_QUEUE_SERIAL);
        _cache = [NSMutableDictionary dictionary];
    }
    return self;
}




























@end
