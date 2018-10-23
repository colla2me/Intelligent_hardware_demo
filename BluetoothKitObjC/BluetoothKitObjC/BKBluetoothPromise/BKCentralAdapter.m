//
//  BKCentralAdapter.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/10/23.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "BKCentralAdapter.h"

@implementation BKCentralAdapter

- (void)setCentralManager:(CBCentralManager *)centralManager {
    if (_centralManager != centralManager || centralManager.delegate != self) {
        _centralManager = centralManager;
        _centralManager.delegate = self;
    }
}

// 当前蓝牙主设备状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

// 扫描到外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
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
