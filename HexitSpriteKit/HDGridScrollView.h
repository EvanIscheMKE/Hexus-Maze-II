//
//  HDGridScrollView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/19/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDMapManager.h"

static const NSUInteger numberOfRows    = 7;
static const NSUInteger numberOfColumns = 4;
static const NSUInteger numberOfPages   = 4;
static const NSUInteger numberOfLocked  = 1;

@protocol HDGridScrollViewDelegate;
@interface HDGridScrollView : UIScrollView
- (instancetype)initWithFrame:(CGRect)frame
                      manager:(HDMapManager *)manager
                     delegate:(id<HDGridScrollViewDelegate>)delegate;

- (void)performIntroAnimationWithCompletion:(dispatch_block_t)completion;
- (void)performOutroAnimationWithCompletion:(dispatch_block_t)completion;
@end

@protocol HDGridScrollViewDelegate <NSObject, UIScrollViewDelegate>
@required

- (void)beginGameAtLevelIndex:(NSUInteger)levelIndex;

@end
