//
//  HDWelcomeViewController.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HDWelcomeViewDelegate;
@interface HDWelcomeView : UIView
@property (nonatomic, weak) id <HDWelcomeViewDelegate> delegate;
@end

@protocol HDWelcomeViewDelegate <NSObject>
@required
- (void)welcomeView:(HDWelcomeView *)welcomeView dismissAnimated:(BOOL)animated;
- (void)welcomeView:(HDWelcomeView *)welcomeView playSoundAtIndex:(NSUInteger)index;
@end

@interface HDWelcomeViewController : UIViewController
@end
