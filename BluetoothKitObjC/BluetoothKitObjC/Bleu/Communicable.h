//
//  Communicable.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/28.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//typedef void(^<#name#>)(<#arguments#>);

NS_ASSUME_NONNULL_BEGIN

@protocol Communicable <NSObject>

@property (nonatomic, strong) CBUUID *serviceUUID;

@property (nonatomic, strong, nullable) NSData *value;

@property (nonatomic, strong, nullable) CBUUID *characteristicUUID;

@property (nonatomic, strong) CBMutableCharacteristic *characteristic;

@end

NS_ASSUME_NONNULL_END
