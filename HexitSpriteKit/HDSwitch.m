//
//  HDSwitch.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/29/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDSwitch.h"
#import "UIColor+ColorAdditions.h"

static const CGFloat kPadding = 5.0f;
@interface HDSwitch ()
@property (nonatomic, strong) UIView *slidingView;
@end

@implementation HDSwitch
{
    UIColor *_onColor;
    UIColor *_offColor;
    BOOL _animating;
    BOOL _toggleValue;
}

- (instancetype)initWithOnColor:(UIColor *)onColor offColor:(UIColor *)offColor
{
    return [self initWithFrame:CGRectZero onColor:onColor offColor:offColor];
}

- (instancetype)initWithFrame:(CGRect)frame onColor:(UIColor *)onColor offColor:(UIColor *)offColor
{
    if (self = [super initWithFrame:frame]) {
        _onColor  = onColor;
        _offColor = offColor;
        [self _setup];
    }
    return self;
}

- (void)_setup
{
    
    _toggleValue = YES;
    
    self.layer.cornerRadius = CGRectGetMidY(self.bounds);
    self.layer.borderColor  = _onColor.CGColor;
    self.layer.borderWidth  = 3.0f;
    
    const CGSize slidingViewSize = CGSizeMake(CGRectGetHeight(self.bounds) - (kPadding*2),
                                              CGRectGetHeight(self.bounds) - (kPadding*2));
    
    CGRect slidingViewFrame = CGRectMake(0.0f, 0.0f, slidingViewSize.width, slidingViewSize.height);
    self.slidingView = [[UIView alloc] initWithFrame:slidingViewFrame];
    self.slidingView.layer.cornerRadius = CGRectGetMidY(self.slidingView.bounds);
    self.slidingView.backgroundColor = [UIColor flatSTEmeraldColor];
    self.slidingView.userInteractionEnabled = NO;
    self.slidingView.center = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetMidX(self.slidingView.bounds) - kPadding,
                                          CGRectGetMidY(self.bounds));
    [self addSubview:self.slidingView];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL wasPreviouslyOn = self.isON;
    if (self.isON) {
        [self setOn:NO animated:YES];
    } else {
        [self setOn:YES animated:YES];
    }
    
    if (wasPreviouslyOn != _toggleValue) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    return YES;
}

- (void)setOn:(BOOL)on
{
    [self setOn:on animated:NO];
}

- (BOOL)isON
{
    return _toggleValue;
}

- (void)setOn:(BOOL)flag animated:(BOOL)animated
{
    _toggleValue = flag;
    if (flag) {
        [self showOnAnimated:animated];
    } else {
        [self showOffAnimated:animated];
    }
}

- (void)showOnAnimated:(BOOL)animated
{
    dispatch_block_t animationBlock = ^{
        self.slidingView.center = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetMidX(self.slidingView.bounds) - kPadding,
                                              CGRectGetMidY(self.bounds));
        self.slidingView.transform = CGAffineTransformIdentity;
        self.slidingView.backgroundColor = [UIColor flatSTEmeraldColor];
        self.layer.borderColor = self.slidingView.backgroundColor.CGColor;
    };
    
    if (!animated) {
        animationBlock();
    } else {
        _animating = YES;
        [UIView animateWithDuration:.3f animations:animationBlock completion:^(BOOL finished) {
            _animating = NO;
        }];
    }
}

- (void)showOffAnimated:(BOOL)animated
{    
    dispatch_block_t animationBlock = ^{
        self.slidingView.center = CGPointMake(CGRectGetMidX(self.slidingView.bounds) + kPadding, CGRectGetMidY(self.bounds));
        self.slidingView.transform = CGAffineTransformMakeScale(.4f,.4f);
        self.slidingView.backgroundColor = [UIColor flatSTLightBlueColor];
        self.layer.borderColor = self.slidingView.backgroundColor.CGColor;
    };
    
    if (!animated) {
        animationBlock();
    } else {
        _animating = YES;
        [UIView animateWithDuration:.3f animations:animationBlock completion:^(BOOL finished) {
            _animating = NO;
        }];
    }
}

@end
