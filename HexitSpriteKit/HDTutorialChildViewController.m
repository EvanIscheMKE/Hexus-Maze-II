//
//  HDTutorialChildViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 1/3/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "UIColor+FlatColors.h"
#import "HDTutorialChildViewController.h"

@interface HDTutorialChildViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation HDTutorialChildViewController

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    [super viewDidLoad];
    [self _setup];
}

#pragma mark - _Private

- (void)_setup
{
    NSArray *animationImages = nil;
    switch (self.index) {
        case 0:
            animationImages = @[[UIImage imageNamed:@"Tutorial-1-1"],
                                [UIImage imageNamed:@"Tutorial-1-2"]];
            break;
        case 1:
            animationImages = @[[UIImage imageNamed:@"Tutorial-1-2"],
                                [UIImage imageNamed:@"Tutorial-2-1"]];
            break;
        case 2:
            animationImages = @[[UIImage imageNamed:@"Tutorial-1-1"],
                                [UIImage imageNamed:@"Tutorial-1-2"],
                                [UIImage imageNamed:@"Tutorial-2-1"],
                                [UIImage imageNamed:@"Tutorial-3-1"],
                                [UIImage imageNamed:@"Tutorial-3-2"],
                                [UIImage imageNamed:@"Tutorial-3-3"],
                                [UIImage imageNamed:@"Tutorial-3-4"],
                                [UIImage imageNamed:@"Tutorial-3-5"],
                                [UIImage imageNamed:@"Tutorial-3-6"],
                                [UIImage imageNamed:@"Tutorial-3-7"],
                                [UIImage imageNamed:@"Tutorial-3-8"]];
            break;
    }
    
    UIImage *imageForSize = [UIImage imageNamed:@"Tutorial-1-1"];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, imageForSize.size.width, imageForSize.size.height)];
     self.imageView.image               = imageForSize;
    self.imageView.animationImages      = animationImages;
    self.imageView.animationRepeatCount = NSIntegerMax;
    self.imageView.animationDuration    = animationImages.count / 2;
    self.imageView.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                        CGRectGetMidY(self.view.bounds) + CGRectGetHeight(self.view.bounds)/8.5f);
    self.imageView.frame = CGRectIntegral(self.imageView.frame);
    self.imageView.transform = CGAffineTransformMakeScale(CGRectGetWidth(self.view.bounds) / (imageForSize.size.width + 70.0f),
                                                          CGRectGetWidth(self.view.bounds) / (imageForSize.size.width + 70.0f));

    [self.view addSubview:self.imageView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.index == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.imageView startAnimating];
        });
    } else {
        [self.imageView startAnimating];
    }
}

@end