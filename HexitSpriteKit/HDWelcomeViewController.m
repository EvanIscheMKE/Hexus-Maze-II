//
//  HDWelcomeViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import iAd;
@import QuartzCore;

#import "HDSoundManager.h"
#import "HDWelcomeViewController.h"
#import "HDTutorialParentViewController.h"
#import "HDHexagonButton.h"
#import "UIColor+FlatColors.h"

#define kPadding  [[UIScreen mainScreen] bounds].size.width < 321.0f ? 2.0f : 4.0f
#define kHexaSize [[UIScreen mainScreen] bounds].size.width / 3.75f


@interface HDWelcomeViewController ()
@property (nonatomic, strong) UILabel *descriptionLabel;
@end

@implementation HDWelcomeViewController

#pragma mark - View Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    [self _setup];
}

- (void)_setup
{
    UIImage *welcome = [UIImage imageNamed:@"HexusLogo"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:welcome];
    imageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 20.0f);
    [self.view addSubview:imageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:ADelegate action:@selector(presentLevelViewController)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.text            = @"Tap to begin";
    self.descriptionLabel.font            = GILLSANS(22.0f);
    self.descriptionLabel.textColor       = [UIColor flatEmeraldColor];
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
    [self _prepareForIntroAnimations];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self _showActivityAnimated:YES];
    
////    if (![[NSUserDefaults standardUserDefaults] boolForKey:HDFirstRunKey]) {
//        HDTutorialParentViewController *controller = [[HDTutorialParentViewController alloc] init];
//        [self.navigationController presentViewController:controller animated:NO completion:nil];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HDFirstRunKey];
////    }
}

#pragma mark - Private

- (void)_hideActivityAnimated:(BOOL)animated
{
    dispatch_block_t animation = ^{
        self.descriptionLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                           CGRectGetHeight(self.view.bounds) + CGRectGetMidY(self.descriptionLabel.bounds));
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
        [UIView animateWithDuration:.3f animations:animation completion:^(BOOL finished) {
            
        }];
    } else {
        animation();
    }
}

- (void)_presentSettingsViewController
{
    [self _hideActivityAnimated:YES];
    [ADelegate presentSettingsViewController];
}

- (void)_prepareForIntroAnimations
{
    [self _hideActivityAnimated:NO];
}

@end
