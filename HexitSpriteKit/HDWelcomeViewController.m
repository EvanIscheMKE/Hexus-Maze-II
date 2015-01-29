//
//  HDWelcomeViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import  QuartzCore;

#import "HDWelcomeViewController.h"
#import "HDTutorialParentViewController.h"
#import "UIColor+FlatColors.h"

const CGFloat titleInset = 20.0f;
@interface HDWelcomeViewController ()
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *begin;
@end

@implementation HDWelcomeViewController

- (void)viewDidLoad
{
    [self _setup];
    [super viewDidLoad];
}

- (void)_setup
{
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    
    UIImage *welcome = [UIImage imageNamed:@"MenuVCIcon-600@2x.png"];
    self.imageView     = [[UIImageView alloc] initWithImage:welcome];
    
    self.begin = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.begin addTarget:ADelegate action:@selector(presentLevelViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.begin setTitle:@"BEGIN" forState:UIControlStateNormal];
    [self.begin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.begin.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.begin.titleLabel.font = GILLSANS_LIGHT(20.0f);
    self.begin.backgroundColor = [UIColor flatPeterRiverColor];
    self.begin.layer.cornerRadius = 20.0f;
    
    for (UIView *subView in @[self.imageView, self.begin]) {
        subView.transform = CGAffineTransformMakeScale(CGRectGetWidth(self.view.bounds)/375.0f, CGRectGetWidth(self.view.bounds)/375.0f);
        subView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:subView];
    }
    
    //ImageView
    NSLayoutConstraint *heightConstraint =
    [NSLayoutConstraint constraintWithItem:self.imageView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0f
                                  constant:welcome.size.height];
    [self.imageView addConstraint:heightConstraint];
    
    NSLayoutConstraint *widthConstraint =
    [NSLayoutConstraint constraintWithItem:self.imageView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0f
                                  constant:welcome.size.width];
    [self.imageView addConstraint:widthConstraint];
    
    NSLayoutConstraint *centerXConstraint =
    [NSLayoutConstraint constraintWithItem:self.imageView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0f
                                  constant:0.0f];
    [self.view addConstraint:centerXConstraint];
    
    NSLayoutConstraint *centerYConstraint =
    [NSLayoutConstraint constraintWithItem:self.imageView
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0f
                                  constant:-20.0f];
    [self.view addConstraint:centerYConstraint];
    
    //Button
    NSLayoutConstraint *buttonHeightConstraint =
    [NSLayoutConstraint constraintWithItem:self.begin
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0f
                                  constant:40.0f];
    [self.begin addConstraint:buttonHeightConstraint];
    
    NSLayoutConstraint *buttonWidthConstraint =
    [NSLayoutConstraint constraintWithItem:self.begin
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0f
                                  constant:160.0f];
    [self.begin addConstraint:buttonWidthConstraint];
    
    NSLayoutConstraint *buttonCenterXConstraint =
    [NSLayoutConstraint constraintWithItem:self.begin
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0f
                                  constant:0.0f];
    [self.view addConstraint:buttonCenterXConstraint];
    
    NSLayoutConstraint *buttonCenterYConstraint =
    [NSLayoutConstraint constraintWithItem:self.begin
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.65f
                                  constant:0];
    [self.view addConstraint:buttonCenterYConstraint];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _prepareForIntroAnimations];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![self _checkForFirstRun]) {
        [self _performIntroAnimations];
    }
}

#pragma mark - Private

- (void)_animateDismissal
{
    [self _hideActivityAnimated:YES];
    [ADelegate presentLevelViewController];
}

- (BOOL)_checkForFirstRun
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HDFirstRunKey]) {
        [ADelegate presentTutorialViewControllerForFirstRun];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HDFirstRunKey];
        return YES;
    }
    return NO;
}

- (void)_prepareForIntroAnimations
{
    self.imageView.alpha = 0.0f;
    [self _hideActivityAnimated:NO];
}

- (void)_performIntroAnimations
{
    [UIView animateWithDuration:.300f animations:^{ self.imageView.alpha = 1.0f; }];
    [self _showActivityAnimated:YES];
}

- (void)_hideActivityAnimated:(BOOL)animated
{
    dispatch_block_t animation = ^{
        self.descriptionLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                                   CGRectGetHeight(self.view.bounds) +
                                                   CGRectGetMidY(self.descriptionLabel.bounds));
    };
    
    if (animated) {
        [UIView animateWithDuration:.300f animations:animation completion:^(BOOL finished) {
            [self.descriptionLabel.layer removeAllAnimations];
        }];
    } else {
        animation();
    }
}

- (void)_showActivityAnimated:(BOOL)animated
{
    dispatch_block_t animation = ^{
        self.descriptionLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                                   CGRectGetHeight(self.view.bounds) - CGRectGetMidY(self.descriptionLabel.bounds) - 8.0f);
    };
    
    if (animated) {
        [UIView animateWithDuration:.300f animations:animation completion:^(BOOL finished) {
            CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
            scale.toValue   = @1.1f;
            scale.fromValue = @1.0f;
            scale.autoreverses = YES;
            scale.repeatCount = CGFLOAT_MAX;
            scale.duration  = .300f;
            [self.descriptionLabel.layer addAnimation:scale forKey:scale.keyPath];
        }];
    } else {
        animation();
    }
}

@end
