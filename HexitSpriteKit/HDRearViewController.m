//
//  HDBackViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/13/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDContainerViewController.h"
#import "HDRearViewController.h"
#import "UIColor+FlatColors.h"
#import "HDSoundManager.h"
#import "HDSettingsManager.h"
#import "HDSwitch.h"
#import "HDHelper.h"

@interface HDRearViewController ()
@property (nonatomic, strong) UIButton *top;
@property (nonatomic, strong) UIButton *bottom;
@end

@implementation HDRearViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setup];
}

#pragma mark - Public

- (void)setGameInterfaceHidden:(BOOL)gameInterfaceHidden
{
    _gameInterfaceHidden = gameInterfaceHidden;
    
    if (gameInterfaceHidden) {
        [self _hideGameInterface];
    } else {
        [self _showGameInterface];
    }
}

#pragma mark - Private

- (void)_setup {
    
    self.view.backgroundColor = [UIColor flatMidnightBlueColor];
    
    CGRect containerBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds)/1.25f, CGRectGetHeight(self.view.bounds));
    UIView *container = [[UIView alloc] initWithFrame:containerBounds];
    container.backgroundColor = [UIColor colorWithWhite:0.0f alpha:.5f];
    [self.view addSubview:container];
    
    const CGFloat buttonHeight = CGRectGetHeight(self.view.bounds)/15;
    const CGFloat buttonWidth  = CGRectGetWidth(containerBounds)/1.5f;
    
    CGRect defaultFrame;
    defaultFrame.size = CGSizeMake(buttonWidth, buttonHeight);
    defaultFrame.origin.x = CGRectGetMidX(containerBounds) - buttonWidth/2;
    defaultFrame.origin.y = CGRectGetHeight(self.view.bounds)/7;
    
    CGRect previousFrame = CGRectZero;
    const CGFloat kPadding = 15.0f;
    for (NSUInteger row = 0; row < 4; row++) {
        CGRect currentFrame = previousFrame;
        
        if (row == 0) {
            currentFrame = defaultFrame;
        } else {
            CGRect frame = currentFrame;
            frame.origin.y += buttonHeight + kPadding; // Padding
            currentFrame = frame;
        }
        
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.frame = CGRectIntegral(currentFrame);
        menuButton.backgroundColor          = [UIColor flatPeterRiverColor];
        menuButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        menuButton.titleLabel.font          = GILLSANS(CGRectGetHeight(menuButton.bounds)/2.9f);
        [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        menuButton.adjustsImageWhenDisabled    = NO;
        menuButton.adjustsImageWhenHighlighted = NO;
        menuButton.layer.cornerRadius = CGRectGetMidY(menuButton.bounds);
        [container addSubview:menuButton];
        
        previousFrame = menuButton.frame;

        switch (row) {
            case 0:
                self.top = menuButton;
                [menuButton setTitle:@"Leaderboards" forState:UIControlStateNormal];
                [self.top addTarget:ADelegate action:@selector(openLeaderboardController:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 1:
                self.bottom = menuButton;
                [menuButton setTitle:@"Achievements" forState:UIControlStateNormal];
                [self.bottom addTarget:ADelegate action:@selector(openAcheivementsController:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 2:
                [menuButton setTitle:@"Remove Ads" forState:UIControlStateNormal];
                [menuButton addTarget:ADelegate action:@selector(removeBanners:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 3:
                [menuButton setTitle:@"Restore" forState:UIControlStateNormal];
                [menuButton addTarget:self action:@selector(restoreIAP:) forControlEvents:UIControlEventTouchUpInside];
                break;
            default:
                break;
        }
    }
    
    const CGFloat toggleHeight = 32.0f;
    const CGFloat toggleWidth  = 70.0f;
    CGFloat originY = CGRectGetMidY(containerBounds) + CGRectGetHeight(containerBounds)/12.f;
    for (NSUInteger i = 0; i < 2; i++) {
        
        originY +=  (i* (toggleHeight + kPadding));
        
        CGRect imageViewFrame = CGRectMake(CGRectGetMidX(containerBounds) - buttonWidth/2, originY, toggleHeight, toggleHeight);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        [container addSubview:imageView];
        
        CGRect titleLabelFrame = CGRectMake(CGRectGetMaxX(imageViewFrame) + kPadding, originY, buttonWidth/1.5f, toggleHeight);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = GILLSANS(toggleHeight/1.5f);//Padding
        titleLabel.textColor = [UIColor whiteColor];
        [container addSubview:titleLabel];
        
        CGRect toggleFrame = CGRectMake(CGRectGetMidX(containerBounds) + buttonWidth/2 - toggleWidth,
                                        titleLabel.frame.origin.y,
                                        toggleWidth,
                                        toggleHeight);
        HDSwitch *toggle = [[HDSwitch alloc] initWithFrame:toggleFrame
                                                   onColor:[UIColor flatPeterRiverColor]
                                                  offColor:[UIColor flatEmeraldColor]];
        [container addSubview:toggle];
        
        switch (i) {
            case 0:
                titleLabel.text = @"Music";
                imageView.image = [UIImage imageNamed:@"MusicIcon"];
                toggle.on = [[HDSettingsManager sharedManager] music];
                [toggle addTarget:self action:@selector(_toggleMusic:) forControlEvents:UIControlEventValueChanged];
                break;
            case 1:
                titleLabel.text = @"Sound";
                imageView.image = [UIImage imageNamed:@"SoundIcon"];
                toggle.on = [[HDSettingsManager sharedManager] sound];
                [toggle addTarget:self action:@selector(_toggleSound:) forControlEvents:UIControlEventValueChanged];
                break;
            default:
                break;
        }
    }
    
    UILabel *gameTitleLabel = [[UILabel alloc] init];
    gameTitleLabel.text      = @"Hexus Maze V2.0";
    gameTitleLabel.textColor = [UIColor whiteColor];
    gameTitleLabel.font      = GILLSANS(24.0f);
    gameTitleLabel.textAlignment = NSTextAlignmentCenter;
    [gameTitleLabel sizeToFit];
    gameTitleLabel.center = CGPointMake(CGRectGetMidX(container.bounds), CGRectGetHeight(container.bounds) -CGRectGetMidY(gameTitleLabel.bounds));
    gameTitleLabel.frame = CGRectIntegral(gameTitleLabel.frame);
    [container addSubview:gameTitleLabel];
}

- (IBAction)_toggleSound:(HDSwitch *)sender {
    
    [sender setSelected:sender.isOn];
    [[HDSettingsManager sharedManager] setSound:![[HDSettingsManager sharedManager] sound]];
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
}

- (IBAction)_toggleMusic:(HDSwitch *)sender {
    
    [sender setSelected:sender.isOn];
    [[HDSettingsManager sharedManager] setMusic:![[HDSettingsManager sharedManager] music]];
    [[HDSoundManager sharedManager] setPlayLoop:[[HDSettingsManager sharedManager] music]];
}

- (void)_hideGameInterface {
    [self.top    setTitle:@"Leaderboard"  forState:UIControlStateNormal];
    [self.bottom setTitle:@"Achievements" forState:UIControlStateNormal];
    [self.top    removeTarget:ADelegate action:@selector(restartCurrentLevel:)          forControlEvents:UIControlEventTouchUpInside];
    [self.bottom removeTarget:ADelegate action:@selector(animateToLevelViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.top    addTarget:ADelegate action:@selector(openLeaderboardController:)       forControlEvents:UIControlEventTouchUpInside];
    [self.bottom addTarget:ADelegate action:@selector(openAcheivementsController:)      forControlEvents:UIControlEventTouchUpInside];
}

- (void)_showGameInterface {
    [self.top    setTitle:@"Restart" forState:UIControlStateNormal];
    [self.bottom setTitle:@"Back To Map"     forState:UIControlStateNormal];
    [self.top    removeTarget:ADelegate action:@selector(openLeaderboardController:)  forControlEvents:UIControlEventTouchUpInside];
    [self.bottom removeTarget:ADelegate action:@selector(openAcheivementsController:) forControlEvents:UIControlEventTouchUpInside];
    [self.top    addTarget:ADelegate action:@selector(restartCurrentLevel:)           forControlEvents:UIControlEventTouchUpInside];
    [self.bottom addTarget:ADelegate action:@selector(animateToLevelViewController:)  forControlEvents:UIControlEventTouchUpInside];
}

@end
