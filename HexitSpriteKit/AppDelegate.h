//
//  AppDelegate.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GameKit;
@import AVFoundation;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
- (void)presentGameCenterControllerForState:(GKGameCenterViewControllerState)state;
- (void)presentShareViewController;
- (void)beginGameWithLevel:(NSInteger)level;
- (void)presentContainerViewController;
- (void)rateHEXUS;

- (IBAction)restartCurrentLevel:(id)sender;
- (IBAction)popToRootViewController:(id)sender;
- (IBAction)animateToLevelViewController:(id)sender;
- (IBAction)openAcheivementsController:(id)sender;

@end

