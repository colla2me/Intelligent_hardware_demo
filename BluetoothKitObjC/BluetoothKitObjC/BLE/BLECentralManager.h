//
//  BLECentralManager.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/12/10.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BLEDelegate <NSObject>
@optional
- (void)bleDidConnect;
- (void)bleDidDisconnect;
- (void)bleDidReadRSSI:(NSNumber *)rssi error:(NSError *)error;
- (void)bleDidReceiveData:(unsigned char *)data length:(int)length;

@end

@interface BLECentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, weak) id<BLEDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *activePeripheral;

//- (UInt16)swap:(UInt16)s;
//- (void)controlSetup;
//- (void)printKnownPeripherals;
//- (void)printPeripheralInfo:(CBPeripheral*)peripheral;

- (void)enableReadNotification:(CBPeripheral *)peripheral;
- (void)read;
- (void)writeValue:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID peripheral:(CBPeripheral *)peripheral data:(NSData *)data;

- (BOOL)isConnected;
- (void)write:(NSData *)data;
- (void)readRSSI;

- (int)findBLEPeripherals:(int)timeout;
- (void)connectPeripheral:(CBPeripheral *)peripheral;

- (const char *)centralManagerStateToString:(int)state;
- (void)scanTimer:(NSTimer *)timer;

- (void)getAllServicesFromPeripheral:(CBPeripheral *)peripheral;
- (void)getAllCharacteristicsFromPeripheral:(CBPeripheral *)peripheral;
- (CBService *)findServiceFromUUID:(CBUUID *)UUID peripheral:(CBPeripheral *)peripheral;
- (CBCharacteristic *)findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service;

- (NSString *)CBUUIDToString:(CBUUID *) UUID;

- (BOOL)compareCBUUID:(CBUUID *)UUID1 UUID2:(CBUUID *)UUID2;
- (BOOL)compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2;
- (UInt16)CBUUIDToInt:(CBUUID *)UUID;
- (BOOL)UUIDSAreEqual:(NSUUID *)UUID1 UUID2:(NSUUID *)UUID2;

@end

