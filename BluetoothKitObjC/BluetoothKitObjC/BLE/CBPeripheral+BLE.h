//
//  CBPeripheral+BLE.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/11/10.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (BLE)

/*!
 *  @property bleAdvertising
 *
 *  @discussion 保存蓝牙外设广播数据
 */
@property (nonatomic, copy) NSString *bleAdvertising;

/*!
 *  @property bleAdvertisementRSSI
 *
 *  @discussion 保存蓝牙外设RSSI
 */
@property (nonatomic, copy) NSNumber *bleAdvertisementRSSI;

/*!
 *  @method ble_setAdvertisementData:RSSI:
 *
 *  @discussion 设置保存advertisementData和RSSI
 */
- (void)ble_setAdvertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber*)rssi;

@end
