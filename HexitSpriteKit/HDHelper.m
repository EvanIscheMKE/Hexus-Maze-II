//
//  HDHelper.m
//  Hexagon
//
//  Created by Evan Ische on 10/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "HDHelper.h"
#import "HDHexagon.h"
#import "HDHexagonNode.h"
#import "UIColor+FlatColors.h"

@implementation HDHelper

+ (BOOL)isWideScreen
{
    return (CGRectGetWidth([[UIScreen mainScreen] bounds]) > 320.0f);
}

+ (CGPathRef)hexagonPathForBounds:(CGRect)bounds
{
    const CGFloat kPadding = CGRectGetWidth(bounds) / 8 / 2;
    UIBezierPath *_path = [UIBezierPath bezierPath];
    [_path setLineJoinStyle:kCGLineJoinRound];
    [_path moveToPoint:CGPointMake(CGRectGetWidth(bounds) / 2, 0)];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) - kPadding, CGRectGetHeight(bounds) * .25f)];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) - kPadding, CGRectGetHeight(bounds) * .75)];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) / 2, CGRectGetHeight(bounds))];
    [_path addLineToPoint:CGPointMake(kPadding, CGRectGetHeight(bounds) * .75f)];
    [_path addLineToPoint:CGPointMake(kPadding, CGRectGetHeight(bounds) * .25f)];
    [_path closePath];
    
    return [_path CGPath];
}

+ (UIBezierPath *)bezierHexagonInFrame:(CGRect)frame
{
    const CGFloat kWidth   = CGRectGetWidth(frame);
    const CGFloat kHeight  = CGRectGetHeight(frame);
    const CGFloat kPadding = kWidth / 8 / 2;
    
    UIBezierPath *_path = [UIBezierPath bezierPath];
    [_path moveToPoint:   CGPointMake(CGRectGetMinX(frame) + (kWidth / 2),        CGRectGetMinY(frame))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + (kWidth - kPadding), CGRectGetMinY(frame) + (kHeight / 4))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + (kWidth - kPadding), CGRectGetMinY(frame) + (kHeight * 3 / 4))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + (kWidth / 2),        CGRectGetMinY(frame) + kHeight)];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + kPadding,            CGRectGetMinY(frame) + (kHeight * .75))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + kPadding,            CGRectGetMinY(frame) + (kHeight / 4))];
    [_path closePath];
    
    return _path;
}

+ (UIBezierPath *)restartArrowAroundPoint:(CGPoint)center
{
    const CGFloat offset = center.y * 2 / 5 /* Multiply the the center.y by 2 to get the height of container*/;
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:center
                                                          radius:offset
                                                      startAngle:DEGREES_RADIANS(330.0f)
                                                        endAngle:DEGREES_RADIANS(290.0f)
                                                       clockwise:YES];
    CGPoint endPoint = circle.currentPoint;
    
    circle.lineCapStyle  = kCGLineCapRound;
    circle.lineJoinStyle = kCGLineJoinRound;
    circle.lineWidth     = 8.0f;
    
    [circle addLineToPoint:CGPointMake(endPoint.x - offset/2, endPoint.y + offset/2.0f)];
    [circle moveToPoint:endPoint];
    [circle addLineToPoint:CGPointMake(endPoint.x - offset/2, endPoint.y - offset/1.85f)];
    
    return circle;
}

+ (void)entranceAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion
{
    // If the arrays empty return, dont need to do animations on nada
    if (tiles.count == 0) {
        if (completion) {
            completion();
        }
    }
    
    // Array count --;
    NSUInteger countTo = tiles.count -1;
    
    // Find minimum and maximum row
    NSUInteger maxRow = 0;
    NSUInteger minRow = NSIntegerMax;
    for (HDHexagon *hexagon in tiles) {
        if (hexagon.row > maxRow) {
            maxRow = hexagon.row;
        }
        if (hexagon.row < minRow) {
            minRow = MAX(hexagon.row, 0);
        }
    }
    
    // Sorting array before looping through it, to hopefully achieve a solid fall for each row
    NSMutableArray *dealTheseTiles = [NSMutableArray arrayWithCapacity:tiles.count];
    for (NSUInteger row = minRow; row < maxRow + 1; row++) {
        for (HDHexagon *hexagon in tiles) {
            if (hexagon.row == row) {
                [dealTheseTiles addObject:hexagon];
            }
        }
    }
    
    // Loop through tiles and scale to zilch
    __block NSInteger index = 0;
    for (NSInteger row = minRow; row < maxRow + 1; row++) {
        for (HDHexagon *hexagon in [dealTheseTiles copy]) {
            if (hexagon.row == row) {
                
                [dealTheseTiles removeObjectIdenticalTo:hexagon];
                
                SKAction *wait          = [SKAction waitForDuration:row * .15f];
                SKAction *dropPositionY = [SKAction moveTo:hexagon.node.defaultPosition duration:.25f];
                SKAction *sequence      = [SKAction sequence:@[wait, dropPositionY]];
                
                CGPoint position = CGPointMake(
                                               hexagon.node.position.x,
                                               CGRectGetHeight([[UIScreen mainScreen] bounds]) + CGRectGetHeight(hexagon.node.frame)/2 + 5.0f
                                               );
                
                hexagon.node.hidden = NO;
                hexagon.node.position = position;
                [hexagon.node runAction:sequence completion:^{
                    if (index == countTo) {
                        if (completion) {
                            completion();
                        }
                    }
                    index++;
                }];
            }
        }
    }
}

+ (void)completionAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion
{
    if (tiles.count == 0) {
        if (completion) {
            completion();
        }
    }
    
    // Array count --;
    NSUInteger countTo = tiles.count -1;
    
    // Scale to zero
    SKAction *scaleDown = [SKAction scaleTo:0.0f duration:.3f];
    
    // Loop through tiles and scale to zilch
    __block NSInteger index = 0;
    for (HDHexagon *tile in tiles) {
        
        [[tile.node children] makeObjectsPerformSelector:@selector(removeFromParent)];
        
        // Setup actions
        SKAction *hide     = [SKAction hide];
        SKAction *sequence = [SKAction sequence:@[scaleDown, hide]];
        
        [tile.node runAction:sequence
                  completion:^{
                        [tile restoreToInitialState];
                                     if (index == countTo) {
                                         if (completion) {
                                             completion();
                                         }
                                     }
                                     index++;
                                 }];
    }
}

+ (NSArray *)possibleMovesForHexagon:(HDHexagon *)hexagon inArray:(NSArray *)array
{
    NSMutableArray *hexagons = [NSMutableArray array];
    
    // Find all possible tiles that are connected to 'hexagon', return any that are in play
    NSInteger hexagonRow[6];
    hexagonRow[0] = hexagon.row;
    hexagonRow[1] = hexagon.row;
    hexagonRow[2] = hexagon.row + 1;
    hexagonRow[3] = hexagon.row + 1;
    hexagonRow[4] = hexagon.row - 1;
    hexagonRow[5] = hexagon.row - 1;
    
    NSInteger hexagonColumn[6];
    hexagonColumn[0] = hexagon.column + 1; // R== , C++
    hexagonColumn[1] = hexagon.column - 1; // R== , C--
    hexagonColumn[2] = hexagon.column;     // R++ , C==
    hexagonColumn[3] = hexagon.column + ((hexagon.row % 2 == 0) ? 1 : -1);
    hexagonColumn[4] = hexagon.column;     // R-- , C==
    hexagonColumn[5] = hexagon.column + ((hexagon.row % 2 == 0) ? 1 : -1);
    
    for (int i = 0; i < 6; i++) {
        for (HDHexagon *current in array) {
            if (!current.isSelected && current.state == HDHexagonStateEnabled) {
                if (current.row == hexagonRow[i] && current.column == hexagonColumn[i]) {
                    [hexagons addObject:current];
                    break;
                }
            }
        }
    }
    return hexagons;
}


@end
