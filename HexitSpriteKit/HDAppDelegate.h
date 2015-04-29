//
//  AppDelegate.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GameKit;

@interface HDAppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
+ (HDAppDelegate *)sharedDelegate;
- (void)presentGameCenterControllerForState:(GKGameCenterViewControllerState)state;
- (void)presentTutorialViewControllerForFirstRun;
- (void)presentActivityViewController;
- (void)presentLevelViewController;
- (void)beginGameWithLevel:(NSInteger)level;
- (void)rateHEXUS;
- (IBAction)openAcheivementsController:(id)sender;
- (IBAction)openLeaderboardController:(id)sender;
- (IBAction)animateToLevelViewController:(id)sender;
- (IBAction)restartCurrentLevel:(id)sender;
- (IBAction)removeBanners:(id)sender;
- (IBAction)restoreIAP:(id)sender;
@end

