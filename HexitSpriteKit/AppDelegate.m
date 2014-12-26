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
#import "HDWelcomeViewController.h"
#import "HDRearViewController.h"
#import "HDContainerViewController.h"

#define HEXUS_ID 898568105
NSString * const iOS8AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%d";

NSString * const HDLeaderBoardIdentifierKey = @"LevelLeaderboard";

@interface AppDelegate ()<HDContainerViewControllerDelegate, GKGameCenterControllerDelegate>
@property (nonatomic, strong) HDContainerViewController *containerController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:YES];
    [self _setup];
    
     self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:[HDWelcomeViewController new]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)_setup
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HDFirstRunKey]) {
        [[HDSettingsManager sharedManager] configureSettingsForFirstRun];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HDFirstRunKey];
    }
    
    [[HDSoundManager sharedManager] startAudio];
    [[HDSoundManager sharedManager] preloadLoopWithName:HDSoundLoopKey];
    [[HDSoundManager sharedManager] preloadSounds:SOUNDS_TO_PRELOAD];
    [[HDSoundManager sharedManager] setPlayLoop:YES];
    
    [[HDGameCenterManager sharedManager] authenticateGameCenter];
}

- (void)presentContainerViewController
{
    HDRearViewController *rearViewController  = [[HDRearViewController alloc] init];
    HDGridViewController *frontViewController = [[HDGridViewController alloc] init];
    self.containerController = [[HDContainerViewController alloc] initWithFrontViewController:frontViewController
                                                                          rearViewController:rearViewController];
    self.containerController.delegate = self;
    
    [self.window.rootViewController presentViewController:self.containerController animated:NO completion:nil];
}

- (void)presentGameCenterControllerForState:(GKGameCenterViewControllerState)state
{
    GKGameCenterViewController *controller = [[GKGameCenterViewController alloc] init];
    controller.gameCenterDelegate = self;
    controller.leaderboardIdentifier = HDLeaderBoardIdentifierKey;
    controller.viewState = state;
    [self.containerController presentViewController:controller animated:YES completion:nil];
}

- (void)beginGameWithLevel:(NSInteger)level
{
    HDGameViewController *controller = [[HDGameViewController alloc] initWithLevel:level];
    [self.containerController setFrontViewController:controller animated:NO];
}

- (IBAction)restartCurrentLevel:(id)sender
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    if (self.containerController.isExpanded) {
        [self.containerController toggleMenuViewControllerWithCompletion:^{
             [(HDGameViewController *)self.containerController.frontViewController restartGame];
        }];
    }
}

- (IBAction)popToRootViewController:(id)sender
{
    if (self.containerController.isExpanded) {
        [self.containerController toggleMenuViewControllerWithCompletion:^{
            if ([[self.containerController.childViewControllers lastObject] isKindOfClass:[HDGridViewController class]]) {
                HDGridViewController *controller = (HDGridViewController *)[self.containerController.childViewControllers lastObject];
                [controller performExitAnimationWithCompletion:^{
                    [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                }];
            }
        }];
    }
}

- (IBAction)animateToLevelViewController:(id)sender
{
    if (self.containerController.isExpanded) {
        [self.containerController toggleMenuViewControllerWithCompletion:^{
            if ([[self.containerController.childViewControllers lastObject] isKindOfClass:[HDGameViewController class]]) {
                HDGameViewController *controller = (HDGameViewController *)[self.containerController.childViewControllers lastObject];
                [controller performExitAnimationWithCompletion:^{
                     [self.containerController setFrontViewController:[[HDGridViewController alloc] init] animated:NO];
                }];
            }
        }];
    }
}

- (IBAction)openAcheivementsController:(id)sender
{
    if (self.containerController.isExpanded) {
        [self.containerController toggleMenuViewControllerWithCompletion:^{
            [self presentGameCenterControllerForState:GKGameCenterViewControllerStateAchievements];
        }];
    }
}

- (void)rateHEXUS
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:iOS8AppStoreURLFormat]]) {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iOS8AppStoreURLFormat]];
    }
}

- (void)presentShareViewController
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    
    NSArray *activityItems = @[@"HELLO", [self _screenshotOfFrontViewController]];
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
    
    [self.containerController presentViewController:controller animated:YES completion:nil];
}

- (UIImage *)_screenshotOfFrontViewController
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, [[UIScreen mainScreen] scale]);
    
    [self.containerController.frontViewController.view drawViewHierarchyInRect:bounds afterScreenUpdates:YES];
    
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenShot;
}

#pragma mark - <GKGameCenterControllerDelegate>

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self.containerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <HDContainerViewControllerDelegate>

- (void)container:(HDContainerViewController *)container willChangeExpandedState:(BOOL)expanded
{
    if (expanded) {
        if ([container.frontViewController isKindOfClass:[HDGameViewController class]]) {
            [[(SKView *)container.frontViewController.view scene] setPaused:YES];
        } else {
            for (id subView in container.frontViewController.view.subviews) {
                if ([subView isKindOfClass:[UIScrollView class]]) {
                    [subView setUserInteractionEnabled:NO];
                    break;
                }
            }
        }
    } else {
        if ([container.frontViewController isKindOfClass:[HDGameViewController class]]) {
            [[(SKView *)container.frontViewController.view scene] setPaused:NO];
        } else {
            for (id subView in container.frontViewController.view.subviews) {
                if ([subView isKindOfClass:[UIScrollView class]]) {
                    [subView setUserInteractionEnabled:YES];
                    break;
                }
            }
        }
    }
}

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
