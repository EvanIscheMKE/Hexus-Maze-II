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
    [self.view setBackgroundColor:[UIColor flatAsbestosColor]];
    
    [self _layoutTitle];
    [self _layoutSideMenu];
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
    
    NSArray *titleXAxis = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[title]"
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

- (UIView *)layoutContainerWithToggleSwitches
{
    CGRect containerBounds = CGRectMake(0.0f, 0.0f, MAX(kAnimationOffsetX,MINIMUM_MENU_OFFSET_X) - (2 * 20.0f), 200.0f);
    UIView *container = [[UIView alloc] initWithFrame:containerBounds];
    [container setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    HDSwitch *buttonOne = [[HDSwitch alloc] initWithOnColor:[UIColor flatEmeraldColor] offColor:[UIColor flatMidnightBlueColor]];
    [buttonOne setOn:[[HDSettingsManager sharedManager] sound]];
    [buttonOne setTag:0];
    
    HDSwitch *buttonTwo = [[HDSwitch alloc] initWithOnColor:[UIColor flatEmeraldColor]  offColor:[UIColor flatMidnightBlueColor]];
    [buttonTwo setOn:[[HDSettingsManager sharedManager] space]];
    [buttonTwo setTag:1];
    
    HDSwitch *buttonThree = [[HDSwitch alloc] initWithOnColor:[UIColor flatEmeraldColor] offColor:[UIColor flatMidnightBlueColor]];
    [buttonThree setOn:[[HDSettingsManager sharedManager] sound]];
    [buttonThree setTag:2];
    
    HDSwitch *buttonFour = [[HDSwitch alloc] initWithOnColor:[UIColor flatEmeraldColor] offColor:[UIColor flatMidnightBlueColor]];
    [buttonFour setOn:[[HDSettingsManager sharedManager] sound]];
    [buttonFour setTag:3];
    
    UILabel *labelOne   = [[UILabel alloc] init];
    [labelOne setText:@"Sound"];
    
    UILabel *labelTwo   = [[UILabel alloc] init];
    [labelTwo setText:@"Music"];
    
    UILabel *labelThree = [[UILabel alloc] init];
    [labelThree setText:@"FX"];
    
    UILabel *labelFour = [[UILabel alloc] init];
    [labelFour setText:@"Guides"];
    
    for (UILabel *label in @[labelOne, labelTwo, labelThree, labelFour]) {
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:GILLSANS_LIGHT(14.0f)];
        [container addSubview:label];
    }
    
    for (UIButton *toggleButton in @[buttonOne, buttonTwo, buttonThree, buttonFour]) {
        [toggleButton addTarget:self action:@selector(updateToggleButtonAtTag:) forControlEvents:UIControlEventValueChanged];
        [toggleButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.arrayOfButtons addObject:toggleButton];
        [container addSubview:toggleButton];
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(buttonOne,
                                                         buttonTwo,
                                                         buttonThree,
                                                         buttonFour,
                                                         labelOne,
                                                         labelTwo,
                                                         labelThree,
                                                         labelFour);
    
    NSDictionary *metrics = @{ @"space"       : @(4.0f),
                               @"buttonHeight": @(35.0f),
                               @"labelHeight" : @(16.0f),
                               @"margin"      : @(20.0f),
                               @"inset"       : @(10.0f),
                               @"buttonWidth" : @(75.0f) };
    
    
    NSArray *verticalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:
                        @"V:|-0-[buttonOne(buttonHeight)]-0-[labelOne(labelHeight)]-30-[buttonThree(buttonHeight)]-0-[labelThree(labelHeight)]"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    
    NSArray *vertical2Constraint = [NSLayoutConstraint constraintsWithVisualFormat:
                        @"V:|-0-[buttonTwo(buttonHeight)]-0-[labelTwo(labelHeight)]-30-[buttonFour(buttonHeight)]-0-[labelFour(labelHeight)]"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:views];
    
    NSArray *horizontal1Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[buttonOne(buttonWidth)]"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    
    NSArray *horizontal2Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[buttonTwo(buttonWidth)]-inset-|"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    
    NSArray *horizontal3Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[buttonThree(buttonWidth)]"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    
    NSArray *horizontal31Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[buttonFour(buttonWidth)]-inset-|"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:views];
    
    NSArray *horizontal4Spacing  = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[labelOne(buttonWidth)]"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:views];
    
    NSArray *horizontal5Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[labelTwo(buttonWidth)]-inset-|"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    
    NSArray *horizontal6Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[labelThree(buttonWidth)]"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    
    NSArray *horizontal9Spacing = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[labelFour(buttonWidth)]-inset-|"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
    
    for (NSArray *constraint in @[verticalConstraint,
                                  vertical2Constraint,
                                  horizontal1Spacing,
                                  horizontal2Spacing,
                                  horizontal3Spacing,
                                  horizontal31Spacing,
                                  horizontal4Spacing,
                                  horizontal5Spacing,
                                  horizontal6Spacing,
                                  horizontal9Spacing]) {
        [container addConstraints:constraint];
    }
    return container;
}

- (void)_layoutSideMenu
{
    UIView *container = [self layoutContainerWithToggleSwitches];
    [self.view addSubview:container];
    
    self.retry = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.retry setTitle:@"Achievements" forState:UIControlStateNormal];
    [self.retry setBackgroundColor:[UIColor flatMidnightBlueColor]];
    [self.retry addTarget:self action:@selector(openAcheivementsController:) forControlEvents:UIControlEventTouchUpInside];
    
    self.map = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.map setBackgroundColor:[UIColor flatEmeraldColor]];
    [self.map setTitle:@"Main Menu" forState:UIControlStateNormal];
    [self.map addTarget:self action:@selector(popToRootViewController:) forControlEvents:UIControlEventTouchUpInside];
    
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
                  @"originYAxis"      : @130.0f,
                  @"containerHeight"  : @280.0f,
                  @"containerOriginX" : @50.0f };
    
    NSArray *verticalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:
                                   @"V:|-originYAxis-[retry(buttonHeight)]-inset-[map(==retry)]-50-[container(containerHeight)]"
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
    
    NSArray *hCConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[container(==map)]"
                                                                    options:0
                                                                    metrics:_metrics
                                                                      views:_views];
    
    for (NSArray *constraint in @[verticalConstraint, hMConstraint, hRConstraint, hCConstraint]) {
        [self.view addConstraints:constraint];
    }
}

- (IBAction)openAcheivementsController:(id)sender
{
    [[HDSoundManager sharedManager] playSound:@"menuClicked.wav"];
    
    HDContainerViewController *container = self.containerViewController;
    [container toggleHDMenuViewController];
    [ADelegate openAchievementsViewController];
}

- (IBAction)popToRootViewController:(id)sender
{
    [[HDSoundManager sharedManager] playSound:@"menuClicked.wav"];
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)updateToggleButtonAtTag:(id)sender
{
    HDSwitch *toggle = (HDSwitch *)sender;
    
    switch (toggle.tag) {
        case 0:
            [[HDSettingsManager sharedManager] toggleSound];
            break;
        case 1:
            [[HDSettingsManager sharedManager] toggleVibration];
            break;
        case 2:
            [[HDSettingsManager sharedManager] toggleSpace];
            break;
        case 3:
            [[HDSettingsManager sharedManager] toggleGuide];
            break;
        default:
            NSAssert(NO, @"TagIndex is outside of 0-3 %@",NSStringFromSelector(_cmd));
            break;
    }
}

- (void)hideGameInterface
{
    [self.retry setTitle:@"Achievements" forState:UIControlStateNormal];
    [self.map   setTitle:@"Main Menu" forState:UIControlStateNormal];
    
    [self.retry removeTarget:ADelegate action:@selector(restartCurrentLevel) forControlEvents:UIControlEventTouchUpInside];
    [self.map   removeTarget:ADelegate action:@selector(navigateToLevelMap)  forControlEvents:UIControlEventTouchUpInside];
    
    [self.retry addTarget:self action:@selector(openAcheivementsController:) forControlEvents:UIControlEventTouchUpInside];
    [self.map   addTarget:self action:@selector(popToRootViewController:)    forControlEvents:UIControlEventTouchUpInside];
}

- (void)showGameInterface
{
    [self.retry setTitle:@"Restart" forState:UIControlStateNormal];
    [self.map   setTitle:@"Back to Map" forState:UIControlStateNormal];
    
    [self.retry addTarget:ADelegate action:@selector(restartCurrentLevel) forControlEvents:UIControlEventTouchUpInside];
    [self.map   addTarget:ADelegate action:@selector(navigateToLevelMap)  forControlEvents:UIControlEventTouchUpInside];
    
    [self.retry removeTarget:self action:@selector(openAcheivementsController:) forControlEvents:UIControlEventTouchUpInside];
    [self.map   removeTarget:self action:@selector(popToRootViewController:)    forControlEvents:UIControlEventTouchUpInside];
}

@end
