//
//  HDIntroViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 3/13/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "HDIntroViewController.h"
#import "UIColor+FlatColors.h"
#import "HDIntroScene.h"

@interface HDIntroViewController () <SKSceneDelegate>
@property (nonatomic, strong) HDIntroScene *introScene;
@end

@implementation HDIntroViewController {
    SKView *_container;
}

- (void)loadView {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.view = [[SKView alloc] initWithFrame:bounds];
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    _container = (SKView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    BOOL firstRun = [self _checkForFirstRun];
    if (!firstRun) {
        [self.introScene performIntroAnimationsWithCompletion:^{
            NSLog(@"COMPLETION");
        }];
    }
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!_container.scene) {
        self.introScene = [[HDIntroScene alloc] initWithSize:_container.bounds.size];
        self.introScene.delegate = self;
        [_container presentScene:self.introScene];
    }
}

- (BOOL)_checkForFirstRun {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HDFirstRunKey]) {
        [ADelegate presentTutorialViewControllerForFirstRun];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HDFirstRunKey];
        return YES;
    }
    return NO;
}

@end
