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

@protocol HDRearViewControllerDelegate;
@interface HDRearViewController : UIViewController

@property (nonatomic, strong) HDSettingsContainer *container;
@property (nonatomic, weak) id<HDRearViewControllerDelegate> delegate;

- (void)hideGameInterfaceAnimated:(BOOL)animated;
- (void)showGameInterfaceAnimated:(BOOL)animated;

@end

@protocol HDRearViewControllerDelegate <NSObject>
@optional
- (void)layoutToggleSwitchesForSettingsFromArray:(NSArray *)array;
@end