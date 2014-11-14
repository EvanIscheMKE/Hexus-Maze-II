//
//  HDBackViewController.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/13/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDSettingsContainer : UIView
@property (nonatomic, readonly, strong) NSArray *settingButtons;
@end

@interface HDBackViewController : UIViewController

@property (nonatomic, strong) HDSettingsContainer *container;

- (void)hideGameInterfaceAnimated:(BOOL)animated;
- (void)showGameInterfaceAnimated:(BOOL)animated;

@end
