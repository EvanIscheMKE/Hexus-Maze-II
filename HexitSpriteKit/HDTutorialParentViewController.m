//
//  HDTutorialParentViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 1/3/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHexagonControl.h"
#import "UIColor+FlatColors.h"
#import "HDTutorialChildViewController.h"
#import "HDTutorialParentViewController.h"

static const NSInteger numberOfPages = 3;
static const CGFloat defaultPageControlHeight = 50.0f;

@interface HDTutorialParentViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate, HDTutorialChildViewControllerDelegate>
@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) HDHexagonControl *pageControl;
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
    self.pageController.dataSource = self;
    self.pageController.delegate   = self;
    
    [self.pageController setViewControllers:@[[self _viewControllerAtIndex:0]]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    
    CGRect containerFrame = CGRectMake(0.0f,
                                       CGRectGetHeight(self.view.bounds)*.7f,
                                       CGRectGetWidth(self.view.bounds),
                                       CGRectGetHeight(self.view.bounds)*.3f);
    
    UIView *container = [[UIView alloc] initWithFrame:containerFrame];
    container.backgroundColor = [UIColor flatPeterRiverColor];
    [self.view addSubview:container];
    
    CGRect controlRect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), defaultPageControlHeight);
    self.pageControl = [[HDHexagonControl alloc] initWithFrame:controlRect];
    self.pageControl.backgroundColor = [UIColor flatPeterRiverColor];
    self.pageControl.numberOfPages = numberOfPages;
    self.pageControl.currentPage = 0;
    [self.pageControl setCenter:CGPointMake(
                                            CGRectGetMidX(self.view.bounds),
                                            CGRectGetHeight(self.view.bounds) - CGRectGetMidY(self.pageControl.bounds))];
    self.pageControl.frame = CGRectIntegral(self.pageControl.frame);
    [self.view addSubview:self.pageControl];
    
    UIButton *test = [UIButton buttonWithType:UIButtonTypeCustom];
    [test setTitle:@"END" forState:UIControlStateNormal];
    [test setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [test addTarget:self
             action:@selector(_returnHome)
   forControlEvents:UIControlEventTouchUpInside];
    test.titleLabel.font = GILLSANS_LIGHT(40.0f);
    test.titleLabel.textAlignment = NSTextAlignmentCenter;
    test.backgroundColor = [UIColor flatPeterRiverColor];
    [test sizeToFit];
    test.center = CGPointMake(CGRectGetMidX(container.bounds), CGRectGetMidY(container.bounds));
    [container addSubview:test];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)_returnHome
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (HDTutorialChildViewController *)_viewControllerAtIndex:(NSUInteger)index {
    
    HDTutorialChildViewController *childViewController = [HDTutorialChildViewController new];
    childViewController.delegate = self;
    childViewController.index = index;
    
    return childViewController;
    
}

#pragma mark - <HDTutorialChildViewControllerDelegate>

- (void)childViewControllerWasSelected:(HDTutorialChildViewController *)childView
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - <UIPageViewControllerDelegate>

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    HDTutorialChildViewController *currentViewController = pageViewController.viewControllers[0];
    self.pageControl.currentPage = currentViewController.index;
}

#pragma mark - <UIPageViewControllerDataSource>

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController{
    
    NSUInteger index = [(HDTutorialChildViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self _viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [(HDTutorialChildViewController *)viewController index];
    
    index++;
    
    if (index == numberOfPages) {
        return nil;
    }
    
    return [self _viewControllerAtIndex:index];
}

@end
