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
#import "HDHexusIAdHelper.h"
#import "HDLevelGenerator.h"
#import "HDMenuBar.h"
#import "UIColor+ColorAdditions.h"
#import "HDGameViewController.h"
#import "HDContainerViewController.h"
#import "HDGameCenterManager.h"
#import "HDCompletionView.h"
#import "HDSoundManager.h"
#import "HDSettingsManager.h"
#import "HDGridManager.h"
#import "HDHintsView.h"
#import "HDGameScene.h"

#define NC [NSNotificationCenter defaultCenter]

@interface HDGameViewController () <ADBannerViewDelegate, HDSceneDelegate, HDCompletionViewDelegate>
@property (nonatomic, strong) HDMenuBar     *menuBar;
@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, strong) HDGameScene   *scene;
@property (nonatomic, strong) HDCompletionView *completionView;
@property (nonatomic, strong) ADBannerView  *bannerView;
@property (nonatomic, assign) BOOL navigationBarHidden;
@end

@implementation HDGameViewController {
    
    BOOL _isBannerVisible;
    
    NSUInteger _levelIdx;
    
    HDHintsView *_hints;
}

- (void)dealloc {
    [NC removeObserver:self name:IAPHelperProductPurchasedNotification     object:nil];
    [NC removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [NC removeObserver:self name:UIApplicationDidBecomeActiveNotification  object:nil];
}

- (instancetype)initWithLevel:(NSInteger)level {
    if (self = [super init]) {
        _levelIdx = level;
         self.gridManager = [[HDGridManager alloc] initWithLevelIndex:_levelIdx];
    }
    return self;
}

- (void)loadView {
    CGRect viewRect = [[UIScreen mainScreen] bounds];
    SKView *skView = [[SKView alloc] initWithFrame:viewRect];
    self.view = skView;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    
    HDContainerViewController *container = self.containerViewController;
    
    const CGFloat menuBarHeight = CGRectGetHeight(self.view.bounds)/8;
    CGRect menuBarFrame = CGRectMake(0.0f, -menuBarHeight, CGRectGetWidth(self.view.bounds), menuBarHeight);
    self.menuBar = [HDMenuBar menuBarWithActivityImage:[UIImage imageNamed:@"PauseGame"]];
    self.menuBar.frame = menuBarFrame;
    [self.menuBar.activityButton setBackgroundImage:[UIImage imageNamed:@"unpause"]
                                           forState:UIControlStateSelected];
    [self.menuBar.navigationButton addTarget:container
                                      action:@selector(toggleMenuViewController)
                            forControlEvents:UIControlEventTouchUpInside];
    [self.menuBar.activityButton addTarget:self
                                    action:@selector(toggleGameState:)
                          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menuBar];
    
    [NC addObserver:self selector:@selector(_removeAdsWasPurchased:)       name:IAPHelperProductPurchasedNotification object:nil];
    [NC addObserver:self selector:@selector(_applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [NC addObserver:self selector:@selector(_applicationDidBecomeActive:)  name:UIApplicationDidBecomeActiveNotification  object:nil];
}

#pragma mark - Public

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    
    _navigationBarHidden = navigationBarHidden;
    if (_navigationBarHidden) {
        [self _hideAnimated:YES];
    } else {
        [self _showAnimated:YES];
    }
}

#pragma mark - Life cycle

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    if (!skView.scene && self.gridManager) {
        
        self.scene = [HDGameScene sceneWithSize:self.view.bounds.size];
        self.scene.myDelegate = self;
        self.scene.levelIndex = _levelIdx;
        self.scene.gridManager = self.gridManager;
        [skView presentScene:self.scene];
        [self _beginGame];
    }
    
    BOOL bannersRemoved = [[NSUserDefaults standardUserDefaults] boolForKey:IAPremoveAdsProductIdentifier];
    if (!self.bannerView && !bannersRemoved) {
        
        self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyManual;
        
        [UIViewController prepareInterstitialAds];
        
        self.bannerView = [[ADBannerView alloc] init];
        self.bannerView.delegate = self;
        [self.view addSubview:self.bannerView];
        
        CGRect bannerFrame = self.bannerView.frame;
        bannerFrame.origin.y = CGRectGetHeight(self.view.bounds);
        self.bannerView.frame = bannerFrame;
    }
}

#pragma mark - Private

- (void)_displayInterstitialAd {
    BOOL bannersRemoved = [[NSUserDefaults standardUserDefaults] boolForKey:IAPremoveAdsProductIdentifier];
    if ([self _rollTheDice] && !bannersRemoved) {
        [self requestInterstitialAdPresentation];
    }
}

- (void)_beginGame {
    
    [self.scene layoutNodesWithGrid:[self.gridManager hexagons]
                         completion:nil];
    
    if (_levelIdx % 28 == 1 || _levelIdx == 1) {
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%zd",_levelIdx]]) {
            
            [self _showTipsWithDescription:descriptionForLevelIdx(_levelIdx)
                                     title:NSLocalizedString(HDTitleLocalizationKey, nil)
                                     images:[HDHelper imageFromLevelIdx:_levelIdx]];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES
                                                    forKey:[NSString stringWithFormat:@"%zd",_levelIdx]];
        }
    }
}

- (void)_showTipsWithDescription:(NSString *)description title:(NSString *)title images:(NSArray *)images {
    
    
    const CGFloat height = IS_IPAD ? CGRectGetHeight(self.view.bounds)/5.5f
                                   : CGRectGetHeight(self.view.bounds)/5.0f;
    
    CGRect hintsFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), height);
    
    _hints = [[HDHintsView alloc] initWithFrame:hintsFrame
                                                 title:title
                                           description:description
                                                images:images];
    _hints.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetHeight(self.view.bounds) + height/2);
    [self.view insertSubview:_hints atIndex:0];
    
    [UIView animateWithDuration:.300f
                          delay:.500f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         CGPoint position = _hints.center;
                         CGFloat bannerHeight = ((_isBannerVisible) ? self.bannerView.bounds.size.height : 0);
                         position.y = CGRectGetHeight(self.view.bounds) - CGRectGetMidY(_hints.bounds) - bannerHeight;
                         _hints.center = position;
                         
                     } completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:.300f
                                               delay:2.5f
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              
                             CGPoint position = _hints.center;
                             position.y = CGRectGetHeight(self.view.bounds) + CGRectGetMidY(_hints.bounds);
                             _hints.center = position;
                                              
                         } completion:^(BOOL finished){
                             [_hints removeFromSuperview];
                         }];
                     }];
}

- (void)_hideAnimated:(BOOL)animated {
    
    dispatch_block_t animate = ^{
        CGRect rect = self.menuBar.frame;
        rect.origin.y = -CGRectGetHeight(self.menuBar.bounds);
        self.menuBar.frame = rect;
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.300f animations:animate];
    }
}

- (void)_showAnimated:(BOOL)animated {
    
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

- (BOOL)_rollTheDice {
    return (arc4random() % 2 == 1);
}

- (IBAction)toggleGameState:(UIButton *)activityButton {
    [self _restartWithAlert:NO];
}

- (IBAction)restart:(id)sender {
    [self.scene restartWithAlert:YES];
    self.scene.userInteractionEnabled = YES;
}

- (void)_restartWithAlert:(BOOL)alert {
    [self _displayInterstitialAd];
    [self.scene restartWithAlert:alert];
}

- (void)performExitAnimationWithCompletion:(dispatch_block_t)completion {
    
    self.navigationBarHidden = YES;
    
    NSError *error = nil;
    [self bannerView:self.bannerView didFailToReceiveAdWithError:error];
    
    if (self.completionView) {
        [self.scene.gameLayer runAction:[SKAction moveToY:0.0f duration:.300f]];
    }
    
    [self.scene performExitAnimationsWithCompletion:^{
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Notifications

- (void)_applicationDidBecomeActive:(NSNotification *)notification {
    self.pauseGame = NO;
    self.scene.view.paused = self.pauseGame;
}

- (void)_applicationWillResignActive:(NSNotification *)notification {
    self.pauseGame = YES;
    self.scene.view.paused = self.pauseGame;
}

#pragma mark - <HDSceneDelegate>

- (void)gameRestartedInScene:(HDScene *)scene alert:(BOOL)alert {
    
    [self _displayInterstitialAd];
    
    [[HDSoundManager sharedManager] playSound:HDGameOverKey];
    
    if (alert) {
        [self _showTipsWithDescription:NSLocalizedString(@"nextTime", nil)
                                 title:NSLocalizedString(@"ohNo", nil)
                                images:@[[UIImage imageNamed:@"Default-Mine"]]];
    }
}

- (void)scene:(HDScene *)scene proceededToLevel:(NSUInteger)level {
    
    _levelIdx += 1;
    self.gridManager = [[HDGridManager alloc] initWithLevelIndex:level];
    self.scene.gridManager = self.gridManager;
    [self _beginGame];
}

- (void)scene:(HDScene *)scene gameEndedWithCompletion:(BOOL)completion {
    
    if (completion) {
        
        self.navigationBarHidden = YES;
        if (!self.completionView) {
            
            const CGFloat height = IS_IPAD ? CGRectGetHeight(self.view.bounds)/5.5f
                                           : CGRectGetHeight(self.view.bounds)/5.0f;
            
            CGRect hintsFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), height);
            self.completionView = [[HDCompletionView alloc] initWithFrame:hintsFrame
                                                                     time:NSLocalizedString(@"amazing!", nil)];
            self.completionView.delegate = self;
            self.completionView.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                                     CGRectGetHeight(self.view.bounds) + CGRectGetMidY(self.completionView.bounds));
            [self.view insertSubview:self.completionView atIndex:0];
            
            [UIView animateWithDuration:.300f
                             animations:^{
                CGRect frame = self.completionView.frame;
                frame.origin.y =  CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.completionView.bounds) - ((_isBannerVisible) ? self.bannerView.bounds.size.height : 0);
                self.completionView.frame = frame;
            }];
        }
    
        [self.scene.gameLayer runAction:[SKAction moveToY:CGRectGetHeight(self.view.bounds)/7 duration:.300f]];
        
        return;
    }
    [self performSelector:@selector(restart:) withObject:nil afterDelay:.300f];
}

- (void)_dismissCompletionViewWithCompletion:(dispatch_block_t)completion {
    
    [self.scene.gameLayer runAction:[SKAction moveToY:0.0f duration:.300f]];
    
    [UIView animateWithDuration:.300f animations:^{
        CGRect frame = self.completionView.frame;
        frame.origin.y = CGRectGetHeight(self.view.bounds);
        self.completionView.frame = frame;
    } completion:^(BOOL finished) {
        
        if (completion) {
            completion();
        }
        
        [self.completionView removeFromSuperview];
        self.completionView = nil;
    }];
}

- (void)gameWillResetInScene:(HDScene *)scene {
    self.navigationBarHidden = NO;
}

#pragma mark - <ADBannerViewDelegate>

- (void)_removeAdsWasPurchased:(NSNotification *)notification {
    
    NSString *productIdentifier = notification.object;
    if (![productIdentifier isEqualToString:IAPremoveAdsProductIdentifier]) {
        return;
    }
    
    [UIView animateWithDuration:.300f animations:^{
        
        CGRect bannerFrame = self.bannerView.frame;
        bannerFrame.origin.y = CGRectGetHeight(self.view.bounds);
        self.bannerView.frame = bannerFrame;
        
        if (_hints) {
            CGRect frame = _hints.frame;
            frame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(_hints.frame);
            _hints.frame = frame;
        } else if (self.completionView){
            CGRect frame = self.completionView.frame;
            frame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.completionView.frame);
            self.completionView.frame = frame;
        }
    } completion:^(BOOL finished) {
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
    }];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    
    const CGFloat bannerHeight = CGRectGetHeight(self.bannerView.bounds);
    
    if (!_isBannerVisible) {
        [UIView animateWithDuration:.300f animations:^{
            
            CGRect bannerFrame = self.bannerView.frame;
            bannerFrame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.bannerView.bounds);
            self.bannerView.frame = bannerFrame;
            
            if (_hints) {
                CGRect frame = _hints.frame;
                frame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(_hints.frame) - bannerHeight;
                _hints.frame = frame;
            } else if (self.completionView){
                CGRect frame = self.completionView.frame;
                frame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.completionView.frame) - bannerHeight;
                self.completionView.frame = frame;
            }
        }];
        _isBannerVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    
    if (_isBannerVisible) {
        [UIView animateWithDuration:.300f animations:^{
            
            CGRect bannerFrame = self.bannerView.frame;
            bannerFrame.origin.y = CGRectGetHeight(self.view.bounds);
            self.bannerView.frame = bannerFrame;
            
            if (_hints) {
                CGRect frame = _hints.frame;
                frame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(_hints.frame);
                _hints.frame = frame;
            } else if (self.completionView){
                CGRect frame = self.completionView.frame;
                frame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.completionView.frame);
                self.completionView.frame = frame;
            }
        }];
        _isBannerVisible = NO;
    }
}

#pragma mark - <HDCompletionViewDelegate>

- (void)completionView:(HDCompletionView *)completionView selectedButtonWithTitle:(NSString *)title {
    
    if ([title isEqualToString:NSLocalizedString(HDNextKey, nil)]) {
        [self.scene stopTileAnimationForCompletion];
        [self _dismissCompletionViewWithCompletion:^{
            [self.scene nextLevel];
        }];
    } else if ([title isEqualToString:NSLocalizedString(HDRestartKey, nil)]) {
        [self.scene stopTileAnimationForCompletion];
        [self _dismissCompletionViewWithCompletion:^{
            [self _restartWithAlert:NO];
            self.navigationBarHidden = NO;
        }];
    } else if ([title isEqualToString:NSLocalizedString(HDRateKey, nil)]) {
        [[HDAppDelegate sharedDelegate] rateHEXUS];
    } else if ([title isEqualToString:NSLocalizedString(HDShareKey, nil)]) {
        [[HDAppDelegate sharedDelegate] presentActivityViewController];
    }
}

@end
