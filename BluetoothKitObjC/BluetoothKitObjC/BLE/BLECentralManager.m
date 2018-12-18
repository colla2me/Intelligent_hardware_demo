//
//  BLECentralManager.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/11/10.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BLECentralManager.h"
#import "CBPeripheral+BLE.h"

static NSString * const kBLECentralRestoreIdentifier = @"kBLECentralRestoreIdentifier";
static const int MAX_BUF_LENGTH = 100;

// TODO:
// should have a configurable list of services
static CBUUID *heartRateSerivceUUID;
static CBUUID *serialServiceUUID;
static CBUUID *readCharacteristicUUID;
static CBUUID *writeCharacteristicUUID;

@implementation BLECentralManager {
    CBCentralManager *_centralManager;
    BOOL _isConnected, _done;
    int _rssi;
}

+ (instancetype)manager {
    return [[BLECentralManager alloc] init];
}

- (instancetype)init {
    return [self initWithOptions:@{CBCentralManagerOptionRestoreIdentifierKey: kBLECentralRestoreIdentifier} queue:nil];
}

- (instancetype)initWithOptions:(nullable NSDictionary<NSString *, id> *)options queue:(nullable dispatch_queue_t)queue {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _rssi = 0;
    _done = NO;
    _isConnected = NO;
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:options];
    return self;
}

- (void)readRSSI {
    [_activePeripheral readRSSI];
}

- (BOOL)isConnected
{
    return _isConnected;
}

- (void)read
{
    if (!_activePeripheral) {
        BLELog(@"Could not read if not active peripheral");
        return;
    }
    //    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    //    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_TX_UUID];
    //    [self readValue:uuid_service characteristicUUID:uuid_char p:activePeripheral];
    [self readValue:serialServiceUUID characteristicUUID:readCharacteristicUUID peripheral:_activePeripheral];
}

- (void)readForCharacteristic:(CBUUID *)characteristicUUID service:(CBUUID *)serviceUUID {
    if (!_activePeripheral) {
        BLELog(@"Could not read if not active peripheral");
        return;
    }

    [self readValue:serviceUUID characteristicUUID:characteristicUUID peripheral:_activePeripheral];
}

- (void)write:(NSData *)data
{
    if (!data || !_activePeripheral) {
        BLELog(@"Could not write if data is null or not active peripheral");
        return;
    }
    BLELog(@"write data in BLE");
    NSInteger data_len = data.length;
    NSData *buffer;
    for (int i = 0; i < data_len; i += MAX_BUF_LENGTH) {
        NSInteger remainLength = data_len - i;
        NSInteger bufLen = (remainLength > MAX_BUF_LENGTH) ? MAX_BUF_LENGTH : remainLength;
        buffer = [data subdataWithRange:NSMakeRange(i, bufLen)];
        
        BLELog(@"Buffer data %ld %i %@", (long)remainLength, i, [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]);
        
        [self writeValue:serialServiceUUID characteristicUUID:writeCharacteristicUUID peripheral:_activePeripheral data:buffer];
    }
}

- (void)enableReadNotification:(CBPeripheral *)peripheral
{
    //    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    //    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_TX_UUID];
    //    [self notification:uuid_service characteristicUUID:uuid_char p:p on:YES];
    [self notification:serialServiceUUID characteristicUUID:readCharacteristicUUID peripheral:peripheral on:YES];
}

- (void)notification:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID peripheral:(CBPeripheral *)peripheral on:(BOOL)on
{
    CBService *service = [self findServiceFromUUID:serviceUUID peripheral:peripheral];
    
    if (!service)
    {
        BLELog(@"Could not find service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:serviceUUID],
              peripheral.identifier.UUIDString);
        
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    
    if (!characteristic)
    {
        BLELog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristicUUID],
              [self CBUUIDToString:serviceUUID],
              peripheral.identifier.UUIDString);
        
        return;
    }
    
    [peripheral setNotifyValue:on forCharacteristic:characteristic];
}

- (NSString *)CBUUIDToString:(CBUUID *)cbuuid;
{
    NSData *data = cbuuid.data;
    
    if ([data length] == 2)
    {
        const unsigned char *tokenBytes = [data bytes];
        return [NSString stringWithFormat:@"%02x%02x", tokenBytes[0], tokenBytes[1]];
    }
    else if ([data length] == 16)
    {
        NSUUID* nsuuid = [[NSUUID alloc] initWithUUIDBytes:[data bytes]];
        return [nsuuid UUIDString];
    }
    
    return [cbuuid description];
}

- (void)readValue:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID peripheral:(CBPeripheral *)peripheral
{
    CBService *service = [self findServiceFromUUID:serviceUUID peripheral:peripheral];
    
    if (!service)
    {
        BLELog(@"Could not find service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:serviceUUID],
              peripheral.identifier.UUIDString);
        
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    
    if (!characteristic)
    {
        BLELog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristicUUID],
              [self CBUUIDToString:serviceUUID],
              peripheral.identifier.UUIDString);
        
        return;
    }
    
    [peripheral readValueForCharacteristic:characteristic];
}

- (void)writeValue:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID peripheral:(CBPeripheral *)peripheral data:(NSData *)data
{
    CBService *service = [self findServiceFromUUID:serviceUUID peripheral:peripheral];
    
    if (!service)
    {
        BLELog(@"Could not find service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:serviceUUID],
              peripheral.identifier.UUIDString);
        
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    
    if (!characteristic)
    {
        BLELog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristicUUID],
              [self CBUUIDToString:serviceUUID],
              peripheral.identifier.UUIDString);
        
        return;
    }
    
    BLELog(@"Write Buffer data length %lu", data.length);
    if ((characteristic.properties & CBCharacteristicPropertyWrite) == CBCharacteristicPropertyWrite) {
        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
    else if ((characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) == CBCharacteristicPropertyWriteWithoutResponse) {
        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    }
}

- (UInt16)swap:(UInt16)s
{
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

- (int)findBLEPeripherals:(NSTimeInterval)timeout
{
    if (_centralManager.state != CBCentralManagerStatePoweredOn)
    {
        BLELog(@"CoreBluetooth not correctly initialized !");
        BLELog(@"State = %ld (%s)\r\n", (long)_centralManager.state, [self centralManagerStateToString:_centralManager.state]);
        return -1;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    
    // TODO:
    heartRateSerivceUUID = [CBUUID UUIDWithString:@"180D"];
    
    NSArray<CBUUID *> *services = @[heartRateSerivceUUID];
    [_centralManager scanForPeripheralsWithServices:services options:nil];

    BLELog(@"scanForPeripheralsWithServices");
    
    return 0; // Started scanning OK !
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    BLELog(@"Connecting to peripheral with UUID : %@", peripheral.identifier.UUIDString);
    
    _activePeripheral = peripheral;
    _activePeripheral.delegate = self;
    [_centralManager connectPeripheral:self.activePeripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES}];
}

- (void)cancelConnection {
    if (_centralManager.isScanning) {
        [_centralManager stopScan];
    }
    
    if (_activePeripheral) {
        if (CBPeripheralStateConnected == _activePeripheral.state) {
            [_centralManager cancelPeripheralConnection:_activePeripheral];
        }
    
        [self notification:serialServiceUUID
        characteristicUUID:readCharacteristicUUID
                peripheral:self.activePeripheral
                        on:NO];
    }
}

- (const char *)centralManagerStateToString:(int)state
{
    switch(state) {
        case CBCentralManagerStateUnknown:
            return "State unknown (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateResetting:
            return "State resetting (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateUnsupported:
            return "State BLE unsupported (CBCentralManagerStateResetting)";
        case CBCentralManagerStateUnauthorized:
            return "State unauthorized (CBCentralManagerStateUnauthorized)";
        case CBCentralManagerStatePoweredOff:
            return "State BLE powered off (CBCentralManagerStatePoweredOff)";
        case CBCentralManagerStatePoweredOn:
            return "State powered up and ready (CBCentralManagerStatePoweredOn)";
        default:
            return "State unknown";
    }
    
    return "Unknown state";
}

- (void)scanTimer:(NSTimer *)timer
{
    [_centralManager stopScan];
    BLELog(@"Stopped Scanning");
    BLELog(@"Known peripherals : %lu", [self.peripherals count]);
    [self printKnownPeripherals];
}

- (void)printKnownPeripherals
{
    BLELog(@"List of currently known peripherals :");
    
    for (int i = 0; i < self.peripherals.count; i++)
    {
        CBPeripheral *p = [self.peripherals objectAtIndex:i];
        
        if (p.identifier != NULL) {
            BLELog(@"%d  |  %@", i, p.identifier.UUIDString);
        } else {
            BLELog(@"%d  |  NULL", i);
        }
        
        [self printPeripheralInfo:p];
    }
}

- (void)printPeripheralInfo:(CBPeripheral*)peripheral
{
    BLELog(@"------------------------------------");
    BLELog(@"Peripheral Info :");
    
    if (peripheral.identifier != NULL) {
        BLELog(@"UUID : %@", peripheral.identifier.UUIDString);
    } else {
        BLELog(@"UUID : NULL");
    }
    
    BLELog(@"Name : %@", peripheral.name);
    BLELog(@"-------------------------------------");
}

- (BOOL)UUIDSAreEqual:(NSUUID *)UUID1 UUID2:(NSUUID *)UUID2
{
    return [UUID1.UUIDString isEqualToString:UUID2.UUIDString];
}

- (void)getAllServicesFromPeripheral:(CBPeripheral *)peripheral
{
    [peripheral discoverServices:nil]; // Discover all services without filter
}

- (void)getAllCharacteristicsFromPeripheral:(CBPeripheral *)peripheral
{
    for (int i = 0; i < peripheral.services.count; i++)
    {
        CBService *service = [peripheral.services objectAtIndex:i];
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (BOOL)compareCBUUID:(CBUUID *)UUID1 UUID2:(CBUUID *)UUID2
{
    char b1[16];
    char b2[16];
    NSUInteger data_len = UUID1.data.length;
    [UUID1.data getBytes:b1 length:data_len];
    [UUID2.data getBytes:b2 length:UUID2.data.length];
    
    if (memcmp(b1, b2, data_len) == 0)
        return YES;
    else
        return NO;
}

- (BOOL)compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2
{
    char b1[16];
    [UUID1.data getBytes:b1 length:UUID1.data.length];
    UInt16 b2 = [self swap:UUID2];
    
    if (memcmp(b1, (char *)&b2, 2) == 0)
        return YES;
    else
        return NO;
}

- (UInt16)CBUUIDToInt:(CBUUID *)UUID
{
    char b1[16];
    [UUID.data getBytes:b1 length:UUID.data.length];
    return ((b1[0] << 8) | b1[1]);
}

- (CBUUID *)IntToCBUUID:(UInt16)UUID
{
    char t[16];
    t[0] = ((UUID >> 8) & 0xff); t[1] = (UUID & 0xff);
    NSData *data = [[NSData alloc] initWithBytes:t length:16];
    return [CBUUID UUIDWithData:data];
}

- (CBService *)findServiceFromUUID:(CBUUID *)UUID peripheral:(CBPeripheral *)peripheral
{
    for(int i = 0; i < peripheral.services.count; i++)
    {
        CBService *s = [peripheral.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    
    return nil; //Service not found on this peripheral
}

- (CBCharacteristic *)findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service
{
    for(int i = 0; i < service.characteristics.count; i++)
    {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    
    return nil; //Characteristic not found on this service
}

#pragma mark - CBCentralManager Delegate

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    NSArray<CBPeripheral *> *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
    [peripherals enumerateObjectsUsingBlock:^(CBPeripheral *peripheral, NSUInteger idx, BOOL *stop) {
        if (peripheral.state == CBPeripheralStateDisconnected) {
            [self connectPeripheral:peripheral];
        }
    }];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    BLELog(@"Status of CoreBluetooth central manager changed %ld (%s)", (long)central.state, [self centralManagerStateToString:central.state]);
    BOOL isBluetoothEnabled = NO;
    if (central.state == CBCentralManagerStatePoweredOn) {
        isBluetoothEnabled = YES;
    }
    
    if (!isBluetoothEnabled && _isConnected) {
        _done = NO;
        _isConnected = NO;
        
        if ([_delegate respondsToSelector:@selector(bleDidDisconnect)]) {
            [_delegate bleDidDisconnect];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(bleDidChangeState:)]) {
        [_delegate bleDidChangeState:isBluetoothEnabled];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (!_peripherals) {
        _peripherals = [[NSMutableArray alloc] initWithObjects:peripheral, nil];
    }
    else {
        for(int i = 0; i < self.peripherals.count; i++)
        {
            CBPeripheral *p = [self.peripherals objectAtIndex:i];
            [p ble_setAdvertisementData:advertisementData RSSI:RSSI];
            
            if ((p.identifier == NULL) || (peripheral.identifier == NULL))
                continue;
            
            if ([self UUIDSAreEqual:p.identifier UUID2:peripheral.identifier])
            {
                [self.peripherals replaceObjectAtIndex:i withObject:peripheral];
                BLELog(@"Duplicate UUID found updating...");
                return;
            }
        }
        
        [self.peripherals addObject:peripheral];
        
        BLELog(@"New UUID, adding");
    }
    
    if ([_delegate respondsToSelector:@selector(bleDidDiscoverPeripheral:advertisementData:RSSI:)]) {
        [_delegate bleDidDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
    }
    BLELog(@"didDiscoverPeripheral");
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (peripheral.identifier != NULL) {
        BLELog(@"Connected to %@ successful", peripheral.identifier.UUIDString);
    } else {
        BLELog(@"Connected to NULL successful");
    }

    _activePeripheral = peripheral;
//    [self.activePeripheral discoverServices:nil];
    [self getAllServicesFromPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    _done = NO;
    
    if ([_delegate respondsToSelector:@selector(bleDidDisconnect)]) {
        [_delegate bleDidDisconnect];
    }
    
    _isConnected = NO;
}

#pragma mark - CBPeripheral Delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        BLELog(@"Service discovery was unsuccessful!");
        return;
    }
    
    // TODO:
    // Determine if we're connected to Red Bear Labs, Adafruit or Laird hardware
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:heartRateSerivceUUID]) {
            BLELog(@"Heart Rate Bluetooth");
            serialServiceUUID = heartRateSerivceUUID;
            readCharacteristicUUID = [CBUUID UUIDWithString:@HEART_RATE_MEASUREMENT];
            writeCharacteristicUUID = [CBUUID UUIDWithString:@TEST_CHAR_RX_UUID];
            break;
        } else {
            // ignore unknown services
        }
    }
    
    // TODO - future versions should just get characteristics we care about
    // [peripheral discoverCharacteristics:characteristics forService:service];
    [self getAllCharacteristicsFromPeripheral:peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        BLELog(@"Characteristic discorvery unsuccessful!");
        return;
    }
    
    BLELog(@"Characteristics of service with UUID : %@ found\n", [self CBUUIDToString:service.UUID]);
    
    for (int i = 0; i < service.characteristics.count; i++)
    {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        BLELog(@"Found characteristic %@\n", [ self CBUUIDToString:c.UUID]);
        CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
        
        if ([service.UUID isEqual:s.UUID])
        {
            if (!_done)
            {
                [self enableReadNotification:_activePeripheral];
                if ([_delegate respondsToSelector:@selector(bleDidConnect)]) {
                    [_delegate bleDidConnect];
                }
                
                _isConnected = YES;
                _done = YES;
            }
            
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        BLELog(@"Error in setting notification state for characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristic.UUID],
              [self CBUUIDToString:characteristic.service.UUID],
              peripheral.identifier.UUIDString);
        
        BLELog(@"Error code was %s", [[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
        return;
    }
    
    if (characteristic.isNotifying) {
        BLELog(@"Enabled Notification for Characteristic");
    } else {
        BLELog(@"Closed Notification for Characteristic");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        BLELog(@"Error in updating value for characteristic with %@, error %@ and code was: %s", [self CBUUIDToString:characteristic.UUID], error.localizedDescription, [[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
        return;
    }
    
    static unsigned char buf[512];
    if ([characteristic.UUID isEqual:readCharacteristicUUID])
    {
        NSUInteger data_len = characteristic.value.length;
        [characteristic.value getBytes:buf length:data_len];
        if ([_delegate respondsToSelector:@selector(bleDidReceiveData:length:)]) {
            [_delegate bleDidReceiveData:buf length:data_len];
        }
        
        // Get the Heart Rate Monitor BPM
        [self getHeartBPMData:characteristic error:error];
    }
}

- (void)getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error {
    // Get the Heart Rate Monitor BPM
    NSData *data = [characteristic value];      // 1
    const uint8_t *reportData = [data bytes];
    uint16_t bpm = 0;
    
    if ((reportData[0] & 0x01) == 0) {          // 2
        // Retrieve the BPM value for the Heart Rate Monitor
        bpm = reportData[1];
    }
    else {
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));  // 3
    }
    // Display the heart rate value to the UI if no error occurred
    if( (characteristic.value)  || !error ) {   // 4
        
        NSString *heartBeatString = [NSString stringWithFormat:@"%i bpm", bpm];
        BLELog(@"heartBeat: %@", heartBeatString);
    }
    return;
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        BLELog(@"Error in writing value for characteristic with %@, error %@ and code was: %s", [self CBUUIDToString:characteristic.UUID], error.localizedDescription, [[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    } else {
        BLELog(@"Write value for characteristic with UUID %@ Successfully!", characteristic.UUID.UUIDString);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (!_isConnected) return;
    
    if (_rssi != RSSI.intValue) {
        _rssi = RSSI.intValue;
        if ([_delegate respondsToSelector:@selector(bleDidReadRSSI:)]) {
            [_delegate bleDidReadRSSI:RSSI];
        }
    }
}

@end
