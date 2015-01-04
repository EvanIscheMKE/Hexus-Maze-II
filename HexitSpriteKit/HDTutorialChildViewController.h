//
//  HDTutorialChildViewController.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 1/3/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HDTutorialChildViewControllerDelegate;
@interface HDTutorialChildViewController : UIViewController
@property (nonatomic, weak) id <HDTutorialChildViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger index;
@end

@protocol HDTutorialChildViewControllerDelegate <NSObject>
@required
- (void)childViewControllerWasSelected:(HDTutorialChildViewController *)childView;
@end
