//
//  ViewController.m
//  SideMenuExample
//
//  Created by Evan Ische on 10/15/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDContainerViewController.h"
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

@property (nonatomic, strong) UIViewController *gameViewController;
@property (nonatomic, strong) UIViewController *rearViewController;

@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *toggleButton;

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
    
    [self _layoutNavigationButtons];
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
        [self.shareButton  removeFromSuperview];
        [self.gameViewController.view addSubview:self.toggleButton];
        [self.gameViewController.view addSubview:self.shareButton];
    
        self.layoutMenuToggle();
        
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

- (void)_layoutNavigationButtons
{
     self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.toggleButton setImage:[UIImage imageNamed: @"TOGGLEE"] forState:UIControlStateNormal];
    [self.toggleButton addTarget:self action:@selector(_toggleHDMenuViewController) forControlEvents:UIControlEventTouchUpInside];
    
     self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareButton setImage:[UIImage imageNamed: @"SHAREE"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(_presentShareViewController) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *button in @[self.toggleButton, self.shareButton]) {
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.gameViewController.view addSubview:button];
    }
    
    UIButton *toggle = self.toggleButton;
    UIButton *share  = self.shareButton;
    
    _views = NSDictionaryOfVariableBindings(toggle, share);
    
    _metrics = @{ @"buttonHeight" : @(30.0f), @"inset" : @(20.0f) };
    
    dispatch_block_t layoutToggleButtonConstraints = ^{
        
        NSArray *tHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[toggle(buttonHeight)]"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
        
        NSArray *tVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[toggle(buttonHeight)]"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
        
        NSArray *sHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[share(buttonHeight)]-inset-|"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
        
        NSArray *sVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[share(buttonHeight)]"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
        
        [self.gameViewController.view addConstraints:tHorizontalConstraint];
        [self.gameViewController.view addConstraints:tVerticalConstraint];
        [self.gameViewController.view addConstraints:sHorizontalConstraint];
        [self.gameViewController.view addConstraints:sVerticalConstraint];
        
    };
    
    self.layoutMenuToggle = layoutToggleButtonConstraints;
    
    layoutToggleButtonConstraints();
}

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
        CGRect rect = self.gameViewController.view.frame;
        rect.origin.x += MAX(ceilf(kAnimationOffsetX), MINIMUM_MENU_OFFSET_X);
        [self.gameViewController.view setFrame:rect];
    };
    
    NSLog(@"%f",kAnimationOffsetX);
    
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

- (void)_toggleHDMenuViewController
{
    [self setExpanded:!self.isExpanded];
}

- (void)_presentShareViewController
{
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[@"HELLO",
                                                                                                    [self _screenshotOfFrontMostViewController]]
                                                                             applicationActivities:nil];
    [controller setExcludedActivityTypes: @[UIActivityTypePostToWeibo,
                                            UIActivityTypePrint,
                                            UIActivityTypeCopyToPasteboard,
                                            UIActivityTypeAssignToContact,
                                            UIActivityTypeAddToReadingList,
                                            UIActivityTypePostToVimeo,
                                            UIActivityTypePostToTencentWeibo,
                                            UIActivityTypeAirDrop]];
    
    [self.gameViewController presentViewController:controller animated:YES completion:nil];
}

- (UIImage *)_screenshotOfFrontMostViewController
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, [[UIScreen mainScreen] scale]);
    
    [self.gameViewController.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenShot;
}

@end

