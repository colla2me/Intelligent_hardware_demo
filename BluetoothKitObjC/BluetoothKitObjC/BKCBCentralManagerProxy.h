//
//  BKCBCentralManagerProxy.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/17.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BKCBCentralManagerProxy : NSProxy

- (instancetype)initWithCentralManagerDelegate:(id<CBCentralManagerDelegate>)centralManagerDelegate;

@end
