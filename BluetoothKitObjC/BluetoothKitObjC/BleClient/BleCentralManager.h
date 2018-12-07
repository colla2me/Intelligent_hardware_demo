//
//  BleCentralManager.h
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/7.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BlePeripheral, CBCentralManager;

typedef void(^BleCentralDiscoverPeripheralsBlock)(NSArray *peripherals);
typedef void(^BleCentralDiscoverPeripheralsChangesBlock)(BlePeripheral *peripheral);

@interface BleCentralManager : NSObject

@end
