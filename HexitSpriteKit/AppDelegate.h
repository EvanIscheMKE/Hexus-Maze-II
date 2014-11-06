//
//  AppDelegate.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UINavigationController *controller;
@property (strong, nonatomic) UIWindow *window;

- (void)openLevelViewController;
- (void)openLevel:(NSInteger)level animated:(BOOL)animated;

@end

