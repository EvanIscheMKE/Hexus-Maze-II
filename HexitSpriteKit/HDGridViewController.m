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
#import "HDHexaControl.h"
#import "HDSoundManager.h"
#import "HDHexaButton.h"
#import "HDNavigationBar.h"
#import "HDGridScrollView.h"
#import "HDHexusIAdHelper.h"
#import "UIColor+ColorAdditions.h"
#import "HDGridViewController.h"
#import "HDSettingsManager.h"
#import "HDLevelsViewController.h"
#import "HDContainerViewController.h"

static const NSUInteger kNumberOfLevelsPerPage = 28;
static const CGFloat defaultPageControlHeight = 50.0f;
@interface HDGridViewController () <UIScrollViewDelegate,
                                    HDGridScrollViewDelegate,
                                    HDLevelsViewControllerDelegate,
                                    HDGridScrollViewDatasource,
                                    HDHexaControlDelegate>
@property (nonatomic, getter=isNavigationBarHidden, assign) BOOL navigationBarHidden;
@property (nonatomic, strong) HDGridScrollView *scrollView;
@property (nonatomic, strong) HDHexaControl *control;
@property (nonatomic, strong) HDNavigationBar *menuBar;
@end

@implementation HDGridViewController {
    NSMutableArray *_pageViews;
    NSInteger _previousPage;
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor flatSTDarkBlueColor];
    self.view.layer.masksToBounds = YES;
    self.view.clipsToBounds = YES;
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
    
    CGRect scrollViewRect = CGRectInset(self.view.bounds, 15.0f, CGRectGetHeight(self.view.bounds)/7.4f);
    self.scrollView = [[HDGridScrollView alloc] initWithFrame:scrollViewRect];
    self.scrollView.delegate = self;
    self.scrollView.datasource = self;
    self.scrollView.clipsToBounds = NO;
    [self.view addSubview:self.scrollView];
    
    CGPoint position = CGPointMake(CGRectGetMidX(self.view.bounds),
                                   CGRectGetHeight(self.view.bounds) + CGRectGetMidY(self.control.bounds));
    CGRect controlRect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), defaultPageControlHeight);
    self.control = [[HDHexaControl alloc] initWithFrame:controlRect];
    self.control.delegate = self;
    self.control.numberOfPages = self.scrollView.numberOfPages;
    self.control.currentPage = 0;
    self.control.center = position;
    self.control.frame = CGRectIntegral(self.control.frame);
    [self.view addSubview:self.control];
    
    const CGFloat menuBarHeight = CGRectGetHeight(self.view.bounds)/9;
    CGRect menuBarFrame = CGRectMake(0.0f, -menuBarHeight, CGRectGetWidth(self.view.bounds), menuBarHeight);
    self.menuBar = [HDNavigationBar menuBarWithActivityImage:[UIImage imageNamed:@"Grid-Unlock"]];
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
        [controller updateLevelsForIAP];
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

- (void)viewDidAppear:(BOOL)animated {
    self.navigationBarHidden = NO;
    [super viewDidAppear:animated];
    [self.scrollView performIntroAnimationWithCompletion:nil];
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
    const NSUInteger numberOfPages = ceilf((float)numberOfLevels / (float)numberOfLevelsPerPage) + 1;
    
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
        self.control.currentPage = MIN(page, scrollView.numberOfPages - 1);
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

#pragma mark <HDHexaControlDelegate>

- (void)hexaControl:(HDHexaControl *)hexaControl pageIndexWasSelected:(NSUInteger)pageIndex {
    CGPoint offset = CGPointMake(CGRectGetWidth(self.scrollView.bounds) * pageIndex, 0);
    [self.scrollView setContentOffset:offset animated:YES];
}

@end
