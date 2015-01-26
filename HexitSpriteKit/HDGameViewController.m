//
//  ViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import iAd;
@import SpriteKit;

#import "HDHelper.h"
#import "HDLevelGenerator.h"
#import "HDMenuBar.h"
#import "UIColor+FlatColors.h"
#import "HDGameViewController.h"
#import "HDSoundManager.h"
#import "HDSettingsManager.h"
#import "HDGridManager.h"
#import "HDScene.h"
#import "HDTileDescriptorView.h"

static const CGFloat defaultContainerHeight = 70.0f;

#define NC [NSNotificationCenter defaultCenter]
@interface HDGameViewController () <ADBannerViewDelegate, HDSceneDelegate>
@property (nonatomic, strong) HDMenuBar     *menuBar;
@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, strong) HDScene       *scene;
@property (nonatomic, strong) ADBannerView  *bannerView;
@property (nonatomic, assign) BOOL pauseGame;
@property (nonatomic, assign) BOOL navigationBarHidden;
@end

@implementation HDGameViewController {
    BOOL _isBannerVisible;
    NSUInteger _levelIdx;
}

- (void)dealloc
{
    [NC removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [NC removeObserver:self name:UIApplicationDidBecomeActiveNotification  object:nil];
}

- (instancetype)initWithLevel:(NSInteger)level
{
    if (self = [super init]) {
        _levelIdx = level;
    }
    return self;
}

- (void)loadView
{
    CGRect viewRect = [[UIScreen mainScreen] bounds];
    SKView *skView = [[SKView alloc] initWithFrame:viewRect];
    [self setView:skView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _setup];
}

#pragma mark - Public

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    _navigationBarHidden = navigationBarHidden;
    
    if (_navigationBarHidden) {
        [self _hideAnimated:YES];
    } else {
        [self _showAnimated:YES];
    }
}

#pragma mark - Life cycle

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    if (!skView.scene && self.gridManager) {
        
        self.scene = [HDScene sceneWithSize:self.view.bounds.size];
        self.scene.delegate = self;
        self.scene.levelIndex = _levelIdx;
        self.scene.gridManager = self.gridManager;
        [skView presentScene:self.scene];
     
        [self _beginGame];
    }
    
    if (!self.bannerView) {
        self.bannerView = [[ADBannerView alloc] init];
        self.bannerView.delegate = self;
        [self.view addSubview:self.bannerView];
        
        CGRect bannerFrame = self.bannerView.frame;
        bannerFrame.origin.y = CGRectGetHeight(self.view.bounds);
        self.bannerView.frame = bannerFrame;
    }
}

#pragma mark - Private

- (void)_setup
{
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    
    self.gridManager = [[HDGridManager alloc] initWithLevelNumber:_levelIdx];
    
    CGRect menuBarFrame = CGRectMake(0.0f, -defaultContainerHeight, CGRectGetWidth(self.view.bounds), defaultContainerHeight);
    self.menuBar = [HDMenuBar menuBarWithActivityImage:[UIImage imageNamed:@"RestartIcon-"]];
    self.menuBar.frame = menuBarFrame;
    self.menuBar.musicButton.selected = [[HDSettingsManager sharedManager] music];
    self.menuBar.soundButton.selected = [[HDSettingsManager sharedManager] sound];
    [self.menuBar.navigationButton addTarget:self action:@selector(_performExitAnimation:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuBar.musicButton      addTarget:self action:@selector(_toggleMusic:)          forControlEvents:UIControlEventTouchUpInside];
    [self.menuBar.soundButton      addTarget:self action:@selector(_toggleSound:)          forControlEvents:UIControlEventTouchUpInside];
    [self.menuBar.activityButton   addTarget:self action:@selector(_restart:)              forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menuBar];
    
    [NC addObserver:self selector:@selector(_applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [NC addObserver:self selector:@selector(_applicationDidBecomeActive:)  name:UIApplicationDidBecomeActiveNotification  object:nil];
}

- (void)_beginGame
{
    NSUInteger previousLevelIdx = _levelIdx - 1;
    if (previousLevelIdx % 14 == 0 && previousLevelIdx >= 14) {
       // if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%tu",previousLevelIdx]]) {
            HDTileDescriptorView *alert = [[HDTileDescriptorView alloc] initWithDescription:descriptionFromLevelIdx((int)previousLevelIdx)
                                                                                      image:[HDHelper iconForType:(int)previousLevelIdx]];
            alert.frame = self.view.bounds;
            [self.view addSubview:alert];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%tu",previousLevelIdx]];
       // }
    }
    
    NSArray *hexagons = [self.gridManager hexagons];
    [self.scene layoutNodesWithGrid:hexagons];
}

- (void)_hideAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGRect rect = self.menuBar.frame;
        rect.origin.y = -defaultContainerHeight;
        self.menuBar.frame = rect;
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.300f animations:animate];
    }
}

- (void)_showAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGRect rect = self.menuBar.frame;
        rect.origin.y = 0.0f;
        self.menuBar.frame = rect;
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.300f animations:animate];
    }
}

#pragma mark - Selectors

- (IBAction)_restart:(id)sender
{
    [self.scene restart];
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

- (IBAction)_performExitAnimation:(id)sender
{
    self.navigationBarHidden = YES;
    [UIView animateWithDuration:.300f animations:^{
        CGRect bannerFrame = self.bannerView.frame;
        bannerFrame.origin.y = CGRectGetHeight(self.view.bounds);
        self.bannerView.frame = bannerFrame;
    }];
    
    [self.scene performExitAnimationsWithCompletion:^{
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

#pragma mark - Notifications

- (void)_applicationDidBecomeActive:(NSNotification *)notification
{
    self.pauseGame = NO;
    self.scene.view.paused = self.pauseGame;
}

- (void)_applicationWillResignActive:(NSNotification *)notification
{
    self.pauseGame = YES;
    self.scene.view.paused = self.pauseGame;
}

#pragma mark - <HDSceneDelegate>

-(void)scene:(HDScene *)scene proceededToLevel:(NSUInteger)level
{
    _levelIdx += 1;
    self.gridManager = [[HDGridManager alloc] initWithLevelNumber:level];
    self.scene.gridManager = self.gridManager;
    [self _beginGame];
}

- (void)scene:(HDScene *)scene gameEndedWithCompletion:(BOOL)completion
{
    if (completion) {
        self.navigationBarHidden = YES;
    } else {
        [self performSelector:@selector(_restart:) withObject:nil afterDelay:.300f];
    }
}

- (void)gameWillResetInScene:(HDScene *)scene
{
    self.navigationBarHidden = NO;
}

#pragma mark - <ADBannerViewDelegate>

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_isBannerVisible) {
        [UIView animateWithDuration:.300f animations:^{
            CGRect bannerFrame = self.bannerView.frame;
            bannerFrame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.bannerView.bounds);
            self.bannerView.frame = bannerFrame;
        }];
        _isBannerVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (_isBannerVisible) {
        [UIView animateWithDuration:.300f animations:^{
            CGRect bannerFrame = self.bannerView.frame;
            bannerFrame.origin.y = CGRectGetHeight(self.view.bounds);
            self.bannerView.frame = bannerFrame;
        }];
        _isBannerVisible = NO;
    }
}

@end
