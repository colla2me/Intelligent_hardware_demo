//
//  Radar.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/28.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "RadarOptions.h"
#import "RadarRequest.h"

typedef NS_ENUM(NSInteger, RadarError) {
    timeout = -1001,
    canceled,
    invalidRequest
};

NS_ASSUME_NONNULL_BEGIN

@interface Radar : NSObject <CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableSet<CBPeripheral *> *discoveredPeripherals;
@property (nonatomic, strong) NSMutableSet<CBPeripheral *> *connectedPeripherals;
@property (nonatomic, copy) NSArray<CBUUID *> *serviceUUIDs;
@property (nonatomic, copy) NSArray<CBCharacteristic *> *characteristics;

@property (nonatomic, assign, readonly) BOOL isNotifying;
@property (nonatomic, assign, readonly) BOOL isScanning;
@property (nonatomic, assign, readonly) CBCentralManagerState state;
@property (nonatomic, strong) RadarOptions *radarOptions;
@property (nonatomic, copy) NSDictionary *scanOptions;

@property (nonatomic, strong) NSMutableDictionary<NSUUID*, NSSet<RadarRequest*>*> *completedRequests;

//@property (nonatomic, assign, readonly) NSInteger thresholdRSSI;
//@property (nonatomic, assign, readonly) BOOL allowDuplicates;
//@property (nonatomic, assign, readonly) NSInteger timeout;
//@property (nonatomic, copy) NSString *restoreIdentifierKey;
@property (nonatomic, copy) void(^startScanBlock)(NSDictionary *);
@property (nonatomic, copy) void(^completionHandler)(NSDictionary* _Nullable,  NSError* _Nullable);

- (instancetype)initWithRequest:(RadarRequest *)request options:(RadarOptions *)options;

- (void)resume;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
