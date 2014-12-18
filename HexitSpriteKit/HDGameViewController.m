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

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) UILabel *completedLabel;
@property (nonatomic, strong) UILabel *completedCountLabel;

@property (nonatomic, strong) ADBannerView *bannerView;

@property (nonatomic, assign) NSUInteger totalTileCount;
@property (nonatomic, assign) NSUInteger completedTileCount;

@property (nonatomic, assign) BOOL pauseGame;
@property (nonatomic, assign) BOOL navigationBarHidden;
@property (nonatomic, assign) BOOL bannerViewIsVisible;

@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIButton *restart;

@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, strong) HDScene *scene;

@end

@implementation HDGameViewController {
    
    BOOL _RandomlyGeneratedLevel;
    BOOL _bannerViewIsVisible;
    
    NSDictionary *_views;
    NSDictionary *_metrics;
    
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
        
        [self setNavigationBarHidden:YES];
        [self setPauseGame:NO];
        [self setExpanded:NO];
        
    }
    return self;
}

- (instancetype)initWithRandomlyGeneratedLevel
{
    if (self = [super init]) {

        _RandomlyGeneratedLevel = YES;
        
        [self setPauseGame:NO];
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
                                             selector:@selector(_transformCompletedCountLabelY)
                                                 name:@"transform"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_updateCompletedTileCount)
                                                 name:@"UpdateCompletedTileCountNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_clearCompletedTileCount)
                                                 name:@"clearCompletedTileCountNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_nextLevel)
                                                 name:HDNextLevelNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_toggleNavigationBar)
                                                 name:HDToggleControlsNotification
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
    
    [self _layoutNavigationButtons];
    
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                                          action:@selector(handlePan:)];
    [leftEdgeGesture setEdges:UIRectEdgeLeft];
    [self.view addGestureRecognizer:leftEdgeGesture];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    SKView * skView = (SKView *)self.view;
    if (!skView.scene && self.gridManager) {
        [self _setupGame];
    }
}

- (void)restartGame
{
    [self.scene restart];
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

- (void)_setupGame
{
    SKView * skView = (SKView *)self.view;
    
     self.scene = [HDScene sceneWithSize:self.view.bounds.size];
    [self.scene setLevelIndex:_level];
    [self.scene setGridManager:self.gridManager];
    [self.scene layoutIndicatorTiles];
    
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
    NSArray *hexagons = [self.gridManager hexagons];
    
    [self setCompletedTileCount:0];
    [self setTotalTileCount:hexagons.count];
    [self.scene layoutNodesWithGrid:hexagons];
}

#pragma mark - 
#pragma mark - NSNotificationCenter

- (void)_clearCompletedTileCount
{
    [self setCompletedTileCount:0];
}

- (void)_updateCompletedTileCount
{
    self.completedTileCount++;
}

- (void)setCompletedTileCount:(NSUInteger)completedTileCount
{
    _completedTileCount = completedTileCount;
    [self _updateCompletedLabel];
}

- (void)setTotalTileCount:(NSUInteger)totalTileCount
{
    _totalTileCount = totalTileCount;
    [self _updateCompletedLabel];
}

- (void)_updateCompletedLabel
{
    [self.completedCountLabel setText:[NSString stringWithFormat:@"%lu/%lu",self.completedTileCount, self.totalTileCount]];
    [self.completedCountLabel sizeToFit];
    [self.completedCountLabel setCenter:CGPointMake(
                                                    CGRectGetMidX(self.view.bounds),
                                                    CGRectGetMaxY(self.completedLabel.frame) + CGRectGetMidY(self.completedCountLabel.bounds)
                                                    )];
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    [scale setByValue:@.2f];
    [scale setToValue:@1.2f];
    [scale setDuration:.2f];
    [scale setAutoreverses:YES];
    [self.completedCountLabel.layer addAnimation:scale forKey:@"BasicBitchesScale"];
    
}

- (void)_transformCompletedCountLabelY
{
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    [scale setByValue:@.2f];
    [scale setToValue:@1.2f];
    [scale setDuration:.2f];
    [scale setAutoreverses:YES];
    [self.completedCountLabel.layer addAnimation:scale forKey:@"BasicBitchesScale"];
}

- (void)_toggleNavigationBar
{
    [self setNavigationBarHidden:!self.navigationBarHidden];
}

- (void)_nextLevel
{
    _level++;
    
    self.gridManager = [[HDGridManager alloc] initWithLevelNumber:_level];
    [self.scene setLevelIndex:_level];
    [self.scene setGridManager:self.gridManager];
    [self.scene layoutIndicatorTiles];
    [self _beginGame];
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
#pragma mark - Layout Geometry

- (void)_layoutNavigationButtons
{
    HDContainerViewController *container = self.containerViewController;
    
    CGRect containerFrame = CGRectMake(0.0f, -70.0f, CGRectGetWidth(self.view.bounds), 70.0f);
    self.container = [[UIView alloc] initWithFrame:containerFrame];
    [self.container setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.container];
    
    self.completedLabel = [[UILabel alloc] init];
    [self.completedLabel setText:@"Completed"];
    [self.completedLabel setTextColor:[UIColor whiteColor]];
    [self.completedLabel setNumberOfLines:1];
    [self.completedLabel setTextAlignment:NSTextAlignmentCenter];
    [self.completedLabel setFont:GILLSANS_LIGHT(18.0f)];
    [self.completedLabel sizeToFit];
    [self.completedLabel setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.completedLabel.bounds) + 5.0f)];
    [self.container addSubview:self.completedLabel];
    
    self.completedCountLabel = [[UILabel alloc] init];
    [self.completedCountLabel setText:[NSString stringWithFormat:@"%lu,/%lu",_completedTileCount,_totalTileCount]];
    [self.completedCountLabel setTextColor:[UIColor whiteColor]];
    [self.completedCountLabel setNumberOfLines:1];
    [self.completedCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.completedCountLabel setFont:GILLSANS(38.0f)];
    [self.completedCountLabel sizeToFit];
    [self.completedCountLabel setCenter:CGPointMake(
                                                    CGRectGetMidX(self.view.bounds),
                                                    CGRectGetMaxY(self.completedLabel.frame) + CGRectGetMidY(self.completedCountLabel.bounds)
                                                    )];
    [self.container addSubview:self.completedCountLabel];
    
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.toggleButton setImage:[UIImage imageNamed:@"Grid"] forState:UIControlStateNormal];
    [self.toggleButton addTarget:container action:@selector(toggleHDMenuViewController) forControlEvents:UIControlEventTouchUpInside];
    
    self.restart = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.restart setImage:[UIImage imageNamed:@"Reset"] forState:UIControlStateNormal];
    [self.restart addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *button in @[self.toggleButton, self.restart]) {
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.container addSubview:button];
    }
    
    UIButton *toggle = self.toggleButton;
    UIButton *share  = self.restart;
    
    _views = NSDictionaryOfVariableBindings(toggle, share);
    
    _metrics = @{ @"buttonHeight" : @(42.0f), @"inset" : @(20.0f) };
    
    NSArray *toggleHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[toggle(buttonHeight)]"
                                                                                  options:0
                                                                                  metrics:_metrics
                                                                                    views:_views];
    [self.view addConstraints:toggleHorizontalConstraint];
    
    NSArray *toggleVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[toggle(buttonHeight)]"
                                                                                  options:0
                                                                                  metrics:_metrics
                                                                                    views:_views];
    [self.view addConstraints:toggleVerticalConstraint];
    
    NSArray *shareHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[share(buttonHeight)]-inset-|"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
    [self.view addConstraints:shareHorizontalConstraint];
    
    NSArray *shareVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[share(buttonHeight)]"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
    [self.view addConstraints:shareVerticalConstraint];
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    _navigationBarHidden = navigationBarHidden;
    
    if (_navigationBarHidden) {
        [self hideAnimated:YES];
    } else {
        [self showAnimated:YES];
    }
}

- (void)hideAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGRect rect = self.container.frame;
        rect.origin.y = -70.0f;
        [self.container setFrame:rect];
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.3f animations:animate];
    }
}

- (void)showAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGRect rect = self.container.frame;
        rect.origin.y = 0.0f;
        [self.container setFrame:rect];
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.3f animations:animate];
    }
}

#pragma mark -
#pragma mark - <UIScreenEdgeGestureRecognizer>

- (void)handlePan:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
         HDContainerViewController *container = self.containerViewController;
        [container toggleHDMenuViewController];
        return;
    }
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

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setNavigationBarHidden:NO];
}

@end
