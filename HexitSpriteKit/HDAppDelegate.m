//
//  AppDelegate.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import Security;
@import SpriteKit;
@import MobileCoreServices;

#define HEXUS_ID 992217673

#import "Flurry.h"
#import "HDTextureManager.h"
#import "HDIAPView.h"
#import "HDHexaButton.h"
#import "HDAppDelegate.h"
#import "HDMapManager.h"
#import "HDSoundManager.h"
#import "HDSettingsManager.h"
#import "HDTileManager.h"
#import "HDGameCenterManager.h"
#import "HDHexusIAdHelper.h"
#import "HDGameViewController.h"
#import "HDGridViewController.h"
#import "HDIntroViewController.h"
#import "HDContainerViewController.h"
#import "HDTutorialViewController.h"
#import "HDRearViewController.h"

NSString * const HDFLURRYAPIKEY = @"B3JYMFF9NC3R57HX825G";
NSString * const iOS8AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%d";
NSString * const HDLeaderBoardIdentifierKey = @"LeaderboardID";
@interface HDAppDelegate ()<GKGameCenterControllerDelegate, HDContainerViewControllerDelegate>
@property (nonatomic, strong) HDContainerViewController *controller;
@property (nonatomic, strong) HDRearViewController *rearController;
@end

@implementation HDAppDelegate

+ (HDAppDelegate *)sharedDelegate {
    return (HDAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.statusBarHidden = YES;
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        application.applicationIconBadgeNumber = 0;
    }
    
    /* Cancel all scheduled notification, */
    [application cancelAllLocalNotifications];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [HDIntroViewController new];
    [self.window makeKeyAndVisible];

    // Register for analytics
    [Flurry startSession:HDFLURRYAPIKEY];
    
    // first time app runs, set up settings configuration
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HDFirstRunKey]) {
        [[HDSettingsManager sharedManager] configureSettingsForFirstRun];
    }
    
    // Preload Game Textures
    [[HDTextureManager sharedManager] preloadTexturesWithCompletion:nil];
    
    // Setup AVAudioPlayer
    [[HDSoundManager sharedManager] startAudio];
    [[HDSoundManager sharedManager] preloadLoopWithName:HDSoundLoopKey];
    [[HDSoundManager sharedManager] preloadSounds:PRELOAD_THESE_SOUNDS];
    [[HDSoundManager sharedManager] setPlayLoop:YES];
    
    return YES;
}

- (void)_scheduleLocalNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 96]; //seconds per minunte * Minutes in hour * hours in 3 days
    localNotification.alertBody = (arc4random() % 2 == 0) ? @"We miss you! Come and play!" : @"Bored? Come and play!";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark - Public

- (IBAction)presentLevelViewController:(id)sender
{
    self.controller = [[HDContainerViewController alloc] initWithFrontViewController:[HDGridViewController new]
                                                                  rearViewController:[HDRearViewController new]];
    self.controller.delegate = self;
    [self.window.rootViewController presentViewController:self.controller animated:NO completion:nil];
    [[HDGameCenterManager sharedManager] authenticateGameCenter];
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
}

- (void)presentGameCenterControllerForState:(GKGameCenterViewControllerState)state {
    
    GKGameCenterViewController *controller = [[GKGameCenterViewController alloc] init];
    controller.gameCenterDelegate = self;
    controller.leaderboardIdentifier = HDLeaderBoardIdentifierKey;
    controller.viewState = state;
    [self.controller presentViewController:controller animated:YES completion:nil];
}

- (void)rate
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    NSURL *rateMe = [NSURL URLWithString:[NSString stringWithFormat:iOS8AppStoreURLFormat,HEXUS_ID]];
    if ([[UIApplication sharedApplication] canOpenURL:rateMe]) {
        [[UIApplication sharedApplication] openURL:rateMe];
    }
}

- (void)presentActivityViewController
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    NSArray *activityItems = @[[self _screenshotOfFrontViewController]];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                     applicationActivities:@[]];
    activityController.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                         UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToTencentWeibo,
                                         UIActivityTypeAirDrop];
    
    [self.controller presentViewController:activityController animated:YES completion:nil];
}

- (void)presentTutorialViewControllerForFirstRun
{
    [self.window.rootViewController presentViewController:[HDTutorialViewController new] animated:NO completion:nil];
}

- (void)beginGameWithLevel:(NSInteger)level
{
    HDGameViewController *gameController = [[HDGameViewController alloc] initWithLevel:level];
    [self.controller setFrontMostViewController:gameController];
}

#pragma mark - Private

- (UIImage *)_screenshotOfFrontViewController
{
    UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, YES, [[UIScreen mainScreen] scale]);
    [self.controller.view drawViewHierarchyInRect:self.window.bounds afterScreenUpdates:YES];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenShot;
}

- (void)_activityControllerForType:(GKGameCenterViewControllerState)state
{
    if (self.controller.isExpanded) {
        [self.controller toggleMenuViewControllerWithCompletion:^{
            [self presentGameCenterControllerForState:state];
        }];
    }
}

#pragma mark - <HDContainerViewControllerDelegate>

- (void)container:(HDContainerViewController *)container willChangeExpandedState:(BOOL)expanded
{
    if ([container.frontViewController isKindOfClass:[HDGameViewController class]]) {
        [[(SKView *)container.frontViewController.view scene] setPaused:expanded ? YES : NO];
        
        HDGameViewController *viewController = (HDGameViewController *)container.frontViewController;
        if (!viewController.pauseGame && expanded) {
            viewController.pauseGame = YES;
        } else if (viewController.pauseGame && !expanded) {
            viewController.pauseGame = NO;
        }
    } else {
        for (id subView in container.frontViewController.view.subviews) {
            if ([subView isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)subView;
                
                for (UIView *view in scrollView.subviews) {
                    for (UIView *page in view.subviews) {
                        for (HDHexaButton *hexaBtn in page.subviews) {
                            hexaBtn.selected = expanded;
                        }
                    }
                }
                [subView setUserInteractionEnabled:expanded ? NO : YES];
                break;
            }
        }
    }
}

- (void)container:(HDContainerViewController *)container
transitionedFromController:(UIViewController *)fromController
     toController:(UIViewController *)toController
{
    if ([fromController isKindOfClass:[HDGridViewController class]] && [toController isKindOfClass:[HDGameViewController class]]) {
        [(HDRearViewController *)self.controller.rearViewController setGameInterfaceHidden:NO];
    } else if ([toController isKindOfClass:[HDGridViewController class]] && [fromController isKindOfClass:[HDGameViewController class]]) {
        [(HDRearViewController *)self.controller.rearViewController setGameInterfaceHidden:YES];
    }
}

#pragma mark - <GKGameCenterControllerDelegate>

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self.controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <UIApplicationDelegate>

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[HDSoundManager sharedManager] stopAudio];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[HDSoundManager sharedManager] startAudio];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
     [self _scheduleLocalNotification];
    [[HDSoundManager sharedManager] stopAudio];
}

#pragma mark - SEL

- (IBAction)restoreIAP:(id)sender
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    [[HDHexusIAdHelper sharedHelper] restoreCompletedTransactions];
}

- (IBAction)removeBanners:(id)sender
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    
    if (self.controller.isExpanded) {
        [self.controller toggleMenuViewControllerWithCompletion:^{
            NSString *message = NSLocalizedString(@"IAPremove", nil);
            HDIAPView *layover = [[HDIAPView alloc] initWithMessage:message];
            layover.completionBlock = ^{
                
                [[HDHexusIAdHelper sharedHelper] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
                    if (success && products.count) {
                        SKProduct *removeAdsProduct = nil;
                        for (SKProduct *product in products) {
                            if ([product.productIdentifier isEqualToString:IAPremoveAdsProductIdentifier]) {
                                removeAdsProduct = product;
                                break;
                            }
                        }
                        
                        if (!removeAdsProduct) {
                            return;
                        }
                        
                        BOOL purchased = [[HDHexusIAdHelper sharedHelper] productPurchased:removeAdsProduct.productIdentifier];
                        if (!purchased) {
                            [[HDHexusIAdHelper sharedHelper] buyProduct:removeAdsProduct];
                        }
                    }
                }];
            };
            [layover show];
        }];
    }
}

- (IBAction)restartCurrentLevel:(id)sender
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    if (self.controller.isExpanded) {
        [self.controller toggleMenuViewControllerWithCompletion:^{
            [(HDGameViewController *)self.controller.frontViewController restart:nil];
        }];
    }
}

- (IBAction)animateToLevelViewController:(id)sender
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    if (self.controller.isExpanded) {
        [self.controller toggleMenuViewControllerWithCompletion:^{
            if ([self.controller.frontViewController isKindOfClass:[HDGameViewController class]]) {
                HDGameViewController *controller = (HDGameViewController *)self.controller.frontViewController;
                [controller performExitAnimationWithCompletion:^{
                    [[HDTileManager sharedManager] clear];
                    [self.controller setFrontMostViewController:[HDGridViewController new]];
                }];
            }
        }];
    }
}

- (IBAction)openAcheivementsController:(id)sender
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    [self _activityControllerForType:GKGameCenterViewControllerStateAchievements];
}

- (IBAction)openLeaderboardController:(id)sender
{
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    [self _activityControllerForType:GKGameCenterViewControllerStateLeaderboards];
}


@end
