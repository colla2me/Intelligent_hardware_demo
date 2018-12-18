//
//  BLEClient.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/12/15.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BLEClient.h"
#import "CBPeripheral+BLE.h"

@interface BLEClient ()
@property (nonatomic, strong) BLECentralManager *bleShield;
@property (nonatomic, strong) NSMutableString *buffer;
@end

@implementation BLEClient

+ (instancetype)sharedClient {
    static BLEClient *client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[BLEClient alloc] init];
    });
    return client;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _bleShield = [BLECentralManager manager];
        [_bleShield setDelegate:self];
        _buffer = [[NSMutableString alloc] init];
    }
    return self;
}

#pragma mark - public methods

- (BOOL)isConnected {
    return [_bleShield isConnected];
}

- (void)connect:(NSString *)uuid {
    BLELog(@"connect");

    // if the uuid is null or blank, scan and
    // connect to the first available device
    if (uuid == (NSString *)[NSNull null]) {
        [self connectToFirstDevice];
    } else if ([uuid isEqualToString:@""]) {
        [self connectToFirstDevice];
    } else {
        [self connectToUUID:uuid];
    }
}

- (void)disconnect {
    BLELog(@"disconnect");
    if (_bleShield.activePeripheral) {
        if(_bleShield.activePeripheral.state == CBPeripheralStateConnected)
        {
//            [_bleShield.centralManager cancelPeripheralConnection:[_bleShield activePeripheral]];
        }
    }
}

- (void)readValueWithBlock:(void(^)(NSString *))block {
    [_bleShield read];
}

- (void)writeValue:(NSData *)data {
    [self writeToDevice:data];
}

- (void)writeText:(NSString *)text type:(BLEWriteEncodingType)type {
    switch (type) {
        case BLEWriteEncodingUTF8:
            [self writeTextToDevice:text];
            break;
        case BLEWriteEncodingBase64:
            [self writeBase64ToDevice:text];
            break;
        case BLEWriteEncodingHex:
            [self writeHexToDevice:text];
            break;
    }
}

- (void)findPeripheralsWithBlock:(void(^)(NSArray<CBPeripheral *>*))block {
    [self scanForBLEPeripherals:3.0];
    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(discoverPeripheralsTimer:)
                                   userInfo:block
                                    repeats:NO];
}

- (void)writeToDevice:(NSData *)data {
    if (!data) return;
    BLELog(@"write data");
    [_bleShield write:data];
}

- (void)writeTextToDevice:(NSString *)text {
    if (!text) return;
    BLELog(@"write text");
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    [_bleShield write:data];
}

- (void)writeBase64ToDevice:(NSString *)base64String {
    BLELog(@"write base64 string");
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    [_bleShield write:data];
}

- (void)writeHexToDevice:(NSString *)hexString {
    if (!hexString) return;
    BLELog(@"write hex string");
    NSData *data = [self hexToBytes:hexString];
    [_bleShield write:data];
}

#pragma mark - timers

- (void)discoverPeripheralsTimer:(NSTimer *)timer {
    void(^block)(NSArray<CBPeripheral*> *) = [timer userInfo];
    if (block) {
        block([self getPeripheralList]);
    }
}

- (void)connectFirstDeviceTimer:(NSTimer *)timer {
    if(_bleShield.peripherals.count > 0) {
        BLELog(@"Connecting");
        [_bleShield connectPeripheral:[_bleShield.peripherals objectAtIndex:0]];
    } else {
        NSString *message = @"Did not find any BLE peripherals";
        BLELog(@"%@", message);
    }
}

- (void)connectUuidTimer:(NSTimer *)timer {
    NSString *uuid = [timer userInfo];
    CBPeripheral *peripheral = [self findPeripheralByUUID:uuid];
    
    if (peripheral) {
        [_bleShield connectPeripheral:peripheral];
    } else {
        NSString *message = [NSString stringWithFormat:@"Could not find peripheral %@.", uuid];
        BLELog(@"%@", message);
    }
}

#pragma mark - internal methods

- (NSString *)readUntilDelimiter:(NSString *)delimiter {
    NSRange range = [_buffer rangeOfString: delimiter];
    NSString *message = @"";
    
    if (range.location != NSNotFound) {
        long end = range.location + range.length;
        message = [_buffer substringToIndex:end];
        
        NSRange truncate = NSMakeRange(0, end);
        [_buffer deleteCharactersInRange:truncate];
    }
    return message;
}

- (NSMutableArray *)getPeripheralList {
    NSMutableArray *peripherals = [NSMutableArray array];
    
    for (int i = 0; i < _bleShield.peripherals.count; i++) {
        NSMutableDictionary *peripheral = [NSMutableDictionary dictionary];
        CBPeripheral *p = [_bleShield.peripherals objectAtIndex:i];
        
        NSString *uuid = p.identifier.UUIDString;
        [peripheral setObject:uuid forKey: @"uuid"];
        [peripheral setObject:uuid forKey: @"id"];
        
        NSString *name = [p name];
        if (!name) {
            name = [peripheral objectForKey:@"uuid"];
        }
        [peripheral setObject:name forKey: @"name"];
        
        NSNumber *rssi = [p bleAdvertisementRSSI];
        if (rssi) { // BLEShield doesn't provide advertised RSSI
            [peripheral setObject: rssi forKey:@"rssi"];
        }
        
        [peripherals addObject:peripheral];
    }
    
    return peripherals;
}

- (void)scanForBLEPeripherals:(NSTimeInterval)timeout {
    BLELog(@"Scanning for BLE Peripherals");
    
    // disconnect
    if (_bleShield.activePeripheral) {
        if(_bleShield.activePeripheral.state == CBPeripheralStateConnected)
        {
//            [_bleShield.centralManager cancelPeripheralConnection:[_bleShield activePeripheral]];
            return;
        }
    }
    
    // remove existing peripherals
    if (_bleShield.peripherals.count > 0) {
        [_bleShield.peripherals removeAllObjects];
    }
    
    [_bleShield findBLEPeripherals:timeout];
}

- (void)connectToFirstDevice {
    [self scanForBLEPeripherals:3.0];
    
    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(connectFirstDeviceTimer:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)connectToUUID:(NSString *)uuid {
    NSTimeInterval interval = 0;
    if (_bleShield.peripherals.count < 1) {
        interval = 3.0;
        [self scanForBLEPeripherals:interval];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:interval
                                     target:self
                                   selector:@selector(connectUuidTimer:)
                                   userInfo:uuid
                                    repeats:NO];
}

- (CBPeripheral *)findPeripheralByUUID:(NSString *)uuid {
    if (!uuid) return nil;
    NSMutableArray *peripherals = [_bleShield peripherals];
    CBPeripheral *peripheral = nil;
    
    for (CBPeripheral *p in peripherals) {
        
        NSString *other = p.identifier.UUIDString;
        
        if ([uuid isEqualToString:other]) {
            peripheral = p;
            break;
        }
    }
    return peripheral;
}

- (NSData*)hexToBytes:(NSString *)hexString {
    hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString: @""];
    NSMutableData* data = [NSMutableData data];
    for (int idx = 0; idx+2 <= hexString.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

#pragma mark - BLEDelegate

- (void)bleDidReceiveData:(unsigned char *)data length:(NSUInteger)length {
    BLELog(@"bleDidReceiveData");
    
    // Append to the buffer
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    BLELog(@"Received data %@", s);
}

- (void)bleDidChangeState:(BOOL)isEnabled {
    NSString *state = isEnabled ? @"bluetoothEnabled" : @"bluetoothDisabled";
    BLELog(@"bleDidChangedState: %@", state);
}

- (void)bleDidConnect {
    BLELog(@"bleDidConnect");
}

- (void)bleDidDisconnect {
    BLELog(@"bleDidDisconnect");
}

- (void)bleDidReadRSSI:(NSNumber *)rssi {
    BLELog(@"bleDidReadRSSI: %@", rssi);
}

@end
