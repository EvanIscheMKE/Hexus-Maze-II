//
//  HDHelper.h
//  Hexagon
//
//  Created by Evan Ische on 10/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//


#import <Foundation/Foundation.h>

NSString *descriptionFromLevelIdx(NSUInteger levelIdx);

@class HDHexagon;
@interface HDHelper : NSObject
+ (CGPathRef)hexagonPathForBounds:(CGRect)bounds;
+ (UIBezierPath *)bezierHexagonInFrame:(CGRect)frame;
+ (UIBezierPath *)restartArrowAroundPoint:(CGPoint)center;
+ (BOOL)isWideScreen;
+ (void)entranceAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion;
+ (void)completionAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion;
+ (NSArray *)possibleMovesForHexagon:(HDHexagon *)hexagon inArray:(NSArray *)array;
@end
