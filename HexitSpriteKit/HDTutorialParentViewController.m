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

static const NSInteger numberOfPages = 3;
static const CGFloat defaultPageControlHeight = 70.0f;

@interface HDTutorialParentViewController ()
@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) UIButton *navigate;
@property (nonatomic, strong) UILabel *descriptionLabel;
@end

@implementation HDTutorialParentViewController

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    self.pageController.view.frame = self.view.bounds;

    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    
    CGRect descriptionBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(CGRectInset(self.view.bounds, 50.0f, 0.0f)), 0.0f);
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.frame         = descriptionBounds;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.font          = GILLSANS(26.0f);
    self.descriptionLabel.textColor     = [UIColor whiteColor];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.text          = NSLocalizedString(@"Start by selecting a white tile.", nil);
    self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:self.descriptionLabel];
    
    CGRect navigateFrame = CGRectMake(0.0f,
                                      CGRectGetHeight(self.view.bounds) - defaultPageControlHeight,
                                      CGRectGetWidth(self.view.bounds),
                                      defaultPageControlHeight);
    self.navigate = [UIButton buttonWithType:UIButtonTypeCustom];
    self.navigate.frame = navigateFrame;
    [self.navigate setTitle:@"Continue" forState:UIControlStateNormal];
    [self.navigate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navigate addTarget:self action:@selector(_nextPage) forControlEvents:UIControlEventTouchUpInside];
    self.navigate.titleLabel.font = GILLSANS(24.0f);
    self.navigate.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigate.backgroundColor = [UIColor flatPeterRiverColor];
    [self.view addSubview:self.navigate];
    
    [self _nextPage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)_nextPage
{
    HDTutorialChildViewController *currentViewController = (HDTutorialChildViewController *)[self.pageController.viewControllers firstObject];
    
    NSInteger pageIndex = 0;
    if (currentViewController) {
        pageIndex = MIN(currentViewController.index += 1, numberOfPages);
        if (pageIndex == numberOfPages) {
             [self _returnHome];
        }
    }
    
    [self _updateLabelForPageIndex:pageIndex];
    
    HDTutorialChildViewController *childViewController = (HDTutorialChildViewController *)[self _viewControllerAtIndex:pageIndex];
    
    [self.pageController setViewControllers:@[childViewController]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:nil];
}

- (HDTutorialChildViewController *)_viewControllerAtIndex:(NSUInteger)index {
    
    HDTutorialChildViewController *childViewController = [HDTutorialChildViewController new];
    childViewController.index = index;
    
    return childViewController;
    
}

- (void)_updateLabelForPageIndex:(NSInteger)pageIndex
{
    switch (pageIndex) {
        case 0:
            self.descriptionLabel.text = NSLocalizedString(@"Start by selecting a white hexagon.", nil);
            break;
        case 1:
            self.descriptionLabel.text = NSLocalizedString(@"Move to an active hexagon that is touching the last hexagon.", nil);
            break;
        case 2:
            self.descriptionLabel.text = NSLocalizedString(@"Continue until the path is completed!", nil);
            [self _changeButtonStateForDismissal];
            break;
    }
    [self.descriptionLabel sizeToFit];
     self.descriptionLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetHeight(self.view.bounds)/8);
     self.descriptionLabel.frame  = CGRectIntegral(self.descriptionLabel.frame);
}

- (void)_changeButtonStateForDismissal
{
    [self.navigate addTarget:self action:@selector(_nextPage) forControlEvents:UIControlEventTouchUpInside];
    [self.navigate setTitle:@"Begin Game" forState:UIControlStateNormal];
}

- (void)_returnHome
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

@end
