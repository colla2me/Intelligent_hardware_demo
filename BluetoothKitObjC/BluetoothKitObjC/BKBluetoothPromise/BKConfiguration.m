//
//  BKConfiguration.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/18.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BKConfiguration.h"

@implementation BKConfiguration

static NSString * const BKCBRestoreIdentifierKey = @"com.bkcb.restore.identifier";

+ (BKConfiguration *)defaultConfiguration {
    //TODO:
    NSUUID *serviceUUID = [[NSUUID alloc] initWithUUIDString:@"8EE4CFC9-9DB5-417D-A08A-EE397C54672F"];
    NSUUID *characteristicUUID = [[NSUUID alloc] initWithUUIDString:@"180D"];
    return [[BKConfiguration alloc] initWithServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
}

- (instancetype)initWithServiceUUID:(NSUUID *)serviceUUID characteristicUUID:(NSUUID *)characteristicUUID {
    self = [super init];
    if (self) {
        _dataServiceUUID = [CBUUID UUIDWithNSUUID:serviceUUID];
        _dataServiceCharacteristicUUID = [CBUUID UUIDWithNSUUID:characteristicUUID];
        _serviceUUIDs = @[ _dataServiceUUID ].mutableCopy;
        _endOfDataMark = [@"EOD" dataUsingEncoding:NSUTF8StringEncoding];
        _dataCancelledMark = [@"COD" dataUsingEncoding:NSUTF8StringEncoding];
        _options = @{CBCentralManagerOptionShowPowerAlertKey: @YES, CBCentralManagerOptionRestoreIdentifierKey: BKCBRestoreIdentifierKey};
        // CBCentralManagerOptionRestoreIdentifierKey: BKCBRestoreIdentifierKey
    }
    return self;
}

- (NSArray<CBUUID *> *)characteristicUUIDsForServiceUUID:(CBUUID *)serviceUUID {
    if (serviceUUID == _dataServiceUUID) {
        return @[ _dataServiceCharacteristicUUID ];
    }
    return @[];
}

@end
