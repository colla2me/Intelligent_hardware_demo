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
    return nil;
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
