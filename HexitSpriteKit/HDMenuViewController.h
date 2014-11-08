//
//  ViewController.h
//  SideMenuExample
//
//  Created by Evan Ische on 10/15/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HDMenuViewController)
- (void)setFrontViewController:(UIViewController *)controller animated:(BOOL)animated;
- (void)bounceFrontViewController:(id)sender;
@end

@interface HDMenuViewController : UIViewController
@property (nonatomic, readonly) UIViewController *rootViewController;
- (instancetype)initWithRootViewController:(UIViewController *)controller NS_DESIGNATED_INITIALIZER;
@end

