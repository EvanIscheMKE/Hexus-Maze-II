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
    
    [self _layoutHUDButtons];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        
         self.scene = [HDScene sceneWithSize:self.view.bounds.size];
        [self.scene setScaleMode:SKSceneScaleModeAspectFill];
        [self.scene setLevels:_levels];
        
        [skView presentScene:self.scene];
        [self _beginGame];
        
    }
}

- (void)_layoutHUDButtons
{
    HDContainerViewController *controller = self.containerViewController;
    
    UIButton *present = [UIButton buttonWithType:UIButtonTypeCustom];
    [present setBackgroundImage:[UIImage imageNamed:@"BounceButton"] forState:UIControlStateNormal];
    [present addTarget:controller action:@selector(bounceFrontViewController) forControlEvents:UIControlEventTouchUpInside];
    [present setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:present];
    
    NSDictionary *dictionary = NSDictionaryOfVariableBindings(present);
    
    for (NSArray *array in @[[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[present(40)]" options:0 metrics:nil views:dictionary]
                            ,[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[present(40)]" options:0 metrics:nil views:dictionary]]) {
        [self.view addConstraints:array];
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

#pragma mark -
#pragma mark - Private

-(void)_pauseGame
{
    _pauseGame = !_pauseGame;
    [self.scene.view setPaused:!self.scene.view.paused];
}

- (void)_applicationDidBecomeActive
{
    [self _pauseGame];
}

- (void)_applicationWillResignActive
{
    [self _pauseGame];
}

@end
