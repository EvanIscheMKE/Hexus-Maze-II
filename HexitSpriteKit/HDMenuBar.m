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
@property (nonatomic, strong) UIButton *soundButton;
@property (nonatomic, strong) UIButton *musicButton;
@end

@implementation HDMenuBar{
    NSDictionary *_views;
    NSDictionary *_metrics;
    
    BOOL _sound;
    BOOL _music;
}

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

- (void)_setup
{
     self.navigationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navigationButton setBackgroundImage:[UIImage imageNamed:@"Grid"] forState:UIControlStateNormal];

     self.activityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.activityButton setBackgroundImage:self.activityImage forState:UIControlStateNormal];
    
     self.soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.soundButton setBackgroundImage:[UIImage imageNamed:@"SoundIcon-ON"] forState:UIControlStateSelected];
    [self.soundButton setBackgroundImage:[UIImage imageNamed:@"SoundIcon-OFF"] forState:UIControlStateNormal];
    
     self.musicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.musicButton setBackgroundImage:[UIImage imageNamed:@"MusicIcon-ON"] forState:UIControlStateSelected];
    [self.musicButton setBackgroundImage:[UIImage imageNamed:@"MusicIcon-OFF"] forState:UIControlStateNormal];
    
    for (UIButton *subView in @[self.navigationButton, self.activityButton, self.soundButton, self.musicButton]) {
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
    UIButton *music  = self.musicButton;
    UIButton *sound  = self.soundButton;
    
    CGFloat buttonHeight = ![HDHelper isWideScreen] ? kSmallButtonSize : kLargeButtonSize;
    
    _views = NSDictionaryOfVariableBindings(toggle, share, music, sound);
    _metrics = @{ @"buttonHeight" : @(buttonHeight),
                  @"inset"        : @(kButtonInset),
                  @"spacing"      : @(floorf(((CGRectGetWidth(self.bounds) - (buttonHeight*4 + kButtonInset*2))/3))) };
    
    NSString *layoutVisualFormatString = @"H:|-inset-[toggle(buttonHeight)]-spacing-[sound(buttonHeight)]-spacing-[music(buttonHeight)]-spacing-[share(buttonHeight)]";
    
    NSArray *horizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:layoutVisualFormatString
                                                                            options:0
                                                                            metrics:_metrics
                                                                              views:_views];
    [self addConstraints:horizontalConstraint];
    
    NSArray *toggleVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[toggle(buttonHeight)]"
                                                                                  options:0
                                                                                  metrics:_metrics
                                                                                    views:_views];
    [self addConstraints:toggleVerticalConstraint];
    
    NSArray *musicVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[music(buttonHeight)]"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
    [self addConstraints:musicVerticalConstraint];
    
    NSArray *soundVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[sound(buttonHeight)]"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
    [self addConstraints:soundVerticalConstraint];
    
    NSArray *shareVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[share(buttonHeight)]"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
    [self addConstraints:shareVerticalConstraint];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        [self _layoutSubviews];
    } else {
        //Tear Down
    }
}

#pragma mark - Override Setters

- (void)setActivityImage:(UIImage *)activityImage
{
    _activityImage = activityImage;
    
    if (self.activityButton) {
        [self.activityButton setImage:activityImage forState:UIControlStateNormal];
    }
}

@end
