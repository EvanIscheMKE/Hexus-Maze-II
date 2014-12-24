//
//  ViewController.h
//  SideMenuExample
//
//  Created by Evan Ische on 10/15/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAnimationOffsetX [[UIScreen mainScreen] bounds].size.width / 2 + 40.0f // UGGLYY

@class HDContainerViewController;

@interface UIViewController (HDMenuViewController)
- (HDContainerViewController *)containerViewController;
@end

@protocol HDContainerViewControllerDelegate;
@interface HDContainerViewController : UIViewController

@property (nonatomic, weak) id<HDContainerViewControllerDelegate> delegate;

@property (nonatomic, readonly) NSArray *toggleSwitchesForSettings;
@property (nonatomic, readonly) UIViewController *frontViewController;
@property (nonatomic, readonly) UIViewController *rearViewController;

@property (nonatomic, readonly) BOOL isExpanded;

- (instancetype)initWithGameViewController:(UIViewController *)gameController
                        rearViewController:(UIViewController *)rearController NS_DESIGNATED_INITIALIZER;

- (void)setFrontViewController:(UIViewController *)controller animated:(BOOL)animated;
- (void)toggleMenuViewControllerWithCompletion:(dispatch_block_t)completion;
- (void)toggleMenuViewController;

@end

@protocol HDContainerViewControllerDelegate <NSObject>
@required

- (void)container:(HDContainerViewController *)container
 transitionedFromController:(UIViewController *)fromController
               toController:(UIViewController *)toController;

@end

