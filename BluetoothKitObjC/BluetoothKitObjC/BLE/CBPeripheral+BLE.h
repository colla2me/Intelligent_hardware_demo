//
//  CBPeripheral+BLE.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/11/10.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (BLE)

@property (nonatomic, copy) NSString *bleAdvertising;
@property (nonatomic, copy) NSNumber *bleAdvertisementRSSI;

- (void)ble_setAdvertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber*)rssi;

@end
