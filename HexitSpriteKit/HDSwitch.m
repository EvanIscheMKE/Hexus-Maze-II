//
//  HDSwitch.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/29/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDSwitch.h"

static const CGFloat kPadding = 5.0f;

@interface HDSwitch ()

@property (nonatomic, strong) UILabel *onLabel;
@property (nonatomic, strong) UILabel *offLabel;

@property (nonatomic, strong) UIView *slidingView;

@end

@implementation HDSwitch {
    UIColor *_onColor;
    UIColor *_offColor;
    
    BOOL _animating;
    BOOL _toggleValue;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame onColor:[UIColor whiteColor] offColor:[UIColor redColor]];
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
        
        [self setBackgroundColor:_onColor];
        [self setupSubviews];
        [self setOn:YES];
        
        CALayer *layer = [self layer];
        [layer setCornerRadius:5.0f];
        
    }
    return self;
}

- (void)setupSubviews;
{
    CGRect slidingViewFrame = CGRectMake(
                                         CGRectGetWidth(self.bounds) - (CGRectGetWidth(self.slidingView.bounds) + kPadding),
                                         kPadding,
                                         CGRectGetWidth(self.bounds)/3,
                                         CGRectGetHeight(self.bounds) - (kPadding*2)
                                         );
    
    self.slidingView = [[UIView alloc] initWithFrame:slidingViewFrame];
    [self.slidingView.layer setCornerRadius:3.0f];
    [self.slidingView setUserInteractionEnabled:NO];
    [self.slidingView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.slidingView];
    
    CGRect onLabelFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds)/1.5f - kPadding, CGRectGetHeight(self.bounds));
     self.onLabel = [[UILabel alloc] initWithFrame:onLabelFrame];
    [self.onLabel setText:NSLocalizedString(@"ON", nil)];
    [self.onLabel setAlpha:1.0f];
    
    CGRect offLabelFrame = CGRectMake(CGRectGetWidth(self.bounds)/3.0f + kPadding, 0.0f, CGRectGetWidth(self.bounds)/1.5f - kPadding, CGRectGetHeight(self.bounds));
     self.offLabel = [[UILabel alloc] initWithFrame:offLabelFrame];
    [self.offLabel setText:NSLocalizedString(@"OFF", nil)];
    [self.offLabel setAlpha:0.0f];
    
    for (UILabel *label in @[self.onLabel, self.offLabel]) {
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor whiteColor]];
        [self addSubview:label];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!_animating) {
    
        [self.offLabel setFrame:CGRectMake(
                                           CGRectGetWidth(self.bounds)/3,
                                           0.0f,
                                           CGRectGetWidth(self.bounds)/1.5f,
                                           CGRectGetHeight(self.bounds)
                                           )];
        
        [self.onLabel setFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds)/1.5f, CGRectGetHeight(self.bounds))];
        
        if (self.isON) {
            CGRect slidingViewFrame = CGRectMake(
                                                 CGRectGetWidth(self.bounds) - (CGRectGetWidth(self.slidingView.bounds) + kPadding),
                                                 kPadding,
                                                 CGRectGetWidth(self.bounds)/3,
                                                 CGRectGetHeight(self.bounds)-(kPadding*2)
                                                 );
            [self.slidingView setFrame:slidingViewFrame];
        } else {
           [self.slidingView setFrame:CGRectMake(kPadding, kPadding, CGRectGetWidth(self.bounds)/3, CGRectGetHeight(self.bounds)-(kPadding*2))];
        }
        
        for (UILabel *label in @[self.onLabel, self.offLabel]) {
            [label setFont:GILLSANS_LIGHT(CGRectGetHeight(self.bounds) * .5f)];
        }
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL wasPreviouslyOn = self.isON;
    
    if (self.isON) {
        [self setOn:NO animated:YES];
    } else if (!self.isON) {
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
        const CGFloat kOriginX = CGRectGetWidth(self.bounds) - (CGRectGetWidth(self.slidingView.bounds) + kPadding);
        CGRect slidingViewFrame = CGRectMake(kOriginX, kPadding, CGRectGetWidth(self.bounds)/3, CGRectGetHeight(self.bounds) - (kPadding*2));
        [self.slidingView setFrame:slidingViewFrame];
        [self setBackgroundColor:_onColor];
        [self.onLabel  setAlpha:1.0f];
        [self.offLabel setAlpha:0.0f];
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
        CGRect slidingViewFrame = CGRectMake(kPadding, kPadding, CGRectGetWidth(self.bounds)/3, CGRectGetHeight(self.bounds) - (kPadding*2));
        [self.slidingView setFrame:slidingViewFrame];
        [self setBackgroundColor:_offColor];
        [self.onLabel setAlpha:0.0f];
        [self.offLabel setAlpha:1.0f];
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
