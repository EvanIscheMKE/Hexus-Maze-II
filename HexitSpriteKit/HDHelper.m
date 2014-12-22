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

+ (UIBezierPath *)hexagonPathWithRect:(CGRect)square cornerRadius:(CGFloat)cornerRadius
{
    UIBezierPath *path  = [UIBezierPath bezierPath];
    
    CGFloat squareWidth = MIN(square.size.width, square.size.height);
    CGFloat sideLength = squareWidth/2;
    
    const NSInteger sides = 6;
    
    /*
     for each 0 ≤ i < 6:
     angle = 2 * PI / 6 * (i + 0.5)
     x_i = center_x + size * cos(angle)
     y_i = center_y + size * sin(angle)
     if i == 0:
     moveTo(x_i, y_i)
     else:
     lineTo(x_i, y_i)
     */
    
    
    // draw the sides and rounded corners of the polygon
    for (NSInteger side = 0; side < sides; side++) {
        
        CGFloat angle = 2 * M_PI / sides * (side + .5f);
        
        CGPoint point = CGPointMake(
                                    squareWidth/2 + sideLength * cosf(angle),
                                    squareWidth/2 + sideLength * sinf(angle)
                                    );
        if (side == 0) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }
    
    [path closePath];
    
    return path;
}


+ (UIBezierPath *)roundedPolygonPathWithRect:(CGRect)square
                                   lineWidth:(CGFloat)lineWidth
                                       sides:(NSInteger)sides
                                cornerRadius:(CGFloat)cornerRadius
{
    UIBezierPath *path  = [UIBezierPath bezierPath];
    
    CGFloat theta       = 2.0f * M_PI / sides;                           // how much to turn at every corner
    CGFloat offset      = cornerRadius * tanf(theta / 2.0);             // offset from which to start rounding corners
    CGFloat squareWidth = MIN(square.size.width, square.size.height);   // width of the square
    
    // calculate the length of the sides of the polygon
    
    CGFloat length      = squareWidth - lineWidth;
    
    if (sides % 4 != 0) {                                               // if not dealing with polygon which will be square with all sides ...
        length = length * cosf(theta / 2.0) + offset/2.0;               // ... offset it inside a circle inside the square
    }
    
    CGFloat sideLength = length * tanf(theta / 2.0);
    
    // start drawing at `point` in lower right corner
    
    CGPoint point = CGPointMake(squareWidth / 2.0 + sideLength / 2.0 - offset, squareWidth - (squareWidth - length) / 2.0);
    CGFloat angle = M_PI;
    [path moveToPoint:point];
    
    // draw the sides and rounded corners of the polygon
    
    for (NSInteger side = 0; side < sides; side++) {
        point = CGPointMake(point.x + (sideLength - offset * 2.0) * cosf(angle), point.y + (sideLength - offset * 2.0) * sinf(angle));
        [path addLineToPoint:point];
        
        CGPoint center = CGPointMake(point.x + cornerRadius * cosf(angle + M_PI_2), point.y + cornerRadius * sinf(angle + M_PI_2));
        [path addArcWithCenter:center radius:cornerRadius startAngle:angle - M_PI_2 endAngle:angle + theta - M_PI_2 clockwise:YES];
        
        point = path.currentPoint; // we don't have to calculate where the arc ended ... UIBezierPath did that for us
        angle += theta;
    }
    
    [path closePath];
    
    return path;
}

+ (CGPathRef)starPathForBounds:(CGRect)bounds
{
    UIBezierPath *starPath = [UIBezierPath bezierPath];
   
    const CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    const NSUInteger numberOfPoints = 5;
    const CGFloat innerRadius = CGRectGetWidth(bounds) / 3.8f;
    const CGFloat outerRadius = CGRectGetMidX(bounds);
    
    CGFloat arcPerPoint = 2.0f * M_PI / 5;
    CGFloat theta = M_PI / 2.0f;
    
    // Move to starting point (tip at 90 degrees on outside of star)
    CGPoint pt = CGPointMake(center.x + (outerRadius * cosf(theta)), center.y + (outerRadius * sinf(theta)));
    
    [starPath moveToPoint:CGPointMake(pt.x, pt.y)];
    
    for (int i = 0; i < numberOfPoints; i++) {
        // Calculate next inner point (moving clockwise), accounting for crossing of 0 degrees
        theta = theta - (arcPerPoint / 2.0f);
        if (theta < 0.0f) {
            theta = theta + (2 * M_PI);
        }
        pt = CGPointMake(center.x + (innerRadius * cosf(theta)), center.y + (innerRadius * sinf(theta)));
        [starPath addLineToPoint:CGPointMake(pt.x, pt.y)];
        
        // Calculate next outer point (moving clockwise), accounting for crossing of 0 degrees
        theta = theta - (arcPerPoint / 2.0f);
        if (theta < 0.0f) {
            theta = theta + (2 * M_PI);
        }
        pt = CGPointMake(center.x + (outerRadius * cosf(theta)), center.y + (outerRadius * sinf(theta)));
        [starPath addLineToPoint:CGPointMake(pt.x, pt.y)];
    }
   
    return [starPath CGPath];
}

+ (void)entranceAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion
{
    NSUInteger count = tiles.count;
    
    NSTimeInterval _delay = 0;
    
    // Setup actions for base tiles
    SKAction *show  = [SKAction unhide];
    SKAction *scale = [SKAction scaleTo:0.0f  duration:0.0f];
    SKAction *pop   = [SKAction scaleTo:1.15f duration:.2f];
    SKAction *size  = [SKAction scaleTo:1.0f  duration:.2f];
    
    // setup actions for children nodes
    SKAction *doubleTouch = [SKAction moveTo:CGPointMake(1.0f, 1.0f) duration:.3f];
    SKAction *tripleTouch = [SKAction sequence: @[[SKAction waitForDuration:.4f], doubleTouch]];
    
    // Animate regular, start, and base tiles onto node with pop effect
    __block NSInteger index = 0;
    for (HDHexagon *hex in tiles) {
        
        NSArray *sequence =  @[[SKAction waitForDuration:_delay], scale, show, pop, size];
        
        [(SKShapeNode *)hex.node runAction:[SKAction sequence:sequence]
                 completion:^{
                     if (index == count - 1) {
                         
                         // Once base animation is complete, check for children and animate them in
                         NSTimeInterval completionTime = 0.0f;
                         for (HDHexagon *hexa in tiles) {
                             
                         NSTimeInterval current = completionTime;
                         if ([(SKShapeNode *)hexa.node childNodeWithName:DOUBLE_KEY]) {
                              completionTime = (.3f > completionTime) ? .3f : current;
                              [[hexa.node childNodeWithName:DOUBLE_KEY] runAction:doubleTouch];
                                 
                              if ([[[(SKShapeNode *)hexa.node children] lastObject] childNodeWithName:TRIPLE_KEY]) {
                                     completionTime = (.7f > completionTime) ? .7f : current;
                                     [[[[hexa.node children] lastObject] childNodeWithName:TRIPLE_KEY] runAction:tripleTouch];
                              }
                            }
                         }
                         
                         // after animations complete, call completion block
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(completionTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             if (completion) {
                                 completion();
                             }
                         });
                     }
                     index++;
                 }];
        _delay += .025f;
    }
}

+ (void)completionAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion
{
    // Array count --;
    NSUInteger countTo = tiles.count -1;
    
    // Scale to zero
    SKAction *scaleUp   = [SKAction scaleTo:1.15f duration:.2f];
    SKAction *scaleDown = [SKAction scaleTo:0.0f duration:.2f];
    
    // Loop through tiles and scale to zilch
    __block NSInteger index = 0;
    NSTimeInterval delay = 0.0f;
    for (HDHexagon *tile in tiles) {
        
        // Setup actions
        SKAction *wait     = [SKAction waitForDuration:delay];
        SKAction *hide     = [SKAction hide];
        SKAction *sequence = [SKAction sequence:@[wait, scaleUp, scaleDown, hide]];
        
        [(SKShapeNode *)tile.node runAction:sequence
                  completion:^{
                      [tile.node setScale:1.0f];
                      [tile restoreToInitialState];
                      if (index == countTo) {
                          if (completion) {
                              completion();
                          }
                      }
                      index++;
                  }];
        delay += .025f;
    }
}

+ (NSArray *)possibleMovesForHexagon:(HDHexagon *)hexagon inArray:(NSArray *)array
{
    NSMutableArray *hexagons = [NSMutableArray array];
    
    // C-Shit, finding all possible tiles that are connected to 'hexagon'
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
