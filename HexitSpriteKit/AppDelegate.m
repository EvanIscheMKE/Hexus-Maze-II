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

@implementation AppDelegate{
    NSInteger _deltaLevel;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self _initalizeModelData];
    [application setStatusBarHidden:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.controller = [[UINavigationController alloc] initWithRootViewController:[HDWelcomeViewController new]];
    [self.controller setNavigationBarHidden:YES];
    [self.window setRootViewController:self.controller];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)openLevelViewController
{
    if (self.controller.visibleViewController != self.window.rootViewController) {
        [self.controller popToRootViewControllerAnimated:NO];
        [self.controller pushViewController:[HDLevelViewController new] animated:NO];
        return;
    }
    [self.controller pushViewController:[HDLevelViewController new] animated:YES];
}

- (void)openLevel:(NSInteger)level animated:(BOOL)animated
{
    if (_deltaLevel != level) {
        _deltaLevel = level;
    }
    
    HDGameViewController *gameController = [[HDGameViewController alloc] initWithLevel:_deltaLevel];
    HDMenuViewController *menuController = [[HDMenuViewController alloc] initWithRootViewController:gameController handler:^(NSArray *list) {
        [[list firstObject] addTarget:self action:@selector(restartCurrentLevel)     forControlEvents:UIControlEventTouchUpInside];
        [[list lastObject]  addTarget:self action:@selector(openLevelViewController) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    [self.controller pushViewController:menuController animated:animated];
}

- (void)restartCurrentLevel
{
    [self.controller popToRootViewControllerAnimated:NO];
    [self openLevel:_deltaLevel animated:NO];
}

- (void)_initalizeModelData
{
    [[HDGameCenterManager sharedManager] authenticateForGameCenter];
    
    BOOL isFirstRun = [[NSUserDefaults standardUserDefaults] boolForKey:hdFirstRunKey];
    
    if (!isFirstRun)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:hdSoundkey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:hdFirstRunKey];
        [[HDMapManager sharedManager] initalizeLevelsForFirstRun];
    }
}

@end
