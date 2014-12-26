//
//  ViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "HDLevelGenerator.h"
#import "HDNavigationBar.h"
#import "UIColor+FlatColors.h"
#import "HDContainerViewController.h"
#import "HDGameViewController.h"
#import "HDGridManager.h"
#import "HDScene.h"

static const CGFloat kDefaultContainerHeight = 70.0f;
static const CGFloat kPadding    = 5.0f;
@interface HDGameViewController () <HDSceneDelegate>

@property (nonatomic, strong) HDNavigationBar *navigationBar;

@property (nonatomic, strong) UILabel *completedLabel;
@property (nonatomic, strong) UILabel *completedCountLabel;

@property (nonatomic, assign) NSUInteger totalTileCount;
@property (nonatomic, assign) NSUInteger completedTileCount;

@property (nonatomic, assign) BOOL pauseGame;
@property (nonatomic, assign) BOOL restartButtonHidden;
@property (nonatomic, assign) BOOL navigationBarHidden;

@property (nonatomic, strong) UIButton *restart;

@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, strong) HDScene *scene;

@end

@implementation HDGameViewController {
    BOOL _randomlyGeneratedLevel;
    
    NSDictionary *_views;
    NSDictionary *_metrics;
    
    NSInteger _level;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification  object:nil];
}

- (id)initWithLevel:(NSInteger)level
{
    if (self = [super init]) {
    
        _level = level;
        _randomlyGeneratedLevel = NO;
        self.pauseGame = NO;
    }
    return self;
}

- (instancetype)initWithRandomlyGeneratedLevel
{
    if (self = [super init]) {
        
        _randomlyGeneratedLevel = YES;
        self.pauseGame = NO;
        
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
    self.view.backgroundColor = [UIColor flatMidnightBlueColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    if (!_randomlyGeneratedLevel) {
        self.gridManager = [[HDGridManager alloc] initWithLevelNumber:_level];
    } else {
//        HDLevelGenerator *generator = [[HDLevelGenerator alloc] init];
//        [generator setNumberOfTiles:4];
//        
//        [generator generateWithCompletionHandler:^(NSDictionary *dictionary, NSError *error) {
//            if (!error) {
//                 self.gridManager = [[HDGridManager alloc] initWithRandomLevel:dictionary];
//                [self _setupGame];
//            }
//        }];
    }
    [self _setup];
}

#pragma mark - Public

- (void)setRestartButtonHidden:(BOOL)restartButtonHidden
{
    _restartButtonHidden = restartButtonHidden;
    
    if (_restartButtonHidden) {
        [self _hideRestartAnimated:YES];
    } else {
        [self _showRestartAnimated:YES];
    }
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    _navigationBarHidden = navigationBarHidden;
    
    if (_navigationBarHidden) {
        [self _hideAnimated:YES];
    } else {
        [self _showAnimated:YES];
    }
}

- (void)restartGame
{
    if (!self.restartButtonHidden) {
        self.restartButtonHidden = YES;
    }
    [self.scene restart];
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

#pragma mark - Private

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    SKView * skView = (SKView *)self.view;
    if (!skView.scene && self.gridManager) {
        [self _setupScene];
    }
}

- (void)_setup
{
    HDContainerViewController *container = self.containerViewController;
    
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture;
    leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    leftEdgeGesture.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:leftEdgeGesture];
    
    UIScreenEdgePanGestureRecognizer *rightEdgeGesture;
    rightEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    rightEdgeGesture.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:rightEdgeGesture];
    
    CGRect navBarFrame = CGRectMake(0.0f, -kDefaultContainerHeight, CGRectGetWidth(self.view.bounds), kDefaultContainerHeight);
    self.navigationBar = [HDNavigationBar viewWithToggleImage:[UIImage imageNamed:@"Grid"] activityImage:[UIImage new]];
    self.navigationBar.frame = navBarFrame;
    [[self.navigationBar.subviews firstObject] addTarget:container
                                                  action:@selector(toggleMenuViewController)
                                        forControlEvents:UIControlEventTouchUpInside];
    [[self.navigationBar.subviews lastObject] addTarget:self
                                                 action:@selector(restartGame)
                                       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.navigationBar];
    
    self.restart = [self _restartButton];
    [self.view addSubview:self.restart];
    
    self.completedLabel = [self _completionLabel];
    [self.navigationBar addSubview:self.completedLabel];
    
    self.completedCountLabel = [self _completedCountLabel];
    [self.navigationBar addSubview:self.completedCountLabel];
}

- (void)_setupScene
{
    SKView * skView = (SKView *)self.view;
    
    self.scene = [HDScene sceneWithSize:self.view.bounds.size];
    self.scene.delegate = self;
    self.scene.levelIndex = _level;
    self.scene.gridManager = self.gridManager;
    [self.scene layoutIndicatorTiles];
    
    [skView presentScene:self.scene];
}

- (void)_beginGame
{
    NSArray *hexagons = [self.gridManager hexagons];
    
    self.completedTileCount = 0;
    self.totalTileCount = hexagons.count;
    [self.scene layoutNodesWithGrid:hexagons];
}

- (void)_hideAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGRect rect = self.navigationBar.frame;
        rect.origin.y = -kDefaultContainerHeight;
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

- (void)_hideRestartAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGPoint position = self.restart.center;
        position.y = CGRectGetHeight(self.view.bounds) + CGRectGetMidX(self.restart.bounds);
        self.restart.center = position;
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.3f animations:animate];
    }
}

- (void)_showRestartAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGPoint position = self.restart.center;
        position.y = CGRectGetHeight(self.view.bounds) - (CGRectGetMidY(self.restart.bounds) + 20.0f);
        self.restart.center = position;
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.3f animations:animate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationBarHidden = NO;
    [super viewDidAppear:animated];
    [self _beginGame];
}

- (void)performExitAnimationWithCompletion:(dispatch_block_t)completion
{
    self.navigationBarHidden = YES;
    [self.scene performExitAnimationsWithCompletion:completion];
}

- (void)_updateCompletedLabel
{
    self.completedCountLabel.text = [NSString stringWithFormat:@"%lu/%lu",self.completedTileCount, self.totalTileCount];
    [self.completedCountLabel sizeToFit];
    
    CGPoint position = CGPointMake(
                                   CGRectGetMidX(self.view.bounds),
                                   CGRectGetMaxY(self.completedLabel.frame) + CGRectGetMidY(self.completedCountLabel.bounds) -kPadding/2
                                   );
    
    [self _scaleAnimationOnKeyPath:@"transform.scale.x"];
    [self.completedCountLabel setCenter:position];
}

- (void)_scaleAnimationOnKeyPath:(NSString *)keyPath
{
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:keyPath];
    scale.byValue = @.2f;
    scale.toValue = @1.2f;
    scale.duration = .2f;
    scale.autoreverses = YES;
    [self.completedCountLabel.layer addAnimation:scale forKey:@"scale"];
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
    _level = level;
    
    self.gridManager = [[HDGridManager alloc] initWithLevelNumber:_level];
    self.scene.delegate = self;
    self.scene.gridManager = self.gridManager;
    [self.scene layoutIndicatorTiles];
    [self _beginGame];
}

- (void)scene:(HDScene *)scene updatedSelectedTileCount:(NSUInteger)count
{
    self.completedTileCount = count;
}

- (void)scene:(HDScene *)scene gameEndedWithCompletion:(BOOL)completion
{
    if (completion) {
        self.navigationBarHidden = YES;
    } else {
        self.restartButtonHidden = NO;
    }
}

- (void)multipleTouchTileWasTouchedInScene:(HDScene *)scene
{
    [self _scaleAnimationOnKeyPath:@"transform.scale.y"];
}

- (void)gameWillResetInScene:(HDScene *)scene
{
    self.navigationBarHidden = NO;
}

#pragma mark - <UIScreenEdgeGestureRecognizer>

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
         HDContainerViewController *container = self.containerViewController;
        [container toggleMenuViewController];
        return;
    }
}

#pragma mark - Button

- (UIButton *)_restartButton
{
    CGRect restartBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(CGRectInset(self.view.bounds, 20.0f, 0.0f)), 44.0f);
    UIButton *restartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    restartButton.frame = restartBounds;
    [restartButton addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
    [restartButton setTitle:@"Try Again" forState:UIControlStateNormal];
    [restartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [restartButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [restartButton.titleLabel setFont:GILLSANS_LIGHT(22.0f)];
    restartButton.layer.borderColor  = [[UIColor whiteColor] CGColor];
    restartButton.layer.borderWidth  = 5.0f;
    restartButton.layer.cornerRadius = 5.0f;
    restartButton.center = CGPointMake(
                                       CGRectGetMidX(self.view.bounds),
                                       CGRectGetHeight(self.view.bounds) + CGRectGetMidX(restartBounds)
                                       );
    
    return restartButton;
}

#pragma mark - Labels

- (UILabel *)_completedCountLabel
{
    UILabel *completedCountLabel = [[UILabel alloc] init];
    completedCountLabel.textColor = [UIColor whiteColor];
    completedCountLabel.numberOfLines = 1;
    completedCountLabel.textAlignment = NSTextAlignmentCenter;
    completedCountLabel.font = GILLSANS(40.0f);
    [completedCountLabel sizeToFit];
    completedCountLabel.center = CGPointMake(
                                            CGRectGetMidX(self.view.bounds),
                                            CGRectGetMaxY(self.completedLabel.frame) + CGRectGetMidY(completedCountLabel.bounds) -kPadding/2
                                            );
    completedCountLabel.frame = CGRectIntegral(completedCountLabel.frame);
    
    return completedCountLabel;
}

- (UILabel *)_completionLabel
{
    UILabel *completedLabel = [[UILabel alloc] init];
    completedLabel.text = @"Completed";
    completedLabel.textColor = [UIColor whiteColor];
    completedLabel.numberOfLines = 1;
    completedLabel.textAlignment = NSTextAlignmentCenter;
    completedLabel.font = GILLSANS_LIGHT(18.0f);
    [completedLabel sizeToFit];
    completedLabel.center = CGPointMake(
                                        CGRectGetMidX(self.view.bounds),
                                        CGRectGetMidY(completedLabel.bounds) + kPadding
                                        );
    completedLabel.frame = CGRectIntegral(completedLabel.frame);

    return completedLabel;
}


@end
