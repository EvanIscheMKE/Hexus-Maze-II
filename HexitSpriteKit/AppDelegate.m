//
//  AppDelegate.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "AppDelegate.h"
#import "HDMapManager.h"
#import "HDGameCenterManager.h"
#import "HDGameViewController.h"
#import "HDWelcomeViewController.h"
#import "HDBackViewController.h"
#import "HDContainerViewController.h"
#import "HDLevelViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) HDContainerViewController *containerController;
@end

@implementation AppDelegate {
    NSInteger _deltaLevel;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self _initalizeModelData];
    [application setStatusBarHidden:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:[HDWelcomeViewController new]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)presentLevelViewController
{
    HDGameViewController *game = [[HDGameViewController alloc] init];
    HDBackViewController *rear = [[HDBackViewController alloc] init];
    
    self.containerController = [[HDContainerViewController alloc] initWithGameViewController:game
                                                                          rearViewController:rear];
    [self.window.rootViewController presentViewController:self.containerController animated:YES completion:nil];
    
//    NSArray *switches = menuController.toggleSwitchesForSettings;
//    
//    if (switches) {
//        [switches[0] addTarget:self action:@selector(toggleEffects:)   forControlEvents:UIControlEventTouchUpInside];
//        [switches[1] addTarget:self action:@selector(toggleSound:)     forControlEvents:UIControlEventTouchUpInside];
//        [switches[2] addTarget:self action:@selector(toggleVibration:) forControlEvents:UIControlEventTouchUpInside];
//    }
}

- (void)restartCurrentLevel
{
    [self navigateToNewLevel:_deltaLevel];
}

- (void)navigateToLevelMap
{
    [HDLevelViewController new];
    [self.containerController setFrontViewController:[HDLevelViewController new] animated:YES];
}

- (void)navigateToNewLevel:(NSInteger)level
{
    _deltaLevel = level;
    HDGameViewController *controller = [[HDGameViewController alloc] initWithLevel:level];
    [self.containerController setFrontViewController:controller animated:YES];
}

#pragma mark -
#pragma mark - Switches

- (void)toggleSound:(id)sender
{
    UIButton *sound = (UIButton *)sender;
    [sound setSelected:!sound.selected];
    
    [[NSUserDefaults standardUserDefaults] setBool:![[NSUserDefaults standardUserDefaults] boolForKey:hdSoundkey] forKey:hdSoundkey];
}

- (void)toggleVibration:(id)sender
{
    UIButton *vibration = (UIButton *)sender;
    [vibration setSelected:!vibration.selected];
    
    [[NSUserDefaults standardUserDefaults] setBool:![[NSUserDefaults standardUserDefaults] boolForKey:hdVibrationKey] forKey:hdVibrationKey];
}

- (void)toggleEffects:(id)sender
{
    UIButton *effects = (UIButton *)sender;
    [effects setSelected:!effects.selected];
    
    [[NSUserDefaults standardUserDefaults] setBool:![[NSUserDefaults standardUserDefaults] boolForKey:hdEffectsKey] forKey:hdEffectsKey];
}

#pragma mark -
#pragma mark - Override Getters

- (BOOL)vibrationIsActive
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:hdVibrationKey];
}

- (BOOL)soundIsActive
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:hdSoundkey];
}

- (BOOL)effectsIfActive
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:hdEffectsKey];
}

#pragma mark - 
#pragma mark - <Private>

- (void)_initalizeModelData
{
    [[HDGameCenterManager sharedManager] authenticateForGameCenter];
    
    BOOL isFirstRun = [[NSUserDefaults standardUserDefaults] boolForKey:hdFirstRunKey];
    
    if (!isFirstRun) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:hdSoundkey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:hdFirstRunKey];
        [[HDMapManager sharedManager] initalizeLevelsForFirstRun];
    }
}

@end
