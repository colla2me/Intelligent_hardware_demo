//
//  BKCentralAdapter.h
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/10/23.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BKCentralAdapter : NSObject
<
CBCentralManagerDelegate,
CBPeripheralDelegate
>

@property (nonatomic, nullable, weak) CBCentralManager *centralManager;

@property (nonatomic, nullable, weak) CBPeripheral *peripheral;

@end
