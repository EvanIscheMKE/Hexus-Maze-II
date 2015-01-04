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
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    
    NSArray *animationImages = nil;
    
    switch (self.index) {
        case 0:
            animationImages = @[[UIImage imageNamed:@"Tutorial-ScreenOne-NonSelected@2x.png"],
                                [UIImage imageNamed:@"Tutorial-ScreenOne-Selected@2x.png"]];
            break;
        case 1:
            animationImages = @[[UIImage imageNamed:@"Tutorial-ScreenOne-Selected@2x.png"],
                                [UIImage imageNamed:@"Tutorial-PageTwo-One@2x"],
                                [UIImage imageNamed:@"Tutorial-ScreenOne-Selected@2x.png"],
                                [UIImage imageNamed:@"Tutorial-PageTwo-Two@2x"],
                                [UIImage imageNamed:@"Tutorial-ScreenOne-Selected@2x.png"],
                                [UIImage imageNamed:@"Tutorial-PageTwo-Three@2x"],
                                [UIImage imageNamed:@"Tutorial-ScreenOne-Selected@2x.png"],
                                [UIImage imageNamed:@"Tutorial-PageTwo-Four@2x"]];
            break;
        case 2:
            animationImages = @[[UIImage imageNamed:@"Tutorial-ScreenOne-NonSelected@2x.png"],
                                [UIImage imageNamed:@"Tutorial-ScreenOne-Selected@2x.png"],
                                [UIImage imageNamed:@"Tutorial-PageTwo-One@2x"],
                                [UIImage imageNamed:@"Tutorial-PageThree-One@2x.png"],
                                [UIImage imageNamed:@"Tutorial-PageThree-Two@2x.png"],
                                [UIImage imageNamed:@"Tutorial-PageThree-Three@2x.png"],
                                [UIImage imageNamed:@"Tutorial-PageThree-Four@2x.png"],
                                [UIImage imageNamed:@"Tutorial-PageThree-Five@2x.png"],
                                [UIImage imageNamed:@"Tutorial-PageThree-Six@2x.png"],
                                [UIImage imageNamed:@"Tutorial-PageThree-Seven@2x.png"]];
            break;
    }
    
    UIImage *imageForSize = [UIImage imageNamed:@"Tutorial-ScreenOne-Selected@2x.png"];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, imageForSize.size.width, imageForSize.size.height)];
    self.imageView.animationImages      = animationImages;
    self.imageView.animationRepeatCount = NSIntegerMax;
    self.imageView.animationDuration    = animationImages.count / 2;
    self.imageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 20.0f);
    [self.view addSubview:self.imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.index == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.imageView startAnimating];
        });
    } else {
        [self.imageView startAnimating];
    }
}

@end