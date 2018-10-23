//
//  BKBluetoothAdapter.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/17.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKBluetoothAdapter : NSObject

@property (nonatomic, nullable, weak) CBCentralManager *centralManager;

@property (nonatomic, nullable, weak) CBPeripheral *peripheral;

//@property (nonatomic, nullable, weak) CBPeripheralManager *peripheralManager;

@end

NS_ASSUME_NONNULL_END
