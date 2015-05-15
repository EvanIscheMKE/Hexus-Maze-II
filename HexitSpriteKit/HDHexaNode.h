//
//  HDHexagonNode.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "HDHexaObject.h"
#import "HDHelper.h"

extern NSString * const HDLockedKey;
@interface HDHexaNode : SKSpriteNode
@property (nonatomic, assign) CGPoint defaultPosition;
@property (nonatomic, getter=isLocked, assign) BOOL locked;
- (void)displayNextMoveIndicatorWithColor:(UIColor *)color direction:(HDTileDirection)direction animated:(BOOL)animated;
@property (nonatomic, assign) BOOL displayNextMoveIndicator;
@end


