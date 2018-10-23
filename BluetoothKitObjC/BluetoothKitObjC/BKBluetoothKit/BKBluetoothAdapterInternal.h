//
//  BKBluetoothAdapterInternal.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/22.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BKBluetoothAdapter.h"
#import "BKCBCentralManagerProxy.h"

@interface BKBluetoothAdapter ()

@property (nonatomic, strong, nullable) BKCBCentralManagerProxy *centralManagerProxy;

@end
