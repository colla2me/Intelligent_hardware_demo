//
//  BLECentralManager.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/12/10.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BLECentralManager.h"
#import "CBPeripheral+BLE.h"

static NSString * const kBLECentralRestoreIdentifier = @"kBLECentralRestoreIdentifier";

@interface BLECentralManager ()

@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *activePeripheral;

@end

@implementation BLECentralManager

static bool isConnected = false;
static int rssi = 0;

static CBUUID *serialServiceUUID;
static CBUUID *readCharacteristicUUID;
static CBUUID *writeCharacteristicUUID;

+ (instancetype)manager {
    return [[BLECentralManager alloc] init];
}

- (instancetype)init {
    return [self initWithOptions:@{CBCentralManagerOptionRestoreIdentifierKey: kBLECentralRestoreIdentifier} queue:dispatch_get_main_queue()];
}

- (instancetype)initWithOptions:(nullable NSDictionary<NSString *, id> *)options queue:(nullable dispatch_queue_t)queue {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:options];
    return self;
}

- (void)readRSSI {
    [_activePeripheral readRSSI];
}

- (BOOL)isConnected
{
    return isConnected;
}

- (void)read
{
    //    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    //    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_TX_UUID];
    
    //    [self readValue:uuid_service characteristicUUID:uuid_char p:activePeripheral];
    [self readValue:serialServiceUUID characteristicUUID:readCharacteristicUUID peripheral:_activePeripheral];
    
}

- (void)write:(NSData *)data
{
    //    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    //    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_RX_UUID];
    //
    //    [self writeValue:uuid_service characteristicUUID:uuid_char p:activePeripheral data:d];
    [self writeValue:serialServiceUUID characteristicUUID:writeCharacteristicUUID peripheral:_activePeripheral data:data];
}

- (void)enableReadNotification:(CBPeripheral *)peripheral
{
    //    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    //    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_TX_UUID];
    //
    //    [self notification:uuid_service characteristicUUID:uuid_char p:p on:YES];
    [self notification:serialServiceUUID characteristicUUID:readCharacteristicUUID peripheral:peripheral on:YES];
    
}

- (void)notification:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID peripheral:(CBPeripheral *)peripheral on:(BOOL)on
{
    CBService *service = [self findServiceFromUUID:serviceUUID peripheral:peripheral];
    
    if (!service)
    {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:serviceUUID],
              peripheral.identifier.UUIDString);
        
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    
    if (!characteristic)
    {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristicUUID],
              [self CBUUIDToString:serviceUUID],
              peripheral.identifier.UUIDString);
        
        return;
    }
    
    [peripheral setNotifyValue:on forCharacteristic:characteristic];
}

//-(UInt16) frameworkVersion
//{
//    return RBL_BLE_FRAMEWORK_VER;
//}

- (NSString *)CBUUIDToString:(CBUUID *) cbuuid;
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

- (void)readValue: (CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID peripheral:(CBPeripheral *)peripheral
{
    CBService *service = [self findServiceFromUUID:serviceUUID peripheral:peripheral];
    
    if (!service)
    {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:serviceUUID],
              peripheral.identifier.UUIDString);
        
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    
    if (!characteristic)
    {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
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
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:serviceUUID],
              peripheral.identifier.UUIDString);
        
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    
    if (!characteristic)
    {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristicUUID],
              [self CBUUIDToString:serviceUUID],
              peripheral.identifier.UUIDString);
        
        return;
    }
    
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

- (int)findBLEPeripherals:(int)timeout
{
    if (self.centralManager.state != CBCentralManagerStatePoweredOn)
    {
        NSLog(@"CoreBluetooth not correctly initialized !");
        NSLog(@"State = %ld (%s)\r\n", (long)self.centralManager.state, [self centralManagerStateToString:self.centralManager.state]);
        return -1;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    
//    redBearLabsServiceUUID = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
//    adafruitServiceUUID = [CBUUID UUIDWithString:@ADAFRUIT_SERVICE_UUID];
//    lairdServiceUUID = [CBUUID UUIDWithString:@LAIRD_SERVICE_UUID];
//    blueGigaServiceUUID = [CBUUID UUIDWithString:@BLUEGIGA_SERVICE_UUID];
//    hm10ServiceUUID = [CBUUID UUIDWithString:@HM10_SERVICE_UUID];
//    hc02ServiceUUID = [CBUUID UUIDWithString:@HC02_SERVICE_UUID];
//    hc02AdvUUID = [CBUUID UUIDWithString:@HC02_ADV_UUID];
    NSArray *services = nil;
  //@[redBearLabsServiceUUID, adafruitServiceUUID, lairdServiceUUID, blueGigaServiceUUID, hm10ServiceUUID, hc02AdvUUID];
    [self.centralManager scanForPeripheralsWithServices:services options: nil];

    NSLog(@"scanForPeripheralsWithServices");
    
    return 0; // Started scanning OK !
}


- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connecting to peripheral with UUID : %@", peripheral.identifier.UUIDString);
    
    self.activePeripheral = peripheral;
    self.activePeripheral.delegate = self;
    [self.centralManager connectPeripheral:self.activePeripheral
                       options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
}

- (const char *)centralManagerStateToString:(int)state
{
    switch(state)
    {
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
    [self.centralManager stopScan];
    NSLog(@"Stopped Scanning");
    NSLog(@"Known peripherals : %lu", (unsigned long)[self.peripherals count]);
    [self printKnownPeripherals];
}

- (void)printKnownPeripherals
{
    NSLog(@"List of currently known peripherals :");
    
    for (int i = 0; i < self.peripherals.count; i++)
    {
        CBPeripheral *p = [self.peripherals objectAtIndex:i];
        
        if (p.identifier != NULL)
            NSLog(@"%d  |  %@", i, p.identifier.UUIDString);
        else
            NSLog(@"%d  |  NULL", i);
        
        [self printPeripheralInfo:p];
    }
}

- (void)printPeripheralInfo:(CBPeripheral*)peripheral
{
    NSLog(@"------------------------------------");
    NSLog(@"Peripheral Info :");
    
    if (peripheral.identifier != NULL)
        NSLog(@"UUID : %@", peripheral.identifier.UUIDString);
    else
        NSLog(@"UUID : NULL");
    
    NSLog(@"Name : %@", peripheral.name);
    NSLog(@"-------------------------------------");
}

- (BOOL)UUIDSAreEqual:(NSUUID *)UUID1 UUID2:(NSUUID *)UUID2
{
    if ([UUID1.UUIDString isEqualToString:UUID2.UUIDString])
        return TRUE;
    else
        return FALSE;
}

- (void)getAllServicesFromPeripheral:(CBPeripheral *)peripheral
{
    [peripheral discoverServices:nil]; // Discover all services without filter
}

- (void)getAllCharacteristicsFromPeripheral:(CBPeripheral *)peripheral
{
    for (int i=0; i < peripheral.services.count; i++)
    {
        CBService *service = [peripheral.services objectAtIndex:i];
        // printf("Fetching characteristics for service with UUID : %s\r\n",[self CBUUIDToString:s.UUID]);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (BOOL)compareCBUUID:(CBUUID *)UUID1 UUID2:(CBUUID *)UUID2
{
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1 length:UUID1.data.length];
    [UUID2.data getBytes:b2 length:UUID2.data.length];
    
    if (memcmp(b1, b2, UUID1.data.length) == 0)
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
    for(int i=0; i < service.characteristics.count; i++)
    {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    
    return nil; //Characteristic not found on this service
}

#pragma mark - CBCentralManager & CBPeripheral delegate methods

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
    NSLog(@"Status of CoreBluetooth central manager changed %ld (%s)", (long)central.state, [self centralManagerStateToString:central.state]);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (!self.peripherals) {
        self.peripherals = [[NSMutableArray alloc] initWithObjects:peripheral,nil];
    }
    else {
        for(int i = 0; i < self.peripherals.count; i++)
        {
            CBPeripheral *peripheral = [self.peripherals objectAtIndex:i];
            [peripheral ble_setAdvertisementData:advertisementData RSSI:RSSI];
            
            if ((peripheral.identifier == NULL) || (peripheral.identifier == NULL))
                continue;
            
            if ([self UUIDSAreEqual:peripheral.identifier UUID2:peripheral.identifier])
            {
                [self.peripherals replaceObjectAtIndex:i withObject:peripheral];
                NSLog(@"Duplicate UUID found updating...");
                return;
            }
        }
        
        [self.peripherals addObject:peripheral];
        
        NSLog(@"New UUID, adding");
    }
    
    NSLog(@"didDiscoverPeripheral");
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (peripheral.identifier != NULL)
        NSLog(@"Connected to %@ successful", peripheral.identifier.UUIDString);
    else
        NSLog(@"Connected to NULL successful");
    
    self.activePeripheral = peripheral;
    [self.activePeripheral discoverServices:nil];
    [self getAllServicesFromPeripheral:peripheral];
}

static bool done = false;

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    done = false;
    
    if ([_delegate respondsToSelector:@selector(bleDidDisconnect)]) {
        [_delegate bleDidDisconnect];
    }
    
    isConnected = false;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (!error)
    {
        NSLog(@"Characteristic discorvery unsuccessful!");
        return;
    }
    
    //        printf("Characteristics of service with UUID : %s found\n",[self CBUUIDToString:service.UUID]);
    
    for (int i=0; i < service.characteristics.count; i++)
    {
        //            CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        //            printf("Found characteristic %s\n",[ self CBUUIDToString:c.UUID]);
        CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
        
        if ([service.UUID isEqual:s.UUID])
        {
            if (!done)
            {
                [self enableReadNotification:_activePeripheral];
                if ([_delegate respondsToSelector:@selector(bleDidConnect)]) {
                    [_delegate bleDidConnect];
                }
                
                isConnected = true;
                done = true;
            }
            
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Service discovery was unsuccessful!");
        return;
    }
    
    // TODO - future versions should just get characteristics we care about
    // [peripheral discoverCharacteristics:characteristics forService:service];
    [self getAllCharacteristicsFromPeripheral:peripheral];
    
    // Determine if we're connected to Red Bear Labs, Adafruit or Laird hardware
//    for (CBService *service in peripheral.services) {
//        if ([service.UUID isEqual:redBearLabsServiceUUID]) {
//            NSLog(@"RedBearLabs Bluetooth");
//            serialServiceUUID = redBearLabsServiceUUID;
//            readCharacteristicUUID = [CBUUID UUIDWithString:@RBL_CHAR_TX_UUID];
//            writeCharacteristicUUID = [CBUUID UUIDWithString:@RBL_CHAR_RX_UUID];
//            break;
//        } else if ([service.UUID isEqual:adafruitServiceUUID]) {
//            NSLog(@"Adafruit Bluefruit LE");
//            serialServiceUUID = adafruitServiceUUID;
//            readCharacteristicUUID = [CBUUID UUIDWithString:@ADAFRUIT_CHAR_TX_UUID];
//            writeCharacteristicUUID = [CBUUID UUIDWithString:@ADAFRUIT_CHAR_RX_UUID];
//            break;
//        } else if ([service.UUID isEqual:lairdServiceUUID]) {
//            NSLog(@"Laird BL600");
//            serialServiceUUID = lairdServiceUUID;
//            readCharacteristicUUID = [CBUUID UUIDWithString:@LAIRD_CHAR_TX_UUID];
//            writeCharacteristicUUID = [CBUUID UUIDWithString:@LAIRD_CHAR_RX_UUID];
//            break;
//        } else if ([service.UUID isEqual:blueGigaServiceUUID]) {
//            NSLog(@"BlueGiga Bluetooth");
//            serialServiceUUID = blueGigaServiceUUID;
//            readCharacteristicUUID = [CBUUID UUIDWithString:@BLUEGIGA_CHAR_TX_UUID];
//            writeCharacteristicUUID = [CBUUID UUIDWithString:@BLUEGIGA_CHAR_RX_UUID];
//            break;
//        } else if ([service.UUID isEqual:hm10ServiceUUID]) {
//            NSLog(@"HM-10 Bluetooth");
//            serialServiceUUID = hm10ServiceUUID;
//            readCharacteristicUUID = [CBUUID UUIDWithString:@HM10_CHAR_TX_UUID];
//            writeCharacteristicUUID = [CBUUID UUIDWithString:@HM10_CHAR_RX_UUID];
//            break;
//        } else if ([service.UUID isEqual:hc02ServiceUUID]) {
//            NSLog(@"HC-02 Bluetooth");
//            NSLog(@"Set HC-02 read write UUID");
//            serialServiceUUID = hc02ServiceUUID;
//            readCharacteristicUUID = [CBUUID UUIDWithString:@HC02_CHAR_TX_UUID];
//            writeCharacteristicUUID = [CBUUID UUIDWithString:@HC02_CHAR_RX_UUID];
//            break;
//        } else {
//            // ignore unknown services
//        }
//    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error in setting notification state for characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristic.UUID],
              [self CBUUIDToString:characteristic.service.UUID],
              peripheral.identifier.UUIDString);
        
        NSLog(@"Error code was %s", [[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
        return;
    }
    
    if (characteristic.isNotifying) {
        NSLog(@"订阅成功");
    } else {
        NSLog(@"取消订阅");
    }
    
//    printf("Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:peripheral.UUID]);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"updateValueForCharacteristic failed!");
        return;
    }
    
    unsigned char data[20];

    static unsigned char buf[512];
    static int len = 0;
    NSInteger data_len;
    
    if ([characteristic.UUID isEqual:readCharacteristicUUID])
    {
        data_len = characteristic.value.length;
        [characteristic.value getBytes:data length:data_len];
        
        if (data_len == 20)
        {
            memcpy(&buf[len], data, 20);
            len += data_len;
            
            if (len >= 64)
            {
                if ([_delegate respondsToSelector:@selector(bleDidReceiveData:length:)]) {
                    [_delegate bleDidReceiveData:buf length:len];
                }
                len = 0;
            }
        }
        else if (data_len < 20)
        {
            memcpy(&buf[len], data, data_len);
            len += data_len;
            
            if ([_delegate respondsToSelector:@selector(bleDidReceiveData:length:)]) {
                [_delegate bleDidReceiveData:buf length:len];
            }
            len = 0;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (!isConnected) return;
    
    if (rssi != RSSI.intValue)
    {
        rssi = RSSI.intValue;
        if ([_delegate respondsToSelector:@selector(bleDidReadRSSI:error:)]) {
            [_delegate bleDidReadRSSI:RSSI error:error];
        }
    }
}

@end
