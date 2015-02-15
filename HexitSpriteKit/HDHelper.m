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

NSString *descriptionForLevelIdx(NSUInteger levelIdx){
    switch (levelIdx) {
        case HDLevelTipOne:
            return @"Watch out for the mines!";
        case HDLevelTipTwo:
            return @"Just tap it twice!";
        case HDLevelTipThree:
            return @"Search for the unlocked one first!";
        case HDLevelTipFour:
            return @"Just tap it three times!";
        case HDLevelTipFive:
            return @"Always end on the red hex!";
        case HDLevelTipSix:
            return @"You've got this!";
        case HDLevelTipSeven:
            return @"Looking like you'll need to teleport";
        default:
            return @"There's more then one for a reason";
        break;
    }
    return nil;
};

@implementation HDHelper

+ (NSArray *)imageFromLevelIdx:(NSUInteger)levelIdx
{
    switch (levelIdx) {
        case HDLevelTipOne:
            return @[[UIImage imageNamed:@"Default-Mine"]];
        case HDLevelTipTwo:
            return @[[UIImage imageNamed:@"Default-Double"]];
        case HDLevelTipThree:
            return @[[UIImage imageNamed:@"Default-Count"]];
        case HDLevelTipFour:
            return @[[UIImage imageNamed:@"Default-Triple"]];
        case HDLevelTipFive:
            return @[[UIImage imageNamed:@"Default-End"]];
        case HDLevelTipSix:
            return @[[UIImage imageNamed:@"Default-End"]];
        case HDLevelTipSeven:
            return @[[UIImage imageNamed:@"Default-Teleport-3"],
                     [UIImage imageNamed:@"Default-Teleport-2"],
                     [UIImage imageNamed:@"Default-Teleport-1"],
                     [UIImage imageNamed:@"Default-Teleport"],];
        default:
            return @[[UIImage imageNamed:@"Default-White"]];
    }
}

+ (BOOL)isWideScreen
{
    return (CGRectGetWidth([[UIScreen mainScreen] bounds]) > 320.0f);
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
        [tile.node runAction:[SKAction sequence:@[scaleDown,[SKAction hide]]]
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
            if ((!current.isSelected && current.state == HDHexagonStateEnabled) || current.type == HDHexagonTypeTeleport) {
                if (current.row == hexagonRow[i] && current.column == hexagonColumn[i]) {
                    [hexagons addObject:current];
                    break;
                }
            }
        }
    }
    return hexagons;
}

+ (BOOL)isIpad {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

@end
