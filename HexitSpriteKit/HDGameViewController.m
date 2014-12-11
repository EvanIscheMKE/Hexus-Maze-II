//
//  ViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;
@import iAd;

#import "HDLevelGenerator.h"
#import "UIColor+FlatColors.h"
#import "HDContainerViewController.h"
#import "HDGameViewController.h"
#import "HDGridManager.h"
#import "HDScene.h"

@interface HDGameViewController ()<ADBannerViewDelegate>

@property (nonatomic, assign) BOOL pauseGame;
@property (nonatomic, assign) BOOL bannerViewIsVisible;

@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, strong) HDScene *scene;

@property (nonatomic, strong) ADBannerView *bannerView;

@end

@implementation HDGameViewController {
    BOOL _RandomlyGeneratedLevel;
    BOOL _bannerViewIsVisible;
    NSInteger _level;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HDNextLevelNotification object:nil];
}

- (id)initWithLevel:(NSInteger)level
{
    if (self = [super init]) {
        
        _level = level;
        _RandomlyGeneratedLevel = NO;
        
        [self setPauseGame:NO];
        [self setExpanded:NO];
    }
    return self;
}

- (instancetype)initWithRandomlyGeneratedLevel
{
    if (self = [super init]) {
        _pauseGame = NO;
        _RandomlyGeneratedLevel = YES;
        [self setExpanded:NO];
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
    [self.view setBackgroundColor:[UIColor flatMidnightBlueColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_presentNextLevel)
                                                 name:HDNextLevelNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    if (!_RandomlyGeneratedLevel) {
        self.gridManager = [[HDGridManager alloc] initWithLevelNumber:_level];
    } else {
        HDLevelGenerator *generator = [[HDLevelGenerator alloc] init];
        [generator setNumberOfTiles:4];
        
        [generator generateWithCompletionHandler:^(NSDictionary *dictionary, NSError *error) {
            if (!error) {
                 self.gridManager = [[HDGridManager alloc] initWithRandomLevel:dictionary];
                [self _setupGame];
            }
        }];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(restartGame)];
    [tap setNumberOfTapsRequired:2];
    //[self.view addGestureRecognizer:tap];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    SKView * skView = (SKView *)self.view;
    if (!skView.scene && self.gridManager) {
        [self _setupGame];
    }
}

- (NSInteger)level
{
    return _level;
}

- (void)restartGame
{
    [self.scene restart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setExpanded:(BOOL)expanded
{
    if (_expanded == expanded) {
        return;
    }
    
    _expanded = expanded;
    
    if (expanded) {
        [self.bannerView setHidden:YES];
    } else {
        [self.bannerView setHidden:NO];
    }
}

#pragma mark -
#pragma mark - < PRIVATE >

- (void)_presentNextLevel
{
    _level++;
    
     self.gridManager = [[HDGridManager alloc] initWithLevelNumber:_level];
    [self.scene setLevelIndex:_level];
    [self.scene setGridManager:self.gridManager];
    [self.scene addUnderlyingIndicatorTiles];
    [self _beginGame];
}

- (void)_setupGame
{
    SKView * skView = (SKView *)self.view;
    
     self.scene = [HDScene sceneWithSize:self.view.bounds.size];
    [self.scene setLevelIndex:_level];
    [self.scene setScaleMode:SKSceneScaleModeAspectFill];
    [self.scene setGridManager:self.gridManager];
    [self.scene addUnderlyingIndicatorTiles];
    
    [skView presentScene:self.scene];
    
    [self _beginGame];
    [self _layoutBannerView];
}

- (void)_layoutBannerView
{
    self.bannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    [self.bannerView setDelegate:self];
    [self.view addSubview:self.bannerView];
    
    CGRect bannerFrame = self.bannerView.frame;
    bannerFrame.origin.y = CGRectGetHeight(self.view.bounds);
    [self.bannerView setFrame:bannerFrame];
    
    [self setBannerViewIsVisible:NO];
}

- (void)_beginGame
{
    [self.scene layoutNodesWithGrid:[self.gridManager hexagons]];
}

- (void)_applicationDidBecomeActive
{
    self.pauseGame = NO;
    [self.scene.view setPaused:self.pauseGame];
}

- (void)_applicationWillResignActive
{
    self.pauseGame = YES;
    [self.scene.view setPaused:self.pauseGame];
}

#pragma mark -
#pragma mark - <ADBannerView>

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerViewIsVisible) {
       [UIView animateWithDuration:.3f animations:^{
           [banner setFrame:CGRectOffset(self.bannerView.frame, 0.0, -CGRectGetHeight(self.bannerView.frame))];
       } completion:^(BOOL finished) {
           self.bannerViewIsVisible = YES;
       }];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.bannerViewIsVisible) {
        [UIView animateWithDuration:.3f animations:^{
            [banner setFrame:CGRectOffset(self.bannerView.frame, 0.0, CGRectGetHeight(self.bannerView.frame))];
        } completion:^(BOOL finished) {
            self.bannerViewIsVisible = NO;
        }];
    }
}

@end
