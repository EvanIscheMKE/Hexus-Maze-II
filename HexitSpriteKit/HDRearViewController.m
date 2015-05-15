//
//  HDBackViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/13/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDContainerViewController.h"
#import "HDRearViewController.h"
#import "UIColor+ColorAdditions.h"
#import "HDSoundManager.h"
#import "HDSettingsManager.h"
#import "HDGameButton.h"
#import "HDSwitch.h"
#import "HDHelper.h"

@interface HDRearViewController ()
@property (nonatomic, strong) UIButton *top;
@property (nonatomic, strong) UIButton *bottom;
@end

@implementation HDRearViewController {
    UIView *_container;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setup];
}

#pragma mark - Public

- (void)setGameInterfaceHidden:(BOOL)gameInterfaceHidden {
    
    _gameInterfaceHidden = gameInterfaceHidden;
    if (gameInterfaceHidden) {
        [self _hideGameInterface];
    } else {
        [self _showGameInterface];
    }
}

- (void)setButtonsSelected:(BOOL)buttonsSelected {
    
    _buttonsSelected = buttonsSelected;
    if (_buttonsSelected) {
        
        for (UIView *subView in [_container subviews]) {
            if ([subView isKindOfClass:[HDGameButton class]]) {
                [(HDGameButton *)subView setSelected:YES];
            }
        }
        
    } else {
        
        for (UIView *subView in [_container subviews]) {
            if ([subView isKindOfClass:[HDGameButton class]]) {
                [(HDGameButton *)subView setSelected:NO];
            }
        }
    }
}

#pragma mark - Private

- (void)_setup {
    
    self.view.backgroundColor = [UIColor flatSTDarkNavyColor];
    
    CGRect containerBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds)/1.25f, CGRectGetHeight(self.view.bounds));
    if (IS_IPAD) {
        containerBounds.size.width = CGRectGetMidX(self.view.bounds);
    }
    
    _container = [[UIView alloc] initWithFrame:containerBounds];
    [self.view addSubview:_container];
    
    const CGFloat buttonHeight = IS_IPAD ? CGRectGetHeight(self.view.bounds)/15   : CGRectGetHeight(self.view.bounds)/14;
    const CGFloat buttonWidth  = IS_IPAD ? CGRectGetWidth(_container.bounds)/1.2f : CGRectGetWidth(_container.bounds)/1.5f;
    
    CGRect defaultFrame;
    defaultFrame.size = CGSizeMake(buttonWidth, buttonHeight);
    defaultFrame.origin.x = CGRectGetMidX(containerBounds) - buttonWidth/2;
    defaultFrame.origin.y = CGRectGetHeight(self.view.bounds)/6;
    
    const CGFloat kPadding = 15.0f * (IS_IPAD ? 1.0f : TRANSFORM_SCALE_X);
    CGRect previousFrame = CGRectZero;
    for (NSUInteger row = 0; row < 4; row++) {
        
        CGRect currentFrame = previousFrame;
        if (row == 0) {
            currentFrame = defaultFrame;
        } else {
            CGRect frame = currentFrame;
            frame.origin.y += buttonHeight + kPadding;
            currentFrame = frame;
        }
        
        HDGameButton *menuButton = [[HDGameButton alloc] initWithFrame:CGRectIntegral(currentFrame)];
        menuButton.buttonColor = [UIColor flatSTLightBlueColor];
        menuButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        menuButton.titleLabel.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(menuButton.bounds)/3.1f);
        menuButton.adjustsImageWhenDisabled = NO;
        menuButton.adjustsImageWhenHighlighted = NO;
        menuButton.selected = YES;
        [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_container addSubview:menuButton];
        
        previousFrame = menuButton.frame;

        switch (row) {
            case 0:
                self.top = menuButton;
                [menuButton setTitle:NSLocalizedString(@"leaderboard", nil)
                            forState:UIControlStateNormal];
                [self.top addTarget:[HDAppDelegate sharedDelegate]
                             action:@selector(openLeaderboardController:)
                   forControlEvents:UIControlEventTouchUpInside];
                break;
            case 1:
                self.bottom = menuButton;
                [menuButton setTitle:NSLocalizedString(@"achievements", nil)
                            forState:UIControlStateNormal];
                [self.bottom addTarget:[HDAppDelegate sharedDelegate]
                                action:@selector(openAcheivementsController:)
                      forControlEvents:UIControlEventTouchUpInside];
                break;
            case 2:
                [menuButton setTitle:NSLocalizedString(@"removeAds", nil)
                            forState:UIControlStateNormal];
                [menuButton addTarget:[HDAppDelegate sharedDelegate]
                               action:@selector(removeBanners:)
                     forControlEvents:UIControlEventTouchUpInside];
                break;
            case 3:
                [menuButton setTitle:NSLocalizedString(@"Restore", nil)
                            forState:UIControlStateNormal];
                [menuButton addTarget:[HDAppDelegate sharedDelegate]
                               action:@selector(restoreIAP:)
                     forControlEvents:UIControlEventTouchUpInside];
                break;
            default:
                break;
        }
    }
    
    const CGFloat toggleHeight = 38.0f * (IS_IPAD ? 1.5f : TRANSFORM_SCALE_X);
    const CGFloat toggleWidth  = 70.0f * (IS_IPAD ? 1.5f : TRANSFORM_SCALE_X);
    CGFloat originY = CGRectGetMidY(containerBounds) + CGRectGetHeight(containerBounds)/(IS_IPAD ? 18.0f : 12.0f);
    for (NSUInteger i = 0; i < 2; i++) {
        
        originY +=  (i* (toggleHeight + kPadding));
        
        CGRect imageViewFrame = CGRectMake(CGRectGetMidX(_container.bounds) - buttonWidth/1.65f, originY, toggleHeight, toggleHeight);
        if (IS_IPAD) {
            imageViewFrame.origin.x = CGRectGetMidX(_container.bounds) - buttonWidth/2.0f;
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        [_container addSubview:imageView];
        
        CGRect titleLabelFrame = CGRectMake(CGRectGetMaxX(imageViewFrame) + kPadding, originY, buttonWidth/1.5f, toggleHeight);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = GAME_FONT_WITH_SIZE(toggleHeight/1.5f);
        titleLabel.textColor = [UIColor whiteColor];
        [_container addSubview:titleLabel];
        
        CGRect toggleFrame = CGRectMake(CGRectGetMidX(containerBounds) + buttonWidth/2 - toggleWidth,
                                        titleLabel.frame.origin.y,
                                        toggleWidth,
                                        toggleHeight);
        HDSwitch *toggle = [[HDSwitch alloc] initWithFrame:toggleFrame
                                                   onColor:[UIColor flatSTEmeraldColor]
                                                  offColor:[UIColor flatEmeraldColor]];
        [_container addSubview:toggle];
        
        switch (i) {
            case 0:
                titleLabel.text = NSLocalizedString(@"music", ni);
                imageView.image = [UIImage imageNamed:@"MusicIcon"];
                toggle.on = [[HDSettingsManager sharedManager] music];
                [toggle addTarget:self action:@selector(_toggleMusic:) forControlEvents:UIControlEventValueChanged];
                break;
            case 1:
                titleLabel.text = NSLocalizedString(@"sound", ni);
                imageView.image = [UIImage imageNamed:@"SoundIcon"];
                toggle.on = [[HDSettingsManager sharedManager] sound];
                [toggle addTarget:self action:@selector(_toggleSound:) forControlEvents:UIControlEventValueChanged];
                break;
            default:
                break;
        }
    }
}

- (IBAction)_toggleSound:(HDSwitch *)sender {
    [[HDSettingsManager sharedManager] setSound:![[HDSettingsManager sharedManager] sound]];
}

- (IBAction)_toggleMusic:(HDSwitch *)sender {
    BOOL music = [[HDSettingsManager sharedManager] music];
    [[HDSettingsManager sharedManager] setMusic:!music];
    [[HDSoundManager sharedManager] setPlayLoop:!music];
}

- (void)_hideGameInterface {
    
    [self.top setTitle:NSLocalizedString(@"leaderboard", nil)
              forState:UIControlStateNormal];
    
    [self.bottom setTitle:NSLocalizedString(@"achievements", nil)
                 forState:UIControlStateNormal];
    
    [self.top removeTarget:[HDAppDelegate sharedDelegate]
                    action:@selector(restartCurrentLevel:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottom removeTarget:[HDAppDelegate sharedDelegate]
                       action:@selector(animateToLevelViewController:)
             forControlEvents:UIControlEventTouchUpInside];
    
    [self.top addTarget:[HDAppDelegate sharedDelegate]
                 action:@selector(openLeaderboardController:)
       forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottom addTarget:[HDAppDelegate sharedDelegate]
                    action:@selector(openAcheivementsController:)
          forControlEvents:UIControlEventTouchUpInside];
}

- (void)_showGameInterface {
    
    [self.top setTitle:NSLocalizedString(@"restart", nil)
              forState:UIControlStateNormal];
    
    [self.bottom setTitle:NSLocalizedString(@"back", nil)
                 forState:UIControlStateNormal];
    
    [self.top removeTarget:[HDAppDelegate sharedDelegate]
                    action:@selector(openLeaderboardController:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottom removeTarget:[HDAppDelegate sharedDelegate]
                       action:@selector(openAcheivementsController:)
             forControlEvents:UIControlEventTouchUpInside];
    
    [self.top addTarget:[HDAppDelegate sharedDelegate]
                 action:@selector(restartCurrentLevel:)
       forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottom addTarget:[HDAppDelegate sharedDelegate]
                    action:@selector(animateToLevelViewController:)
          forControlEvents:UIControlEventTouchUpInside];
}

@end
