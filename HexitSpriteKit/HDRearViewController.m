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

@implementation HDRearViewController {
    NSDictionary *_views;
    NSDictionary *_metrics;
}

- (void)viewDidLoad
{
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
    
    const CGFloat kSquareSize = CGRectGetMidY(self.view.bounds)/2;
    const CGFloat kSpacing    = CGRectGetHeight(self.view.bounds)/5 + 10.0f;// padding
    
    CGRect containerBounds = CGRectMake(0.0f, 0.0f, kSquareSize, CGRectGetHeight(self.view.bounds));
    UIView *container = [[UIView alloc] initWithFrame:containerBounds];
    container.backgroundColor = [UIColor flatMidnightBlueColor];
    [self.view addSubview:container];
    
    for (NSUInteger row = 0; row < 4; row++) {
        
        CGRect squareFrame = CGRectMake(0.0f,
                                        0.0f,
                                        [UIImage imageNamed:@"MusicON"].size.width,
                                        [UIImage imageNamed:@"MusicON"].size.height);
        
        UIButton *square = [UIButton buttonWithType:UIButtonTypeCustom];
        square.frame = squareFrame;
        square.center = CGPointMake(CGRectGetMidX(container.bounds), (CGRectGetMidY(container.bounds) - (1.5f * kSpacing)) + row * kSpacing);
        square.transform = CGAffineTransformMakeScale(CGRectGetWidth(self.view.bounds)/375.0f, CGRectGetWidth(self.view.bounds)/375.0f);
        square.adjustsImageWhenDisabled    = NO;
        square.adjustsImageWhenHighlighted = NO;
        [container addSubview:square];
        
        switch (row) {
            case 0:
                self.top = square;
                [self.top setBackgroundImage:[UIImage imageNamed:@"LeaderboardIcon"]  forState:UIControlStateNormal];
                [self.top addTarget:ADelegate action:@selector(openAcheivementsController:)  forControlEvents:UIControlEventTouchUpInside];
                break;
            case 1:
                self.bottom = square;
                [self.bottom setBackgroundImage:[UIImage imageNamed:@"AchievementsIcon"] forState:UIControlStateNormal];
                [self.bottom addTarget:ADelegate action:@selector(openLeaderboardController:)   forControlEvents:UIControlEventTouchUpInside];
                break;
            case 2:
                square.selected = [[HDSettingsManager sharedManager] music];
                [square addTarget:self action:@selector(_toggleMusic:) forControlEvents:UIControlEventTouchUpInside];
                [square setBackgroundImage:[UIImage imageNamed:@"MusicOFF"]  forState:UIControlStateNormal];
                [square setBackgroundImage:[UIImage imageNamed:@"MusicON"] forState:UIControlStateSelected];
                break;
            default:
                square.selected = [[HDSettingsManager sharedManager] sound];
                [square addTarget:self action:@selector(_toggleSound:) forControlEvents:UIControlEventTouchUpInside];
                [square setBackgroundImage:[UIImage imageNamed:@"SoundOFF"]  forState:UIControlStateNormal];
                [square setBackgroundImage:[UIImage imageNamed:@"SoundON"] forState:UIControlStateSelected];
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
    [self.top setBackgroundImage:[UIImage imageNamed:@"LeaderboardIcon"]                forState:UIControlStateNormal];
    [self.bottom setBackgroundImage:[UIImage imageNamed:@"AchievementsIcon"]            forState:UIControlStateNormal];
    [self.top    removeTarget:ADelegate action:@selector(restartCurrentLevel:)          forControlEvents:UIControlEventTouchUpInside];
    [self.bottom removeTarget:ADelegate action:@selector(animateToLevelViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.top    addTarget:ADelegate action:@selector(openAcheivementsController:)      forControlEvents:UIControlEventTouchUpInside];
    [self.bottom addTarget:ADelegate action:@selector(openLeaderboardController:)       forControlEvents:UIControlEventTouchUpInside];
}

- (void)_showGameInterface
{
    [self.top    setBackgroundImage:[UIImage imageNamed:@"RestartCurrentGame"]        forState:UIControlStateNormal];
    [self.bottom setBackgroundImage:[UIImage imageNamed:@"ReturnToMenu"]              forState:UIControlStateNormal];
    [self.top    removeTarget:ADelegate action:@selector(openAcheivementsController:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottom removeTarget:ADelegate action:@selector(openLeaderboardController:)  forControlEvents:UIControlEventTouchUpInside];
    [self.top    addTarget:ADelegate action:@selector(restartCurrentLevel:)           forControlEvents:UIControlEventTouchUpInside];
    [self.bottom addTarget:ADelegate action:@selector(animateToLevelViewController:)  forControlEvents:UIControlEventTouchUpInside];
}

@end
