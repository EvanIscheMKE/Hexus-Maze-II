//
//  UIImage+ImageAdditions.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 4/29/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "UIImage+ImageAdditions.h"
#import "UIColor+ColorAdditions.h"

@implementation UIImage (ImageAdditions)

+ (UIImage *)tileFromSize:(CGSize)size
                    color:(UIColor *)color
                direction:(HDTileDirection)direction {
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    const CGFloat radius = ((size.width/3.95f)/2);
    
    CGPoint position = [[self class] centerFromSize:size direction:direction];
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 5.0f;
    path.lineCapStyle = kCGLineCapRound;
    [path moveToPoint:[[self class] pointFromAngle:angleForDirection([HDHelper oppositeForDirection:direction])
                                            center:position
                                            radius:radius]];
    [path addLineToPoint:[[self class] pointFromAngle:angleForDirection(direction)
                                               center:position
                                               radius:radius]];
    [color setStroke];
    [path stroke];
    
    position = [[self class] shadowCenterFromSize:size direction:direction];
    UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    shadowPath.lineWidth = path.lineWidth;
    shadowPath.lineCapStyle = path.lineCapStyle;
    [shadowPath moveToPoint:[[self class] pointFromAngle:angleForDirection([HDHelper oppositeForDirection:direction])
                                            center:position
                                            radius:radius]];
    [shadowPath addLineToPoint:[[self class] pointFromAngle:angleForDirection(direction)
                                               center:position
                                               radius:radius]];
    [[color colorWithAlphaComponent:.7f] setStroke];
    [shadowPath stroke];
    
    UIImage *tile = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tile;
}

+ (CGPoint)shadowCenterFromSize:(CGSize)size
                      direction:(HDTileDirection)direction {
    
    CGPoint centerPoint = CGPointMake(size.width/2, size.height/2);
    switch (direction) {
        case HDTileDirectionLeft:
        case HDTileDirectionRight:
            centerPoint = CGPointMake(size.width/2, size.height/2 + 1.0f);
            break;
        case HDTileDirectionTopLeft:
        case HDTileDirectionBottomRight:
            centerPoint = CGPointMake(size.width/2 - 1.0f, size.height/2 + 1.0f);
            break;
        case HDTileDirectionTopRight:
        case HDTileDirectionBottomLeft:
            centerPoint = CGPointMake(size.width/2 + 1.0f, size.height/2 + 1.0f);
            break;
        default:
            break;
    }
    return centerPoint;
}

+ (CGPoint)centerFromSize:(CGSize)size
                direction:(HDTileDirection)direction {
    
    CGPoint centerPoint = CGPointMake(size.width/2, size.height/2);
    switch (direction) {
        case HDTileDirectionLeft:
        case HDTileDirectionRight:
            centerPoint = CGPointMake(size.width/2, size.height/2 - 1.0f);
            break;
        case HDTileDirectionTopLeft:
        case HDTileDirectionBottomRight:
            centerPoint = CGPointMake(size.width/2 + 1.0f, size.height/2);
            break;
        case HDTileDirectionTopRight:
        case HDTileDirectionBottomLeft:
            centerPoint = CGPointMake(size.width/2 - 1.0f, size.height/2);
            break;
        default:
            break;
    }
    return centerPoint;
}

+ (CGPoint)pointFromAngle:(CGFloat)angle center:(CGPoint)center radius:(CGFloat)radius {
    return CGPointMake(radius * cos(angle) + center.x, radius * sin(angle) + center.y);
}

@end
