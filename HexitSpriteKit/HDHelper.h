//
//  HDHelper.h
//  Hexagon
//
//  Created by Evan Ische on 10/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//


#import <Foundation/Foundation.h>

NSString *descriptionFromLevelIdx(NSUInteger levelIdx);

typedef enum{
    HDLevelTypeDoubles = 14,
    HDLevelTypeCount   = 28,
    HDLevelTypeTriples = 42,
    HDLevelTypeEnd     = 56
}HDLevelType;

@class HDHexagon;
@interface HDHelper : NSObject
+ (UIImage *)iconForType:(HDLevelType)type;
+ (CGPathRef)hexagonPathForBounds:(CGRect)bounds;
+ (UIBezierPath *)bezierHexagonInFrame:(CGRect)frame;

+ (CGPathRef)starPathForBounds:(CGRect)bounds;
+ (UIBezierPath *)restartArrowAroundPoint:(CGPoint)center;
+ (UIBezierPath *)hexagonPathWithRect:(CGRect)square cornerRadius:(CGFloat)cornerRadius;
+ (UIBezierPath *)roundedPolygonPathWithRect:(CGRect)square
                                   lineWidth:(CGFloat)lineWidth
                                       sides:(NSInteger)sides
                                cornerRadius:(CGFloat)cornerRadius;
+ (BOOL)isWideScreen;
+ (CGFloat)sideMenuOffsetX;
+ (void)entranceAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion;
+ (void)completionAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion;
+ (NSArray *)possibleMovesForHexagon:(HDHexagon *)hexagon inArray:(NSArray *)array;

@end
