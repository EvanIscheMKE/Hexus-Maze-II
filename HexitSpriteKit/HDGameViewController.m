//
//  ViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "HDGameViewController.h"
#import "HDLevels.h"
#import "HDScene.h"

@interface HDGameViewController ()
@property (nonatomic, strong) HDScene *scene;
@end

@implementation HDGameViewController{
    BOOL _pauseGame;
    HDLevels *_levels;
    NSInteger _level;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (id)init
{
    return [self initWithLevel:(NSInteger)1];
}

- (id)initWithLevel:(NSInteger)level
{
    if (self = [super init]){
        _level = level;
    }
    return self;
}

- (void)loadView
{
    CGRect viewRect = [[UIScreen mainScreen] bounds];
    SKView *skView = [[SKView alloc] initWithFrame:viewRect];
    [skView setAllowsTransparency:YES];
    [self setView:skView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    SKView *view = (SKView *)self.view;
    
    self.scene = [HDScene sceneWithSize:self.view.bounds.size];
    [self.scene setScaleMode:SKSceneScaleModeAspectFill];
    
    _levels = [[HDLevels alloc] initWithLevel:_level];
    [self.scene setLevels:_levels];
    
    [view presentScene:self.scene];
    [self beginGame];
}

- (void)beginGame
{
    [self.scene layoutNodesWithGrid:[_levels hexagons]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Notification selectors for game state(Private)

-(void)_pauseGame
{
    _pauseGame = YES;
    [self.scene.view setPaused:YES];
}

-(void)_unpauseGame
{
    _pauseGame = NO;
    [self.scene.view setPaused:NO];
}

- (void)applicationDidBecomeActive
{
    if (_pauseGame) {
        [self _unpauseGame];
    }
}

- (void)applicationWillResignActive
{
    if (!_pauseGame) {
        [self _pauseGame];
    }
}

@end
