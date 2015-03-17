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
#import "UIColor+FlatColors.h"
#import "HDGameViewController.h"
#import "HDContainerViewController.h"
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
@property (nonatomic, strong) HDHintsView   *hintsView;
@property (nonatomic, strong) HDCompletionView *completionView;
@property (nonatomic, strong) ADBannerView  *bannerView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL pauseGame;
@property (nonatomic, assign) BOOL navigationBarHidden;
@end

@implementation HDGameViewController {
    BOOL _isBannerVisible;
    NSUInteger _levelIdx;
    NSTimeInterval _startingInterval;
}

- (void)dealloc {
    [NC removeObserver:self name:IAPHelperProductPurchasedNotification     object:nil];
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
        } else if (self.completionView) {
            CGRect frame = self.completionView.frame;
            frame.origin.y = CGRectGetHeight(self.view.bounds);
            self.completionView.frame = frame;
        }
    }];
    
    if (self.completionView) {
        [self.scene.gameLayer runAction:[SKAction moveToY:0.0f duration:.300f]];
    }
    
    [self.scene performExitAnimationsWithCompletion:^{
        if (completion) {
            completion();
        }
    }];
}

- (void)loadView {
    CGRect viewRect = [[UIScreen mainScreen] bounds];
    SKView *skView = [[SKView alloc] initWithFrame:viewRect];
    self.view = skView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIViewController prepareInterstitialAds];
    [self _setup];
    self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyManual;
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
    
    if (!self.bannerView && ![[NSUserDefaults standardUserDefaults] boolForKey:@"AdsRemovedKey"]) {
        self.bannerView = [[ADBannerView alloc] init];
        self.bannerView.delegate = self;
        [self.view addSubview:self.bannerView];
        
        CGRect bannerFrame = self.bannerView.frame;
        bannerFrame.origin.y = CGRectGetHeight(self.view.bounds);
        self.bannerView.frame = bannerFrame;
    }
}

#pragma mark - Private

- (void)_setup {
    
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    
    self.gridManager = [[HDGridManager alloc] initWithLevelIndex:_levelIdx];
    
    HDContainerViewController *container = self.containerViewController;
    
    //
    const CGFloat menuBarHeight = CGRectGetHeight(self.view.bounds)/8;
    CGRect menuBarFrame = CGRectMake(0.0f, -menuBarHeight, CGRectGetWidth(self.view.bounds), menuBarHeight);
    self.menuBar = [HDMenuBar menuBarWithActivityImage:nil];
    self.menuBar.frame = menuBarFrame;
    [self.menuBar.navigationButton setBackgroundImage:[UIImage imageNamed:@"GridIcon-Blue"] forState:UIControlStateNormal];
    [self.menuBar.navigationButton addTarget:container
                                      action:@selector(toggleMenuViewController)
                            forControlEvents:UIControlEventTouchUpInside];
    [self.menuBar.activityButton addTarget:self
                                    action:@selector(restart:)
                          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menuBar];
    
//    // Move to Menu Bar
//    self.timeLabel = [[UILabel alloc] init];
//    self.timeLabel.textAlignment = NSTextAlignmentCenter;
//    self.timeLabel.font = GILLSANS(28.0f);
//    self.timeLabel.textColor = [[UIColor flatPeterRiverColor] colorWithAlphaComponent:.7];
//    self.timeLabel.center = self.menuBar.activityButton.center;
//    [self.menuBar addSubview:self.timeLabel];
    
    [NC addObserver:self selector:@selector(_removeAdsWasPurchased:)       name:IAPHelperProductPurchasedNotification object:nil];
    [NC addObserver:self selector:@selector(_applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [NC addObserver:self selector:@selector(_applicationDidBecomeActive:)  name:UIApplicationDidBecomeActiveNotification  object:nil];
}

- (void)_displayInterstitialAd {
    
    if ([self rollTheDice]) {
        [self requestInterstitialAdPresentation];
    }
}

- (void)_beginGame {
    
    NSArray *hexagons = [self.gridManager hexagons];
    [self.scene layoutNodesWithGrid:hexagons completion:nil];
    if (_levelIdx % 28 == 1 || _levelIdx == 1) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%zd",_levelIdx]]) {
            [self _showTipsWithDescription:descriptionForLevelIdx(_levelIdx)
                                     images:[HDHelper imageFromLevelIdx:_levelIdx]];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%zd",_levelIdx]];
        }
    }
}

- (void)_showTipsWithDescription:(NSString *)description images:(NSArray *)images {
    [self _showTipsWithDescription:description title:HDTitleLocalizationKey images:images];
}

- (void)_showTipsWithDescription:(NSString *)description title:(NSString *)title images:(NSArray *)images {
    
    if (!self.hintsView) {
        
        CGRect hintsFrame = CGRectMake(0.0f,
                                       CGRectGetHeight(self.view.bounds),
                                       CGRectGetWidth(self.view.bounds),
                                       CGRectGetHeight(self.view.bounds)/5);
        
        self.hintsView = [[HDHintsView alloc] initWithFrame:hintsFrame
                                                      title:title
                                                description:description
                                                     images:images];
        
        [self.view insertSubview:self.hintsView atIndex:0];
    }
    
    [UIView animateWithDuration:.300f delay:.750f options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.hintsView.frame;
        frame.origin.y = CGRectGetHeight(self.view.bounds)/1.25f - ((_isBannerVisible) ? self.bannerView.bounds.size.height : 0);
        self.hintsView.frame = frame;
    } completion:^(BOOL finished){
        [self performSelector:@selector(_dismissHintsView) withObject:nil afterDelay:3.5f];
    }];
}

- (void)_dismissHintsView {
    
    [UIView animateWithDuration:.300f animations:^{
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

- (BOOL)rollTheDice {
    return (arc4random() % 2 == 1);
}

- (IBAction)restart:(id)sender {
    UIButton *restartButton = (UIButton *)sender;
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [restartButton.layer removeAllAnimations];
    }];
    
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotation.byValue = @(M_PI*2);
    rotation.duration = .3f;
    [restartButton.layer addAnimation:rotation forKey:rotation.keyPath];
    
    [CATransaction commit];
    [self _restartWithAlert:YES];
}

- (void)_restartWithAlert:(BOOL)alert {
    [self _displayInterstitialAd];
    [self.scene restartWithAlert:alert];
}

- (void)_startTheTimer {
    
//    if (self.timer) {
//        return;
//    }
//    
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(_tickTock) userInfo:nil repeats:YES];
//    _startingInterval = [NSDate timeIntervalSinceReferenceDate];
//    [self.timer fire];
}

- (void)_tickTock {
    
//    NSTimeInterval _timeInterval = [NSDate timeIntervalSinceReferenceDate] - _startingInterval;
//    
//    NSInteger minutes = _timeInterval/60;
//    _timeInterval -= ((NSTimeInterval)minutes * 60);
//    
//    NSInteger seconds = (NSInteger)_timeInterval;
//    _timeInterval -= (NSTimeInterval)seconds;
//    
//    NSInteger millisec = (NSTimeInterval)_timeInterval * 100;
//    
//    NSString *minute = minutes  > 9 ? [NSString stringWithFormat:@"%zd",minutes]  : [NSString stringWithFormat:@"0%zd",minutes];
//    NSString *second = seconds  > 9 ? [NSString stringWithFormat:@"%zd",seconds]  : [NSString stringWithFormat:@"0%zd",seconds];
//    NSString *millis = millisec > 9 ? [NSString stringWithFormat:@"%zd",millisec] : [NSString stringWithFormat:@"0%zd",millisec];
//    
//    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@:%@",minute,second,millis];
//    [self.timeLabel sizeToFit];
//    self.timeLabel.center = CGPointMake(CGRectGetMidX(self.menuBar.bounds), CGRectGetMidY(self.menuBar.bounds));
//    self.timeLabel.frame = CGRectIntegral(self.timeLabel.frame);
//    
//    NSLog(@"%@:%@:%@",minute,second,millis);
}

- (void)_stopTheClock {
//    [self.timer invalidate];
//    self.timer = nil;
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

- (void)startTileWasSelectedInScene:(HDScene *)scene {
    [self _startTheTimer];
}

- (void)gameRestartedInScene:(HDScene *)scene alert:(BOOL)alert {
    
    [self _stopTheClock];
    [self _displayInterstitialAd];
    if (alert) {
       [self _showTipsWithDescription:@"Better luck next time!" title:@"Oh No!" images:@[]];
    }
}

- (void)scene:(HDScene *)scene proceededToLevel:(NSUInteger)level {
    
    _levelIdx += 1;
    [self _stopTheClock];
    self.gridManager = [[HDGridManager alloc] initWithLevelIndex:level];
    self.scene.gridManager = self.gridManager;
    [self _beginGame];
}

- (void)scene:(HDScene *)scene gameEndedWithCompletion:(BOOL)completion {
    
    if (completion) {
        
        [self _stopTheClock];
        [[HDSoundManager sharedManager] playSound:HDCompletionZing];
        
        self.navigationBarHidden = YES;
        if (!self.completionView) {
            
            CGRect hintsFrame = CGRectMake(0.0f,
                                           CGRectGetHeight(self.view.bounds),
                                           CGRectGetWidth(self.view.bounds),
                                           CGRectGetHeight(self.view.bounds)/5);
            
            self.completionView = [[HDCompletionView alloc] initWithFrame:hintsFrame];
            self.completionView.delegate = self;
            [self.view insertSubview:self.completionView atIndex:0];
        }
        
        [UIView animateWithDuration:.300f animations:^{
            CGRect frame = self.completionView.frame;
            frame.origin.y = CGRectGetHeight(self.view.bounds)/1.25f - ((_isBannerVisible) ? self.bannerView.bounds.size.height : 0);
            self.completionView.frame = frame;
        }];
        
        [self.scene.gameLayer runAction:[SKAction moveToY:CGRectGetHeight(self.view.bounds)/7 duration:.300f]];
        
    } else {
        [self performSelector:@selector(restart:) withObject:nil afterDelay:.300f];
    }
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
    } completion:^(BOOL finished) {
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
        _isBannerVisible = NO;
    }];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    
    if (_isBannerVisible) {
        [UIView animateWithDuration:.300f animations:^{
            
            CGRect bannerFrame = self.bannerView.frame;
            bannerFrame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.bannerView.bounds);
            self.bannerView.frame = bannerFrame;
            
            if (self.hintsView) {
                CGRect frame = self.hintsView.frame;
                frame.origin.y = CGRectGetHeight(self.view.bounds)/1.25f - CGRectGetHeight(self.bannerView.bounds);
                self.hintsView.frame = frame;
            } else if (self.completionView){
                CGRect frame = self.completionView.frame;
                frame.origin.y = CGRectGetHeight(self.view.bounds)/1.25f - CGRectGetHeight(self.bannerView.bounds);
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
            
            if (self.hintsView) {
                CGRect frame = self.hintsView.frame;
                frame.origin.y = CGRectGetHeight(self.view.bounds)/1.25f;
                self.hintsView.frame = frame;
            } else if (self.completionView){
                CGRect frame = self.completionView.frame;
                frame.origin.y = CGRectGetHeight(self.view.bounds)/1.25f;
                self.completionView.frame = frame;
            }
        }];
        _isBannerVisible = NO;
    }
}

#pragma mark - <HDCompletionViewDelegate>

- (void)completionView:(HDCompletionView *)completionView selectedButtonWithTitle:(NSString *)title {
    
    if ([title isEqualToString:HDNextKey]) {
        [self.scene removeConfettiEmitter];
        [self _dismissCompletionViewWithCompletion:^{
            [self.scene nextLevel];
        }];
    } else if ([title isEqualToString:HDRestartKey]) {
        [self.scene removeConfettiEmitter];
        [self _dismissCompletionViewWithCompletion:^{
            [self _restartWithAlert:NO];
            self.navigationBarHidden = NO;
        }];
    } else if ([title isEqualToString:HDRateKey]) {
        [ADelegate rateHEXUS];
    } else if ([title isEqualToString:HDShareKey]) {
        [ADelegate presentShareViewControllerWithLevelIndex:_levelIdx];
    }
}

@end
