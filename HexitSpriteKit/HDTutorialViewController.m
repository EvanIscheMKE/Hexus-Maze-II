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
#import "HDSoundManager.h"
#import "HDHintsView.h"

@interface HDTutorialViewController ()<HDSceneDelegate>
@property (nonatomic, assign) BOOL isAlertHidden;
@property (nonatomic, strong) UILabel *descriptorLabel;
@property (nonatomic, strong) HDHintsView *infoView;
@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, strong) HDTutorialScene *scene;
@end

@implementation HDTutorialViewController {
    __weak SKView *_container;
}

- (instancetype)init {
    if (self = [super init]) {
        self.isAlertHidden = YES;
    }
    return self;
}

- (void)loadView {
    self.view = [[SKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _container = (SKView *)self.view;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.gridManager = [[HDGridManager alloc] initWithLevelIndex:1000];
    _container.backgroundColor = [SKColor flatWetAsphaltColor];
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    if (!_container.scene) {
        
        self.scene = [HDTutorialScene sceneWithSize:self.view.bounds.size];
        self.scene.myDelegate = self;
        self.scene.gridManager = self.gridManager;
        self.scene.partyAtTheEnd = NO;
        [_container presentScene:self.scene];
        
        [self.scene layoutNodesWithGrid:[self.gridManager hexagons] completion:^{
            [self _presentTitle:@"First things first"
                    description:@"Start by selecting a white tile"
                         images:@[[UIImage imageNamed:@"Default-Start"]]];
        }];
    }
}

- (void)_presentTitle:(NSString *)title description:(NSString *)description images:(NSArray *)images {
    
    if (!_infoView) {
        
        __weak __typeof__(self) weakSelf = self;
        CGRect infoFrame = CGRectMake(0.0f,
                                      CGRectGetHeight(self.view.bounds),
                                      CGRectGetWidth(self.view.bounds),
                                      CGRectGetHeight(self.view.bounds)/5);
        _infoView = [[HDHintsView alloc] initWithFrame:infoFrame
                                                 title:title
                                           description:description
                                                images:images];
        [weakSelf.view insertSubview:_infoView
                             atIndex:0];
        [weakSelf toggleAlert];
        [weakSelf performSelector:@selector(toggleAlert) withObject:nil afterDelay:2.5f];
    }
}

- (void)toggleAlert {
    self.isAlertHidden = !self.isAlertHidden;
}

- (void)setIsAlertHidden:(BOOL)isAlertHidden {
    
    if (_isAlertHidden == isAlertHidden) {
        return;
    }
  
    _isAlertHidden = isAlertHidden;
    if (_isAlertHidden) {
        [self hideAlertAnimated:YES completion:nil];
    } else {
        [self showAlertAnimated:YES];
    }
}

- (void)showAlertAnimated:(BOOL)animated {
    
    dispatch_block_t animate = ^{
        CGRect infoFrame = self.infoView.frame;
        infoFrame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.infoView.bounds);
        self.infoView.frame = infoFrame;
    };
    
    if (animated) {
        [UIView animateWithDuration:.300f animations:animate];
    } else {
        animate();
    }
}

- (void)hideAlertAnimated:(BOOL)animated completion:(dispatch_block_t)completion {
    
    dispatch_block_t animate = ^{
        CGRect infoFrame = self.infoView.frame;
        infoFrame.origin.y = CGRectGetHeight(self.view.bounds);
        self.infoView.frame = infoFrame;
    };
    
    if (animated) {
        [UIView animateWithDuration:.300f animations:animate completion:^(BOOL finished) {
            [self.infoView removeFromSuperview];
             self.infoView = nil;
            
            if (completion) {
                completion();
            }
        }];
    } else {
        animate();
        [self.infoView removeFromSuperview];
        self.infoView = nil;
        
        if (completion) {
            completion();
        }
    }
}

#pragma mark - <HDSceneDelegate>

- (void)scene:(HDTutorialScene *)scene gameEndedWithCompletion:(BOOL)completion {
    
    [[HDSoundManager sharedManager] playSound:HDCompletionZing];
    if (completion) {
        
        [scene performExitAnimationsWithCompletion:^{
            
            self.descriptorLabel = [self _descriptorLabelWithText:@"Beautiful!"];
            [self.view addSubview:self.descriptorLabel];
            [UIView animateWithDuration:.3f animations:^{
                self.descriptorLabel.alpha = 1;
            } completion:^(BOOL finished) {
                self.scene.space.particleBirthRate = 0;
                [UIView animateWithDuration:.3f
                                      delay:3.0f
                                    options:0
                                 animations:^{
                                     self.descriptorLabel.alpha = 0;
                                 } completion:^(BOOL finished) {
                                     self.descriptorLabel = [self _descriptorLabelWithText:@"Welcome."];
                                     [self.view addSubview:self.descriptorLabel];
                                     [UIView animateWithDuration:.3f animations:^{
                                         self.descriptorLabel.alpha = 1;
                                     } completion:^(BOOL finished) {
                                         [UIView animateWithDuration:.3f
                                                               delay:3.0f
                                                             options:0
                                                          animations:^{
                                                              self.descriptorLabel.alpha = 0;
                                                          } completion:^(BOOL finished) {
                                                              [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                                          }];
                                     }];
                                 }];
            }];
        }];
        
    } else {
        [scene performExitAnimationsWithCompletion:^{
            
            [scene nextLevel];
            scene.partyAtTheEnd = YES;
            
            self.descriptorLabel = [self _descriptorLabelWithText:@"Amazing!"];
            [self.view addSubview:self.descriptorLabel];
            [UIView animateWithDuration:.3f animations:^{
                self.descriptorLabel.alpha = 1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.3f
                                      delay:2.0f
                                    options:0
                                 animations:^{
                                     self.descriptorLabel.alpha = 0;
                                 } completion:^(BOOL finished) {
                                     self.gridManager = [[HDGridManager alloc] initWithLevelIndex:1001];
                                     [self.scene layoutNodesWithGrid:[self.gridManager hexagons] completion:^{
                                         [self _presentTitle:@"One More Time"
                                                 description:@"Let's make sure you've got a hang of this"
                                                      images:@[[UIImage imageNamed:@"Default-OneTap"]]];
                                     }];
                                 }];
            }];
        }];
    }
}

- (void)startTileWasSelectedInScene:(HDScene *)scene {
    
    static NSUInteger count = 0;
    if (count == 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self hideAlertAnimated:YES completion:^{
            [self _presentTitle:@"Next"
                    description:@"Move to a tile that is touching the previous tile"
                         images:@[[UIImage imageNamed:@"Default-OneTap"]]];
        }];
    } else if (count == 1) {
        
    }
    
    count++;
}

- (UILabel *)_descriptorLabelWithText:(NSString *)text {
    
    UILabel *label = [[UILabel alloc] init];
    label.font = GILLSANS_LIGHT(42.0f);
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 1;
    label.text = text;
    label.alpha = 0;
    [label sizeToFit];
    label.center = self.view.center;
    label.frame = CGRectIntegral(label.frame);
    
    return label;
}

@end
