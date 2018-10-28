//
//  RadarOptions.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/28.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RadarOptions : NSObject

@property (nonatomic, assign) BOOL showPowerAlertKey;
@property (nonatomic, copy) NSString *restoreIdentifierKey;
@property (nonatomic, assign) BOOL allowDuplicatesKey;
@property (nonatomic, assign) NSInteger thresholdRSSI;
@property (nonatomic, assign) NSInteger timeout;

@end

NS_ASSUME_NONNULL_END
