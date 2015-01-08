//
//  AppDelegate.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "AppDelegate.h"
#import "HDMapManager.h"
#import "HDSoundManager.h"
#import "HDSettingsManager.h"
#import "HDGameCenterManager.h"
#import "HDGameViewController.h"
#import "HDGridViewController.h"
#import "HDSettingsViewController.h"
#import "HDWelcomeViewController.h"

#define HEXUS_ID 945933714
NSString * const iOS8AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%d";

NSString * const HDLeaderBoardIdentifierKey = @"LevelLeaderboard";

@interface AppDelegate ()<GKGameCenterControllerDelegate>
@property (nonatomic, strong) UINavigationController *controller;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.statusBarHidden = YES;
    
    self.controller = [[UINavigationController alloc] initWithRootViewController:[HDWelcomeViewController new]];
    self.controller.navigationBarHidden = YES;
    
     self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.controller;
    [self.window makeKeyAndVisible];
    
    [self _setup];
    
    return YES;
}

- (void)_setup
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HDFirstRunKey]) {
        [[HDSettingsManager sharedManager] configureSettingsForFirstRun];
    }
    
    [[HDSoundManager sharedManager] startAudio];
    [[HDSoundManager sharedManager] preloadLoopWithName:HDSoundLoopKey];
    [[HDSoundManager sharedManager] preloadSounds:SOUNDS_TO_PRELOAD];
    [[HDSoundManager sharedManager] setPlayLoop:YES];
    
    [[HDGameCenterManager sharedManager] authenticateGameCenter];
}

- (void)presentSettingsViewController
{
    [self.window.rootViewController presentViewController:[HDSettingsViewController new] animated:NO completion:nil];
}

- (void)presentLevelViewController
{
    [self.controller pushViewController:[HDGridViewController new] animated:NO];
}

- (void)presentGameCenterControllerForState:(GKGameCenterViewControllerState)state
{
    GKGameCenterViewController *controller = [[GKGameCenterViewController alloc] init];
    controller.gameCenterDelegate    = self;
    controller.leaderboardIdentifier = HDLeaderBoardIdentifierKey;
    controller.viewState             = state;
    [self.controller presentViewController:controller animated:YES completion:nil];
}

- (void)presentGameControllerToPlayLevel:(NSInteger)level
{
    HDGameViewController *controller = [[HDGameViewController alloc] initWithLevel:level];
    [self.controller pushViewController:controller animated:NO];
    
}

- (void)rateHEXUS
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:iOS8AppStoreURLFormat]]) {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iOS8AppStoreURLFormat]];
    }
}

- (void)presentShareViewControllerWithLevelIndex:(NSInteger)index
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    
    NSString *shareText = [NSString stringWithFormat:@"I just completed level %lu on Hexus",index];
    
    NSArray *activityItems = @[shareText, [self _screenshotOfFrontViewController]];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                             applicationActivities:nil];
    controller.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                         UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToTencentWeibo,
                                         UIActivityTypeAirDrop];
    
    [self.controller presentViewController:controller animated:YES completion:nil];
}

- (UIImage *)_screenshotOfFrontViewController
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, [[UIScreen mainScreen] scale]);
    
    [self.controller.view drawViewHierarchyInRect:bounds afterScreenUpdates:YES];
    
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenShot;
}

#pragma mark - <GKGameCenterControllerDelegate>

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self.controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <UIApplicationDelegate>

- (void)applicationWillResignActive:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[HDSoundManager sharedManager] stopAudio];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[HDSoundManager sharedManager] startAudio];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[HDSoundManager sharedManager] stopAudio];
}

@end
