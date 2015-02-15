//
//  HDTutorialParentViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 1/3/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "UIColor+FlatColors.h"
#import "HDTutorialChildViewController.h"
#import "HDTutorialParentViewController.h"

static const CGFloat inset = 50.0f;
static const CGFloat defaultPageControlHeight = 70.0f;
static const NSInteger numberOfPages = 3;
@interface HDTutorialParentViewController ()
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) UIButton *navigate;
@property (nonatomic, strong) UILabel *descriptionLabel;
@end

@implementation HDTutorialParentViewController

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    [super viewDidLoad];
    [self _setup];
    [self _nextPage];
}

#pragma mark - Private

- (void)_setup
{
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    self.pageViewController.view.frame = self.view.bounds;
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    CGRect descriptionBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(CGRectInset(self.view.bounds, inset, 0.0f)), 0.0f);
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.frame         = descriptionBounds;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.font          = GILLSANS(26.0f);
    self.descriptionLabel.textColor     = [UIColor whiteColor];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.text          = NSLocalizedString(@"tutorial1", nil);
    self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
  //  self.descriptionLabel.transform     = CGAffineTransformMakeScale(CGRectGetWidth(self.view.bounds)/375.0f,
  //                                                                   CGRectGetWidth(self.view.bounds)/375.0f);
    [self.view addSubview:self.descriptionLabel];
    
    CGRect navigateFrame = CGRectMake(
                                      0.0f,
                                      CGRectGetHeight(self.view.bounds) - defaultPageControlHeight,
                                      CGRectGetWidth(self.view.bounds),
                                      defaultPageControlHeight
                                      );
    
    self.navigate = [UIButton buttonWithType:UIButtonTypeCustom];
    self.navigate.frame = navigateFrame;
    [self.navigate setTitle:NSLocalizedString(@"continue", nil) forState:UIControlStateNormal];
    [self.navigate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navigate addTarget:self action:@selector(_nextPage) forControlEvents:UIControlEventTouchUpInside];
    self.navigate.titleLabel.font = GILLSANS(24.0f * CGRectGetWidth(self.view.bounds)/375.0f);
    self.navigate.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigate.backgroundColor = [UIColor colorWithWhite:0.0f alpha:.95f];
    [self.view addSubview:self.navigate];
}

- (void)_nextPage
{
    HDTutorialChildViewController *currentViewController = (HDTutorialChildViewController *)[self.pageViewController.viewControllers firstObject];
    
    NSInteger pageIndex = 0;
    if (currentViewController) {
        pageIndex = MIN(currentViewController.index += 1, numberOfPages);
        if (pageIndex == numberOfPages) {
             [self _returnHome];
            return;
        }
    }
    
    [self _updateLabelForPageIndex:pageIndex];
    [self.pageViewController setViewControllers:@[(HDTutorialChildViewController *)[self _viewControllerAtIndex:pageIndex]]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:nil];
}

- (HDTutorialChildViewController *)_viewControllerAtIndex:(NSUInteger)index
{
    HDTutorialChildViewController *childViewController = [HDTutorialChildViewController new];
    childViewController.index = index;
    
    return childViewController;
}

- (void)_updateLabelForPageIndex:(NSInteger)pageIndex
{
    switch (pageIndex) {
        case 0:
            self.descriptionLabel.text = NSLocalizedString(@"tutorial1", nil);
            break;
        case 1:
            self.descriptionLabel.text = NSLocalizedString(@"tutorial2", nil);
            break;
        case 2:
            self.descriptionLabel.text = NSLocalizedString(@"tutorial3", nil);
            [self _changeButtonStateForDismissal];
            break;
    }
    
    [self.descriptionLabel sizeToFit];
     self.descriptionLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetHeight(self.view.bounds)/8);
     self.descriptionLabel.frame  = CGRectIntegral(self.descriptionLabel.frame);
}

- (void)_changeButtonStateForDismissal
{
    [self.navigate addTarget:self action:@selector(_returnHome) forControlEvents:UIControlEventTouchUpInside];
    [self.navigate setTitle:NSLocalizedString(@"begin", nil) forState:UIControlStateNormal];
}

- (void)_returnHome
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
