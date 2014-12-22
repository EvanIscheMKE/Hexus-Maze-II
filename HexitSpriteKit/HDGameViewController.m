//
//  ViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "HDLevelGenerator.h"
#import "UIColor+FlatColors.h"
#import "HDContainerViewController.h"
#import "HDGameViewController.h"
#import "HDGridManager.h"
#import "HDScene.h"

static const CGFloat kDefaultContainerHeight = 70.0f;
static const CGFloat kPadding    = 5.0f;
static const CGFloat kButtonSize = 42.0f;
static const CGFloat kInset      = 20.0f;
@interface HDGameViewController ()

@property (nonatomic, strong) UIView *topContainer;

@property (nonatomic, strong) UILabel *completedLabel;
@property (nonatomic, strong) UILabel *completedCountLabel;

@property (nonatomic, assign) NSUInteger totalTileCount;
@property (nonatomic, assign) NSUInteger completedTileCount;

@property (nonatomic, assign) BOOL pauseGame;
@property (nonatomic, assign) BOOL navigationBarHidden;

@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIButton *restart;

@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, strong) HDScene *scene;

@end

@implementation HDGameViewController {
    BOOL _RandomlyGeneratedLevel;
    
    NSDictionary *_views;
    NSDictionary *_metrics;
    
    NSInteger _level;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HDCompletedTileCountNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HDAnimateLabelNotification        object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HDClearTileCountNotification      object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HDNextLevelNotification           object:nil];
}

- (id)initWithLevel:(NSInteger)level
{
    if (self = [super init]) {
        
        _level = level;
        _RandomlyGeneratedLevel = NO;
    
        [self setPauseGame:NO];
        
    }
    return self;
}

- (instancetype)initWithRandomlyGeneratedLevel
{
    if (self = [super init]) {
        
        _RandomlyGeneratedLevel = YES;
        [self setPauseGame:NO];
        
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
                                             selector:@selector(_performExitAnimation)
                                                 name:@"performExitAnimations"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_performHeightAnimationOnCountLabel)
                                                 name:HDAnimateLabelNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_updateCompletedTileCount)
                                                 name:HDCompletedTileCountNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_clearCompletedTileCount)
                                                 name:HDClearTileCountNotification
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
    
    [self _setupGestureRecognizer];
    [self _setup];
}

#pragma mark - 
#pragma mark - < PUBLIC >

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

#pragma mark -
#pragma mark - < PRIVATE >

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    SKView * skView = (SKView *)self.view;
    if (!skView.scene && self.gridManager) {
        [self _setupScene];
    }
}

- (void)_setupGestureRecognizer
{
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                                          action:@selector(handlePan:)];
    [leftEdgeGesture setEdges:UIRectEdgeLeft];
    [self.view addGestureRecognizer:leftEdgeGesture];
}

- (void)_setup
{
    HDContainerViewController *container = self.containerViewController;
    
    CGRect topContainerFrame = CGRectMake(0.0f, -kDefaultContainerHeight, CGRectGetWidth(self.view.bounds), kDefaultContainerHeight);
    self.topContainer = [[UIView alloc] initWithFrame:topContainerFrame];
    [self.topContainer setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.topContainer];
    
    self.completedLabel = [self _completionLabel];
    [self.topContainer addSubview:self.completedLabel];
    
    self.completedCountLabel = [self _completedCountLabel];
    [self.topContainer addSubview:self.completedCountLabel];
    
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.toggleButton setImage:[UIImage imageNamed:@"Grid"]                            forState:UIControlStateNormal];
    [self.toggleButton addTarget:container action:@selector(toggleMenuViewController)   forControlEvents:UIControlEventTouchUpInside];
    
    self.restart = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.restart setImage:[UIImage imageNamed:@"Reset"]       forState:UIControlStateNormal];
    [self.restart addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *subView in @[self.toggleButton, self.restart]) {
        [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.topContainer addSubview:subView];
    }
    
    UIButton *toggle  = self.toggleButton;
    UIButton *share   = self.restart;
    
    _views = NSDictionaryOfVariableBindings(toggle, share);
    
    _metrics = @{ @"buttonHeight" : @(kButtonSize), @"inset" : @(kInset) };
    
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

- (void)_setupScene
{
    SKView * skView = (SKView *)self.view;
    
     self.scene = [HDScene sceneWithSize:self.view.bounds.size];
    [self.scene setLevelIndex:_level];
    [self.scene setGridManager:self.gridManager];
    [self.scene layoutIndicatorTiles];
    
    [skView presentScene:self.scene];
  //  [self _beginGame];
}

- (void)_beginGame
{
    NSArray *hexagons = [self.gridManager hexagons];
    
    [self setCompletedTileCount:0];
    [self setTotalTileCount:hexagons.count];
    [self.scene layoutNodesWithGrid:hexagons];
}

- (void)_hideAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGRect rect = self.topContainer.frame;
        rect.origin.y = -kDefaultContainerHeight;
        [self.topContainer setFrame:rect];
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
        CGRect rect = self.topContainer.frame;
        rect.origin.y = 0.0f;
        [self.topContainer setFrame:rect];
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
    [super viewDidAppear:animated];
    [self setNavigationBarHidden:NO];
    
    // Since the views going to appear at the start of the the transition animation, we want to wait.
    [self _beginGame];
}

#pragma mark - 
#pragma mark - Notifications

- (void)_clearCompletedTileCount
{
    [self setCompletedTileCount:0];
}

- (void)_updateCompletedTileCount
{
    self.completedTileCount++;
}

- (void)_updateCompletedLabel
{
    [self.completedCountLabel setText:[NSString stringWithFormat:@"%lu/%lu",self.completedTileCount, self.totalTileCount]];
    [self.completedCountLabel sizeToFit];
    
    CGPoint position = CGPointMake(
                                   CGRectGetMidX(self.view.bounds),
                                   CGRectGetMaxY(self.completedLabel.frame) + CGRectGetMidY(self.completedCountLabel.bounds) -kPadding/2
                                   );
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    [scale setByValue:@.2f];
    [scale setToValue:@1.2f];
    [scale setDuration:.2f];
    [scale setAutoreverses:YES];
    [self.completedCountLabel.layer addAnimation:scale forKey:@"scale"];
    
    [self.completedCountLabel setCenter:position];
}

- (void)_performHeightAnimationOnCountLabel
{
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    [scale setByValue:@.2f];
    [scale setToValue:@1.2f];
    [scale setDuration:.2f];
    [scale setAutoreverses:YES];
    [self.completedCountLabel.layer addAnimation:scale forKey:@"scale"];
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

- (void)_performExitAnimation
{
    [self setNavigationBarHidden:YES];
    [self.scene performExitAnimationsWithCompletion:^{
        [ADelegate navigateToLevelController];
    }];
}

#pragma mark -
#pragma mark - <UIScreenEdgeGestureRecognizer>

- (void)handlePan:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
         HDContainerViewController *container = self.containerViewController;
        [container toggleMenuViewController];
        return;
    }
}

#pragma mark -

- (UILabel *)_completedCountLabel
{
    UILabel *completedCountLabel = [[UILabel alloc] init];
    [completedCountLabel setTextColor:[UIColor whiteColor]];
    [completedCountLabel setNumberOfLines:1];
    [completedCountLabel setTextAlignment:NSTextAlignmentCenter];
    [completedCountLabel setFont:GILLSANS(40.0f)];
    [completedCountLabel sizeToFit];
    [completedCountLabel setCenter:CGPointMake(
                                               CGRectGetMidX(self.view.bounds),
                                               CGRectGetMaxY(self.completedLabel.frame) + CGRectGetMidY(completedCountLabel.bounds) -kPadding/2
                                               )];
    return completedCountLabel;
}

- (UILabel *)_completionLabel
{
    UILabel *completedLabel = [[UILabel alloc] init];
    [completedLabel setText:@"Completed"];
    [completedLabel setTextColor:[UIColor whiteColor]];
    [completedLabel setNumberOfLines:1];
    [completedLabel setTextAlignment:NSTextAlignmentCenter];
    [completedLabel setFont:GILLSANS_LIGHT(18.0f)];
    [completedLabel sizeToFit];
    [completedLabel setCenter:CGPointMake(
                                          CGRectGetMidX(self.view.bounds),
                                          CGRectGetMidY(completedLabel.bounds) + kPadding
                                           )];

    return completedLabel;
}


@end
