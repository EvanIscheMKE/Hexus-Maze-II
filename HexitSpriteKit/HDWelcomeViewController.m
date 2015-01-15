//
//  HDWelcomeViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDWelcomeViewController.h"
#import "HDTutorialParentViewController.h"
#import "UIColor+FlatColors.h"

const CGFloat titleInset = 20.0f;

@interface HDWelcomeViewController ()
@property (nonatomic, strong) UILabel *descriptionLabel;
@end

@implementation HDWelcomeViewController

#pragma mark - View Cycle

- (void)viewDidLoad
{
    [self _setup];
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
}

- (void)_setup
{
    UIImage *welcome = [UIImage imageNamed:@"HexusLogo"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:welcome];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:imageView];
    
     NSLayoutConstraint *heightConstraint =
    [NSLayoutConstraint constraintWithItem:imageView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0f
                                  constant:CGRectGetHeight(self.view.bounds)/5.7];
    [imageView addConstraint:heightConstraint];
    
     NSLayoutConstraint *widthConstraint =
    [NSLayoutConstraint constraintWithItem:imageView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0f
                                  constant:CGRectGetWidth(CGRectInset(self.view.bounds, titleInset, 0.0f))];
    [imageView addConstraint:widthConstraint];
    
     NSLayoutConstraint *centerXConstraint =
    [NSLayoutConstraint constraintWithItem:imageView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0f
                                  constant:0.0f];
    [self.view addConstraint:centerXConstraint];
    
     NSLayoutConstraint *centerYConstraint =
    [NSLayoutConstraint constraintWithItem:imageView
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0f
                                  constant:0.0f];
    [self.view addConstraint:centerYConstraint];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:ADelegate action:@selector(presentLevelViewController)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.text            = @"TAP TO BEGIN";
    self.descriptionLabel.font            = GILLSANS(24.0f);
    self.descriptionLabel.textColor       = [UIColor whiteColor];
    self.descriptionLabel.textAlignment   = NSTextAlignmentCenter;
    self.descriptionLabel.backgroundColor = [UIColor flatWetAsphaltColor];
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                               CGRectGetHeight(self.view.bounds) + CGRectGetMidY(self.descriptionLabel.bounds));
    self.descriptionLabel.frame = CGRectIntegral(self.descriptionLabel.frame);
    [self.view addSubview:self.descriptionLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _hideActivityAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self _showActivityAnimated:YES];
   // [self _checkForFirstRun];
}

#pragma mark - Private

- (void)_animateDismissal
{
    [self _hideActivityAnimated:YES];
    [ADelegate presentLevelViewController];
}

- (void)_checkForFirstRun
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HDFirstRunKey]) {
        HDTutorialParentViewController *controller = [[HDTutorialParentViewController alloc] init];
        [self.navigationController presentViewController:controller animated:NO completion:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HDFirstRunKey];
    }
}

- (void)_hideActivityAnimated:(BOOL)animated
{
    dispatch_block_t animation = ^{
        self.descriptionLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                                   CGRectGetHeight(self.view.bounds) +
                                                   CGRectGetMidY(self.descriptionLabel.bounds));
    };
    
    if (animation) {
        [UIView animateWithDuration:.3f animations:animation];
    } else {
        animation();
    }
}

- (void)_showActivityAnimated:(BOOL)animated
{
    dispatch_block_t animation = ^{
        self.descriptionLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                           CGRectGetHeight(self.view.bounds) - CGRectGetMidY(self.descriptionLabel.bounds) - 15.0f);
    };
    
    if (animated) {
        [UIView animateWithDuration:.3f animations:animation];
    } else {
        animation();
    }
}

@end
