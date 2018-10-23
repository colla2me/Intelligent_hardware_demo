//
//  BKBluetoothAdapter+CBCentralManager.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/22.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BKBluetoothAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface BKBluetoothAdapter (CBCentralManager)
<
CBCentralManagerDelegate,
CBPeripheralDelegate
>

@end

NS_ASSUME_NONNULL_END
