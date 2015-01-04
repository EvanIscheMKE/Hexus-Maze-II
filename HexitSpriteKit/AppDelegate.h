//
//  AppDelegate.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GameKit;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
- (void)presentGameCenterControllerForState:(GKGameCenterViewControllerState)state;
- (void)presentShareViewControllerWithLevelIndex:(NSInteger)index;
- (void)presentGameControllerToPlayLevel:(NSInteger)level;
- (void)presentSettingsViewController;
- (void)presentLevelViewController;
- (void)rateHEXUS;

@end

