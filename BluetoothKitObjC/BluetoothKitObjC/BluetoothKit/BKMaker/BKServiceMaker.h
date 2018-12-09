//
//  BKServiceMaker.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/12/9.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@class BKCharacteristicMaker;
@interface BKServiceMaker : NSObject

@property (nonatomic, copy, readonly) NSString *UUIDString;
@property (nonatomic, assign) BOOL primary;
@property (nonatomic, strong) NSMutableArray<BKCharacteristicMaker *> *characteristics;
@property (nonatomic, copy) NSArray<CBUUID *> *packetBasedCharacteristicUUIDS;
@property (nonatomic, strong) NSMutableDictionary<CBUUID *, void(^)(NSData  * _Nullable, NSError * _Nullable)> *characteristicUpdateCallbacks;

- (instancetype)initWithUUIDString:(NSString *)UUIDString;

- (CBService *)makeService;

@end

NS_ASSUME_NONNULL_END
