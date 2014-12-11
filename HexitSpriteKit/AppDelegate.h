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

- (void)openAchievementsViewController;
- (void)navigateToRandomlyGeneratedLevel;
- (void)navigateToNewLevel:(NSInteger)level;
- (void)presentLevelViewController;
- (void)navigateToLevelController;
- (void)restartCurrentLevel;

@end

