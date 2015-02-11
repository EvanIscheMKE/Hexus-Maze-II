//
//  HDNavigationBar.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/25/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDMenuBar.h"
#import "UIColor+FlatColors.h"
#import "HDSettingsManager.h"
#import "HDHelper.h"

@interface HDMenuBar ()
@property (nonatomic, strong) UIButton *navigationButton;
@property (nonatomic, strong) UIButton *activityButton;
@end

@implementation HDMenuBar{
    NSDictionary *_views;
    NSDictionary *_metrics;
}

#pragma mark - Custom Initalizers

+ (instancetype)menuBarWithActivityImage:(UIImage *)activityImage;
{
    return [[HDMenuBar alloc] initWithActivityImage:activityImage];
}

- (instancetype)initWithActivityImage:(UIImage *)activityImage
{
    if (self = [super init]) {
        self.activityImage = activityImage;
        [self _setup];
    }
    return self;
}

#pragma mark - Private

- (void)_setup
{
    self.backgroundColor = [UIColor clearColor];
    
     self.navigationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navigationButton setBackgroundImage:[UIImage imageNamed:@"Grid"] forState:UIControlStateNormal];

     self.activityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.activityButton setBackgroundImage:self.activityImage forState:UIControlStateNormal];
    
    for (UIButton *subView in @[self.navigationButton, self.activityButton]) {
        subView.adjustsImageWhenDisabled = NO;
        subView.adjustsImageWhenHighlighted = NO;
        subView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:subView];
    }
}

- (void)_layoutSubviews
{
    UIButton *toggle = self.navigationButton;
    UIButton *share  = self.activityButton;
    
    _views = NSDictionaryOfVariableBindings(toggle, share);
    _metrics = @{ @"buttonHeight" : @([UIImage imageNamed:@"Grid"].size.height),
                  @"inset"        : @(kButtonInset) };
    

    NSArray *toggleHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[toggle(buttonHeight)]"
                                                                            options:0
                                                                            metrics:_metrics
                                                                              views:_views];
    [self addConstraints:toggleHorizontalConstraint];
    
    NSArray *activityHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[share(buttonHeight)]-inset-|"
                                                                            options:0
                                                                            metrics:_metrics
                                                                              views:_views];
    [self addConstraints:activityHorizontalConstraint];
    
    NSArray *toggleVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[toggle(buttonHeight)]"
                                                                                  options:0
                                                                                  metrics:_metrics
                                                                                    views:_views];
    [self addConstraints:toggleVerticalConstraint];
    
    NSArray *shareVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[share(buttonHeight)]"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
    [self addConstraints:shareVerticalConstraint];
    
    for (UIButton *subView in self.subviews) {
        subView.transform = CGAffineTransformMakeScale(CGRectGetWidth(self.bounds)/375.0f, CGRectGetWidth(self.bounds)/375.0f);
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        [self _layoutSubviews];
    }
}

#pragma mark - Setters

- (void)setActivityImage:(UIImage *)activityImage
{
    _activityImage = activityImage;
    
    if (self.activityButton) {
        [self.activityButton setImage:activityImage forState:UIControlStateNormal];
    }
}

@end
