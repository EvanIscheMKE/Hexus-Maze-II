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

static const CGFloat MINIMUM_MENU_OFFSET_X = 228.0f;

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

@property (nonatomic, copy) dispatch_block_t layoutMenuToggle;

@property (nonatomic, strong) UIViewController *frontViewController;
@property (nonatomic, strong) UIViewController *rearViewController;

@property (nonatomic, setter=setExpanded:, assign) BOOL isExpanded;

@end

@implementation HDContainerViewController {
    NSDictionary *_metrics;
    NSDictionary *_views;
    BOOL _isExpanded;
}

@synthesize isExpanded = _isExpanded;
- (instancetype)initWithGameViewController:(UIViewController *)gameController rearViewController:(UIViewController *)rearController
{
    NSParameterAssert(gameController);
    NSParameterAssert(rearController);
    if (self = [super init]) {
        [self setFrontViewController:gameController];
        [self setRearViewController:rearController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addChildViewController:self.rearViewController];
    [self addChildViewController:self.frontViewController];
    
    [self.view addSubview:self.rearViewController.view];
    [self.view addSubview:self.frontViewController.view];
    
    [self.rearViewController didMoveToParentViewController:self];
    [self.frontViewController didMoveToParentViewController:self];
    
}

- (void)setFrontViewController:(UIViewController *)controller animated:(BOOL)animated
{
    UIViewController *oldController = self.frontViewController;
    
    [self setFrontViewController:controller];
    [self addChildViewController:self.frontViewController];
    
    void (^completionBlock)(BOOL) = ^(BOOL finished){
        
        [oldController willMoveToParentViewController:nil];
        [oldController removeFromParentViewController];
        [self.frontViewController didMoveToParentViewController:self];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(container:transitionedFromController:toController:)]) {
            [self.delegate container:self transitionedFromController:oldController toController:self.frontViewController];
        } 
    };
    
    dispatch_block_t animation = ^{
        
        if (!animated) {
            [oldController.view removeFromSuperview];
            [self.view addSubview:self.frontViewController.view];
        }
        
        if (self.isExpanded) {
            self.isExpanded = NO;
            
            CGRect rect = self.frontViewController.view.frame;
            rect.origin.x = 0;
            [self.frontViewController.view setFrame:rect];
        }
    };
    
    if (animated) {
        [self transitionFromViewController:oldController
                          toViewController:self.frontViewController
                                  duration:.5f
                                   options:UIViewAnimationOptionTransitionFlipFromRight
                                animations:animation
                                completion:completionBlock];
    } else {
        animation();
        completionBlock(YES);
    }
}

- (void)setExpanded:(BOOL)isExpanded
{
    if (_isExpanded == isExpanded) {
        return;
    }
    
    _isExpanded = isExpanded;
    
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

- (void)_closeAnimated:(BOOL)animated
{
    dispatch_block_t closeAnimation = ^{
        CGRect rect = self.frontViewController.view.frame;
        rect.origin.x = 0;
        [self.frontViewController.view setFrame:rect];
    };
    
    if (!animated) {
        closeAnimation();
    } else {
        [UIView animateWithDuration:.3f
                              delay:0.0f
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
        rect.origin.x = MAX(ceilf(kAnimationOffsetX), MINIMUM_MENU_OFFSET_X);
        [self.frontViewController.view setFrame:rect];
    };
    
    if (!animated) {
        expandAnimation();
    } else {
        [UIView animateWithDuration:.3f
                              delay:0.0f
             usingSpringWithDamping:.8f
              initialSpringVelocity:.05f
                            options:0
                         animations:expandAnimation
                         completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

