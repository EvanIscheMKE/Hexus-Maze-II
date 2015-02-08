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
#import "HDContainerViewController.h"
#import "HDSoundManager.h"
#import "HDSettingsManager.h"
#import "HDGridManager.h"
#import "HDHintsView.h"
#import "HDScene.h"

#define NC [NSNotificationCenter defaultCenter]

static const CGFloat defaultContainerHeight = 70.0f;
@interface HDGameViewController () <ADBannerViewDelegate, HDSceneDelegate>
@property (nonatomic, strong) HDMenuBar     *menuBar;
@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, strong) HDScene       *scene;
@property (nonatomic, strong) HDHintsView   *hintsView;
@property (nonatomic, strong) ADBannerView  *bannerView;
@property (nonatomic, assign) BOOL pauseGame;
@property (nonatomic, assign) BOOL navigationBarHidden;
@end

@implementation HDGameViewController {
    BOOL _isBannerVisible;
    NSUInteger _levelIdx;
}

- (void)dealloc {
    
    [NC removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [NC removeObserver:self name:UIApplicationDidBecomeActiveNotification  object:nil];
}

- (instancetype)initWithLevel:(NSInteger)level {
    
    if (self = [super init]) {
        _levelIdx = level;
    }
    return self;
}

- (void)performExitAnimationWithCompletion:(dispatch_block_t)completion {
    
    self.navigationBarHidden = YES;
    [UIView animateWithDuration:.300f animations:^{
        
        CGRect bannerFrame = self.bannerView.frame;
        bannerFrame.origin.y = CGRectGetHeight(self.view.bounds);
        self.bannerView.frame = bannerFrame;
        
        if (self.hintsView) {
            CGRect frame = self.hintsView.frame;
            frame.origin.y = CGRectGetHeight(self.view.bounds);
            self.hintsView.frame = frame;
        }
    }];
    
    [self.scene performExitAnimationsWithCompletion:^{
        if (completion) {
            completion();
        }
    }];
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
    if (!skView.scene && self.gridManager) {
        
        self.scene = [HDScene sceneWithSize:self.view.bounds.size];
        self.scene.myDelegate = self;
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
    
    self.gridManager = [[HDGridManager alloc] initWithLevelIndex:_levelIdx];
    
    HDContainerViewController *container = self.containerViewController;
    
    CGRect menuBarFrame = CGRectMake(0.0f, -defaultContainerHeight, CGRectGetWidth(self.view.bounds), defaultContainerHeight);
    self.menuBar = [HDMenuBar menuBarWithActivityImage:[UIImage imageNamed:@"RestartIcon-"]];
    self.menuBar.frame = menuBarFrame;
    [self.menuBar.navigationButton addTarget:container action:@selector(toggleMenuViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.menuBar.activityButton addTarget:self action:@selector(restart:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menuBar];
    
    [NC addObserver:self selector:@selector(_applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [NC addObserver:self selector:@selector(_applicationDidBecomeActive:)  name:UIApplicationDidBecomeActiveNotification  object:nil];
}

- (void)_beginGame
{    
    NSArray *hexagons = [self.gridManager hexagons];
    [self.scene layoutNodesWithGrid:hexagons];
    
    if (_levelIdx % 14 == 1 || _levelIdx == 1) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%zd",_levelIdx]]) {
            [self _showTipsWithDescription:descriptionForLevelIdx(_levelIdx)
                                     image:[HDHelper imageFromLevelIdx:_levelIdx]];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%zd",_levelIdx]];
        }
    }
}

- (void)_showTipsWithDescription:(NSString *)description image:(UIImage *)image
{
    if (!self.hintsView) {
        CGRect hintsFrame = CGRectMake(0.0f,
                                       CGRectGetHeight(self.view.bounds),
                                       CGRectGetWidth(self.view.bounds),
                                       CGRectGetHeight(self.view.bounds)/5);
        self.hintsView = [[HDHintsView alloc] initWithDescription:description];
        self.hintsView.imageView.image = image;
        self.hintsView.frame = hintsFrame;
        [self.view insertSubview:self.hintsView atIndex:0];
    }
    
    [UIView animateWithDuration:.3f delay:.75f options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.hintsView.frame;
        frame.origin.y = CGRectGetHeight(self.view.bounds)/1.25f - ((_isBannerVisible) ? self.bannerView.bounds.size.height : 0);
        self.hintsView.frame = frame;
    } completion:^(BOOL finished){
        [self performSelector:@selector(_dismissHintsView) withObject:nil afterDelay:3.5f];
    }];
}

- (void)_dismissHintsView {
    
    [UIView animateWithDuration:.3f animations:^{
        CGRect frame = self.hintsView.frame;
        frame.origin.y = CGRectGetHeight(self.view.bounds);
        self.hintsView.frame = frame;
    } completion:^(BOOL finished){
        [self.hintsView removeFromSuperview];
        self.hintsView = nil;
    }];
}

- (void)_hideAnimated:(BOOL)animated {
    
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

- (IBAction)restart:(id)sender
{
    [self.scene restart];
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
    self.gridManager = [[HDGridManager alloc] initWithLevelIndex:level];
    self.scene.gridManager = self.gridManager;
    [self _beginGame];
}

- (void)scene:(HDScene *)scene gameEndedWithCompletion:(BOOL)completion
{
    if (completion) {
        self.navigationBarHidden = YES;
    } else {
        [self performSelector:@selector(restart:) withObject:nil afterDelay:.300f];
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
            
            if (self.hintsView) {
                CGRect frame = self.hintsView.frame;
                frame.origin.y = CGRectGetHeight(self.view.bounds)/1.25f - CGRectGetHeight(self.bannerView.bounds);
                self.hintsView.frame = frame;
            }
            
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
            
            if (self.hintsView) {
                CGRect frame = self.hintsView.frame;
                frame.origin.y = CGRectGetHeight(self.view.bounds)/1.25f;
                self.hintsView.frame = frame;
            }
            
        }];
        _isBannerVisible = NO;
    }
}

@end
