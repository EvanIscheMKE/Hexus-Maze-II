//
//  HDLevelsViewController.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/23/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDGridScrollView.h"

@protocol HDLevelsViewControllerDelegate;

@interface HDLevelsContainerView : UIView
@end

@interface HDLevelsView : UIView <HDGridScrollViewChild>
- (HDLevelsContainerView *)containerView;
@end

@interface HDLevelsViewController : UIViewController
@property (nonatomic, weak) id <HDLevelsViewControllerDelegate> delegate;
@property (nonatomic, assign) NSRange levelRange;
@property (nonatomic, assign) NSUInteger columns;
@property (nonatomic, assign) NSUInteger rows;
- (void)updateState;
@end

@protocol HDLevelsViewControllerDelegate <NSObject>
- (void)levelsViewController:(HDLevelsViewController *)controller didSelectLevel:(NSUInteger)level;
@end