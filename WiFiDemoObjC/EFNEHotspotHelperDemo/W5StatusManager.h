//
//  W5StatusManager.h
//  EFNEHotspotHelperDemo
//
//  Created by Samuel on 2018/10/21.
//  Copyright © 2018年 EyreFree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^W5StatusSenderBlock)(id);

@interface W5StatusManager : NSObject

+ (W5StatusManager *)shared;

// 连接 WIFI 名称
- (void)getSSID:(W5StatusSenderBlock)callback;

// 连接 WIFI MAC 地址
- (void)getBSSID:(W5StatusSenderBlock)callback;

// 连接 WIFI 信号强度
- (void)getSignalStrength:(W5StatusSenderBlock)callback;

- (void)getBroadcast:(W5StatusSenderBlock)callback;

- (void)getIPAddress:(W5StatusSenderBlock)callback;

- (void)getIPV4Address:(W5StatusSenderBlock)callback;

@end
