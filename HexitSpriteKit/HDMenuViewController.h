//
//  ViewController.h
//  SideMenuExample
//
//  Created by Evan Ische on 10/15/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompletionBlock)(NSArray *list);

@interface UIViewController (HDMenuViewController)
- (void)bounceGameView:(id)sender;
@end

@interface HDMenuViewController : UIViewController
@property (nonatomic, readonly) UIViewController *rootViewController;
- (instancetype)initWithRootViewController:(UIViewController *)controller handler:(CompletionBlock)block NS_DESIGNATED_INITIALIZER;
@end

