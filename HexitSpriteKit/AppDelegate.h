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
@property (nonatomic, getter=isPlayingLoop, assign) BOOL playLoop;

- (void)presentGameCenterControllerForState:(GKGameCenterViewControllerState)state;

- (void)presentShareViewController;

//- (void)navigateToRandomlyGeneratedLevel;

- (void)navigateToNewLevel:(NSInteger)level;

- (void)presentContainerViewController;

- (void)navigateToLevelController;

- (void)restartCurrentLevel;

- (void)rateHEXUS;

@end

