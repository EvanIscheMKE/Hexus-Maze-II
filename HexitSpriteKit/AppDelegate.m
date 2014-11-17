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
#import "HDRearViewController.h"
#import "HDContainerViewController.h"
#import "HDLevelViewController.h"

@interface AppDelegate ()<HDRearViewControllerDelegate, HDContainerViewControllerDelegate>
@property (nonatomic, strong) HDContainerViewController *containerController;
@property (nonatomic, strong) HDRearViewController *rearViewController;
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
    HDLevelViewController *level = [[HDLevelViewController alloc] init];
    
    self.rearViewController = [[HDRearViewController alloc] init];
    [self.rearViewController setDelegate:self];
    
     self.containerController = [[HDContainerViewController alloc] initWithGameViewController:level
                                                                           rearViewController:self.rearViewController];
    [self.containerController setDelegate:self];
    
    [self.window.rootViewController presentViewController:self.containerController animated:YES completion:nil];
}

- (void)restartCurrentLevel
{
    [self.containerController _toggleHDMenuViewController];
   // [self navigateToNewLevel:_deltaLevel];
}

- (void)navigateToLevelMap
{
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
        [[NSUserDefaults standardUserDefaults] setFloat:0   forKey:HDRemainingTime];
        [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:HDRemainingLivesKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:hdSoundkey];
        [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:hdFirstRunKey];
        [[HDMapManager sharedManager] initalizeLevelsForFirstRun];
    }
}

#pragma mark -
#pragma mark - <HDRearViewControllerDelegate>

- (void)layoutToggleSwitchesForSettingsFromArray:(NSArray *)array
{
    if (array) {
        [array[0] addTarget:self action:@selector(toggleEffects:)   forControlEvents:UIControlEventTouchUpInside];
        [array[1] addTarget:self action:@selector(toggleSound:)     forControlEvents:UIControlEventTouchUpInside];
        [array[2] addTarget:self action:@selector(toggleVibration:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark -
#pragma mark - <HDContainerViewControllerDelegate>

- (void)container:(HDContainerViewController *)container
       transitionedFromController:(UIViewController *)fromController
                     toController:(UIViewController *)toController
{
    NSLog(@"FROM: %@, TO: %@", NSStringFromClass([fromController class]), NSStringFromClass([toController class]));
    if ([fromController isKindOfClass:[HDLevelViewController class]] && [toController isKindOfClass:[HDGameViewController class]]) {
        [(HDRearViewController *)self.containerController.rearViewController showGameInterfaceAnimated:YES];
    } else if ([toController isKindOfClass:[HDLevelViewController class]] && [fromController isKindOfClass:[HDGameViewController class]]) {
        [(HDRearViewController *)self.containerController.rearViewController hideGameInterfaceAnimated:YES];
    }
}

@end
