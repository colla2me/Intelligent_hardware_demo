//
//  BKCBCentralManager.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/10/23.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "BKCBCentralManager.h"

typedef void(^BKCentralDidDiscoverBlock)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);

@interface BKCBCentralManager ()

@property (readwrite, nonatomic, strong) CBCentralManager *centralManager;

@property (readwrite, nonatomic, strong) BKConfiguration *configuration;

@property (readwrite, nonatomic, strong) dispatch_queue_t queue;

@property (readwrite, nonatomic, copy) NSDictionary *options;

@property (nonatomic, copy) BKCentralDidDiscoverBlock didDiscoverBlock;

@end

@implementation BKCBCentralManager

static NSString * const BKCBRestoreIdentifierKey = @"com.bkcb.restore.identifier";

- (instancetype)initWithConfiguration:(BKConfiguration *)configuration {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if (!configuration) {
        configuration = [BKConfiguration defaultConfiguration];
    }
    
    self.configuration = configuration;
    
    self.queue = dispatch_get_main_queue();
    
    self.options = @{CBCentralManagerOptionShowPowerAlertKey: @YES, CBCentralManagerOptionRestoreIdentifierKey: BKCBRestoreIdentifierKey};
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.queue options:self.options];
    
    return self;
}

- (void)setScanPeripheralCompleteBlock:(void(^)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI))block {
    self.didDiscoverBlock = block;
}

- (void)startScanForPeripheralsWithCompletionHandler:(BKCentralDidDiscoverBlock)completionHandler {
    self.didDiscoverBlock = completionHandler;
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey: @YES};
    [self.centralManager scanForPeripheralsWithServices:self.configuration.serviceUUIDs options:options];
}

- (void)stopScan {
    [self.centralManager stopScan];
    NSLog(@"停止继续搜索外设");
}

// 当前蓝牙主设备状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStateResetting:
            NSLog(@"正在重置");
            break;
            
        case CBCentralManagerStatePoweredOn:
            NSLog(@"蓝牙已开启");
            break;
            
        case CBCentralManagerStatePoweredOff:
            NSLog(@"蓝牙未打开");
            break;
            
        case CBCentralManagerStateUnsupported:
            NSLog(@"该设备不支持蓝牙BLE");
            break;
            
        case CBCentralManagerStateUnauthorized:
            NSLog(@"未授权使用蓝牙");
            break;
            
        default:
            NSLog(@"未知状态");
            break;
    }
}

// 扫描到外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (_didDiscoverBlock) {
        self.didDiscoverBlock(peripheral, advertisementData, RSSI);
    }
}

// 连接到外设
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
}

// 连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
}

// 断开与外设的连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
}

// 扫描到服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
}

// 扫描到特征值
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error {
    
}

// 扫描到具体设备
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

@end
