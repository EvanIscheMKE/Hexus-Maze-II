//
//  HDGridScrollView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/19/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDMapManager.h"

@protocol HDGridScrollViewDelegate;
@protocol HDGridScrollViewDatasource;
@protocol HDGridScrollViewChild;

@interface HDGridScrollView : UIScrollView

@property (nonatomic, weak) id <HDGridScrollViewDelegate> delegate;
@property (nonatomic, weak) id <HDGridScrollViewDatasource> datasource;
@property (nonatomic, readonly) NSUInteger numberOfPages;

- (void)performIntroAnimationWithCompletion:(dispatch_block_t)completion;
- (void)performOutroAnimationWithCompletion:(dispatch_block_t)completion;
@end

@protocol HDGridScrollViewDelegate <NSObject, UIScrollViewDelegate>
@required
- (void)gridScrollView:(HDGridScrollView *)gridScrollView selectedLevelAtIndex:(NSUInteger)levelIndex;
@end

@protocol HDGridScrollViewDatasource <NSObject>
@required
//All views should correspond to HDScrollViewChild protocol
- (NSArray *)pageViewsForGridScrollView:(HDGridScrollView *)gridScrollView;
@end

@protocol HDGridScrollViewChild <NSObject>
- (void)performIntroAnimationWithCompletion:(dispatch_block_t)completion;
- (void)performOutroAnimationWithCompletion:(dispatch_block_t)completion;
@end
