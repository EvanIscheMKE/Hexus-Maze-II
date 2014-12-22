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
#import "HDSoundManager.h"
#import "HDSettingsManager.h"
#import "HDSwitch.h"

static const CGFloat MINIMUM_MENU_OFFSET_X = 228.0f;

@interface HDRearViewController ()
@property (nonatomic, strong) NSMutableArray *arrayOfButtons;
@property (nonatomic, strong) UIButton *retry;
@property (nonatomic, strong) UIButton *map;
@end

@implementation HDRearViewController{
    NSDictionary *_views;
    NSDictionary *_metrics;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.arrayOfButtons = [NSMutableArray arrayWithCapacity:4];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor flatCloudsColor]];
    [self _setup];
}

- (void)setGameInterfaceHidden:(BOOL)gameInterfaceHidden
{
    _gameInterfaceHidden = gameInterfaceHidden;
    
    if (gameInterfaceHidden) {
        [self _hideGameInterface];
    } else {
        [self _showGameInterface];
    }
}

#pragma mark -
#pragma mark - Selectors

- (IBAction)_openAcheivementsController:(id)sender
{
    HDContainerViewController *container = self.containerViewController;
    if (container.isExpanded) {
        [container toggleMenuViewControllerWithCompletion:^{
             [ADelegate presentGameCenterControllerForState:GKGameCenterViewControllerStateAchievements];
        }];
    }
}

- (IBAction)_popToRootViewController:(id)sender
{
    HDContainerViewController *container = self.containerViewController;
    if (container.isExpanded) {
        [container toggleMenuViewControllerWithCompletion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gridPerformExitAnimations" object:nil];
        }];
    }
}

- (IBAction)_animateToLevelViewController:(id)sender
{
    HDContainerViewController *container = self.containerViewController;
    if (container.isExpanded) {
        [container toggleMenuViewControllerWithCompletion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"performExitAnimations" object:nil];
        }];
    }
}

- (IBAction)updateToggleButtonAtTag:(id)sender
{
    HDSwitch *toggle = (HDSwitch *)sender;
    
    HDSettingsManager *manager = [HDSettingsManager sharedManager];
    
    switch (toggle.tag) {
        case 0:
            [manager setSound:!manager.sound];
            break;
        case 1:
            [manager setMusic:!manager.music];
            [ADelegate setPlayLoop:manager.music];
            break;
        case 2:
            [manager setVibe:!manager.vibe];
            break;
        case 3:
            [manager setFx:!manager.fx];
            break;
        default:
            NSAssert(NO, @"TagIndex is outside of 0-3 %@",NSStringFromSelector(_cmd));
            break;
    }
}

#pragma mark -
#pragma mark - <Private>

- (void)_hideGameInterface
{
    [self.retry setTitle:@"Achievements" forState:UIControlStateNormal];
    [self.map   setTitle:@"Main Menu"    forState:UIControlStateNormal];
    
    [self.retry removeTarget:ADelegate action:@selector(restartCurrentLevel)       forControlEvents:UIControlEventTouchUpInside];
    [self.map   removeTarget:self action:@selector(_animateToLevelViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.retry addTarget:self action:@selector(_openAcheivementsController:) forControlEvents:UIControlEventTouchUpInside];
    [self.map   addTarget:self action:@selector(_popToRootViewController:)    forControlEvents:UIControlEventTouchUpInside];
}

- (void)_showGameInterface
{
    [self.retry setTitle:@"Restart"     forState:UIControlStateNormal];
    [self.map   setTitle:@"Back to Map" forState:UIControlStateNormal];
    
    [self.retry removeTarget:self action:@selector(_openAcheivementsController:) forControlEvents:UIControlEventTouchUpInside];
    [self.map   removeTarget:self action:@selector(_popToRootViewController:)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.retry addTarget:ADelegate action:@selector(restartCurrentLevel)       forControlEvents:UIControlEventTouchUpInside];
    [self.map   addTarget:self action:@selector(_animateToLevelViewController:) forControlEvents:UIControlEventTouchUpInside];
}

- (UIView *)_setupSwitches
{
    CGRect containerBounds = CGRectMake(0.0f, 0.0f, MAX(kAnimationOffsetX,MINIMUM_MENU_OFFSET_X) - (2 * 20.0f), 200.0f);
    UIView *container = [[UIView alloc] initWithFrame:containerBounds];
    [container setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    HDSwitch *sound = [[HDSwitch alloc] initWithOnColor:[UIColor flatPeterRiverColor] offColor:[UIColor flatMidnightBlueColor]];
    [sound setOn:[[HDSettingsManager sharedManager] sound]];
    [sound setTag:0];
    
    HDSwitch *music = [[HDSwitch alloc] initWithOnColor:[UIColor flatPeterRiverColor]  offColor:[UIColor flatMidnightBlueColor]];
    [music setOn:[[HDSettingsManager sharedManager] music]];
    [music setTag:1];
    
    HDSwitch *vibe = [[HDSwitch alloc] initWithOnColor:[UIColor flatPeterRiverColor] offColor:[UIColor flatMidnightBlueColor]];
    [vibe setOn:[[HDSettingsManager sharedManager] vibe]];
    [vibe setTag:2];
    
    HDSwitch *fx = [[HDSwitch alloc] initWithOnColor:[UIColor flatPeterRiverColor]  offColor:[UIColor flatMidnightBlueColor]];
    [fx setOn:[[HDSettingsManager sharedManager] fx]];
    [fx setTag:3];
    
    UILabel *labelOne   = [[UILabel alloc] init];
    [labelOne setText:@"Sound"];
    
    UILabel *labelTwo   = [[UILabel alloc] init];
    [labelTwo setText:@"Music"];
    
    UILabel *labelThree = [[UILabel alloc] init];
    [labelThree setText:@"Vibration"];
    
    UILabel *labelFour  = [[UILabel alloc] init];
    [labelFour setText:@"FX"];
    
    for (UILabel *label in @[labelOne, labelTwo, labelThree, labelFour]) {
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setTextColor:[UIColor flatMidnightBlueColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:GILLSANS_LIGHT(14.0f)];
        [container addSubview:label];
    }
    
    for (UIButton *toggleButton in @[sound, music, vibe, fx]) {
        [toggleButton addTarget:self action:@selector(updateToggleButtonAtTag:) forControlEvents:UIControlEventValueChanged];
        [toggleButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.arrayOfButtons addObject:toggleButton];
        [container addSubview:toggleButton];
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(sound, music, vibe, fx, labelOne, labelTwo, labelThree, labelFour);
    
    NSDictionary *metrics = @{ @"space"       : @(4.0f),
                               @"buttonHeight": @(35.0f),
                               @"labelHeight" : @(16.0f),
                               @"margin"      : @(20.0f),
                               @"inset"       : @(10.0f),
                               @"buttonWidth" : @(75.0f) };
    
    
    NSString *constraintVerticalLeft = @"V:|[sound(buttonHeight)][labelOne(labelHeight)]-inset-[vibe(buttonHeight)][labelThree(labelHeight)]";
    NSArray *verticalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:constraintVerticalLeft
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    [container addConstraints:verticalConstraint];
    
    NSString *constraintVerticalRight = @"V:|[music(buttonHeight)][labelTwo(labelHeight)]-inset-[fx(buttonHeight)][labelFour(labelHeight)]";
    NSArray *vertical2Constraint = [NSLayoutConstraint constraintsWithVisualFormat:constraintVerticalRight
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:views];
    [container addConstraints:vertical2Constraint];
    
    NSArray *horizontal1Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[sound(buttonWidth)]"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    [container addConstraints:horizontal1Spacing];
    
    NSArray *horizontal2Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[music(buttonWidth)]-inset-|"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    [container addConstraints:horizontal2Spacing];
    
    NSArray *horizontal4Spacing  = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[labelOne(buttonWidth)]"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:views];
    [container addConstraints:horizontal4Spacing];
    
    NSArray *horizontal5Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[labelTwo(buttonWidth)]-inset-|"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    [container addConstraints:horizontal5Spacing];
    
    //
    NSArray *vibeSpacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[vibe(buttonWidth)]"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    [container addConstraints:vibeSpacing];
    
    NSArray *fxSpacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[fx(buttonWidth)]-inset-|"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    [container addConstraints:fxSpacing];
    
    //
    NSArray *horizontal8Spacing  = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[labelThree(buttonWidth)]"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:views];
    [container addConstraints:horizontal8Spacing];
    
    NSArray *horizontal9Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[labelFour(buttonWidth)]-inset-|"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    [container addConstraints:horizontal9Spacing];
    
    return container;
}

- (void)_setup
{
    UIView *container = [self _setupSwitches];
    [self.view addSubview:container];
    
    self.retry = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.retry setTitle:@"Achievements" forState:UIControlStateNormal];
    [self.retry setBackgroundColor:[UIColor flatMidnightBlueColor]];
    [self.retry addTarget:self action:@selector(_openAcheivementsController:) forControlEvents:UIControlEventTouchUpInside];
    
    self.map = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.map setBackgroundColor:[UIColor flatPeterRiverColor]];
    [self.map setTitle:@"Main Menu" forState:UIControlStateNormal];
    [self.map addTarget:self action:@selector(_popToRootViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *map   = self.map;
    UIButton *retry = self.retry;
    
    for (UIButton *button in @[self.retry, self.map]) {
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [[button titleLabel] setFont:GILLSANS_LIGHT(20.0f)];
        [[button titleLabel] setTextAlignment:NSTextAlignmentCenter];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.layer setCornerRadius:20.0f];
        [self.view insertSubview:button belowSubview:container];
    }
    
    _views = NSDictionaryOfVariableBindings(retry, map, container);
    
    _metrics = @{ @"inset"            : @20.0f,
                  @"buttonHeight"     : @44.0f,
                  @"buttonWidth"      : @(ceilf(MAX(kAnimationOffsetX, MINIMUM_MENU_OFFSET_X) - (20.0f * 2))), // 20 pixel inset both sides
                  @"originYAxis"      : @(CGRectGetHeight(self.view.bounds)/5.15f),
                  @"containerHeight"  : @280.0f,
                  @"containerOriginX" : @50.0f };
    
    NSString *visualFormatString = @"V:|-originYAxis-[retry(buttonHeight)]-inset-[map(==retry)]-40-[container(containerHeight)]";
    NSArray *verticalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:visualFormatString
                                                                          options:0
                                                                          metrics:_metrics
                                                                            views:_views];
    [self.view addConstraints:verticalConstraint];
    
    NSArray *horizontalMapConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[map(buttonWidth)]"
                                                                               options:0
                                                                               metrics:_metrics
                                                                                 views:_views];
    [self.view addConstraints:horizontalMapConstraint];
    
    NSArray *horizontalRetryConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[retry(==map)]"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
    [self.view addConstraints:horizontalRetryConstraint];
    
    NSArray *horizontalContainerConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[container(==map)]"
                                                                                     options:0
                                                                                     metrics:_metrics
                                                                                       views:_views];
    [self.view addConstraints:horizontalContainerConstraint];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
