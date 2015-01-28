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
#import "HDHelper.h"

@interface HDRearViewController ()
@property (nonatomic, strong) UIButton *retry;
@property (nonatomic, strong) UIButton *map;
@end

@implementation HDRearViewController {
    NSDictionary *_views;
    NSDictionary *_metrics;
    NSArray *_switches;
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor flatMidnightBlueColor];
    [super viewDidLoad];
    [self _setup];
}

#pragma mark - Public

- (void)setGameInterfaceHidden:(BOOL)gameInterfaceHidden
{
    _gameInterfaceHidden = gameInterfaceHidden;
    
    if (gameInterfaceHidden) {
        [self _hideGameInterface];
    } else {
        [self _showGameInterface];
    }
}

- (IBAction)updateToggleAtTag:(id)sender
{
    HDSwitch *toggle = (HDSwitch *)sender;
    
    HDSettingsManager *manager = [HDSettingsManager sharedManager];
    
    switch (toggle.tag) {
        case 0:
            [manager setSound:!manager.sound];
            [[HDSoundManager sharedManager] playSound:HDButtonSound];
            break;
        case 1:
            [manager setMusic:!manager.music];
            [[HDSoundManager sharedManager] setPlayLoop:manager.music];
            [[HDSoundManager sharedManager] playSound:HDButtonSound];
            break;
    }
}

#pragma mark - Private

- (void)_hideGameInterface
{
    [self.retry setTitle:@"Achievements" forState:UIControlStateNormal];
    [self.map   setTitle:@"Main Menu"    forState:UIControlStateNormal];
    
    [self.retry removeTarget:ADelegate action:@selector(restartCurrentLevel:)           forControlEvents:UIControlEventTouchUpInside];
    [self.map   removeTarget:ADelegate action:@selector(animateToLevelViewController:)  forControlEvents:UIControlEventTouchUpInside];
    
    [self.retry addTarget:ADelegate action:@selector(openAcheivementsController:) forControlEvents:UIControlEventTouchUpInside];
    [self.map   addTarget:ADelegate action:@selector(popToRootViewController:)    forControlEvents:UIControlEventTouchUpInside];
}

- (void)_showGameInterface
{
    [self.retry setTitle:@"Restart"     forState:UIControlStateNormal];
    [self.map   setTitle:@"Back to Map" forState:UIControlStateNormal];
    
    [self.retry removeTarget:ADelegate action:@selector(openAcheivementsController:) forControlEvents:UIControlEventTouchUpInside];
    [self.map   removeTarget:ADelegate action:@selector(popToRootViewController:)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.retry addTarget:ADelegate action:@selector(restartCurrentLevel:)           forControlEvents:UIControlEventTouchUpInside];
    [self.map   addTarget:ADelegate action:@selector(animateToLevelViewController:)  forControlEvents:UIControlEventTouchUpInside];
}

- (void)_setup
{
    CGRect containerBounds = CGRectMake(0.0f, 0.0f, [HDHelper sideMenuOffsetX], CGRectGetHeight(self.view.bounds));
    UIView *container = [[UIView alloc] initWithFrame:containerBounds];
    container.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:container];
    
    self.retry = [UIButton buttonWithType:UIButtonTypeCustom];
    self.retry.backgroundColor = [UIColor flatWetAsphaltColor];
    [self.retry setTitle:@"Achievements" forState:UIControlStateNormal];
    [self.retry addTarget:ADelegate action:@selector(openAcheivementsController:) forControlEvents:UIControlEventTouchUpInside];
    
    self.map = [UIButton buttonWithType:UIButtonTypeCustom];
    self.map.backgroundColor = [UIColor flatPeterRiverColor];
    [self.map setTitle:@"Main Menu" forState:UIControlStateNormal];
    [self.map addTarget:ADelegate action:@selector(popToRootViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *button in @[self.retry, self.map]) {
        button.adjustsImageWhenDisabled    = NO;
        button.adjustsImageWhenHighlighted = NO;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.titleLabel.font          = GILLSANS_LIGHT(20.0f);
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.layer.cornerRadius       = 20.0f;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [container addSubview:button];
    }
    
    NSMutableArray *switches = [NSMutableArray array];
    NSMutableArray *labels   = [NSMutableArray array];
    
    for (int i = 0; i < 2; i++) {
        HDSwitch *toggle = [[HDSwitch alloc] initWithOnColor:[UIColor flatPeterRiverColor]
                                                    offColor:[UIColor flatWetAsphaltColor]];
        toggle.tag = i;
        toggle.translatesAutoresizingMaskIntoConstraints = NO;
        [toggle addTarget:self action:@selector(updateToggleAtTag:) forControlEvents:UIControlEventValueChanged];
        [switches addObject:toggle];
        [container addSubview:toggle];
        
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.textColor     = [UIColor flatWetAsphaltColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font          = GILLSANS_LIGHT(14.0f);
        [labels addObject:label];
        [container addSubview:label];
        
        switch (i) {
            case 0:
                toggle.on = [[HDSettingsManager sharedManager] sound];
                label.text = @"Sound";
                break;
            case 1:
                toggle.on = [[HDSettingsManager sharedManager] music];
                label.text = @"Music";
                break;
        }
    }
    
    UILabel *soundLabel     = labels[0];
    UILabel *musicLabel     = labels[1];
    
    HDSwitch *soundSwitch     = switches[0];
    HDSwitch *musicSwitch     = switches[1];
    
    UIButton *retryButton = self.retry;
    UIButton *mapButton   = self.map;
    
    _views = NSDictionaryOfVariableBindings(soundLabel,  musicLabel, soundSwitch, musicSwitch, retryButton, mapButton);

    _metrics = @{ @"buttonInsetY" : @(CGRectGetHeight(self.view.bounds)/4),
                  @"buttonHeight" : @(50.0f),
                  @"switchHeight" : @(40.0f),
                  @"labelHeight"  : @(16.0f),
                  @"margin"       : @(20.0f),
                  @"inset"        : @(30.0f)};
    
    NSString * const verButtonString = @"V:|-buttonInsetY-[retryButton(buttonHeight)]-10-[mapButton(buttonHeight)]";
    
    NSString * const verLeftString   = @"V:[mapButton]-70-[soundSwitch(switchHeight)][soundLabel(labelHeight)]";
    
    NSString * const verRightString  = @"V:[mapButton]-70-[musicSwitch(switchHeight)][musicLabel(labelHeight)]";
    
    // Vertical Constraints
    NSArray *verButtonConstraint = [NSLayoutConstraint constraintsWithVisualFormat:verButtonString
                                                                           options:0
                                                                           metrics:_metrics
                                                                             views:_views];
    [container addConstraints:verButtonConstraint];
    
    NSArray *vertSoundVibeConstr = [NSLayoutConstraint constraintsWithVisualFormat:verLeftString
                                                                           options:0
                                                                           metrics:_metrics
                                                                             views:_views];
    [container addConstraints:vertSoundVibeConstr];
    
    NSArray *vertMusicFxConstrai = [NSLayoutConstraint constraintsWithVisualFormat:verRightString
                                                                           options:0
                                                                           metrics:_metrics
                                                                             views:_views];
    [container addConstraints:vertMusicFxConstrai];
    
    // Horizontal Constraints
    NSArray *horiRetryConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[retryButton]-40-|"
                                                                           options:0
                                                                           metrics:_metrics
                                                                             views:_views];
    [container addConstraints:horiRetryConstraint];
    
    NSArray *horizoMapConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[mapButton]-40-|"
                                                                           options:0
                                                                           metrics:_metrics
                                                                             views:_views];
    [container addConstraints:horizoMapConstraint];
    
    NSArray *horiSoundConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[soundSwitch(80.0)]"
                                                                          options:0
                                                                          metrics:_metrics
                                                                            views:_views];
    [container addConstraints:horiSoundConstraint];
    
    NSArray *horiSoundLConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[soundLabel(80.0)]"
                                                                           options:0
                                                                           metrics:_metrics
                                                                             views:_views];
    [container addConstraints:horiSoundLConstraint];
    
    NSArray *horiMusicConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[musicSwitch(80.0)]-50-|"
                                                                           options:0
                                                                           metrics:_metrics
                                                                             views:_views];
    [container addConstraints:horiMusicConstraint];
    
    NSArray *horiMusicLConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[musicLabel(80.0)]-50-|"
                                                                            options:0
                                                                            metrics:_metrics
                                                                              views:_views];
    [container addConstraints:horiMusicLConstraint];
    
}

@end
