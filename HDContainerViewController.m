//
//  ViewController.m
//  SideMenuExample
//
//  Created by Evan Ische on 10/15/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDContainerViewController.h"
#import "HDSoundManager.h"
#import "HDGameViewController.h"
#import "UIColor+FlatColors.h"
#import "HDHexagon.h"
#import "HDHelper.h"
#import "HDConstants.h"

@implementation UIViewController (HDMenuViewController)

- (HDContainerViewController *)containerViewController
{
    UIViewController *parent = self;
    Class containerClass = [HDContainerViewController class];
    while ( nil != (parent = [parent parentViewController]) && ![parent isKindOfClass:containerClass] ) { }
    
    return (id)parent;
}

@end

@interface HDContainerViewController ()
@property (nonatomic, strong) UIViewController *frontViewController;
@property (nonatomic, strong) UIViewController *rearViewController;
@property (nonatomic, setter=setExpanded:, assign) BOOL isExpanded;
@end

@implementation HDContainerViewController {
    NSDictionary *_metrics;
    NSDictionary *_views;
    
    CGFloat _menuOffsetX;
    
    BOOL _isExpanded;
}

@synthesize isExpanded = _isExpanded;
- (instancetype)initWithFrontViewController:(UIViewController *)frontController rearViewController:(UIViewController *)rearController
{
    NSParameterAssert(frontController);
    NSParameterAssert(rearController);
    if (self = [super init]) {
        self.frontViewController = frontController;
        self.rearViewController  = rearController;
    }
    return self;
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addChildViewController:self.rearViewController];
    [self addChildViewController:self.frontViewController];
    
    [self.view addSubview:self.rearViewController.view];
    [self.view addSubview:self.frontViewController.view];
    
    [self.rearViewController  didMoveToParentViewController:self];
    [self.frontViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Public

- (void)setFrontMostViewController:(UIViewController *)controller
{
    UIViewController *oldController = self.frontViewController;
    
    self.frontViewController = controller;
    
    [oldController willMoveToParentViewController:nil];
    [oldController.view removeFromSuperview];
    [oldController removeFromParentViewController];
    
    [self addChildViewController:self.frontViewController];
    [self.view addSubview:self.frontViewController.view];
    [self.frontViewController didMoveToParentViewController:self];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(container:transitionedFromController:toController:)]) {
        [self.delegate container:self transitionedFromController:oldController toController:self.frontViewController];
    }
}

- (void)setExpanded:(BOOL)isExpanded
{
    if (_isExpanded == isExpanded) {
        return;
    }
    
    _isExpanded = isExpanded;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(container:willChangeExpandedState:)]) {
        [self.delegate container:self willChangeExpandedState:isExpanded];
    }
    
    if (_isExpanded) {
        [self _expandAnimated:YES];
    } else {
        [self _closeAnimated:YES];
    }
}

- (void)toggleMenuViewControllerWithCompletion:(dispatch_block_t)completion
{
    [self toggleMenuViewController];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) {
            completion();
        }
    });
}

- (void)toggleMenuViewController
{
    [self setExpanded:!self.isExpanded];
}

#pragma mark - Private

- (void)_closeAnimated:(BOOL)animated
{
    dispatch_block_t closeAnimation = ^{
        CGRect rect = self.frontViewController.view.frame;
        rect.origin.x = 0;
        self.frontViewController.view.frame = rect;
    };
    
    if (!animated) {
        closeAnimation();
    } else {
        [UIView animateWithDuration:.3f
                              delay:.0f
             usingSpringWithDamping:.8f
              initialSpringVelocity:.05f
                            options:0
                         animations:closeAnimation
                         completion:nil];
    }
}

- (void)_expandAnimated:(BOOL)animated
{
    dispatch_block_t expandAnimation = ^{
        CGRect rect = self.frontViewController.view.frame;
        rect.origin.x = [HDHelper sideMenuOffsetX];
        self.frontViewController.view.frame = rect;
    };
    
    if (!animated) {
        expandAnimation();
    } else {
        [UIView animateWithDuration:.3f
                              delay:.0f
             usingSpringWithDamping:.8f
              initialSpringVelocity:.05f
                            options:0
                         animations:expandAnimation
                         completion:nil];
    }
}

@end
