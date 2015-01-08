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
#import "HDNavigationBar.h"
#import "UIColor+FlatColors.h"
#import "HDGameViewController.h"
#import "HDGridManager.h"
#import "HDScene.h"

static const CGFloat defaultContainerHeight = 70.0f;

@interface HDGameViewController () <ADBannerViewDelegate, HDSceneDelegate>

@property (nonatomic, strong) HDNavigationBar *navigationBar;
@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, strong) HDScene *scene;

@property (nonatomic, strong) ADBannerView *bannerView;

@property (nonatomic, assign) NSUInteger level;

@property (nonatomic, assign) BOOL pauseGame;
@property (nonatomic, assign) BOOL navigationBarHidden;

@end

@implementation HDGameViewController {
    BOOL _isBannerVisible;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification  object:nil];
}

- (id)initWithLevel:(NSInteger)level
{
    if (self = [super init]) {
        self.level = level;
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
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    self.gridManager = [[HDGridManager alloc] initWithLevelNumber:_level];
    
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

- (void)performExitAnimation
{
    self.navigationBarHidden = YES;
    
    [UIView animateWithDuration:.3f animations:^{
        CGRect bannerFrame = self.bannerView.frame;
        bannerFrame.origin.y = CGRectGetHeight(self.view.bounds);
        self.bannerView.frame = bannerFrame;
    }];
    
    [self.scene performExitAnimationsWithCompletion:^{
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

#pragma mark - Life cycle

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    SKView * skView = (SKView *)self.view;
    if (!skView.scene && self.gridManager) {
        [self _setupScene];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)_restart
{
    [self.scene restart];
}

- (void)_setup
{
    CGRect navBarFrame = CGRectMake(0.0f, -defaultContainerHeight, CGRectGetWidth(self.view.bounds), defaultContainerHeight);
    self.navigationBar = [HDNavigationBar viewWithToggleImage:[UIImage imageNamed:@"Grid"] activityImage:[UIImage imageNamed:@"Reset"]];
    self.navigationBar.frame = navBarFrame;
    [[self.navigationBar.subviews firstObject] addTarget:self
                                                  action:@selector(performExitAnimation)
                                        forControlEvents:UIControlEventTouchUpInside];
    [[self.navigationBar.subviews lastObject] addTarget:self
                                                 action:@selector(_restart)
                                       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.navigationBar];
}

- (void)_setupScene
{
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    self.scene = [HDScene sceneWithSize:self.view.bounds.size];
    self.scene.delegate = self;
    self.scene.levelIndex = _level;
    self.scene.gridManager = self.gridManager;
    [skView presentScene:self.scene];
    
    [self _beginGame];
}

- (void)_beginGame
{
    NSArray *hexagons = [self.gridManager hexagons];
    [self.scene layoutNodesWithGrid:hexagons];
}

- (void)_hideAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGRect rect = self.navigationBar.frame;
        rect.origin.y = -defaultContainerHeight;
        self.navigationBar.frame = rect;
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.3f animations:animate];
    }
}

- (void)_showAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGRect rect = self.navigationBar.frame;
        rect.origin.y = 0.0f;
        self.navigationBar.frame = rect;
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.3f animations:animate];
    }
}

#pragma mark - Notifications

- (void)_applicationDidBecomeActive
{
    self.pauseGame = NO;
    self.scene.view.paused = self.pauseGame;
}

- (void)_applicationWillResignActive
{
    self.pauseGame = YES;
    self.scene.view.paused = self.pauseGame;
}

#pragma mark - <HDSceneDelegate>

- (void)scene:(HDScene *)scene proceededToLevel:(NSUInteger)level
{
    self.gridManager = [[HDGridManager alloc] initWithLevelNumber:level];
    self.scene.gridManager = self.gridManager;
    [self _beginGame];
}

- (void)scene:(HDScene *)scene gameEndedWithCompletion:(BOOL)completion
{
    if (completion) {
        self.navigationBarHidden = YES;
    } else {
        [self performSelector:@selector(_restart) withObject:nil afterDelay:.3f];
    }
}

- (void)gameWillResetInScene:(HDScene *)scene
{
    self.navigationBarHidden = NO;
}

#pragma mark - <ADBannerViewDelegate>

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (_isBannerVisible) {
        [UIView animateWithDuration:.3f animations:^{
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
        [UIView animateWithDuration:.3f animations:^{
            CGRect bannerFrame = self.bannerView.frame;
            bannerFrame.origin.y = CGRectGetHeight(self.view.bounds);
            self.bannerView.frame = bannerFrame;
        }];
        _isBannerVisible = NO;
    }
}

@end
