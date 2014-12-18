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
#import "HDSettingsManager.h"
#import "HDGameCenterManager.h"
#import "HDGameViewController.h"
#import "HDGridViewController.h"
#import "HDWelcomeViewController.h"
#import "HDRearViewController.h"
#import "HDContainerViewController.h"

#define HEXUS_ID 898568105
NSString * const iOS8AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%d";

@interface AppDelegate ()<HDContainerViewControllerDelegate, GKGameCenterControllerDelegate>
@property (nonatomic, strong) HDContainerViewController *containerController;
@property (nonatomic, strong) AVAudioPlayer *loop;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:YES];
    
     self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:[HDWelcomeViewController new]];
    [self.window makeKeyAndVisible];
    
    [[HDSoundManager sharedManager] preloadSounds:SOUNDS_TO_PRELOAD];
    [[HDGameCenterManager sharedManager] authenticateGameCenter];
    [self _prepareSoundLoop];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HDFirstRunKey]) {
        [[HDMapManager sharedManager] configureDataBaseForFirstRun];
        [[HDSettingsManager sharedManager] configureSettingsForFirstRun];
    }
    
    return YES;
}

- (void)presentLevelViewController
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    
    HDRearViewController *rearViewController  = [[HDRearViewController alloc] init];
    HDGridViewController *frontViewController = [[HDGridViewController alloc] init];
    self.containerController = [[HDContainerViewController alloc] initWithGameViewController:frontViewController
                                                                          rearViewController:rearViewController];
    [self.containerController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self.containerController setDelegate:self];
    
    [self.window.rootViewController presentViewController:self.containerController animated:YES completion:nil];
}

- (void)presentGameCenterControllerForState:(GKGameCenterViewControllerState)state
{
    GKGameCenterViewController *controller = [[GKGameCenterViewController alloc] init];
    [controller setGameCenterDelegate:self];
    [controller setLeaderboardIdentifier:@""];
    [controller setViewState:state];
    [self.containerController presentViewController:controller animated:YES completion:nil];
}

- (void)navigateToLevelController
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    
    HDGridViewController *frontViewController = [[HDGridViewController alloc] init];
    [self.containerController setFrontViewController:frontViewController animated:YES];
}

- (void)restartCurrentLevel
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    [self.containerController toggleHDMenuViewController];
    [(HDGameViewController *)self.containerController.frontViewController restartGame];
}

- (void)navigateToNewLevel:(NSInteger)level
{
    HDGameViewController *controller = [[HDGameViewController alloc] initWithLevel:level];
    [self.containerController setFrontViewController:controller animated:YES];
}

//- (void)navigateToRandomlyGeneratedLevel
//{
//    HDGameViewController *controller = [[HDGameViewController alloc] initWithRandomlyGeneratedLevel];
//    [self.containerController setFrontViewController:controller animated:YES];
//}

- (void)_prepareSoundLoop
{
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Mellowtron" ofType:@"mp3"];
    self.loop = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:&error];
    [self.loop setNumberOfLoops:-1];
    [self.loop setVolume:.3f];
    [self.loop prepareToPlay];
    [self.loop play];
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

- (void)setPlayLoop:(BOOL)playLoop
{
    _playLoop = playLoop;
    
    if (playLoop) {
        [self.loop play];
    } else {
        [self.loop stop];
    }
}

- (void)rateHEXUS
{
    NSURL *url = [NSURL URLWithString:iOS8AppStoreURLFormat];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)presentShareViewController
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    
    NSArray *activityItems = @[@"HELLO", [self _screenshotOfFrontViewController]];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                             applicationActivities:nil];
    [controller setExcludedActivityTypes: @[UIActivityTypePostToWeibo,
                                            UIActivityTypePrint,
                                            UIActivityTypeCopyToPasteboard,
                                            UIActivityTypeAssignToContact,
                                            UIActivityTypeAddToReadingList,
                                            UIActivityTypePostToVimeo,
                                            UIActivityTypePostToTencentWeibo,
                                            UIActivityTypeAirDrop]];
    
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


@end
