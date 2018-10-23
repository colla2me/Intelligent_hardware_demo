//
//  BKConfiguration.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/18.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKConfiguration : NSObject

@property (nonatomic, strong) CBUUID *dataServiceUUID;

@property (nonatomic, strong) CBUUID *dataServiceCharacteristicUUID;

@property (nonatomic, strong) NSData *endOfDataMark;

@property (nonatomic, strong) NSData *dataCancelledMark;

@property (nonatomic, strong) NSMutableArray<CBUUID *> *serviceUUIDs;

- (instancetype)initWithServiceUUID:(NSUUID *)serviceUUID characteristicUUID:(NSUUID *)characteristicUUID;

@end

NS_ASSUME_NONNULL_END
