//
//  BKCBCentralManager.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/10/23.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "BKCBCentralManager.h"

@interface BKCBCentralManager ()

@property (readwrite, nonatomic, strong) CBCentralManager *centralManager;
@property (readwrite, nonatomic, strong) CBPeripheral *connectedPeripheral;
@property (readwrite, nonatomic, strong) BKConfiguration *configuration;
@property (nonatomic, strong) NSMutableDictionary<NSString *, FBLPromise<id> *> *multiPendingPromises;
@property (nonatomic, strong) NSMutableDictionary<NSUUID *, CBPeripheral *> *connectedPeripherals;

@end

@implementation BKCBCentralManager

static NSString * const BKDiscoverPeripheralsKey = @"BKDiscoverPeripheralsKey";
static NSString * const BKConnectPeripheralKey = @"BKConnectPeripheralKey";
static NSString * const BKDiscoverServicesKey = @"BKDiscoverServicesKey";
static NSString * const BKDiscoverCharacteristicsKey = @"BKDiscoverCharacteristicsKey";
static NSString * const BKReadValueForCharacteristicKey = @"BKReadValueForCharacteristicKey";

+ (BKCBCentralManager *)manager {
    return [[BKCBCentralManager alloc] initWithConfiguration:nil];
}

- (instancetype)initWithConfiguration:(nullable BKConfiguration *)configuration {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if (!configuration) {
        configuration = [BKConfiguration defaultConfiguration];
    }
    
    self.multiPendingPromises = [NSMutableDictionary dictionary];
    
    self.connectedPeripherals = [NSMutableDictionary dictionary];
    
    self.configuration = configuration;
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:configuration.options];
    
    return self;
}

- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
    [self.centralManager cancelPeripheralConnection:peripheral];
}

- (void)stopScan {
    NSLog(@"停止搜索!!!");
    [self.centralManager stopScan];
}

- (FBLPromise<BKDiscovery *> *)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs {
    NSLog(@"开始搜索...");
    FBLPromise<id> *promise = [FBLPromise pendingPromise];
    if (self.multiPendingPromises[BKDiscoverPeripheralsKey]) {
        NSError *error = [NSError errorWithDomain:@"com.bk.bluetooth" code:400 userInfo:@{NSLocalizedDescriptionKey: @"scan for peripherals cancelled !!!"}];
        [self.multiPendingPromises[BKDiscoverPeripheralsKey] reject:error];
    }
    self.multiPendingPromises[BKDiscoverPeripheralsKey] = promise;
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey: @YES};
    [self.centralManager scanForPeripheralsWithServices:serviceUUIDs options:options];
    return promise;
}

- (FBLPromise<CBPeripheral *> *)connectPeripheral:(CBPeripheral *)peripheral {
    FBLPromise<id> *promise = [FBLPromise pendingPromise];
    self.multiPendingPromises[BKConnectPeripheralKey] = promise;
    NSDictionary *options = @{ CBConnectPeripheralOptionNotifyOnConnectionKey: @YES,
                              CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES };
    [self.centralManager connectPeripheral:peripheral options:options];
    return promise;
}

- (FBLPromise<NSArray<CBService *> *> *)discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs {
    NSLog(@"开始搜索服务集合...");
    FBLPromise<id> *promise = [FBLPromise pendingPromise];
    self.multiPendingPromises[BKDiscoverServicesKey] = promise;
    CBPeripheral *peripheral = [[self.centralManager retrieveConnectedPeripheralsWithServices:serviceUUIDs] firstObject];
    [peripheral discoverServices:serviceUUIDs];
    return promise;
}

- (FBLPromise<NSArray<CBCharacteristic *> *> *)discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service {
    NSLog(@"开始搜索服务的特征集合...");
    FBLPromise<id> *promise = [FBLPromise pendingPromise];
    self.multiPendingPromises[BKDiscoverCharacteristicsKey] = promise;
    CBPeripheral *peripheral = [[self.centralManager retrieveConnectedPeripheralsWithServices:@[service.UUID]] firstObject];
    [peripheral discoverCharacteristics:characteristicUUIDs forService:service];
    return promise;
}

- (FBLPromise<NSData *> *)readValueForCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"读取特征中的值...");
    FBLPromise<id> *promise = [FBLPromise pendingPromise];
    self.multiPendingPromises[BKReadValueForCharacteristicKey] = promise;
    CBPeripheral *peripheral = [[self.centralManager retrieveConnectedPeripheralsWithServices:@[characteristic.service.UUID]] firstObject];
    [peripheral readValueForCharacteristic:characteristic];
    return promise;
}

#pragma mark - CBCentralManager & CBPeripheral Delegates

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
    NSLog(@"扫描到外设");
    if (_multiPendingPromises[BKDiscoverPeripheralsKey]) {
        FBLPromise<NSArray *> *promise = _multiPendingPromises[BKDiscoverPeripheralsKey];
        BKDiscovery *discovery = [[BKDiscovery alloc] initWithAdvertisementData:advertisementData pheripheral:peripheral RSSI:RSSI];
        [promise fulfill:discovery];
        _multiPendingPromises[BKDiscoverPeripheralsKey] = nil;
    }
}

// 连接到外设
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"连接到外设");
    self.connectedPeripheral = peripheral;
    self.connectedPeripherals[peripheral.identifier] = peripheral;
    peripheral.delegate = self;
    if (_multiPendingPromises[BKConnectPeripheralKey]) {
        FBLPromise<NSArray *> *promise = _multiPendingPromises[BKConnectPeripheralKey];
        [promise fulfill:peripheral];
        _multiPendingPromises[BKConnectPeripheralKey] = nil;
    }
    [peripheral discoverServices:nil];
}

// 连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    if (_multiPendingPromises[BKConnectPeripheralKey]) {
        FBLPromise<NSArray *> *promise = _multiPendingPromises[BKConnectPeripheralKey];
        [promise reject:error];
        _multiPendingPromises[BKConnectPeripheralKey] = nil;
    }
}

// 断开与外设的连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"断开与外设的连接 error: %@", error);
    [self.connectedPeripherals removeObjectForKey:peripheral.identifier];
}

// 扫描到服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"扫描到服务 error: %@", error);
    if (_multiPendingPromises[BKDiscoverServicesKey]) {
        FBLPromise<NSArray *> *promise = _multiPendingPromises[BKDiscoverServicesKey];
        if (error) {
            [promise reject:error];
        } else {
            [promise fulfill:peripheral.services];
        }
        _multiPendingPromises[BKDiscoverServicesKey] = nil;
    }
}

// 扫描到特征值
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error {
    NSLog(@"扫描到特征值 error: %@", error);
    if (_multiPendingPromises[BKDiscoverCharacteristicsKey]) {
        FBLPromise<NSArray *> *promise = _multiPendingPromises[BKDiscoverCharacteristicsKey];
        if (error) {
            [promise reject:error];
        } else {
            [promise fulfill:service.characteristics];
        }
        _multiPendingPromises[BKDiscoverCharacteristicsKey] = nil;
    }
}

// 读取特征中的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"读取特征中的值: %@", characteristic.value);
    if (_multiPendingPromises[BKReadValueForCharacteristicKey]) {
        FBLPromise<NSArray *> *promise = _multiPendingPromises[BKReadValueForCharacteristicKey];
        if (error) {
            [promise reject:error];
        } else {
            [promise fulfill:characteristic.value];
        }
        _multiPendingPromises[BKReadValueForCharacteristicKey] = nil;
    }
}

@end
