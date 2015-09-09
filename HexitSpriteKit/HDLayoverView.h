//
//  HDLayoverView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 5/7/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import UIKit;

static const NSTimeInterval defaultAnimationDuration = .5f;

@class HDLabel;
@interface HDLayoverView : UIView
@property (nonatomic, copy) dispatch_block_t completionBlock;
@property (nonatomic, strong) id retainSelf;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) HDLabel *titleLbl;
@property (nonatomic, strong) HDLabel *descriptionLbl;
- (CAKeyframeAnimation *)jiggleAnimationWithDuration:(NSTimeInterval)duration
                                         repeatCount:(CGFloat)count;
- (void)show;
- (void)dismiss;
@end
