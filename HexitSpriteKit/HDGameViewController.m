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

@interface HDGameViewController ()

@property (nonatomic, strong) UIButton *reverseAMove;
@property (nonatomic, strong) UIButton *selectATile;

@property (nonatomic, strong) HDGridManager *gridManager;

@property (nonatomic, strong) HDScene *scene;

@end

@implementation HDGameViewController {
    
    NSDictionary *_views;
    NSDictionary *_metrics;
    
    NSInteger _level;
    
    BOOL _pauseGame;
    BOOL _RandomlyGeneratedLevel;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification  object:nil];
}

- (id)init
{
    return [self initWithLevel:(NSInteger)1];
}

- (id)initWithLevel:(NSInteger)level
{
    if (self = [super init]){
        _level = level;
        _pauseGame = NO;
        _RandomlyGeneratedLevel = NO;
    }
    return self;
}

- (instancetype)initWithRandomlyGeneratedLevel
{
    if (self = [super init]){
        _pauseGame = NO;
        _RandomlyGeneratedLevel = YES;
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
    [self.view setBackgroundColor:[SKColor flatMidnightBlueColor]];
    
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
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    SKView * skView = (SKView *)self.view;
    if (!skView.scene && self.gridManager) {
        [self _setupGame];
    }
}

- (void)_setupGame
{
    SKView * skView = (SKView *)self.view;
    
    self.scene = [HDScene sceneWithSize:self.view.bounds.size];
    [self.scene setScaleMode:SKSceneScaleModeAspectFill];
    [self.scene setGridManager:self.gridManager];
    [self.scene addUnderlyingIndicatorTiles];
    
    [skView presentScene:self.scene];
    
    [self _beginGame];
}

- (void)_beginGame
{
    [self.scene layoutNodesWithGrid:[self.gridManager hexagons]];
}

- (NSInteger)level
{
    return _level;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Private

- (void)_applicationDidBecomeActive
{
    _pauseGame = NO;
    [self.scene.view setPaused:_pauseGame];
}

- (void)_applicationWillResignActive
{
    _pauseGame = YES;
    [self.scene.view setPaused:_pauseGame];
}

@end
