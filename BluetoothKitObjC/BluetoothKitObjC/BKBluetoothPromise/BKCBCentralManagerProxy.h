//
//  BKCBCentralManagerProxy.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/17.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//@protocol BKCBCentralManagerStateDelegate <NSObject>
//
//- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
//
//@end
//
//@protocol BKCBCentralManagerDiscoveryDelegate <NSObject>
//
//- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI;
//
//@end
//
//@protocol BKCBCentralManagerConnectionDelegate <NSObject>
//
//- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
//
//- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
//
//- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
//
//@end

@interface BKCBCentralManagerProxy : NSProxy

- (instancetype)initWithCentralManagerDelegate:(id<CBCentralManagerDelegate>)centralManagerDelegate;

@end
