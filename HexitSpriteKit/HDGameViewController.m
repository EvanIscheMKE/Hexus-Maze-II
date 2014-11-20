//
//  ViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "UIColor+FlatColors.h"
#import "HDContainerViewController.h"
#import "HDGameViewController.h"
#import "HDProgressView.h"
#import "HDLevels.h"
#import "HDScene.h"

@interface HDGameViewController ()

@property (nonatomic, strong) HDProgressView *progressView;
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    _levels = [[HDLevels alloc] initWithLevel:_level];
    
    [self _layoutDisplayWithTileCount:[[_levels hexagons] count]];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        
         self.scene = [HDScene sceneWithSize:self.view.bounds.size];
        [self.scene setScaleMode:SKSceneScaleModeAspectFill];
        [self.scene setLevels:_levels];
        [self.scene addUnderlyingIndicatorTiles];
        
        [skView presentScene:self.scene];
        
        [self _beginGame];
        
    }
}

- (void)_beginGame
{
    [self.scene layoutNodesWithGrid:[_levels hexagons]];
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

- (void)showAlertWithTitle:(NSString *)title
               description:(NSString *)descripton
                       tag:(NSInteger)tag
                  delegate:(id<UIAlertViewDelegate>)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:descripton
                                                       delegate:delegate
                                              cancelButtonTitle:@"Continue"
                                              otherButtonTitles:@"Leave",nil];
    [alertView setTag:tag];
    [alertView show];
}

#pragma mark -
#pragma mark - Private

- (void)_layoutDisplayWithTileCount:(NSInteger)tileCount
{
    if (!self.progressView) {
        CGRect progressFrame = CGRectMake(0.0, CGRectGetHeight(self.view.bounds) - 53.0f, CGRectGetWidth(self.view.bounds), 50.0f);
         self.progressView = [[HDProgressView alloc] initWithFrame:progressFrame];
        [self.view addSubview:self.progressView];
    }
}

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
