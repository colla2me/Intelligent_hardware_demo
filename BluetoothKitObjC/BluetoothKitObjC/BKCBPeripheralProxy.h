//
//  BKCBPeripheralProxy.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/19.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BKCBPeripheralProxy : NSProxy

- (instancetype)initWithPeripheralDelegate:(id<CBPeripheralDelegate>)peripheralDelegate;

@end
