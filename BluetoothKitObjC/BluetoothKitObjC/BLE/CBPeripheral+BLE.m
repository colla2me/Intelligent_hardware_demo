//
//  CBPeripheral+BLE.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/11/10.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "CBPeripheral+BLE.h"
#import <objc/runtime.h>

static char BLE_ADVERTISING_IDENTIFER;
static char BLE_ADVERTISEMENT_RSSI_IDENTIFER;

@implementation CBPeripheral (BLE)

- (void)ble_setAdvertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber*)rssi {
    if (advertisementData) {
        NSData *manufacturerData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
        if (manufacturerData) {
            const uint8_t *bytes = [manufacturerData bytes];
            long len = [manufacturerData length];
            // skip manufacturer uuid
            NSData *data = [NSData dataWithBytes:bytes+2 length:len-2];
            [self setBleAdvertising: [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        }
    }
    
    [self setBleAdvertisementRSSI:rssi];
}

- (void)setBleAdvertising:(NSString *)newAdvertisingValue{
    objc_setAssociatedObject(self, &BLE_ADVERTISING_IDENTIFER, newAdvertisingValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)bleAdvertising{
    return objc_getAssociatedObject(self, &BLE_ADVERTISING_IDENTIFER);
}

- (void)setBleAdvertisementRSSI:(NSNumber *)newAdvertisementRSSIValue {
    objc_setAssociatedObject(self, &BLE_ADVERTISEMENT_RSSI_IDENTIFER, newAdvertisementRSSIValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)bleAdvertisementRSSI{
    return objc_getAssociatedObject(self, &BLE_ADVERTISEMENT_RSSI_IDENTIFER);
}

@end
