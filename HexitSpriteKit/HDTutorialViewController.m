//
//  HDTutorialViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/17/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "HDHelper.h"
#import "HDTutorialScene.h"
#import "HDGridManager.h"
#import "UIColor+ColorAdditions.h"
#import "HDTutorialViewController.h"
#import "HDSoundManager.h"
#import "HDHintsView.h"

@interface HDTutorialViewController ()<HDSceneDelegate>
@property (nonatomic, strong) UILabel *descriptorLabel;
@property (nonatomic, strong) HDHintsView *infoView;
@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, strong) HDTutorialScene *scene;
@end

@implementation HDTutorialViewController {
    __weak SKView *_container;
}

- (void)loadView {
    self.view = [[SKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _container = (SKView *)self.view;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.gridManager = [[HDGridManager alloc] initWithLevelIndex:1000];
    _container.backgroundColor = [SKColor flatMidnightBlueColor];
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    if (!_container.scene) {
        
        self.scene = [HDTutorialScene sceneWithSize:self.view.bounds.size];
        self.scene.myDelegate = self;
        self.scene.gridManager = self.gridManager;
        self.scene.partyAtTheEnd = NO;
        [_container presentScene:self.scene];
        
        [self.scene layoutNodesWithGrid:[self.gridManager hexagons] completion:nil];
    }
}

#pragma mark - <HDSceneDelegate>

- (void)scene:(HDTutorialScene *)scene gameEndedWithCompletion:(BOOL)completion {
    
    [[HDSoundManager sharedManager] playSound:HDCompletionZing];
    if (completion) {
        
        [scene performExitAnimationsWithCompletion:^{
            
            self.descriptorLabel = [self _descriptionLabelWithText:NSLocalizedString(@"beautiful", nil)];
            [self.view addSubview:self.descriptorLabel];
            [UIView animateWithDuration:.3f animations:^{
                self.descriptorLabel.alpha = 1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.3f
                                      delay:1.5f
                                    options:0
                                 animations:^{
                                     self.descriptorLabel.alpha = 0;
                                 } completion:^(BOOL finished) {
                                     self.descriptorLabel = [self _descriptionLabelWithText:NSLocalizedString(@"welcome", nil)];
                                     [self.view addSubview:self.descriptorLabel];
                                     [UIView animateWithDuration:.3f animations:^{
                                         self.descriptorLabel.alpha = 1;
                                     } completion:^(BOOL finished) {
                                         [UIView animateWithDuration:.3f
                                                               delay:1.5f
                                                             options:0
                                                          animations:^{
                                                              self.descriptorLabel.alpha = 0;
                                                          } completion:^(BOOL finished) {
                                                              [self.presentingViewController dismissViewControllerAnimated:NO
                                                                                                                completion:nil];
                                                          }];
                                     }];
                                 }];
            }];
        }];
        
    } else {
        
        [scene performExitAnimationsWithCompletion:^{
            
            [scene nextLevel];
            scene.partyAtTheEnd = YES;
            self.descriptorLabel = [self _descriptionLabelWithText:NSLocalizedString(@"amazing!", nil)];
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
                                     [self.scene layoutNodesWithGrid:[self.gridManager hexagons] completion:nil];
                                 }];
            }];
        }];
    }
}

- (UILabel *)_descriptionLabelWithText:(NSString *)text {
    
    const CGFloat scale = IS_IPAD ? 12.0f : 10.0f;
    
    UILabel *label = [[UILabel alloc] init];
    label.font = GILLSANS_LIGHT(CGRectGetWidth(self.view.bounds)/ scale);
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
