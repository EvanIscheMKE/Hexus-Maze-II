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
#import "HDHexagonButton.h"
#import "HDNavigationBar.h"
#import "HDGridScrollView.h"
#import "UIColor+FlatColors.h"
#import "HDGridViewController.h"
#import "HDLevelsViewController.h"
#import "HDLockedViewController.h"

static const NSUInteger kNumberOfLevelsPerPage = 28;
static const CGFloat defaultContainerHeight   = 70.0f;
static const CGFloat defaultPageControlHeight = 50.0f;

@interface HDGridViewController () <UIScrollViewDelegate ,HDGridScrollViewDelegate, HDLevelsViewControllerDelegate,HDGridScrollViewDatasource>
@property (nonatomic, getter=isNavigationBarHidden, assign) BOOL navigationBarHidden;
@property (nonatomic, strong) HDGridScrollView *scrollView;
@property (nonatomic, strong) HDHexagonControl *control;
@property (nonatomic, strong) HDNavigationBar  *container;
@end

@implementation HDGridViewController {
    
    NSDictionary *_metrics;
    NSDictionary *_views;
    NSMutableArray *_pageViews;
    NSMutableArray *_imageViews;
    
    NSInteger _previousPage;
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    [super viewDidLoad];
    [self _setup];
}

#pragma mark - Public

- (void)levelsViewController:(HDLevelsViewController *)viewController didSelectLevel:(NSUInteger)level
{
    [self beginLevel:level];
}

- (void)beginLevel:(NSUInteger)level
{
    HDLevel *gamelevel = [[HDMapManager sharedManager] levelAtIndex:(NSInteger)level - 1];
    
    //if (gamelevel.isUnlocked) {
        self.navigationBarHidden = YES;
        [[HDSoundManager sharedManager] playSound:HDButtonSound];
        [self.scrollView performOutroAnimationWithCompletion:^{
            [ADelegate presentGameControllerToPlayLevel:level];
        }];
   // }
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

#pragma mark - Private

- (void)_setup
{
    NSUInteger numberOfPages = [self pageViewsForGridScrollView:self.scrollView].count;
    
    CGRect scrollViewRect = CGRectInset(self.view.bounds, 0.0f, CGRectGetHeight(self.view.bounds) / 7.4f);
    self.scrollView = [[HDGridScrollView alloc] initWithFrame:scrollViewRect];
    self.scrollView.delegate = self;
    self.scrollView.datasource = self;
    [self.view addSubview:self.scrollView];
    
    CGRect controlRect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), defaultPageControlHeight);
    self.control = [[HDHexagonControl alloc] initWithFrame:controlRect];
    self.control.numberOfPages = self.scrollView.numberOfPages;
    self.control.currentPage = 0;
    [self.control setCenter:CGPointMake(
                                        CGRectGetMidX(self.view.bounds),
                                        CGRectGetHeight(self.view.bounds) + CGRectGetMidY(self.control.bounds)
                                        )];
    [self.view addSubview:self.control];
    
    CGRect containerFrame = CGRectMake(0.0f, -defaultContainerHeight, CGRectGetWidth(self.view.bounds), defaultContainerHeight);
    self.container = [HDNavigationBar viewWithToggleImage:[UIImage imageNamed:@"Grid"] activityImage:[UIImage imageNamed:@"Play"]];
    self.container.frame = containerFrame;
    [[self.container.subviews firstObject] addTarget:self
                                              action:@selector(performExitAnimation)
                                    forControlEvents:UIControlEventTouchUpInside];
    [[self.container.subviews lastObject] addTarget:self
                                              action:@selector(_beginLastUnlockedLevel)
                                    forControlEvents:UIControlEventTouchUpInside];
    self.container.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.container];
}

- (void)performExitAnimation
{
    self.navigationBarHidden = YES;
    [self.scrollView performOutroAnimationWithCompletion:^{
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (void)_beginLastUnlockedLevel
{
    [self beginLevel:[[HDMapManager sharedManager] indexOfCurrentLevel]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     self.navigationBarHidden = NO;
    [self.scrollView performIntroAnimationWithCompletion:nil];
}

- (void)_hideAnimated:(BOOL)animated
{
    dispatch_block_t animate = ^{
        CGRect rect = self.container.frame;
        rect.origin.y = -defaultContainerHeight;
        self.container.frame = rect;
        
        CGPoint center = self.control.center;
        center.y =  CGRectGetHeight(self.view.bounds) + 25.0f;
        self.control.center = center;
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
        self.container.frame = rect;
        
        CGPoint center = self.control.center;
        center.y = CGRectGetHeight(self.view.bounds) - 45.0f;
        self.control.center = center;
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

#pragma mark - <HDGridScrollViewDelegate>

- (NSArray *)pageViewsForGridScrollView:(HDGridScrollView *)gridScrollView
{
    if (_pageViews) {
        return _pageViews;
    }
    
    _pageViews = [NSMutableArray array];
    
    HDMapManager *mapManager = [HDMapManager sharedManager];
    const NSUInteger numberOfLevels = mapManager.numberOfLevels;
    const NSUInteger numberOfLevelsPerPage = kNumberOfLevelsPerPage;
    const NSUInteger numberOfPages = ceilf((float)numberOfLevels / (float)numberOfLevelsPerPage) + 1 /* 1 for the "locked" screen*/;
    
    NSUInteger displayedLevels = 0;
    NSUInteger remainingNumberOfLevels = numberOfLevels;
    for (NSUInteger i = 0; i < numberOfPages - 1; i++) {
        NSRange levelRange = NSMakeRange(displayedLevels, numberOfLevelsPerPage);
        
        HDLevelsViewController *viewController = [[HDLevelsViewController alloc] init];
        viewController.delegate = self;
        viewController.rows = 7;
        viewController.columns = 4;
        viewController.levelRange = levelRange;
        
        displayedLevels += numberOfLevelsPerPage;
        remainingNumberOfLevels -= numberOfLevelsPerPage;
        
        [viewController willMoveToParentViewController:self];
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
        
        [_pageViews addObject:viewController.view];
    }
    
    HDLockedViewController *lockedViewController = [HDLockedViewController new];
    [lockedViewController willMoveToParentViewController:self];
    [self addChildViewController:lockedViewController];
    [_pageViews addObject:lockedViewController.view];
    [lockedViewController didMoveToParentViewController:self];
    
    return _pageViews;
}

- (NSArray *)_imageViewsFromScrollView:(UIScrollView *)scrollView
{
    if (_imageViews) {
        return  _imageViews;
    }
    
    _imageViews = [NSMutableArray array];
    
    NSMutableArray *hexagons   = [NSMutableArray array];
    NSArray *viewsCorrespondingToProtocol = [[scrollView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject conformsToProtocol:@protocol(HDGridScrollViewChild)];
    }]];
    
    for (UIView *view in viewsCorrespondingToProtocol) {
        NSArray *firstSubviews = view.subviews;
        [hexagons addObjectsFromArray:[[firstSubviews firstObject] subviews]];
    }

    for (HDHexagonButton *hexa in hexagons) {
        if (hexa.imageView) {
            [_imageViews addObject:hexa.imageView];
        }
    }
    
    return _imageViews;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(HDGridScrollView *)scrollView
{
    CGFloat offset = fmod(ABS(scrollView.contentOffset.x), CGRectGetWidth(scrollView.bounds)) / CGRectGetWidth(scrollView.bounds);
    if (offset > .5f) {
        offset = 1 - offset;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIImageView *imageView in [self _imageViewsFromScrollView:scrollView]) {
            imageView.transform = CGAffineTransformMakeScale(1.0f - offset, 1.0f - offset);
        }
    });
    
    NSInteger page = 0;
    if (scrollView.isDragging || scrollView.isDecelerating){
        page = floor((self.scrollView.contentOffset.x - CGRectGetWidth(scrollView.bounds) / 2) / CGRectGetWidth(scrollView.bounds)) + 1;
    }
    
    if (page != _previousPage) {
        [self.control setCurrentPage:MIN(page, scrollView.numberOfPages - 1)];
        _previousPage = page;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (scrollView.contentOffset.x >= 0) {
            [[HDSoundManager sharedManager] playSound:HDSwipeSound];
        }
    });
}

@end
