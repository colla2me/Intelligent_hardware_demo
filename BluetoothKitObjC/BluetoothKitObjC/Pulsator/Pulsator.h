//
//  Pulsator.h
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/6.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface Pulsator : CAReplicatorLayer

@property (nonatomic, assign) BOOL autoRemove;
@property (nonatomic, assign, readonly) BOOL isPulsating;
@property (nonatomic, assign) NSUInteger numPulse;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat fromValueForRadius;
@property (nonatomic, assign) CGFloat keyTimeForHalfOpacity;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) NSTimeInterval pulseInterval;
@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;

- (void)start;
- (void)stop;

@end
