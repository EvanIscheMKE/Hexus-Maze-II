//
//  HDTutorialViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/17/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "HDTutorialScene.h"
#import "HDGridManager.h"
#import "UIColor+FlatColors.h"
#import "HDTutorialViewController.h"

@interface HDTutorialViewController ()<HDSceneDelegate>
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, strong) HDTutorialScene *scene;
@end

@implementation HDTutorialViewController {
    __weak SKView *_container;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
    }
    return self;
}

- (void)loadView {
    self.view = [[SKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _container = (SKView *)self.view;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!_container.scene) {
        self.scene = [HDTutorialScene sceneWithSize:self.view.bounds.size];
        self.scene.myDelegate = self;
        self.scene.gridManager = self.gridManager;
        self.scene.partyAtTheEnd = NO;
        [(SKView *)_container presentScene:self.scene];
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.gridManager = [[HDGridManager alloc] initWithLevelIndex:1000];
    
    _container.backgroundColor = [SKColor flatWetAsphaltColor];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.descriptionLabel.text = @"Welcome.";
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.font = GILLSANS_LIGHT(42.0f);
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.center = _container.center;
    [self.view addSubview:self.descriptionLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.descriptionLabel.alpha = 0;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:.3f animations:^{ self.descriptionLabel.alpha = 1; }];
    [self performSelector:@selector(_dismissInitialText) withObject:nil afterDelay:2.0f];
    [super viewDidAppear:animated];
}

#pragma mark - Private

- (void)_dismissInitialText {
    
    [UIView animateWithDuration:.3f animations:^{
        self.descriptionLabel.alpha = 0;
    } completion:^(BOOL finished) {
        
        CGRect frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.view.bounds)/10*2, 0.0f);
        self.descriptionLabel.frame = frame;
        self.descriptionLabel.text = @"\"The best way to find out whether you're on the right path? Stop looking at the path.\"\n-Marcus Buckingham";
        self.descriptionLabel.font = GILLSANS_LIGHT(28.0f);
        [self.descriptionLabel sizeToFit];
        self.descriptionLabel.center = _container.center;
        
        [UIView animateWithDuration:.3f animations:^{
            self.descriptionLabel.alpha = 1;
        } completion:^(BOOL finished) {
            [self performSelector:@selector(_performSceneIntroAnimations) withObject:nil afterDelay:2.0f];
        }];
    }];
}

- (void)_performSceneIntroAnimations {
    
    [UIView animateWithDuration:.3f animations:^{
        self.descriptionLabel.alpha = 0;
    } completion:^(BOOL finished) {
        
        __weak __typeof__(self) weakSelf = self;
        [self.scene layoutNodesWithGrid:[self.gridManager hexagons] completion:^{
            
            CGRect frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.view.bounds)/8*2, 0.0f);
            weakSelf.descriptionLabel.frame = frame;
            weakSelf.descriptionLabel.text = @"You must always begin on a white tile.";
            weakSelf.descriptionLabel.font = GILLSANS_LIGHT(30.0f);
            [weakSelf.descriptionLabel sizeToFit];
            weakSelf.descriptionLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetHeight(self.view.bounds)/5);
            
            [UIView animateWithDuration:.2f animations:^{
                weakSelf.descriptionLabel.alpha = 1;
            }];
        }];
    }];
}

#pragma mark - <HDSceneDelegate>

- (void)scene:(HDScene *)scene gameEndedWithCompletion:(BOOL)completion {
    
    if (completion) {
        [scene startConfettiEmitter];
    } else {
        [scene performExitAnimationsWithCompletion:^{
            [scene nextLevel];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.gridManager = [[HDGridManager alloc] initWithLevelIndex:1001];
                self.scene.partyAtTheEnd = YES;
                [self.scene layoutNodesWithGrid:[self.gridManager hexagons] completion:nil];
            });
        }];
    }
}

@end
