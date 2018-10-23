//
//  BKCBPeripheralManagerProxy.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/17.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BKCBPeripheralManagerProxy.h"

@interface BKCBPeripheralManagerProxy () {
    __weak id _peripheralManagerDelegate;
}

@end

@implementation BKCBPeripheralManagerProxy

- (instancetype)initWithPeripheralManagerDelegate:(id<CBPeripheralManagerDelegate>)peripheralManagerDelegate {
    if (self) {
        _peripheralManagerDelegate = peripheralManagerDelegate;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_peripheralManagerDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _peripheralManagerDelegate;
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
