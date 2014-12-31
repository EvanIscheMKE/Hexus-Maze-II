//
//  ViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "HDAlertView.h"
#import "HDInfoView.h"
#import "HDTVManager.h"
#import "HDTVHexagonItem.h"
#import "HDLevelGenerator.h"
#import "HDNavigationBar.h"
#import "UIColor+FlatColors.h"
#import "HDContainerViewController.h"
#import "HDGameViewController.h"
#import "HDTableViewCell.h"
#import "HDGridManager.h"
#import "HDScene.h"

static const CGFloat kDefaultContainerHeight = 70.0f;
static const CGFloat kPadding                = 5.0f;

@interface HDGameViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, HDSceneDelegate>

@property (nonatomic, strong) HDNavigationBar *navigationBar;

@property (nonatomic, strong) UILabel *completedLabel;
@property (nonatomic, strong) UILabel *completedCountLabel;

@property (nonatomic, assign) NSUInteger level;
@property (nonatomic, assign) NSUInteger totalTileCount;
@property (nonatomic, assign) NSUInteger completedTileCount;

@property (nonatomic, assign) BOOL pauseGame;
@property (nonatomic, assign) BOOL restartButtonHidden;
@property (nonatomic, assign) BOOL navigationBarHidden;

@property (nonatomic, strong) UIButton *restart;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftEdgeGesture;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *rightEdgeGesture;

@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, strong) HDScene *scene;

@end

@implementation HDGameViewController {
    BOOL _randomlyGeneratedLevel;
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
        if (!self.restartButtonHidden) {
            self.restartButtonHidden = YES;
        }
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

- (void)performExitAnimationWithCompletion:(dispatch_block_t)completion
{
    self.navigationBarHidden = YES;
    [self.scene performExitAnimationsWithCompletion:completion];
}

#pragma mark - Life cycle

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    SKView * skView = (SKView *)self.view;
    if (!skView.scene && self.gridManager) {
        [self _setupScene];
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
    [self _beginGame];
}

#pragma mark - Private

- (void)_setup
{
    HDContainerViewController *container = self.containerViewController;
    
    self.leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.leftEdgeGesture.edges = UIRectEdgeLeft;
    self.leftEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:self.leftEdgeGesture];
    
    self.rightEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.rightEdgeGesture.edges = UIRectEdgeRight;
    self.rightEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:self.rightEdgeGesture];
    
    CGRect navBarFrame = CGRectMake(0.0f, -kDefaultContainerHeight, CGRectGetWidth(self.view.bounds), kDefaultContainerHeight);
    self.navigationBar = [HDNavigationBar viewWithToggleImage:[UIImage imageNamed:@"Grid"] activityImage:[UIImage imageNamed:@"TileToggle-"]];
    self.navigationBar.frame = navBarFrame;
    [[self.navigationBar.subviews firstObject] addTarget:container
                                                  action:@selector(toggleMenuViewController)
                                        forControlEvents:UIControlEventTouchUpInside];
    [[self.navigationBar.subviews lastObject] addTarget:self
                                                 action:@selector(_presentInfoView)
                                       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.navigationBar];
    
    self.restart = [self _restartButton];
    [self.view addSubview:self.restart];
    
    self.completedLabel = [self _completionLabel];
    [self.navigationBar addSubview:self.completedLabel];
    
    self.completedCountLabel = [self _completedCountLabel];
    [self.navigationBar addSubview:self.completedCountLabel];
}

- (void)_presentInfoView
{
    HDAlertView *alertView = [[HDAlertView alloc] init];
    [alertView.infoView setDelegate:self dataSource:self];
    [alertView show];
}

- (void)_setupScene
{
    SKView * skView = (SKView *)self.view;
    
    self.scene = [HDScene sceneWithSize:self.view.bounds.size];
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    self.scene.delegate = self;
    self.scene.levelIndex = _level;
    self.scene.gridManager = self.gridManager;
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

- (void)_updateCompletedLabel
{
    self.completedCountLabel.text = [NSString stringWithFormat:@"%lu/%lu",self.completedTileCount, self.totalTileCount];
    [self.completedCountLabel sizeToFit];
    
    CGPoint position = CGPointMake(
                                   CGRectGetMidX(self.view.bounds),
                                   CGRectGetMaxY(self.completedLabel.frame) + CGRectGetMidY(self.completedCountLabel.bounds) -kPadding/2
                                   );
    
    [self _scaleAnimationOnKeyPath:@"transform.scale.x"];
    self.completedCountLabel.center = position;
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
    self.gridManager = [[HDGridManager alloc] initWithLevelNumber:level];
    self.level = level;
    self.scene.gridManager = self.gridManager;
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

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{    
    HDContainerViewController *container = self.containerViewController;
    
    if (gestureRecognizer == self.leftEdgeGesture && !container.isExpanded) {
        return YES;
    } else if (gestureRecognizer == self.rightEdgeGesture && container.isExpanded) {
        return YES;
    }
    return NO;
}

#pragma mark - <UITableViewDatasource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[HDTVManager sharedManager] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewIdentifier forIndexPath:indexPath];
    
    HDTVHexagonItem *item = [[HDTVManager sharedManager] itemAtIndex:indexPath.row];
    
    cell.imageView.image      = item.image;
    cell.detailTextLabel.text = item.hexDescription;
    cell.textLabel.text       = item.title;
    
    return cell;
}

#pragma mark - <UITableViewDelegat>

#pragma mark - <UIScreenEdgeGestureRecognizer>

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.containerViewController toggleMenuViewController];
    }
}

#pragma mark - Buttons

- (UIButton *)_restartButton
{
    CGRect restartBounds = CGRectMake(
                                      0.0f,
                                      0.0f,
                                      CGRectGetWidth(CGRectInset(self.view.bounds, 25.0f, 0.0f)),
                                      CGRectGetWidth(self.view.bounds) < 321.0f ? 34.0f : 44.0f
                                      );
    
    UIButton *restartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    restartButton.frame = restartBounds;
    [restartButton addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
    [restartButton setTitle:@"Try Again" forState:UIControlStateNormal];
    [restartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [restartButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [restartButton.titleLabel setFont:GILLSANS_LIGHT(22.0f)];
    restartButton.backgroundColor = [UIColor flatPeterRiverColor];
    restartButton.layer.cornerRadius = 8.0f;
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
    completedCountLabel.textColor     = [UIColor whiteColor];
    completedCountLabel.numberOfLines = 1;
    completedCountLabel.textAlignment = NSTextAlignmentCenter;
    completedCountLabel.font          = GILLSANS(CGRectGetWidth(self.view.bounds) / 10.0f);
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
    completedLabel.text          = @"Completed";
    completedLabel.textColor     = [UIColor whiteColor];
    completedLabel.numberOfLines = 1;
    completedLabel.textAlignment = NSTextAlignmentCenter;
    completedLabel.font          = GILLSANS_LIGHT(CGRectGetWidth(self.view.bounds) / 20.0f);
    [completedLabel sizeToFit];
    completedLabel.center = CGPointMake(
                                        CGRectGetMidX(self.view.bounds),
                                        CGRectGetMidY(completedLabel.bounds) + kPadding
                                        );
    completedLabel.frame = CGRectIntegral(completedLabel.frame);

    return completedLabel;
}


@end
