//
//  HDHelper.h
//  Hexagon
//
//  Created by Evan Ische on 10/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//


#import <Foundation/Foundation.h>

@class HDHexagon;
@interface HDHelper : NSObject

+ (CGPathRef)hexagonPathForBounds:(CGRect)bounds;
+ (CGPathRef)starPathForBounds:(CGRect)bounds;
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

+ (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row numberOfColumns:(NSUInteger)numberOfColumns numberOfRows:(NSUInteger)numberOfRows;

@end
