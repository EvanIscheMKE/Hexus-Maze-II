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

- (void)_setup
{
    self.view.backgroundColor = [UIColor flatMidnightBlueColor];
    
    const CGFloat kSquareSize = CGRectGetMidX(self.view.bounds)/3;
    const CGFloat kSpacing    = CGRectGetHeight(self.view.bounds)/6;// padding
    
    CGRect containerBounds = CGRectMake(0.0f, 0.0f, kSquareSize, CGRectGetHeight(self.view.bounds));
    UIView *container = [[UIView alloc] initWithFrame:containerBounds];
    container.backgroundColor = [UIColor flatMidnightBlueColor];
    [self.view addSubview:container];
    
    for (NSUInteger row = 0; row < 6; row++) {
        
        CGRect squareFrame = CGRectMake(0.0f, 0.0f, kSquareSize, kSpacing);
        UIButton *square = [UIButton buttonWithType:UIButtonTypeCustom];
        square.frame = squareFrame;
        square.titleLabel.textAlignment = NSTextAlignmentCenter;
        square.titleLabel.font          = GILLSANS(24.0f);
        [square setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        square.center = CGPointMake(CGRectGetMidX(container.bounds), (CGRectGetMidY(container.bounds) - (2.5f * kSpacing)) + row * kSpacing);
        square.adjustsImageWhenDisabled    = NO;
        square.adjustsImageWhenHighlighted = NO;
        [container addSubview:square];
        
        switch (row) {
            case 0:
                self.top = square;
                [self.top setImage:[UIImage imageNamed:@"leaderboard"] forState:UIControlStateNormal];
                [self.top addTarget:ADelegate action:@selector(openLeaderboardController:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 1:
                self.bottom = square;
                [square setImage:[UIImage imageNamed:@"SideMenu-Star-60"] forState:UIControlStateNormal];
                [self.bottom addTarget:ADelegate action:@selector(openAcheivementsController:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 2:
                square.selected = [[HDSettingsManager sharedManager] music];
                [square setImage:[UIImage imageNamed:@"MusicIcon-ON"] forState:UIControlStateNormal];
                [square addTarget:self action:@selector(_toggleMusic:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 3:
                square.selected = [[HDSettingsManager sharedManager] sound];
                [square setImage:[UIImage imageNamed:@"SoundIcon-ON"] forState:UIControlStateNormal];
                [square addTarget:self action:@selector(_toggleSound:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 4:
                [square setTitle:@"Ads" forState:UIControlStateNormal];
                [square addTarget:self action:@selector(_toggleSound:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 5:
                [square setTitle:@"Restore" forState:UIControlStateNormal];
                [square addTarget:self action:@selector(_toggleSound:) forControlEvents:UIControlEventTouchUpInside];
                break;
        }
    }
}

- (IBAction)_toggleSound:(UIButton *)sender
{
    [sender setSelected:!sender.selected];
    [[HDSettingsManager sharedManager] setSound:![[HDSettingsManager sharedManager] sound]];
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
}

- (IBAction)_toggleMusic:(UIButton *)sender
{
    [sender setSelected:!sender.selected];
    [[HDSettingsManager sharedManager] setMusic:![[HDSettingsManager sharedManager] music]];
    [[HDSoundManager sharedManager] setPlayLoop:[[HDSettingsManager sharedManager] music]];
}

- (void)_hideGameInterface
{
    [self.top    setTitle:@"Leaderboard"  forState:UIControlStateNormal];
    [self.bottom setTitle:@"Achievements" forState:UIControlStateNormal];
    [self.top    removeTarget:ADelegate action:@selector(restartCurrentLevel:)          forControlEvents:UIControlEventTouchUpInside];
    [self.bottom removeTarget:ADelegate action:@selector(animateToLevelViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.top    addTarget:ADelegate action:@selector(openLeaderboardController:)       forControlEvents:UIControlEventTouchUpInside];
    [self.bottom addTarget:ADelegate action:@selector(openAcheivementsController:)      forControlEvents:UIControlEventTouchUpInside];
}

- (void)_showGameInterface
{
    [self.top    setTitle:@"Restart" forState:UIControlStateNormal];
    [self.bottom setTitle:@"Map"     forState:UIControlStateNormal];
    [self.top    removeTarget:ADelegate action:@selector(openLeaderboardController:)  forControlEvents:UIControlEventTouchUpInside];
    [self.bottom removeTarget:ADelegate action:@selector(openAcheivementsController:) forControlEvents:UIControlEventTouchUpInside];
    [self.top    addTarget:ADelegate action:@selector(restartCurrentLevel:)           forControlEvents:UIControlEventTouchUpInside];
    [self.bottom addTarget:ADelegate action:@selector(animateToLevelViewController:)  forControlEvents:UIControlEventTouchUpInside];
}

@end
