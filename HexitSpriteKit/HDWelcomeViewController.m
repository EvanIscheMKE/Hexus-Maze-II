//
//  HDWelcomeViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import iAd;
@import QuartzCore;

#import "HDWelcomeViewController.h"
#import "UIColor+FlatColors.h"

@interface HDWelcomeViewController ()
@property (nonatomic, strong) UIButton *beginGame;
@end

@implementation HDWelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setCanDisplayBannerAds:YES];
    [self.view setBackgroundColor:[UIColor flatMidnightBlueColor]];
    
    UILabel *title = [[UILabel alloc] init];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:[UIColor whiteColor]];
    [title setText:NSLocalizedString(@"HEXUS", nil)];
    [title setFont:GILLSANS_LIGHT(120.0f)];
    [title setMinimumScaleFactor:.25f];
    [title setAdjustsFontSizeToFitWidth:YES];
    
     self.beginGame = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beginGame addTarget:ADelegate action:@selector(presentLevelViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.beginGame setBackgroundColor:[UIColor flatPeterRiverColor]];
    [[self.beginGame titleLabel] setTextAlignment:NSTextAlignmentCenter];
    [[self.beginGame titleLabel] setFont:GILLSANS_LIGHT(22.0f)];
    [self.beginGame setTitle:NSLocalizedString(@"START", nil) forState:UIControlStateNormal];
    [self.beginGame setTitleColor:[UIColor flatMidnightBlueColor] forState:UIControlStateNormal];
    [self.beginGame.layer setCornerRadius:17.5f];
    
    for (UIView *subView in @[title, self.beginGame]) {
        [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:subView];
    }
    
    // Title Label Width
    NSLayoutConstraint *constraintTitle = [NSLayoutConstraint constraintWithItem:title
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0f
                                                                        constant:CGRectGetWidth(CGRectInset(self.view.bounds, 15.0f, 0.0f))];
    [title addConstraint:constraintTitle];
    
    // Title Label Center X
    NSLayoutConstraint *centerTitleX =  [NSLayoutConstraint constraintWithItem:title
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1
                                                                      constant:0];
    [self.view addConstraint:centerTitleX];
    
    // Title Label Center Y
    NSLayoutConstraint *centerTitleY = [NSLayoutConstraint constraintWithItem:title
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:.8f
                                                                      constant:0];
    [self.view addConstraint:centerTitleY];

    // Begin button width
    NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:self.beginGame
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0f
                                                                        constant:CGRectGetWidth(self.view.bounds)/2.5f];
    [self.beginGame addConstraint:constraintWidth];
    
    // Begin button height
    NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:self.beginGame
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0f constant:35.0f];
    [self.beginGame addConstraint:constraintHeight];
    
    // Begin button center C
    NSLayoutConstraint *centerButtonX =  [NSLayoutConstraint constraintWithItem:self.beginGame
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1
                                                                      constant:0];
    [self.view addConstraint:centerButtonX];
    
    // Begin button center x
    NSLayoutConstraint *centerButtonY = [NSLayoutConstraint constraintWithItem:self.beginGame
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1.1f
                                                                     constant:0];
    [self.view addConstraint:centerButtonY];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.beginGame setAlpha:0.0f];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_block_t animateStart = ^{
        [self.beginGame setAlpha:1.0f];
    };
    [UIView animateWithDuration:.5f animations:animateStart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
