//
//  Bleu.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/28.
//  Copyright © 2018 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Radar.h"

NS_ASSUME_NONNULL_BEGIN

@interface Bleu : NSObject

+ (Bleu *)shared;

+ (Radar *)sendRequest:(RadarRequest *)request options:(RadarOptions *)options completionHandler:(void(^)(NSDictionary* _Nullable, NSError * _Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END
