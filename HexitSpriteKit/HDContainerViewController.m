//
//  ViewController.m
//  SideMenuExample
//
//  Created by Evan Ische on 10/15/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDContainerViewController.h"
#import "HDGameViewController.h"
#import "HDLevelViewController.h"
#import "UIColor+FlatColors.h"
#import "HDHexagon.h"
#import "HDHelper.h"
#import "HDConstants.h"

@implementation UIViewController (HDMenuViewController)

- (HDContainerViewController *)containerViewController
{
    UIViewController *parent = self;
    Class revealClass = [HDContainerViewController class];
    while ( nil != (parent = [parent parentViewController])
           && ![parent isKindOfClass:revealClass] ) {
    
    }
    return (id)parent;
}

@end

static CGFloat const kAnimationOffsetX = 180.0f;

@interface HDContainerViewController ()

@property (nonatomic, strong) UIViewController *gameViewController;
@property (nonatomic, strong) UIViewController *rearViewController;

@property (nonatomic, strong) UIButton *toggleButton;

@property (nonatomic, setter=setExpanded:, assign) BOOL isExpanded;

@end

@implementation HDContainerViewController{
    BOOL _isExpanded;
}

@synthesize isExpanded = _isExpanded;
- (instancetype)initWithGameViewController:(UIViewController *)gameController rearViewController:(UIViewController *)rearController
{
    NSParameterAssert(gameController);
    NSParameterAssert(rearController);
    if (self = [super init]) {
        [self setGameViewController:gameController];
        [self setRearViewController:rearController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.rearViewController.view];
    [self.view addSubview:self.gameViewController.view];
    
    [self addChildViewController:self.gameViewController];
    [self addChildViewController:self.rearViewController];
    
    [self.gameViewController didMoveToParentViewController:self];
    [self.rearViewController didMoveToParentViewController:self];
    
    CGRect menuRect = CGRectMake(5.0f, 5.0f, 50.0f, 50.0f);
    self.toggleButton = [[UIButton alloc] initWithFrame:menuRect];
    [self.toggleButton setImage:[UIImage imageNamed: @"BounceButton.png" ] forState:UIControlStateNormal];
    [self.toggleButton addTarget:self action:@selector(_toggleHDMenuViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.gameViewController.view addSubview:self.toggleButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setFrontViewController:(UIViewController *)controller animated:(BOOL)animated
{
    UIViewController *oldController = self.gameViewController;
    
    [self setGameViewController:controller];
    [self addChildViewController:self.gameViewController];
    
    void (^completionBlock)(BOOL) = ^(BOOL finished){
        
        [oldController willMoveToParentViewController:nil];
        [oldController removeFromParentViewController];
        [self.gameViewController didMoveToParentViewController:self];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(container:transitionedFromController:toController:)]) {
            [self.delegate container:self transitionedFromController:oldController toController:self.gameViewController];
        }
    };
    
    dispatch_block_t animation = ^{
        if (!animated) {
            [oldController.view removeFromSuperview];
            [self.view addSubview:self.gameViewController.view];
        }
        
        [self.toggleButton removeFromSuperview];
        [self.gameViewController.view addSubview:self.toggleButton];
        
        if (self.isExpanded) {
            self.isExpanded = NO;
            
            CGRect rect = self.gameViewController.view.frame;
            rect.origin.x = 0;
            [self.gameViewController.view setFrame:rect];
        }
    };
    
    if (animated) {
        [self transitionFromViewController:oldController
                          toViewController:self.gameViewController
                                  duration:.3f
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

#pragma mark -
#pragma mark - Private

- (void)_closeAnimated:(BOOL)animated
{
    dispatch_block_t closeAnimation = ^{
        CGRect rect = self.gameViewController.view.frame;
        rect.origin.x = 0;
        [self.gameViewController.view setFrame:rect];
    };
    
    if (!animated) {
        closeAnimation();
    } else {
        [UIView animateWithDuration:.3f
                         animations:closeAnimation
                         completion:nil];
    }
}

- (void)_expandAnimated:(BOOL)animated
{
    dispatch_block_t expandAnimation = ^{
        CGRect rect = self.gameViewController.view.frame;
        rect.origin.x += kAnimationOffsetX;
        [self.gameViewController.view setFrame:rect];
    };
    
    if (!animated) {
        expandAnimation();
    } else {
        [UIView animateWithDuration:.3f
                         animations:expandAnimation
                         completion:nil];
    }
}

- (void)_toggleHDMenuViewController
{
    [self setExpanded:!self.isExpanded];
}


@end

