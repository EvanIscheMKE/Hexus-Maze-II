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
#import "HDGridViewController.h"
#import "HDWelcomeViewController.h"
#import "HDRearViewController.h"
#import "HDContainerViewController.h"

@interface AppDelegate ()<HDContainerViewControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) HDContainerViewController *containerController;
@property (nonatomic, strong) HDRearViewController *rearViewController;
@property (nonatomic, strong) HDGridViewController *frontViewController;
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
    self.frontViewController = [[HDGridViewController alloc] init];
    
    self.rearViewController  = [[HDRearViewController alloc] init];
    
    self.containerController = [[HDContainerViewController alloc] initWithGameViewController:self.frontViewController
                                                                          rearViewController:self.rearViewController];
    [self.containerController setDelegate:self];
    
    [self.window.rootViewController presentViewController:self.containerController animated:YES completion:nil];
}

- (void)navigateToLevelMap
{
    [self.containerController setFrontViewController:self.frontViewController animated:YES];
}

- (void)restartCurrentLevel
{
    [self navigateToNewLevel:_deltaLevel];
}

- (void)navigateToNewLevel:(NSInteger)level
{
    _deltaLevel = level;
    HDGameViewController *controller = [[HDGameViewController alloc] initWithLevel:level];
    [self.containerController setFrontViewController:controller animated:YES];
}

#pragma mark - 
#pragma mark - <Private>

- (HDGameViewController *)_gameViewController
{
    return (HDGameViewController *)self.containerController.gameViewController;
}

- (void)_initalizeModelData
{
    [[HDGameCenterManager sharedManager] authenticateForGameCenter];
    
    BOOL isFirstRun = [[NSUserDefaults standardUserDefaults] boolForKey:hdFirstRunKey];
    
    if (!isFirstRun) {
        [[NSUserDefaults standardUserDefaults] setFloat:1000   forKey:HDRemainingTime];
        [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:HDRemainingLivesKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:hdSoundkey];
        [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:hdFirstRunKey];
        [[HDMapManager sharedManager] initalizeLevelsForFirstRun];
    }
}

#pragma mark -
#pragma mark - <HDContainerViewControllerDelegate>

- (void)container:(HDContainerViewController *)container
       transitionedFromController:(UIViewController *)fromController
                     toController:(UIViewController *)toController
{
    NSLog(@"FROM: %@, TO: %@", NSStringFromClass([fromController class]), NSStringFromClass([toController class]));
    if ([fromController isKindOfClass:[HDGridViewController class]] && [toController isKindOfClass:[HDGameViewController class]]) {
        [(HDRearViewController *)self.containerController.rearViewController showGameInterfaceAnimated:YES];
    } else if ([toController isKindOfClass:[HDGridViewController class]] && [fromController isKindOfClass:[HDGameViewController class]]) {
        [(HDRearViewController *)self.containerController.rearViewController hideGameInterfaceAnimated:YES];
    }
}

@end
