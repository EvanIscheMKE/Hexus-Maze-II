//
//  ViewController.h
//  SideMenuExample
//
//  Created by Evan Ische on 10/15/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDNavigationBar : UIView
@property (nonatomic, readonly) NSArray *lives;
@property (nonatomic, assign)   NSInteger remainingLives;
@property (nonatomic, readonly) NSTimeInterval remainingTime;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIButton *toggleSideMenu;

- (void)decreaseLifeCountByUno;
@end

@class HDContainerViewController;

@interface UIViewController (HDMenuViewController)
- (HDContainerViewController *)containerViewController;
@end

@protocol HDContainerViewControllerDelegate;
@interface HDContainerViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) id<HDContainerViewControllerDelegate> delegate;

@property (nonatomic, readonly) NSArray *toggleSwitchesForSettings;
@property (nonatomic, readonly) UIViewController *gameViewController;
@property (nonatomic, readonly) UIViewController *rearViewController;

- (instancetype)initWithGameViewController:(UIViewController *)gameController
                        rearViewController:(UIViewController *)rearController NS_DESIGNATED_INITIALIZER;

- (void)_toggleHDMenuViewControllerWithCompletion:(dispatch_block_t)completion;
- (void)setFrontViewController:(UIViewController *)controller animated:(BOOL)animated;

- (void)decreaseLifeCountByUno;

@end

@protocol HDContainerViewControllerDelegate <NSObject>
@optional

- (void)container:(HDContainerViewController *)container
 transitionedFromController:(UIViewController *)fromController
               toController:(UIViewController *)toController;

@end

