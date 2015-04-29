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
#import "HDMenuBar.h"
#import "HDGridScrollView.h"
#import "HDHexusIAdHelper.h"
#import "UIColor+ColorAdditions.h"
#import "HDGridViewController.h"
#import "HDSettingsManager.h"
#import "HDLevelsViewController.h"
#import "HDContainerViewController.h"

static const NSUInteger kNumberOfLevelsPerPage = 28;
static const CGFloat defaultPageControlHeight = 50.0f;
@interface HDGridViewController () <UIScrollViewDelegate, HDGridScrollViewDelegate, HDLevelsViewControllerDelegate, HDGridScrollViewDatasource>
@property (nonatomic, getter=isNavigationBarHidden, assign) BOOL navigationBarHidden;
@property (nonatomic, strong) HDGridScrollView *scrollView;
@property (nonatomic, strong) HDHexagonControl *control;
@property (nonatomic, strong) HDMenuBar *menuBar;
@end

@implementation HDGridViewController {
    NSMutableArray *_pageViews;
    NSInteger       _previousPage;
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor flatSTDarkBlueColor];
    [super viewDidLoad];
    [self _setup];
}

#pragma mark - Public

- (void)performExitAnimationWithCompletion:(dispatch_block_t)completion {
    self.navigationBarHidden = YES;
    [self.scrollView performOutroAnimationWithCompletion:^{
        if (completion) {
            completion();
        }
    }];
}

- (void)levelsViewController:(HDLevelsViewController *)viewController didSelectLevel:(NSUInteger)level {
    [self beginLevel:level];
}

- (void)beginLevel:(NSUInteger)levelIdx {
    
    HDLevel *gamelevel = [[HDMapManager sharedManager] levelAtIndex:(NSInteger)levelIdx - 1];
   // if (gamelevel.isUnlocked) {
        self.navigationBarHidden = YES;
        [self.scrollView performOutroAnimationWithCompletion:^{
            [[HDAppDelegate sharedDelegate] beginGameWithLevel:levelIdx];
        }];
   // }
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    _navigationBarHidden = navigationBarHidden;
    if (_navigationBarHidden) {
        [self _hideAnimated:YES];
    } else {
        [self _showAnimated:YES];
    }
}

#pragma mark - Private

- (void)_setup {
    
    (void)[self pageViewsForGridScrollView:self.scrollView].count;
    
    HDContainerViewController *container = self.containerViewController;
    
    CGRect scrollViewRect = CGRectInset(self.view.bounds, 0.0f, CGRectGetHeight(self.view.bounds)/7.4f);
    self.scrollView = [[HDGridScrollView alloc] initWithFrame:scrollViewRect];
    self.scrollView.delegate = self;
    self.scrollView.datasource = self;
    [self.view addSubview:self.scrollView];
    
    NSInteger completedLevelIndex = [[NSUserDefaults standardUserDefaults] integerForKey:HDLastCompletedLevelKey];
    NSInteger currentPage = completedLevelIndex/kNumberOfLevelsPerPage;
    
    CGPoint position = CGPointMake(CGRectGetMidX(self.view.bounds),
                                   CGRectGetHeight(self.view.bounds) + CGRectGetMidY(self.control.bounds));
    CGRect controlRect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), defaultPageControlHeight);
    self.control = [[HDHexagonControl alloc] initWithFrame:controlRect];
    self.control.numberOfPages = self.scrollView.numberOfPages;
    self.control.currentPage = MIN(self.scrollView.numberOfPages - 2, currentPage);
    self.control.center = position;
    self.control.frame = CGRectIntegral(self.control.frame);
    [self.view addSubview:self.control];
    
    const CGFloat menuBarHeight = CGRectGetHeight(self.view.bounds)/9;
    CGRect menuBarFrame = CGRectMake(0.0f, -menuBarHeight, CGRectGetWidth(self.view.bounds), menuBarHeight);
    self.menuBar = [HDMenuBar menuBarWithActivityImage:[UIImage imageNamed:@"Grid-Unlock"]];
    self.menuBar.frame = menuBarFrame;
    [self.menuBar.navigationButton addTarget:container action:@selector(toggleMenuViewController)forControlEvents:UIControlEventTouchUpInside];
    [self.menuBar.activityButton addTarget:self action:@selector(_purchaseIADUnlockedLevel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menuBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_unlockAllLevel:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
}

- (void)_unlockAllLevel:(NSNotification *)notification {
    [[HDMapManager sharedManager] unlockAllLevels];
    for (HDLevelsViewController *controller in [self childViewControllers]) {
        [controller updateLevelsForiAPPurchase];
    }
}

- (IBAction)_purchaseIADUnlockedLevel:(id)sender {
    
    [[HDHexusIAdHelper sharedHelper] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success && products.count) {
            
            SKProduct *unlockAllLevelSKProduct = nil;
            for (SKProduct *product in products) {
                if ([product.productIdentifier isEqualToString:IAPUnlockAllLevelsProductIdentifier]) {
                    unlockAllLevelSKProduct = product;
                    break;
                }
            }
            
            if (!unlockAllLevelSKProduct) {
                return;
            }
            
            BOOL purchased = [[HDHexusIAdHelper sharedHelper] productPurchased:unlockAllLevelSKProduct.productIdentifier];
            if (!purchased) {
                [[HDHexusIAdHelper sharedHelper] buyProduct:unlockAllLevelSKProduct];
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSInteger completedLevelIndex = [[NSUserDefaults standardUserDefaults] integerForKey:HDLastCompletedLevelKey];
    CGFloat offsetY = CGRectGetWidth(self.view.bounds) * (floorf(completedLevelIndex/kNumberOfLevelsPerPage));
    
    const CGFloat KMaxLevelOffset = self.scrollView.contentSize.width - CGRectGetWidth(self.view.bounds);
    if (offsetY > 0) {
        offsetY -= (offsetY != KMaxLevelOffset)? CGRectGetWidth(self.view.bounds) : CGRectGetWidth(self.view.bounds)*2;
    }
    CGPoint offset = CGPointMake(offsetY, 0.0f);
    self.scrollView.contentOffset = offset;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationBarHidden = NO;
    [self.scrollView performIntroAnimationWithCompletion:nil];
    NSInteger completedLevelIndex = [[NSUserDefaults standardUserDefaults] integerForKey:HDLastCompletedLevelKey];
    CGFloat offsetY = CGRectGetWidth(self.view.bounds) * (floorf(completedLevelIndex/kNumberOfLevelsPerPage));
    
    const CGFloat KMaxLevelOffset = self.scrollView.contentSize.width - CGRectGetWidth(self.view.bounds);
    if (offsetY == KMaxLevelOffset) {
        offsetY -= CGRectGetWidth(self.view.bounds);
    }
    
    CGPoint offset = CGPointMake(offsetY, 0.0f);
    [UIView animateWithDuration:.25f
                     animations:^{
                         self.scrollView.contentOffset = offset;
                     }];
}

- (void)_hideAnimated:(BOOL)animated {
    dispatch_block_t animate = ^{
        CGRect rect = self.menuBar.frame;
        rect.origin.y = -CGRectGetHeight(self.menuBar.bounds);
        self.menuBar.frame = rect;
        
        CGPoint center = self.control.center;
        center.y =  CGRectGetHeight(self.view.bounds) + CGRectGetMidY(self.control.bounds);
        self.control.center = center;
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.300f animations:animate];
    }
}

- (void)_showAnimated:(BOOL)animated {
    dispatch_block_t animate = ^{
        CGRect rect = self.menuBar.frame;
        rect.origin.y = 0.0f;
        self.menuBar.frame = rect;
        
        CGPoint center = self.control.center;
        center.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.control.bounds);
        self.control.center = center;
    };
    
    if (!animated) {
        animate();
    } else {
        [UIView animateWithDuration:.300f animations:animate];
    }
}

#pragma mark - <HDGridScrollViewDelegate>

- (NSArray *)pageViewsForGridScrollView:(HDGridScrollView *)gridScrollView {
    
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
    
    return _pageViews;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(HDGridScrollView *)scrollView {
    
    NSInteger page = 0;
    if (scrollView.isDragging || scrollView.isDecelerating){
        page = floor((self.scrollView.contentOffset.x - CGRectGetWidth(scrollView.bounds) / 2) / CGRectGetWidth(scrollView.bounds)) + 1;
    }
    
    if (page != _previousPage) {
        [self.control setCurrentPage:MIN(page, scrollView.numberOfPages - 1)];
        _previousPage = page;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    for (UIView *subview in scrollView.subviews) {
        if (!subview.userInteractionEnabled) {
             subview.userInteractionEnabled = YES;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    for (UIView *subview in scrollView.subviews) {
        if (subview.userInteractionEnabled) {
            subview.userInteractionEnabled = NO;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (scrollView.contentOffset.x >= 0) {
            [[HDSoundManager sharedManager] playSound:HDSwipeSound];
        }
    });
}

@end
