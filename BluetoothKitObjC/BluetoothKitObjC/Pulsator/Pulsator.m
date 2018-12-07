//
//  Pulsator.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/6.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "Pulsator.h"

@interface Pulsator () <CAAnimationDelegate>

@property (nonatomic, strong) CALayer *pulse;
@property (nonatomic, strong) CAAnimationGroup *animationGroup;
@property (nonatomic, assign) CGFloat alpha;

@property (nonatomic, weak) CALayer *prevSuperlayer;
@property (nonatomic, assign) NSInteger prevLayerIndex;

@end

static NSString * const kPulsatorAnimationKey = @"pulsator";

@implementation Pulsator

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setBackgroundColor:(CGColorRef)backgroundColor {
    self.pulse.backgroundColor = backgroundColor;
    CGFloat alpha = CGColorGetAlpha(backgroundColor);
    if (alpha != _alpha) {
        self.alpha = alpha;
        [self recreate];
    }
    [super setBackgroundColor:backgroundColor];
}

- (void)setRepeatCount:(float)repeatCount {
    if (self.animationGroup) {
        self.animationGroup.repeatCount = repeatCount;
    }
    [super setRepeatCount:repeatCount];
}

- (void)setNumPulse:(NSUInteger)numPulse {
    if (numPulse < 1) {
        numPulse = 1;
    }
    _numPulse = numPulse;
    self.instanceCount = numPulse;
    [self updateInstanceDelay];
}

- (void)setFromValueForRadius:(CGFloat)fromValueForRadius {
    if (fromValueForRadius >= 1.0) {
        fromValueForRadius = 0.0;
    }
    _fromValueForRadius = fromValueForRadius;
    [self recreate];
}

- (void)setKeyTimeForHalfOpacity:(CGFloat)keyTimeForHalfOpacity {
    _keyTimeForHalfOpacity = keyTimeForHalfOpacity;
    [self recreate];
}

- (void)setTimingFunction:(CAMediaTimingFunction *)timingFunction {
    _timingFunction = timingFunction;
    if (self.animationGroup) {
        self.animationGroup.timingFunction = timingFunction;
    }
}

- (void)setAnimationDuration:(NSTimeInterval)animationDuration {
    _animationDuration = animationDuration;
    [self updateInstanceDelay];
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    [self updatePulse];
}

- (BOOL)isPulsating {
    NSArray *keys = [self.pulse animationKeys];
    return keys && keys.count > 0;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _alpha = 0.45;
        _numPulse = 1;
        _radius = 60.0;
        _autoRemove = NO;
        _pulseInterval = 0;
        _animationDuration = 3;
        _fromValueForRadius = 0.0;
        _keyTimeForHalfOpacity = 0.2;
        _timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        
        _pulse = [CALayer layer];
        
        [self setupPulse];
        
        self.instanceDelay = 1;
        self.repeatCount = MAXFLOAT;
        self.backgroundColor = [UIColor colorWithRed:0 green:0.455 blue:0.756 alpha:0.45].CGColor;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)setupPulse {
    self.pulse.contentsScale = [UIScreen mainScreen].scale;
    self.pulse.opaque = 0.0;
    [self addSublayer:self.pulse];
    [self updatePulse];
}

- (void)setupAnimationGroup {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    scaleAnimation.fromValue = @(self.fromValueForRadius);
    scaleAnimation.toValue = @(1.0);
    scaleAnimation.duration = self.animationDuration;
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = self.animationDuration;
    opacityAnimation.values = @[@(self.alpha), @(self.alpha * 0.5), @(0.0)];
    opacityAnimation.keyTimes = @[@(0.0), @(self.keyTimeForHalfOpacity), @(1.0)];
    
    self.animationGroup = [CAAnimationGroup animation];
    self.animationGroup.animations = @[scaleAnimation, opacityAnimation];
    self.animationGroup.duration = self.animationDuration + self.pulseInterval;
    self.animationGroup.repeatCount = self.repeatCount;
    if (self.timingFunction) {
        self.animationGroup.timingFunction = self.timingFunction;
    }
    self.animationGroup.delegate = self;
}

- (void)updatePulse {
    CGFloat diameter = self.radius * 2;
    self.pulse.bounds = CGRectMake(0, 0, diameter, diameter);
    self.pulse.cornerRadius = self.radius;
    self.pulse.backgroundColor = self.backgroundColor;
}

- (void)updateInstanceDelay {
    if (self.numPulse < 1) return;
    self.instanceDelay = (self.animationDuration + self.pulseInterval) / (CGFloat)self.numPulse;
}

- (void)stop {
    [self.pulse removeAllAnimations];
    self.animationGroup = nil;
}

- (void)start {
    [self setupPulse];
    [self setupAnimationGroup];
    [self.pulse addAnimation:self.animationGroup forKey:kPulsatorAnimationKey];
}

- (void)save {
    self.prevSuperlayer = self.superlayer;
    self.prevLayerIndex = [self.prevSuperlayer.sublayers indexOfObject:self];
}

- (void)resume {
    if (self.prevSuperlayer && self.prevLayerIndex != NSNotFound) {
        [self.prevSuperlayer insertSublayer:self atIndex:(unsigned)self.prevLayerIndex];
    }
    
    if (!self.pulse.superlayer) {
        [self addSublayer:self.pulse];
    }
    
    BOOL isAnimating = [self.pulse animationForKey:kPulsatorAnimationKey] != nil;
    
    if (self.animationGroup && !isAnimating) {
        [self.pulse addAnimation:self.animationGroup forKey:kPulsatorAnimationKey];
    }
}

- (void)recreate {
    if (!_animationGroup) return;
    [self stop];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self start];
    });
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSArray<NSString *> *keys = [self.pulse animationKeys];
    if (keys && keys.count > 0) {
        [self.pulse removeAllAnimations];
    }
    [self.pulse removeFromSuperlayer];
    
    if (self.autoRemove) {
        [self removeFromSuperlayer];
    }
}

@end
