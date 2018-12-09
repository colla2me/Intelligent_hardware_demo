//
//  BKServiceMaker.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/12/9.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BKServiceMaker.h"
#import "BKCharacteristicMaker.h"

@implementation BKServiceMaker

- (instancetype)initWithUUIDString:(NSString *)UUIDString {
    self = [super init];
    if (!self) return nil;
    
    _UUIDString = UUIDString;
    self.primary = YES;
    self.characteristics = [NSMutableArray array];
    self.characteristicUpdateCallbacks = [NSMutableDictionary dictionary];
    
    return self;
}

- (CBService *)makeService {
    CBMutableService *mService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:self.UUIDString] primary:self.primary];
    
    for (BKCharacteristicMaker *maker in self.characteristics) {
        CBCharacteristic *characteristic = [maker makeCharacteristic];
        if (!characteristic) continue;
        if (mService.characteristics != nil) {
            NSMutableArray<CBCharacteristic *> *array = [mService.characteristics mutableCopy];
            [array addObject:characteristic];
            mService.characteristics = [array copy];
        } else {
            mService.characteristics = @[characteristic];
        }
        
        CBUUID *characteristicUUID = characteristic.UUID;
        self.characteristicUpdateCallbacks[characteristicUUID] = maker.updateCallback;
    }
    
    return mService;
}

- (BKServiceMaker *)addCharacteristic:(NSString *)UUIDString maker:(void(^)(BKCharacteristicMaker *characteristic))maker {
    BKCharacteristicMaker *characteristic = [[BKCharacteristicMaker alloc] initWithUUIDString:UUIDString];
    maker(characteristic);
    [self.characteristics addObject:characteristic];
    return self;
}

@end
