//
//  HDTutorialViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/17/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;
@import Social;

#import "HDLabel.h"
#import "HDHelper.h"
#import "HDTutorialScene.h"
#import "HDGridManager.h"
#import "UIColor+ColorAdditions.h"
#import "HDTutorialViewController.h"
#import "HDSoundManager.h"

@interface HDTutorialViewController ()<HDSceneDelegate>
@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, strong) HDTutorialScene *scene;
@end

@implementation HDTutorialViewController
{
    __weak SKView *_container;
    HDLabel *_titleLbl;
    HDLabel *_descriptionLbl;
    UIImageView *_imageView;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.gridManager = [[HDGridManager alloc] initWithLevelIndex:1000];
    }
    return self;
}

- (void)loadView
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.view = [[SKView alloc] initWithFrame:bounds];
    self.view.backgroundColor = [UIColor flatSTDarkBlueColor];
    _container = (SKView *)self.view;
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconForIntro"]];
    _imageView.center = self.view.center;
    _imageView.transform = IS_IPAD ? CGAffineTransformIdentity : CGAffineTransformMakeScale(TRANSFORM_SCALE_X, TRANSFORM_SCALE_X);
    [_container addSubview:_imageView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (!_container.scene) {
        self.scene = [HDTutorialScene sceneWithSize:self.view.bounds.size];
        self.scene.myDelegate = self;
        self.scene.gridManager = self.gridManager;
        self.scene.dismissAfterCompletion = NO;
        [_container presentScene:self.scene];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:.3f animations:^{
        _imageView.alpha = 0;
    } completion:^(BOOL finished) {
        _imageView = nil;
        [_imageView removeFromSuperview];
        [self.scene layoutNodesWithGrid:[self.gridManager hexagons] completion:^{
            if (!_descriptionLbl) {
                _descriptionLbl = [self _descriptionLblWithString:NSLocalizedString(@"tut1", nil)];
                [self.view addSubview:_descriptionLbl];
                
                [self updateLabel:_descriptionLbl
                            alpha:1.0f
                         duration:.3f
                            delay:0.0f
                       completion:nil];
            }
        }];
    }];
}

#pragma mark - <HDSceneDelegate>

- (void)scene:(HDTutorialScene *)scene gameEndedWithCompletion:(BOOL)completion
{
    [[HDSoundManager sharedManager] playSound:HDCompletionZing];
    if (completion) {
        
        [self updateLabel:_descriptionLbl
                    alpha:0.0f
                 duration:.3f
                    delay:0.0f
               completion:nil];

        [scene performExitAnimationsWithCompletion:^{
            
            _titleLbl.text = NSLocalizedString(@"beautiful", nil);
            [_titleLbl sizeToFit];
            _titleLbl.center = self.view.center;
            _titleLbl.frame = CGRectIntegral(_titleLbl.frame);
            
            [self updateLabel:_titleLbl
                        alpha:1.0f
                     duration:0.3f
                        delay:0.0f
                   completion:^{
                                       
            [self updateLabel:_titleLbl
                        alpha:0.0f
                     duration:0.3f
                        delay:1.5f
                    completion:^{
                     
            _titleLbl.text = NSLocalizedString(@"welcome", nil);
            [_titleLbl sizeToFit];
            _titleLbl.center = self.view.center;
            _titleLbl.frame = CGRectIntegral(_titleLbl.frame);
                                       
            [self updateLabel:_titleLbl
                        alpha:1.0f
                     duration:0.3f
                        delay:0.0f
                   completion:^{
                                       
            [self updateLabel:_titleLbl
                        alpha:0.0f
                     duration:0.3f
                        delay:1.5f
                   completion:^{
                                   
                    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
                                       
                                  }];
                                }];
                              }];
                            }];
                          }];
        return;
    }
    
    if (!_titleLbl) {
        _titleLbl = [self _titleLblWithString:NSLocalizedString(@"amazing!", nil)];
        [self.view addSubview:_titleLbl];
    }
    
    [self updateLabel:_descriptionLbl
                alpha:0.0f
             duration:.3f
                delay:0.0f
           completion:nil];
    
    [scene performExitAnimationsWithCompletion:^{
    [scene updateDataForNextLevel];
            
    [self updateLabel:_titleLbl
                alpha:1.0f
             duration:0.3f
                delay:0.0f
           completion:^{
               
    [self updateLabel:_titleLbl
                alpha:0.0f
             duration:.3f
                delay:2.0f
           completion:^{

    self.scene.dismissAfterCompletion = YES;
                                       
    self.gridManager = [[HDGridManager alloc] initWithLevelIndex:1001];
                               
    [self.scene layoutNodesWithGrid:[self.gridManager hexagons] completion:^{
        
         _descriptionLbl.text = NSLocalizedString(@"tut2", nil);
        [_descriptionLbl sizeToFit];
        _descriptionLbl.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                             CGRectGetHeight(self.view.bounds) - CGRectGetMidY(_descriptionLbl.bounds) - 5.0f);
        _descriptionLbl.frame = CGRectIntegral(_descriptionLbl.frame);
        
        [self updateLabel:_descriptionLbl
                    alpha:1.0f
                 duration:.3f
                    delay:0.0f
               completion:nil];
    }];
               
                                     }];
                                   }];
                                 }];
}

- (void)updateLabel:(HDLabel *)label
              alpha:(CGFloat)alpha
           duration:(NSTimeInterval)duration
              delay:(NSTimeInterval)delay
         completion:(dispatch_block_t)completion
{
    if (!label) {
        return;
    }
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         label.alpha = alpha;
                     } completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

#pragma mark - Convenince Labels

- (HDLabel *)_descriptionLblWithString:(NSString *)text
{
    const CGFloat scale = IS_IPAD ? 24.0f : 22.0f;
    
    CGRect bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(CGRectInset(self.view.bounds, 40.0f, 0.0f)), 0.0);
    HDLabel *descriptionLbl = [[HDLabel alloc] initWithFrame:bounds];
    descriptionLbl.font = GAME_FONT_WITH_SIZE(CGRectGetWidth(self.view.bounds) / scale);
    descriptionLbl.textAlignment = NSTextAlignmentCenter;
    descriptionLbl.textColor = [UIColor whiteColor];
    descriptionLbl.numberOfLines = 2;
    descriptionLbl.alpha = 0.0f;
    descriptionLbl.text = text;
    [descriptionLbl sizeToFit];
    descriptionLbl.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                        CGRectGetHeight(self.view.bounds) - CGRectGetMidY(descriptionLbl.bounds) - 5.0f);
    descriptionLbl.frame = CGRectIntegral(descriptionLbl.frame);
    
    return descriptionLbl;
}

- (HDLabel *)_titleLblWithString:(NSString *)text
{
    const CGFloat scale = IS_IPAD ? 14.0f : 12.0f;
    
    HDLabel *titleLbl = [[HDLabel alloc] init];
    titleLbl.font = GAME_FONT_WITH_SIZE(CGRectGetWidth(self.view.bounds)/ scale);
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.textColor = [UIColor whiteColor];
    titleLbl.numberOfLines = 1;
    titleLbl.text = text;
    titleLbl.alpha = 0.0f;
    [titleLbl sizeToFit];
    titleLbl.center = self.view.center;
    titleLbl.frame = CGRectIntegral(titleLbl.frame);
    
    return titleLbl;
}

@end
