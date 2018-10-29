//
//  RadarOptions.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/28.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "RadarOptions.h"

@implementation RadarOptions

- (instancetype)init {
    if (self = [super init]) {
        _showPowerAlertKey = NO;
        _restoreIdentifierKey = @"com.bleu.radar.restore.key";
        _allowDuplicatesKey = NO;
        _thresholdRSSI = -30;
        _timeout = 10;
    }
    return self;
}

@end
