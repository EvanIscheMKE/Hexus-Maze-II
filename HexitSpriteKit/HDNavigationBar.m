//
//  HDNavigationBar.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/25/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDNavigationBar.h"
#import "UIColor+FlatColors.h"

static const CGFloat kSmallButtonSize  = 34.0f;
static const CGFloat kLargeButtonSize  = 42.0f;
static const CGFloat kInset            = 20.0f;
@interface HDNavigationBar ()
@property (nonatomic, strong) UIButton *navigationButton;
@property (nonatomic, strong) UIButton *activityButton;
@end

@implementation HDNavigationBar{
    NSDictionary *_views;
    NSDictionary *_metrics;
}

+ (instancetype)viewWithToggleImage:(UIImage *)toggleImage activityImage:(UIImage *)activityImage
{
    return [[HDNavigationBar alloc] initWithToggleImage:toggleImage activityImage:activityImage];
}

- (instancetype)initWithToggleImage:(UIImage *)toggleImage activityImage:(UIImage *)activityImage
{
    NSParameterAssert(toggleImage);
    NSParameterAssert(activityImage);
    if (self = [super init]) {
        self.toggleImage = toggleImage;
        self.activityImage = activityImage;
        [self _setup];
    }
    return self;
}

- (void)_setup
{
    self.navigationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navigationButton setBackgroundImage:self.toggleImage forState:UIControlStateNormal];

     self.activityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.activityButton setBackgroundImage:self.activityImage forState:UIControlStateNormal];
    
    for (UIButton *subView in @[self.navigationButton, self.activityButton]) {
        subView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:subView];
    }

    UIButton *toggle  = self.navigationButton;
    UIButton *share   = self.activityButton;
    
    _views = NSDictionaryOfVariableBindings(toggle, share);
    
    _metrics = @{ @"buttonHeight" : @(CGRectGetWidth([[UIScreen mainScreen] bounds]) < 321.0f ? kSmallButtonSize : kLargeButtonSize),
                  @"inset"        : @(kInset) };
    
    NSArray *toggleHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[toggle(buttonHeight)]"
                                                                                  options:0
                                                                                  metrics:_metrics
                                                                                    views:_views];
    [self addConstraints:toggleHorizontalConstraint];
    
    NSArray *toggleVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[toggle(buttonHeight)]"
                                                                                  options:0
                                                                                  metrics:_metrics
                                                                                    views:_views];
    [self addConstraints:toggleVerticalConstraint];
    
    NSArray *shareHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[share(buttonHeight)]-inset-|"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
    [self addConstraints:shareHorizontalConstraint];
    
    NSArray *shareVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[share(buttonHeight)]"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
    [self addConstraints:shareVerticalConstraint];
}

#pragma mark - Override Setters

- (void)setActivityImage:(UIImage *)activityImage
{
    _activityImage = activityImage;
    
    if (self.activityButton) {
        [self.activityButton setImage:activityImage forState:UIControlStateNormal];
    }
}

- (void)setToggleImage:(UIImage *)toggleImage
{
    _toggleImage = toggleImage;
    
    if (self.navigationButton) {
        [self.navigationButton setImage:toggleImage forState:UIControlStateNormal];
    }
}

@end
