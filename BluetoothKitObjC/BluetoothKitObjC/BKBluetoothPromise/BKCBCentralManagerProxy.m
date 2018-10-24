//
//  BKCBCentralManagerProxy.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/17.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BKCBCentralManagerProxy.h"

@interface BKCBCentralManagerProxy () {
    __weak id _centralManagerDelegate;
}

@end

@implementation BKCBCentralManagerProxy

- (instancetype)initWithCentralManagerDelegate:(id<CBCentralManagerDelegate>)centralManagerDelegate {
    if (self) {
        _centralManagerDelegate = centralManagerDelegate;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_centralManagerDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _centralManagerDelegate;
}

// handling unimplemented methods and nil target/interceptor
// https://github.com/Flipboard/FLAnimatedImage/blob/76a31aefc645cc09463a62d42c02954a30434d7d/FLAnimatedImage/FLAnimatedImage.m#L786-L807
- (void)forwardInvocation:(NSInvocation *)invocation {
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

@end
