//
//  HDHelper.m
//  Hexagon
//
//  Created by Evan Ische on 10/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

CGFloat degreesToRadians(CGFloat degrees) {
    return (degrees * M_PI) / 180;
}

@import SpriteKit;

#import "HDHelper.h"
#import "HDHexaNode.h"
#import "UIColor+ColorAdditions.h"

CGFloat angleForDirection(HDTileDirection direction) {
    switch (direction) {
        case HDTileDirectionLeft:
            return M_PI;
        case HDTileDirectionRight:
            return 0.0f;
        case HDTileDirectionTopRight:
            return degreesToRadians(300.0f);
        case HDTileDirectionTopLeft:
            return degreesToRadians(240.0f);
        case HDTileDirectionBottomRight:
            return degreesToRadians(60.0f);
        case HDTileDirectionBottomLeft:
            return degreesToRadians(120.0f);
        default:
            return 0;
    }
}

NSString *descriptionForLevelIdx(NSUInteger levelIdx){
    switch (levelIdx) {
        case HDLevelTipOne:
            return NSLocalizedString(@"tip1", nil);
        case HDLevelTipTwo:
            return NSLocalizedString(@"tip2", nil);
        case HDLevelTipThree:
            return NSLocalizedString(@"tip3", nil);
        case HDLevelTipFour:
            return NSLocalizedString(@"tip4", nil);
        case HDLevelTipFive:
            return NSLocalizedString(@"tip5", nil);
        case HDLevelTipSix:
            return NSLocalizedString(@"tip6", nil);
        default:
            return NSLocalizedString(@"tip7", nil);
        break;
    }
    return nil;
};

@implementation HDHelper

+ (NSString *)imageURLFromType:(HDHexagonType)type {
    switch (type) {
        case HDHexagonTypeRegular:
            return @"Default-OneTap";
        case HDHexagonTypeStarter:
            return @"Default-Start";
        case HDHexagonTypeDouble:
            return @"Default-Double";
        case HDHexagonTypeTriple:
            return @"Triple-OneLeft";
        case HDHexagonTypeEnd:
            return @"Default-End";
        case HDHexagonTypeNone:
            return @"Default-Mine";
        default:
            return @"Default-Count";
    }
}

+ (UIColor *)colorFromType:(HDHexagonType)type touchCount:(NSUInteger)touchCount {
    switch (type) {
        case HDHexagonTypeRegular:
            return [UIColor flatSTLightBlueColor];
        case HDHexagonTypeStarter:
            return [UIColor whiteColor];
        case HDHexagonTypeDouble:
            switch (touchCount) {
                case 0:
                    return [UIColor flatSTEmeraldColor];
                default:
                    return [UIColor flatSTLightBlueColor];
            }
        case HDHexagonTypeTriple:
            switch (touchCount) {
                case 0:
                    return [UIColor flatLCOrangeColor];
                case 1:
                    return [UIColor flatSTEmeraldColor];
                default:
                    return [UIColor flatSTLightBlueColor];
            }
        case HDHexagonTypeEnd:
            return [UIColor flatSTRedColor];
        case HDHexagonTypeFive:
        case HDHexagonTypeFour:
        case HDHexagonTypeThree:
        case HDHexagonTypeTwo:
        case HDHexagonTypeOne:
            return [UIColor flatSTRedColor];
        default:
            return [UIColor clearColor];
    }
}

+ (UIImage *)imageFromLevelIdx:(NSUInteger)levelIdx {
    
    switch (levelIdx) {
        case HDLevelTipOne:
            return [UIImage imageNamed:@"Alert-Mine"];
        case HDLevelTipTwo:
            return [UIImage imageNamed:@"Default-Double"];
        case HDLevelTipThree:
            return [UIImage imageNamed:@"Default-Count"];
        case HDLevelTipFour:
            return [UIImage imageNamed:@"Default-Triple"];
        case HDLevelTipFive:
            return [UIImage imageNamed:@"Default-End"];
        case HDLevelTipSix:
            return [UIImage imageNamed:@"Default-End"];
        default:
            return [UIImage imageNamed:@"Default-Start"];
    }
}

+ (void)entranceAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion {
    
    if (tiles.count == 0) {
        if (completion) {
            completion();
        }
    }
    
    NSUInteger countTo = tiles.count -1;
    
    NSUInteger maxRow = 0;
    NSUInteger minRow = NSIntegerMax;
    for (HDHexaObject *hexagon in tiles) {
        if (hexagon.row > maxRow) {
            maxRow = hexagon.row;
        }
        if (hexagon.row < minRow) {
            minRow = MAX(hexagon.row, 0);
        }
    }
    
    NSMutableArray *dealTheseTiles = [NSMutableArray arrayWithCapacity:tiles.count];
    for (NSUInteger row = minRow; row < maxRow + 1; row++) {
        for (HDHexaObject *hexagon in tiles) {
            if (hexagon.row == row) {
                [dealTheseTiles addObject:hexagon];
            }
        }
    }
    
    __block NSInteger index = 0;
    for (NSInteger row = minRow; row < maxRow + 1; row++) {
        for (HDHexaObject *hexagon in [dealTheseTiles copy]) {
            if (hexagon.row == row) {
                
                [dealTheseTiles removeObjectIdenticalTo:hexagon];
                
                SKAction *wait          = [SKAction waitForDuration:row * .15f];
                SKAction *dropPositionY = [SKAction moveTo:hexagon.node.defaultPosition duration:.25f];
                SKAction *sequence      = [SKAction sequence:@[wait, dropPositionY]];
                
                CGPoint position = CGPointMake(hexagon.node.position.x,
                                               CGRectGetHeight([[UIScreen mainScreen] bounds]) + CGRectGetHeight(hexagon.node.frame)/2 + 5.0f);
                
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

+ (void)completionAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)completion {
    
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
    for (HDHexaObject *tile in tiles) {
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

+ (NSArray *)possibleMovesFromMine:(HDHexaObject *)obj containedIn:(NSArray *)array{
    
    NSMutableArray *hexaObjects = [NSMutableArray array];
    
    NSInteger hexaRow[6];
    hexaRow[0] = obj.row;
    hexaRow[1] = obj.row;
    hexaRow[2] = obj.row + 1;
    hexaRow[3] = obj.row + 1;
    hexaRow[4] = obj.row - 1;
    hexaRow[5] = obj.row - 1;
    
    NSInteger hexaColumn[6];
    hexaColumn[0] = obj.column + 1; // R== , C++
    hexaColumn[1] = obj.column - 1; // R== , C--
    hexaColumn[2] = obj.column;     // R++ , C==
    hexaColumn[3] = obj.column + ((obj.row % 2 == 0) ? 1 : -1);
    hexaColumn[4] = obj.column;     // R-- , C==
    hexaColumn[5] = obj.column + ((obj.row % 2 == 0) ? 1 : -1);
    
    for (int i = 0; i < 6; i++) {
        for (HDHexaObject *hexaObj in array) {
            if (hexaObj.type == HDHexagonTypeNone) {
                if (hexaObj.row == hexaRow[i] && hexaObj.column == hexaColumn[i]) {
                    [hexaObjects addObject:hexaObj];
                    break;
                }
            }
        }
    }
    return hexaObjects;
}

+ (NSArray *)possibleMovesForHexagon:(HDHexaObject *)hexagon inArray:(NSArray *)array {
    
    NSMutableArray *hexaObjects = [NSMutableArray array];
    
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
        for (HDHexaObject *current in array) {
            if ((!current.isSelected && current.state == HDHexagonStateEnabled)) {
                if (current.row == hexagonRow[i] && current.column == hexagonColumn[i]) {
                    [hexaObjects addObject:current];
                    break;
                }
            }
        }
    }
    return hexaObjects;
}

+ (HDTileDirection)oppositeForDirection:(HDTileDirection)direction {
    switch (direction) {
        case HDTileDirectionLeft:
            return HDTileDirectionRight;
            break;
        case HDTileDirectionRight:
            return HDTileDirectionLeft;
            break;
        case HDTileDirectionTopLeft:
            return HDTileDirectionBottomRight;
            break;
        case HDTileDirectionTopRight:
            return HDTileDirectionBottomLeft;
            break;
        case HDTileDirectionBottomLeft:
            return HDTileDirectionTopRight;
            break;
        case HDTileDirectionBottomRight:
            return HDTileDirectionTopLeft;
            break;
        default:
            break;
    }
}

+ (HDTileDirection)tileDirectionsToTile:(HDHexaObject *)toHexagon fromTile:(HDHexaObject *)fromHexagon {
    
    if (toHexagon.row == fromHexagon.row && toHexagon.column == fromHexagon.column + 1) {
        return HDTileDirectionRight;
    }
    
    if (toHexagon.row == fromHexagon.row && toHexagon.column == fromHexagon.column - 1) {
        return HDTileDirectionLeft;
    }
    
    if (toHexagon.row == fromHexagon.row + 1 && toHexagon.column == fromHexagon.column) {
        if (fromHexagon.row % 2 != 0) {
            return HDTileDirectionTopRight;
        } else {
            return HDTileDirectionTopLeft;
        }
    }
    
    if (toHexagon.row == fromHexagon.row + 1 && toHexagon.column == (fromHexagon.column + ((fromHexagon.row % 2 == 0) ? 1 : -1))) {
        if (fromHexagon.row % 2 == 0) {
            return HDTileDirectionTopRight;
        } else {
            return HDTileDirectionTopLeft;
        }
    }
    
    if (toHexagon.row == fromHexagon.row - 1 && toHexagon.column == fromHexagon.column) {
        if (fromHexagon.row % 2 != 0) {
            return HDTileDirectionBottomRight;
        } else {
            return HDTileDirectionBottomLeft;
        }
    }
    
    if (toHexagon.row == fromHexagon.row - 1 && toHexagon.column == (fromHexagon.column + ((fromHexagon.row % 2 == 0) ? 1 : -1))) {
        if (fromHexagon.row % 2 == 0) {
            return HDTileDirectionBottomRight;
        } else {
            return HDTileDirectionBottomLeft;
        }
    }
    return 0;
}

@end
