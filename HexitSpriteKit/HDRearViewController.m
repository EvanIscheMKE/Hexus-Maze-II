//
//  HDBackViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/13/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDContainerViewController.h"
#import "HDRearViewController.h"
#import "UIColor+FlatColors.h"
#import "HDSettingsManager.h"

@implementation HDSettingsContainer
{
    NSMutableArray *_buttons;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor flatPeterRiverColor]];
    }
    return self;
}

- (NSArray *)settingButtons
{
    if (_buttons) {
        return _buttons;
    }
    
    _buttons = [NSMutableArray array];
    
    UIButton *buttonOne = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonOne setTag:0];
    [buttonOne setImage:[UIImage imageNamed:@"_ToggleOnButton"]  forState:UIControlStateNormal];
    [buttonOne setImage:[UIImage imageNamed:@"_ToggleOffButton"] forState:UIControlStateSelected];
    
    UIButton *buttonTwo = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonTwo setTag:1];
    [buttonTwo setImage:[UIImage imageNamed:@"_ToggleOnButton"]  forState:UIControlStateNormal];
    [buttonTwo setImage:[UIImage imageNamed:@"_ToggleOffButton"] forState:UIControlStateSelected];
    
    UIButton *buttonThree = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonThree setTag:2];
    [buttonThree setImage:[UIImage imageNamed:@"_ToggleOnButton"]  forState:UIControlStateNormal];
    [buttonThree setImage:[UIImage imageNamed:@"_ToggleOffButton"] forState:UIControlStateSelected];
    
    UILabel *labelOne = [[UILabel alloc] init];
    [labelOne setText:@"Effects"];
    [self addSubview:labelOne];
    
    UILabel *labelTwo = [[UILabel alloc] init];
    [labelTwo setText:@"Sound"];
    [self addSubview:labelTwo];
    
    UILabel *labelThree = [[UILabel alloc] init];
    [labelThree setText:@"Vibration"];
    [self addSubview:labelThree];
    
    for (UILabel *label in @[labelOne, labelTwo, labelThree]) {
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:GILLSANS_LIGHT(18.0f)];
        [self addSubview:label];
    }
    
    for (UIButton *selectors in @[buttonOne, buttonTwo, buttonThree]) {
        [selectors setAdjustsImageWhenHighlighted:NO];
        [selectors setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_buttons addObject:selectors];
        [self addSubview:selectors];
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(buttonOne, buttonTwo, buttonThree, labelOne, labelTwo, labelThree);
    
    NSDictionary *metrics = @{ @"space"       : @(4.0f),
                               @"buttonHeight": @(30.0f),
                               @"labelHeight" : @(18.0f),
                               @"margin"      : @(20.0f),
                               @"inset"       : @(10.0f),
                               @"buttonWidth" : @(120.0f) };
    
    NSString *vfConstaint = @"V:|-[labelOne(labelHeight)]-space-[buttonOne(buttonHeight)]-margin-[labelTwo(labelHeight)]-space-[buttonTwo(buttonHeight)]-margin-[labelThree(labelHeight)]-space-[buttonThree(buttonHeight)]";
    
    NSArray *verticalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:vfConstaint
                                                                    options:0
                                                                    metrics:metrics
                                                                      views:views];
    
    NSArray *horizontal1Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[buttonOne(buttonWidth)]-inset-|"
                                                                         options:0
                                                                         metrics:metrics
                                                                           views:views];
    
    NSArray *horizontal2Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[buttonTwo(buttonWidth)]-inset-|"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    
    NSArray *horizontal3Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[buttonThree(buttonWidth)]-inset-|"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    
    NSArray *horizontal4Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[labelOne]"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    
    NSArray *horizontal5Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[labelTwo]"
                                                                         options:0
                                                                         metrics:metrics
                                                                           views:views];
    
    NSArray *horizontal6Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[labelThree]"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    
    for (NSArray *constraint in @[verticalConstraint,
                                  horizontal1Spacing,
                                  horizontal2Spacing,
                                  horizontal3Spacing,
                                  horizontal4Spacing,
                                  horizontal5Spacing,
                                  horizontal6Spacing]) {
        [self addConstraints:constraint];
    }
    
    return _buttons;
}

@end

@interface HDRearViewController ()
@property (nonatomic, strong) NSMutableArray *buttonList;
@end

@implementation HDRearViewController{
    NSDictionary *_views;
    NSDictionary *_metrics;
    NSArray *_vLC;
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _layoutTitle];
    [self setDelegate:[HDSettingsManager sharedManager]];
    [self _layoutSideMenu];
    [self.view setBackgroundColor:[UIColor flatPeterRiverColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_layoutTitle
{
    UILabel *title = [[UILabel alloc] init];
    [title setTranslatesAutoresizingMaskIntoConstraints:NO];
    [title setTextAlignment:NSTextAlignmentLeft];
    [title setText:@"HEXUS"];
    [title setFont:GILLSANS(24.0f)];
    [title setTextColor:[UIColor whiteColor]];
    [self.view addSubview:title];
    
    NSDictionary *views   = NSDictionaryOfVariableBindings(title);
    NSDictionary *metrics = @{ @"inset" : @(5.0f) };
    
    NSArray *titleXAxis = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[title]"
                                                                  options:0
                                                                  metrics:metrics
                                                                    views:views];
    
    NSArray *titleYAxis = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[title]-inset-|"
                                                                  options:0
                                                                  metrics:metrics
                                                                    views:views];
    
    for (NSArray *layout in @[titleXAxis, titleYAxis]) {
        [self.view addConstraints:layout];
    }
    
}

- (void)_layoutSideMenu
{
     self.container = [[HDSettingsContainer alloc] init];
    [self.container setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.container];
    
    UIButton *retry = [UIButton buttonWithType:UIButtonTypeCustom];
    [retry setTitle:@"Retry" forState:UIControlStateNormal];
    [retry setBackgroundColor:[UIColor flatMidnightBlueColor]];
    [retry addTarget:ADelegate action:@selector(restartCurrentLevel) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *map = [UIButton buttonWithType:UIButtonTypeCustom];
    [map setBackgroundColor:[UIColor flatEmeraldColor]];
    [map setTitle:@"Map" forState:UIControlStateNormal];
    [map addTarget:ADelegate action:@selector(navigateToLevelMap) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *achievements = [UIButton buttonWithType:UIButtonTypeCustom];
    [achievements setBackgroundColor:[UIColor flatTurquoiseColor]];
    [achievements setTitle:@"Achievemnets" forState:UIControlStateNormal];
    [achievements addTarget:ADelegate action:@selector(navigateToLevelMap) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *button in @[retry, map, achievements]) {
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [[button titleLabel] setFont:GILLSANS_LIGHT(20.0f)];
        [[button titleLabel] setTextAlignment:NSTextAlignmentCenter];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.layer setCornerRadius:10.0f];
        [self.view insertSubview:button belowSubview:self.container];
    }
    
    UIView *container = self.container;
    
    _views = NSDictionaryOfVariableBindings(retry, map, achievements, container);
    
    _metrics = @{ @"inset"            : @20.0f,
                  @"buttonHeight"     : @40.0f,
                  @"buttonWidth"      : @140.0f,
                  @"originYAxis"      : @130.0f,
                  @"containerHeight"  : @280.0f,
                  @"containerOriginX" : @50.0f };
    
    NSArray *verticalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:
                                   @"V:|-originYAxis-[retry(buttonHeight)]-inset-[map(==retry)]-inset-[achievements(==retry)]"
                                                                          options:0
                                                                          metrics:_metrics
                                                                            views:_views];
    
    NSArray *hMConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[map(buttonWidth)]"
                                                                    options:0
                                                                    metrics:_metrics
                                                                      views:_views];
    
    NSArray *hRConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[retry(==map)]"
                                                                    options:0
                                                                    metrics:_metrics
                                                                      views:_views];
    
    NSArray *aCConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[achievements(==map)]"
                                                                    options:0
                                                                    metrics:_metrics
                                                                      views:_views];
    
    NSArray *hCConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[container(==map)]"
                                                                    options:0
                                                                    metrics:_metrics
                                                                      views:_views];
    
    _vLC  = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[container(280)]" options:0 metrics:nil views:_views];
    
    for (NSArray *constraint in @[verticalConstraint, aCConstraint, _vLC, hMConstraint, hRConstraint, hCConstraint]) {
        [self.view addConstraints:constraint];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(layoutToggleSwitchesForSettingsFromArray:)]) {
        [self.delegate layoutToggleSwitchesForSettingsFromArray:self.container.settingButtons];
    }
}

- (void)hideGameInterfaceAnimated:(BOOL)animated
{
    [self.view removeConstraints:_vLC];
    
    _vLC  = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[container(containerHeight)]"
                                                    options:0
                                                    metrics:_metrics
                                                      views:_views];
    [self.view addConstraints:_vLC];
    
    dispatch_block_t closeAnimation = ^{
        [self.view layoutSubviews];
    };
    
    if (!animated) {
        closeAnimation();
    } else {
        [UIView animateWithDuration:.3f
                         animations:closeAnimation
                         completion:nil];
    }
}

- (void)showGameInterfaceAnimated:(BOOL)animated
{
    [self.view removeConstraints:_vLC];
    
    _vLC  = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[achievements]-inset-[container(280)]"
                                                    options:0
                                                    metrics:_metrics
                                                      views:_views];
    [self.view addConstraints:_vLC];
    
    dispatch_block_t expandAnimation = ^{
        [self.view layoutSubviews];
    };
    
    if (!animated) {
        expandAnimation();
    } else {
        [UIView animateWithDuration:.3f
                         animations:expandAnimation
                         completion:nil];
    }
}

@end
