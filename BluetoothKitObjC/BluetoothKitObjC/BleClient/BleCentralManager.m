//
//  BleCentralManager.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/7.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "BleCentralManager.h"

#define SERVICE_UUID        @"CDD1"
#define CHARACTERISTIC_UUID @"CDD2"

typedef void(^BLECentralScanForPeripheralsBlock)(NSArray<CBPeripheral *> *peripherals);
typedef void(^BLECentralDidDisoverPeripheralBlock)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);
typedef void(^BLECentralDidDiscoverServicesBlock)(CBPeripheral *peripheral, NSError *error);
typedef void(^BLECentralDidDiscoverCharacteristicsBlock)(CBPeripheral *peripheral, CBService *service, NSError *error);
typedef void(^BLEReadValueCompletion)(NSData *data, NSError *error);
typedef void(^BLEWriteValueCompletion)(NSError *error);

// static NSUInteger const BLECharacteristicPropertyAll = CBCharacteristicPropertyBroadcast | CBCharacteristicPropertyRead | CBCharacteristicPropertyWriteWithoutResponse | CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify | CBCharacteristicPropertyIndicate | CBCharacteristicPropertyAuthenticatedSignedWrites | CBCharacteristicPropertyExtendedProperties | CBCharacteristicPropertyNotifyEncryptionRequired | CBCharacteristicPropertyIndicateEncryptionRequired;

@interface BleCentralManager () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
//@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) NSMutableSet<CBPeripheral *> *discoveredPeripherals;
@property (nonatomic, strong) NSMutableSet<CBService *> *discoveredServices;
@property (nonatomic, strong) NSMutableSet<CBCharacteristic *> *discoveredCharacteristics;

@property (nonatomic, copy) BLECentralScanForPeripheralsBlock centralScanForPeripherals;
@property (nonatomic, copy) BLECentralDidDisoverPeripheralBlock centralDidDisoverPeripheral;
@property (nonatomic, copy) BLECentralDidDiscoverServicesBlock centralDidDiscoverServices;
@property (nonatomic, copy) BLECentralDidDiscoverCharacteristicsBlock centralDidDiscoverCharacteristics;
@property (nonatomic, copy) BLEReadValueCompletion readValueCompletion;
@property (nonatomic, copy) BLEWriteValueCompletion writeValueCompletion;
@property (nonatomic, strong) NSSortDescriptor *sortRSSIDescriptor;

@end

@implementation BleCentralManager

+ (instancetype)manager {
    return [[BleCentralManager alloc] init];
}

- (instancetype)init {
    return [self initWithOptions:nil];
}

- (instancetype)initWithOptions:(nullable NSDictionary<NSString *, id> *)options {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.managerOptions = options;
    self.discoveredPeripherals = [NSMutableSet set];
    self.discoveredServices = [NSMutableSet set];
    self.discoveredCharacteristics = [NSMutableSet set];
    self.queue = dispatch_queue_create("com.30days-tech.ble.central", DISPATCH_QUEUE_SERIAL);
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:_queue options:options];
    return self;
}

- (NSSortDescriptor *)sortRSSIDescriptor {
    if (!_sortRSSIDescriptor) {
        _sortRSSIDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"RSSI" ascending:NO];
    }
    return _sortRSSIDescriptor;
}

- (void)cleanup {
    self.peripheral = nil;
    [self.discoveredServices removeAllObjects];
    [self.discoveredPeripherals removeAllObjects];
    [self.discoveredCharacteristics removeAllObjects];
}

- (void)cancel {
    if (self.centralManager.isScanning) {
        [self.centralManager stopScan];
    }
    
    if (CBPeripheralStateConnected == self.peripheral.state) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
    
    for (CBCharacteristic *characteristic in self.discoveredCharacteristics) {
        if (!characteristic.isNotifying) continue;
        [self.peripheral setNotifyValue:NO forCharacteristic:characteristic];
    }
    
    [self cleanup];
}

- (BleManagerState)state {
    return (BleManagerState)self.centralManager.state;
}

- (BOOL)isScanning {
    return self.centralManager.isScanning;
}

- (void)scanForPeripheralsWithOptions:(NSDictionary<NSString *,id> *)options handler:(void (^ _Nullable)(NSArray<CBPeripheral *> * _Nonnull))handler {
    [self scanForPeripheralsWithServices:nil options:options handler:handler];
}

- (void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options handler:(void(^ _Nullable)(NSArray<CBPeripheral *> *peripherals))handler {
    self.centralScanForPeripherals = handler;
    
    if (self.isScanning) return;
    
    if (BleManagerStatePoweredOn == self.state) {
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:options];
    }
}

- (void)setCentralDidDiscoverPeripheralBlock:(void(^)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI))block {
    self.centralDidDisoverPeripheral = block;
}

- (void)setCentralDidDiscoverServicesBlock:(void (^)(CBPeripheral *peripheral, NSError *error))block {
    self.centralDidDiscoverServices = block;
}

- (void)setCentralDidDiscoverCharacteristicsBlock:(void (^)(CBPeripheral *peripheral, CBService *service, NSError *error))block {
    self.centralDidDiscoverCharacteristics = block;
}

- (void)setReadValueCompletionHandler:(void(^)(NSData *data, NSError *error))block {
    self.readValueCompletion = block;
}

- (void)connectPeripheral:(CBPeripheral *)peripheral options:(nullable NSDictionary<NSString *,id> *)options {
    if (!peripheral || 0 == self.discoveredPeripherals.count) return;
    
    self.connectionOptions = options;
    
    // 断开之前的设备
    if (self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
    
    self.peripheral = peripheral;
    
    // 连接到新的设备
    [self.centralManager connectPeripheral:peripheral options:options];
}

- (void)readValueForCharacteristic:(CBUUID *)UUID completion:(void(^)(NSData *data, NSError *error))completion {
    CBCharacteristic *characteristic = [self findCharacteristicByUUID:UUID];
    if (!characteristic) return; // TODO: throw error
    if (CBCharacteristicPropertyRead & characteristic.properties) {
        self.readValueCompletion = completion;
        [self.peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)writeValue:(NSData *)data forCharacteristic:(CBUUID *)UUID type:(CBCharacteristicWriteType)type completion:(void (^)(NSError *))completion {
    CBCharacteristic *characteristic = [self findCharacteristicByUUID:UUID];
    if (!characteristic) return; // TODO: throw error
    if ((CBCharacteristicPropertyWrite & characteristic.properties) || (CBCharacteristicPropertyWriteWithoutResponse & characteristic.properties)) {
        self.writeValueCompletion = completion;
        [self.peripheral writeValue:data forCharacteristic:characteristic type:type];
    }
}

- (CBCharacteristic *)findCharacteristicByUUID:(CBUUID *)UUID {
    CBCharacteristic *discoveredCharacteristic = nil;
    if (!UUID || 0 == self.discoveredCharacteristics.count) {
        return discoveredCharacteristic;
    }
    
    for (CBCharacteristic *characteristic in self.discoveredCharacteristics) {
        if ([UUID isEqual:characteristic.UUID]) {
            discoveredCharacteristic = characteristic;
            break;
        }
    }
    return discoveredCharacteristic;
}

#pragma mark -
#pragma mark - CBCentralManagerDelegate

/** 判断手机蓝牙状态 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    BleManagerState state = (BleManagerState)central.state;
    switch (state) {
        case BleManagerStatePoweredOn:
            NSLog(@"蓝牙已打开");
            [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:nil];
            break;
        case BleManagerStatePoweredOff:
            NSLog(@"蓝牙已关闭");
            break;
        case BleManagerStateResetting:
            NSLog(@"蓝牙正在重置");
            break;
        case BleManagerStateUnsupported:
            NSLog(@"该设备不支持蓝牙");
            break;
        case BleManagerStateUnauthorized:
            NSLog(@"蓝牙未授权");
            break;
        default:
            NSLog(@"蓝牙未知");
            break;
    }
}

/** 发现符合要求的外设，回调 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    // 记录发现的外设
    [self.discoveredPeripherals addObject:peripheral];
    
    if (self.centralScanForPeripherals) {
        NSArray *array = [self.discoveredServices sortedArrayUsingDescriptors:@[self.sortRSSIDescriptor]];
        self.centralScanForPeripherals(array);
    }
    
    // 可以根据外设名字来过滤外设
    if (self.peripheralName && peripheral.name && [peripheral.name hasPrefix:self.peripheralName]) {
        [central connectPeripheral:peripheral options:nil];
    }
    
    // 连接外设
//    [central connectPeripheral:peripheral options:nil];
    
    if (self.centralDidDisoverPeripheral) {
        self.centralDidDisoverPeripheral(peripheral, advertisementData, RSSI);
    }
}

/** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // 对外设对象进行强引用
    self.peripheral = peripheral;
    // 可以停止扫描
    [self.centralManager stopScan];
    // 设置代理
    peripheral.delegate = self;
    // 根据UUID来寻找服务
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
    NSLog(@"连接成功");
}

/** 连接失败的回调 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接失败");
}

/** 断开连接 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"断开连接");
    // 断开连接可以设置重新连接
    [central connectPeripheral:peripheral options:nil];
}

#pragma mark -
#pragma mark - CBPeripheralDelegate

/** 发现服务 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (self.centralDidDiscoverServices) {
        self.centralDidDiscoverServices(peripheral, error);
    }
    
    if (error) {
        NSLog(@"发现服务失败");
        NSLog(@"%@",error);
        return;
    }
    
    NSArray<CBService *> *services = peripheral.services;
    
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:CHARACTERISTIC_UUID];
    
    // 遍历出外设中所有的服务
    for (CBService *service in services) {
        NSLog(@"所有的服务：%@",service);
        // 根据UUID寻找服务中的特征
        [peripheral discoverCharacteristics:@[characteristicUUID] forService:service];
    }
    
    // 记录发现的所有服务
    [self.discoveredServices addObjectsFromArray:services];
}

/** 发现特征回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (self.centralDidDiscoverCharacteristics) {
        self.centralDidDiscoverCharacteristics(peripheral, service, error);
    }
    
    if (error) {
        NSLog(@"发现特征失败");
        NSLog(@"%@",error);
        return;
    }
    
    NSArray<CBCharacteristic *> *characteristics = service.characteristics;
    
    // 遍历出所需要的特征
    for (CBCharacteristic *characteristic in characteristics) {
        
        NSLog(@"所有特征：%@", characteristic);
        // 从外设开发人员那里拿到不同特征的UUID，不同特征做不同事情，比如有读取数据的特征，也有写入数据的特征
        // TODO:
        
        // 直接读取这个特征数据，会调用didUpdateValueForCharacteristic
        if (characteristic.properties & CBCharacteristicPropertyRead) {
            [peripheral readValueForCharacteristic:characteristic];
        }
        
        // 订阅通知
        if (characteristic.properties & CBCharacteristicPropertyNotify) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    // 记录发现的所有特征
    [self.discoveredCharacteristics addObjectsFromArray:characteristics];
}

/** 订阅状态的改变 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"订阅失败");
        NSLog(@"%@",error);
        return;
    }
    
    if (characteristic.isNotifying) {
        NSLog(@"订阅成功");
    } else {
        NSLog(@"取消订阅");
    }
}

/** 接收到数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"更新特征值失败");
        NSLog(@"%@",error);
    }
    
    NSString *logValue = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"拿到外设发送过来的数据: %@", logValue);
    
    // 拿到外设发送过来的数据的回调
    if (self.readValueCompletion) {
        self.readValueCompletion(characteristic.value, error);
    }
}

/** 写入数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        NSLog(@"写入特征值失败");
        NSLog(@"%@",error);
    }
    
    NSLog(@"写入成功");
    // 成功写入外设的回调
    if (self.writeValueCompletion) {
        self.writeValueCompletion(error);
    }
}

/** 发现描述回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"特征的所有描述 %@", characteristic.descriptors);
}

@end
