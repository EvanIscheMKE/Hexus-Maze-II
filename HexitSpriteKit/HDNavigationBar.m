//
//  HDNavigationBar.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/25/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDGameButton.h"
#import "HDNavigationBar.h"
#import "UIColor+ColorAdditions.h"
#import "HDSettingsManager.h"
#import "HDHelper.h"

static const CGFloat inset = 20.0f;
@interface HDNavigationBar ()
@property (nonatomic, strong) HDGameButton *navigationButton;
@property (nonatomic, strong) HDGameButton *activityButton;
@end

@implementation HDNavigationBar
{
    NSDictionary *_views;
    NSDictionary *_metrics;
}

#pragma mark - Custom Initalizers

+ (instancetype)menuBarWithActivityImage:(UIImage *)activityImage
{
    return [[HDNavigationBar alloc] initWithActivityImage:activityImage];
}

- (instancetype)initWithActivityImage:(UIImage *)activityImage
{
    if (self = [super init]) {
        
        _activityImage = activityImage;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.navigationButton = [[HDGameButton alloc] init];
        [self.navigationButton setImage:[UIImage imageNamed:@"menuToggle"] forState:UIControlStateNormal];
        
        self.activityButton = [[HDGameButton alloc] init];
        [self.activityButton setImage:self.activityImage forState:UIControlStateNormal];
        
        for (HDGameButton *subView in @[self.navigationButton, self.activityButton]) {
            subView.buttonColor = [UIColor flatSTLightBlueColor];
            subView.adjustsImageWhenDisabled = NO;
            subView.adjustsImageWhenHighlighted = NO;
            subView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:subView];
        }
    }
    return self;
}

#pragma mark - Private

- (void)_layoutSubviews
{
    UIButton *toggle = self.navigationButton;
    UIButton *share  = self.activityButton;
    
    _views = NSDictionaryOfVariableBindings(toggle, share);
    _metrics = @{ @"buttonHeight": @(IS_IPAD ? 75.0f : 44.0f),
                  @"inset":        @(IS_IPAD ? inset*1.5f : inset*TRANSFORM_SCALE_X) };
    

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
    
    if (!IS_IPAD) {
        for (HDGameButton *subView in self.subviews) {
            subView.transform = CGAffineTransformMakeScale(TRANSFORM_SCALE_X, TRANSFORM_SCALE_X);
        }
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
