//
//  AppDelegate.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "AppDelegate.h"
#import "HDMapManager.h"
#import "HDSoundManager.h"
#import "HDGameCenterManager.h"
#import "HDGameViewController.h"
#import "HDGridViewController.h"
#import "HDWelcomeViewController.h"
#import "HDRearViewController.h"
#import "HDContainerViewController.h"

@interface AppDelegate ()<HDContainerViewControllerDelegate, GKGameCenterControllerDelegate>
@property (nonatomic, strong) HDContainerViewController *containerController;
@property (nonatomic, strong) HDRearViewController *rearViewController;
@property (nonatomic, strong) HDGridViewController *frontViewController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:YES];
    
     self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:[HDWelcomeViewController new]];
    [self.window makeKeyAndVisible];
    
    [[HDSoundManager sharedManager] preloadSounds:SOUNDS_TO_PRELOAD];
    [[HDGameCenterManager sharedManager] authenticateForGameCenter];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HDFirstRunKey]) {
        [self _initalizeModelData];
    }
    
    return YES;
}

- (void)presentLevelViewController
{
    [[HDSoundManager sharedManager] playSound:@"menuClicked.wav"];
    
    self.frontViewController = [[HDGridViewController alloc] init];
    self.rearViewController  = [[HDRearViewController alloc] init];
    self.containerController = [[HDContainerViewController alloc] initWithGameViewController:self.frontViewController
                                                                          rearViewController:self.rearViewController];
    [self.containerController setDelegate:self];
    
    [self.window.rootViewController presentViewController:self.containerController animated:YES completion:nil];
}

- (void)openAchievementsViewController
{
    GKGameCenterViewController *controller = [[GKGameCenterViewController alloc] init];
    [controller setGameCenterDelegate:self];
    [controller setViewState:GKGameCenterViewControllerStateAchievements];
    [self.containerController presentViewController:controller animated:YES completion:nil];
}

- (void)navigateToLevelController
{
    [[HDSoundManager sharedManager] playSound:@"menuClicked.wav"];
    [self.containerController setFrontViewController:self.frontViewController animated:YES];
}

- (void)restartCurrentLevel
{
    [[HDSoundManager sharedManager] playSound:@"menuClicked.wav"];
    [self.containerController toggleHDMenuViewController];
    [(HDGameViewController *)self.containerController.frontViewController restartGame];
}

- (void)navigateToNewLevel:(NSInteger)level
{
    HDGameViewController *controller = [[HDGameViewController alloc] initWithLevel:level];
    [self.containerController setFrontViewController:controller animated:YES];
}

- (void)navigateToRandomlyGeneratedLevel
{
    HDGameViewController *controller = [[HDGameViewController alloc] initWithRandomlyGeneratedLevel];
    [self.containerController setFrontViewController:controller animated:YES];
}

#pragma mark - 
#pragma mark - <PRIVATE>

- (void)_initalizeModelData
{
    [[NSUserDefaults standardUserDefaults] setFloat:1000 forKey:HDRemainingTime];
    [[NSUserDefaults standardUserDefaults] setInteger:3  forKey:HDRemainingLivesKey];
    [[NSUserDefaults standardUserDefaults] setBool:YES   forKey:HDSoundkey];
    [[NSUserDefaults standardUserDefaults] setBool:YES   forKey:HDFirstRunKey];
    [[HDMapManager sharedManager] configureLevelDataForFirstRun];
}

#pragma mark -
#pragma mark - <GKGameCenterControllerDelegate>

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self.containerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - <HDContainerViewControllerDelegate>

- (void)container:(HDContainerViewController *)container
       transitionedFromController:(UIViewController *)fromController
                     toController:(UIViewController *)toController
{
    if ([fromController isKindOfClass:[HDGridViewController class]] && [toController isKindOfClass:[HDGameViewController class]]) {
        [(HDRearViewController *)self.containerController.rearViewController setGameInterfaceHidden:NO];
    } else if ([toController isKindOfClass:[HDGridViewController class]] && [fromController isKindOfClass:[HDGameViewController class]]) {
        [(HDRearViewController *)self.containerController.rearViewController setGameInterfaceHidden:YES];
    }
}

@end
