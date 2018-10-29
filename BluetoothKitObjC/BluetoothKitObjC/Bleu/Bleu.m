//
//  Bleu.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/28.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "Bleu.h"

@interface Bleu ()

@property (nonatomic, strong) NSMutableSet<Radar *> *radars;

@end

@implementation Bleu

+ (Bleu *)shared {
    static dispatch_once_t onceToken;
    static Bleu *bleu = nil;
    dispatch_once(&onceToken, ^{
        bleu = [[Bleu alloc] init];
    });
    return bleu;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    self.radars = [NSMutableSet set];
    return self;
}

+ (Radar *)sendRequest:(RadarRequest *)request options:(RadarOptions *)options completionHandler:(void(^)(NSDictionary* _Nullable, NSError * _Nullable))completionHandler {
    Radar *radar = [[Radar alloc] initWithRequest:request options:options];
    radar.completionHandler = completionHandler;
    [[Bleu shared].radars addObject:radar];
    [radar resume];
    return radar;
}

@end
