//
//  HDGridViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/21/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//



#import "HDLevel.h"
#import "HDHelper.h"
#import "HDMapManager.h"
#import "HDHexagonControl.h"
#import "HDSoundManager.h"
#import "HDHexagonView.h"
#import "HDGridScrollView.h"
#import "UIColor+FlatColors.h"
#import "HDGridViewController.h"
#import "HDContainerViewController.h"

static const CGFloat kDefaultContainerHeight   = 70.0f;
static const CGFloat kDefaultPageControlHeight = 50.0f;

static const CGFloat kButtonSize = 42.0f;
static const CGFloat kInset      = 20.0f;

@interface HDGridViewController () <UIScrollViewDelegate,HDGridScrollViewDelegate>

@property (nonatomic, strong) HDGridScrollView *scrollView;
@property (nonatomic, strong) HDHexagonControl *control;

@property (nonatomic, assign) BOOL navigationBarHidden;

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIButton *play;

@end

@implementation HDGridViewController {
    NSDictionary *_metrics;
    NSDictionary *_views;
    
    NSInteger _previousPage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor flatMidnightBlueColor]];
    [self.view setClipsToBounds:YES];
    [self _setup];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_performExitAnimation)
                                                 name:@"gridPerformExitAnimations"
                                               object:nil];
}

#pragma mark -
#pragma mark - < PUBLIC >

- (void)beginLevel:(NSInteger)level
{
    HDLevel *gamelevel = [[HDMapManager sharedManager] levelAtIndex:(NSInteger)level - 1];
    
   // if (gamelevel.isUnlocked) {
    [self setNavigationBarHidden:YES];
    [[HDSoundManager sharedManager] playSound:HDButtonSound];
    [self.scrollView performOutroAnimationWithCompletion:^{
        [ADelegate navigateToNewLevel:(NSInteger)level];

    }];
        
  //  }
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    _navigationBarHidden = navigationBarHidden;
    
    if (_navigationBarHidden) {
        [self _hideAnimated:YES];
    } else {
        [self _showAnimated:YES];
    }
}

#pragma mark -
#pragma mark - < PRIVATE >

- (HDContainerViewController *)containerController
{
    return self.containerViewController;
}

- (void)_setup
{
    CGRect scrollViewRect = CGRectInset(self.view.bounds, 0.0f, CGRectGetHeight(self.view.bounds) / 7.4f);
    self.scrollView = [[HDGridScrollView alloc] initWithFrame:scrollViewRect
                                                                   manager:[HDMapManager sharedManager]
                                                                  delegate:self];
    [self.scrollView setDelegate:self];
    [self.view addSubview:self.scrollView];
    
    CGRect controlRect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), kDefaultPageControlHeight);
    self.control = [[HDHexagonControl alloc] initWithFrame:controlRect];
    [self.control setNumberOfPages:numberOfPages];
    [self.control setCurrentPage:0];
    [self.control setCenter:CGPointMake(
                                        CGRectGetMidX(self.view.bounds),
                                        CGRectGetHeight(self.view.bounds) + CGRectGetMidY(self.control.bounds)
                                        )];
    [self.view addSubview:self.control];
    
    CGRect containerFrame = CGRectMake(0.0f, -kDefaultContainerHeight, CGRectGetWidth(self.view.bounds), kDefaultContainerHeight);
    self.container = [[UIView alloc] initWithFrame:containerFrame];
    [self.container setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.container];
    
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.toggleButton setImage:[UIImage imageNamed:@"Grid"] forState:UIControlStateNormal];
    [self.toggleButton addTarget:[self containerController] action:@selector(toggleMenuViewController) forControlEvents:UIControlEventTouchUpInside];
    
    self.play = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.play setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    [self.play addTarget:self action:@selector(_beginLastUnlockedLevel) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *button in @[self.toggleButton, self.play]) {
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.container addSubview:button];
    }
    
    UIButton *toggle = self.toggleButton;
    UIButton *play   = self.play;
    
    _views = NSDictionaryOfVariableBindings(toggle, play);
    
    _metrics = @{ @"buttonHeight" : @(kButtonSize), @"inset" : @(kInset) };
    
    NSArray *toggleHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[toggle(buttonHeight)]"
                                                                                  options:0
                                                                                  metrics:_metrics
                                                                                    views:_views];
    [self.view addConstraints:toggleHorizontalConstraint];
    
    NSArray *toggleVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[toggle(buttonHeight)]"
                                                                                  options:0
                                                                                  metrics:_metrics
                                                                                    views:_views];
    [self.view addConstraints:toggleVerticalConstraint];
    
    NSArray *shareHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[play(buttonHeight)]-inset-|"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
    [self.view addConstraints:shareHorizontalConstraint];
    
    NSArray *shareVerticalConstraint   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[play(buttonHeight)]"
                                                                                 options:0
                                                                                 metrics:_metrics
                                                                                   views:_views];
    [self.view addConstraints:shareVerticalConstraint];
}

- (void)_performExitAnimation
{
    [self setNavigationBarHidden:YES];
    [self.scrollView performOutroAnimationWithCompletion:^{
        [ADelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)_beginLastUnlockedLevel
{
    [self beginLevel:[[HDMapManager sharedManager] indexOfCurrentLevel]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setNavigationBarHidden:NO];
    [self.scrollView performIntroAnimationWithCompletion:nil];
}

- (void)_hideAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGRect rect = self.container.frame;
        rect.origin.y = -kDefaultContainerHeight;
        [self.container setFrame:rect];
        
        CGPoint center = self.control.center;
        center.y =  CGRectGetHeight(self.view.bounds) + 25.0f;
        [self.control setCenter:center];
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.3f animations:animate];
    }
}

- (void)_showAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGRect rect = self.container.frame;
        rect.origin.y = 0.0f;
        [self.container setFrame:rect];
        
        CGPoint center = self.control.center;
        center.y = CGRectGetHeight(self.view.bounds) - 45.0f;
        [self.control setCenter:center];
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.3f animations:animate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - <HDGridScrollViewDelegate>

- (void)beginGameAtLevelIndex:(NSUInteger)levelIndex
{
    [self beginLevel:levelIndex];
}

#pragma mark -
#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat percent = ((int)(scrollView.contentOffset.x) % (int)(scrollView.frame.size.width)) / scrollView.frame.size.width;
    if (percent > 0.0 && percent < 1.0) {
        NSLog(@"%f",percent);
    }
    
    
    NSInteger page = 0;
    if (scrollView.isDragging || scrollView.isDecelerating){
        page = floor((self.scrollView.contentOffset.x - CGRectGetWidth(scrollView.bounds) / 2) / CGRectGetWidth(scrollView.bounds)) + 1;
    }
    
    if (page != _previousPage) {
        
        [self.control setCurrentPage:MIN(page, numberOfPages - 1)];
        
        _previousPage = page;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[HDSoundManager sharedManager] playSound:HDSwipeSound];
}

@end
