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
#import "HDMenuViewController.h"
#import "HDLevelViewController.h"

@interface AppDelegate ()

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
    UINavigationController *controller   = [[UINavigationController alloc] initWithRootViewController:[HDLevelViewController new]];
    [controller setNavigationBarHidden:YES];
    HDMenuViewController *menuController = [[HDMenuViewController alloc] initWithRootViewController:controller];
    [self.window.rootViewController presentViewController:menuController animated:YES completion:nil];
}

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
