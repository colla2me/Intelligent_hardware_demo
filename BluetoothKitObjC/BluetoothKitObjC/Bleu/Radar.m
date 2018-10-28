//
//  Radar.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/28.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "Radar.h"

@interface Radar () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) RadarRequest *request;
@property (nonatomic, assign) BOOL isNeedCheckScanCompleted;
@end

@implementation Radar

- (instancetype)initWithRequest:(RadarRequest *)request options:(RadarOptions *)options {
    self = [super init];
    if (!self) return nil;

    NSMutableDictionary *scanOptions = [NSMutableDictionary dictionary];
    scanOptions[CBCentralManagerScanOptionAllowDuplicatesKey] = @(options.allowDuplicatesKey);
    
    self.scanOptions = scanOptions;
    self.radarOptions = options;
    self.request = request;
    self.queue = dispatch_queue_create("com.bleu.radar", DISPATCH_QUEUE_SERIAL);
    
    self.serviceUUIDs = @[request.serviceUUID];
    self.characteristics = @[request.characteristic];
    self.connectedPeripherals = [NSMutableSet set];
    self.discoveredPeripherals = [NSMutableSet set];
//    self.completedRequests = [NSMutableDictionary dictionary];
    self.isNeedCheckScanCompleted = NO;
    
    NSMutableDictionary *centralOptions = [NSMutableDictionary dictionary];
    centralOptions[CBCentralManagerOptionRestoreIdentifierKey] = options.restoreIdentifierKey;
    centralOptions[CBCentralManagerOptionShowPowerAlertKey] = @(options.showPowerAlertKey);
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:centralOptions];
    
    return self;
}

- (BOOL)isScanning {
    return self.centralManager.isScanning;
}

// TODO:
- (BOOL)isNotifying {
    return NO;
}

- (void)resume {
    if (_state == CBCentralManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:self.scanOptions];
        NSLog(@"[Bleu Radar] start scan.");
    } else {
        __weak typeof(self) weakSelf = self;
        self.startScanBlock = ^(NSDictionary *scanOptions) {
            if (!weakSelf.isScanning) {
                [weakSelf.centralManager scanForPeripheralsWithServices:nil options:scanOptions];
                NSLog(@"[Bleu Radar] start scan.");
            }
        };
    }
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.radarOptions.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (!self.centralManager.isScanning) {
//            return;
//        }
//
//        if (self.isNotifying && self.connectedPeripherals.count > 0) {
//            return;
//        }
//
//        [self stopScan:YES];
//        NSError *error = [NSError errorWithDomain:@"com.bleu.resume" code:timeout userInfo:nil];
//        if (self.completionHandler) self.completionHandler(@{}, error);
//    });
}

- (void)cancel {
    NSLog(@"[Bleu Radar] Cancel");
    [self stopScan:YES];
    NSError *error = [NSError errorWithDomain:@"com.bleu.cancel" code:canceled userInfo:nil];
    if (self.completionHandler) self.completionHandler(@{}, error);
}

- (void)stopScan:(BOOL)cleaned {
    NSLog(@"[Bleu Radar] Stop scan.");
    [self.centralManager stopScan];
    if (cleaned) {
        [self cleanup];
    }
}

- (void)cleanup {
    NSLog(@"[Bleu Radar] Clean");
    [self.discoveredPeripherals removeAllObjects];
    [self.connectedPeripherals removeAllObjects];
}

- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
    [self.centralManager cancelPeripheralConnection:peripheral];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"蓝牙已开启");
            if (_startScanBlock) self.startScanBlock(self.scanOptions);
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"蓝牙未打开");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"蓝牙正在重置");
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

//- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)state {
//    NSArray<CBPeripheral *> *peripherals = state[CBCentralManagerRestoredStatePeripheralsKey];
//    for (CBPeripheral *peripheral in peripherals) {
//        [self.discoveredPeripherals addObject:peripheral];
//        if (peripheral.state == CBPeripheralStateConnected) {
//            [self.connectedPeripherals addObject:peripheral];
//        }
//    }
//    NSLog(@"central will Restore State: %@", state);
//}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"[Bleu Radar] discover peripheral: %@, RSSI: %@", peripheral, RSSI);
    [self.discoveredPeripherals addObject:peripheral];
    NSDictionary *options = @{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES, CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES};
    if (_radarOptions.allowDuplicatesKey) {
        if (_radarOptions.thresholdRSSI < RSSI.integerValue) {
            [self.centralManager connectPeripheral:peripheral options:options];
            [self stopScan:NO];
        }
    } else {
        [self.centralManager connectPeripheral:peripheral options:options];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"[Bleu Radar] did connect peripheral: %@", peripheral);
    peripheral.delegate = self;
    [peripheral discoverServices:self.serviceUUIDs];
    [self.connectedPeripherals addObject:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"[Bleu Radar] fail to connect peripheral: %@, error: %@", peripheral, error);
    [self.connectedPeripherals removeObject:peripheral];
}

#pragma mark -

- (void)get:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic {
    if ([self.request.characteristicUUID isEqual:characteristic.UUID]) {
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)post:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic {
    if ([self.request.characteristicUUID isEqual:characteristic.UUID]) {
        NSData *data = self.request.value;
        if (!data) return;
        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (void)notify:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic {
    if ([self.request.characteristicUUID isEqual:characteristic.UUID]) {
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}

- (void)receiveResponse:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([self.request.characteristicUUID isEqual:characteristic.UUID]) {
        if (self.request.response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.request.response(peripheral, characteristic, error);
            });
        }
        
//        if (self.completedRequests[peripheral.identifier]) {
//            NSMutableSet<RadarRequest *> *requests = self.completedRequests[peripheral.identifier].mutableCopy;
//            [requests addObject:self.request];
//        } else {
//            self.completedRequests[peripheral.identifier] = [NSSet setWithObject:self.request];
//        }
    }
    [self checkRequestCompletedForPeripheral:peripheral];
}

- (void)checkRequestCompletedForPeripheral:(CBPeripheral *)peripheral {
//    NSSet *requests = self.completedRequests[peripheral.identifier];
//    if (requests.count == self.completedRequests.count) {
        NSLog(@"[Bleu Radar] Check request completed for peripheral: %@", peripheral);
        if (!self.isNotifying) {
            [self.centralManager cancelPeripheralConnection:peripheral];
            [self setNeedsCheckScanCompleted];
        }
//    }
}

- (void)setNeedsCheckScanCompleted {
    self.isNeedCheckScanCompleted = YES;
}

- (void)checkScanCompletedIfnNeeded {
    if (self.isNeedCheckScanCompleted) {
        [self checkScanCompleted];
        self.isNeedCheckScanCompleted = NO;
    }
}

- (void)checkScanCompleted {
    if (self.connectedPeripherals.count == 0) {
        [self stopScan:YES];
        [self completion];
    }
}

- (void)completion {
    NSLog(@"[Bleu Radar] Completed");
    self.completionHandler(@{}, nil);
}

#pragma mark - Serivce

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    NSArray<CBService *> *serives = peripheral.services;
    NSLog(@"[Bleu Radar] did discover service %@ peripheral %@ error %@", serives, peripheral, error);
    NSArray<CBUUID *> *characteristicUUIDs = @[self.request.characteristicUUID];
    for (CBService *service in serives) {
        [peripheral discoverCharacteristics:characteristicUUIDs forService:service];
    }
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    NSLog(@"[Bleu Radar] update name %@", peripheral);
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(nonnull NSArray<CBService *> *)invalidatedServices {
    NSLog(@"[Bleu Radar] didModifyServices %@, %@", peripheral, invalidatedServices);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(nonnull CBService *)service error:(nullable NSError *)error {
    NSLog(@"[Bleu Radar] did discover included services for %@, %@", peripheral, service);
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(nonnull NSNumber *)RSSI error:(nullable NSError *)error {
    NSLog(@"[Bleu Radar] did read RSSI %@", RSSI);
}

#pragma mark - Characteristic

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error {
    if (error) {
        NSLog(@"[Bleu Radar] did discover characteristics for service error: %@", peripheral);
        return;
    }
    NSLog(@"[Bleu Radar] did discover characteristics for service %@", peripheral);
    CBCharacteristicProperties properties = CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify;
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:self.request.characteristicUUID]) {
            if (properties & CBCharacteristicPropertyNotify) {
                NSLog(@"[Bleu Radar] characteristic properties notify");
                [self notify:peripheral characteristic:characteristic];
            }
            if (properties & CBCharacteristicPropertyRead) {
                NSLog(@"[Bleu Radar] characteristic properties read");
                [self get:peripheral characteristic:characteristic];
            }
            if (properties & CBCharacteristicPropertyWrite) {
                NSLog(@"[Bleu Radar] characteristic properties write");
                [self post:peripheral characteristic:characteristic];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"[Bleu Radar] did update value for characteristic %@ %@", peripheral, characteristic);
    [self receiveResponse:peripheral characteristic:characteristic error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"[Bleu Radar] did write value for characteristic %@ %@", peripheral, characteristic);
    [self receiveResponse:peripheral characteristic:characteristic error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"[Bleu Radar] did update notification state for characteristic %@ %@", peripheral, characteristic);
    [self receiveResponse:peripheral characteristic:characteristic error:error];
}

#pragma mark - Descriptor

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"[Bleu Radar] did discover descriptors for %@ %@", peripheral, characteristic);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(nonnull CBDescriptor *)descriptor error:(nullable NSError *)error {
    NSLog(@"[Bleu Radar] did update value for descriptor %@ %@", peripheral, descriptor);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(nonnull CBDescriptor *)descriptor error:(nullable NSError *)error {
    NSLog(@"[Bleu Radar] did write value for descriptor %@ %@", peripheral, descriptor);
}

@end
