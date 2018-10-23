//
//  BKCBCentralManager.h
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/10/23.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <PromisesObjC/FBLPromises.h>
#import "BKConfiguration.h"

@interface BKCBCentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

- (instancetype)initWithConfiguration:(BKConfiguration *)configuration;

@property (readonly, nonatomic, strong) CBCentralManager *centralManager;

@property (readonly, nonatomic, strong) BKConfiguration *configuration;

@property (readonly, nonatomic, strong) dispatch_queue_t queue;

@property (readonly, nonatomic, copy) NSDictionary *options;

//- (void)setScanPeripheralCompleteBlock:(void(^)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI))block;

- (void)startScanForPeripheralsWithCompletionHandler:(void(^)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI))completionHandler;

- (void)stopScan;

@end
