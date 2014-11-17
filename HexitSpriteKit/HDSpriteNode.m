//
//  HDSpriteNode.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/16/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "UIColor+FlatColors.h"
#import "HDSpriteNode.h"
#import "HDHexagon.h"

@implementation HDSpriteNode

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)updateTextureFromHexagonType:(HDHexagonType)type direction:(HDSpriteDirection)direction;
{
    UIImage *textureImage;
    switch (type) {
        case HDHexagonTypeRegular:
            textureImage = [self imageWithSize:self.size direction:direction];
            break;
        case HDHexagonTypeStarter:
            textureImage = [self imageWithSize:self.size direction:direction];
            break;
        case HDHexagonTypeDouble:
            textureImage = [self imageWithSize:self.size direction:direction];
            break;
        case HDHexagonTypeTriple:
            textureImage = [self imageWithSize:self.size direction:direction];
            break;
        case HDHexagonTypeOne:
            textureImage = [self imageWithSize:self.size direction:direction];
            break;
        case HDHexagonTypeTwo:
            textureImage = [self imageWithSize:self.size direction:direction];
            break;
        case HDHexagonTypeThree:
            textureImage = [self imageWithSize:self.size direction:direction];
            break;
        case HDHexagonTypeFour:
            textureImage = [self imageWithSize:self.size direction:direction];
            break;
        case HDHexagonTypeFive:
            textureImage = [self imageWithSize:self.size direction:direction];
            break;
        case HDHexagonTypeNone:
            [self setTexture:[SKTexture textureWithImage:[self plainTransparentBackground]]];
            return;
    }
    [self setTexture:[SKTexture textureWithImage:textureImage]];
}

- (UIImage *)plainTransparentBackground
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    
    UIImage *circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return circle;
}

- (UIImage *)imageWithSize:(CGSize)size direction:(HDSpriteDirection)direction
{
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    
    [[UIColor flatSilverColor] setStroke];
    
    UIBezierPath *line = [UIBezierPath bezierPath];
    switch (direction) {
        case HDSpriteDirectionLeft:
            [line moveToPoint:CGPointMake(size.width / 2, size.height / 2)];
            [line addLineToPoint:CGPointMake(0.0f, size.height / 2)];
            break;
        case HDSpriteDirectionRight:
            [line moveToPoint:CGPointMake(size.width / 2, size.height / 2)];
            [line addLineToPoint:CGPointMake(size.width, size.height / 2)];
            break;
        case HDSpriteDirectionUpLeft:
            [line moveToPoint:CGPointMake(size.width / 2, size.height / 2)];
            [line addLineToPoint:CGPointMake(size.width * .25f, size.height * .095f)];
            break;
        case HDSpriteDirectionUpRight:
            [line moveToPoint:CGPointMake(size.width / 2, size.height / 2)];
            [line addLineToPoint:CGPointMake(size.width * .75f, size.height * .095f)];
            break;
        case HDSpriteDirectionDownLeft:
            [line moveToPoint:CGPointMake(size.width / 2, size.height / 2)];
            [line addLineToPoint:CGPointMake(size.width * .25f, size.height * .905f)];
            break;
        case HDSpriteDirectionDownRight:
            [line moveToPoint:CGPointMake(size.width / 2, size.height / 2)];
            [line addLineToPoint:CGPointMake(size.width * .75f, size.height * .905f)];
            break;
        case HDSpriteDirectionNone:
            
            break;
        default:
            break;
    }
    
    [line setLineWidth:4];
    [line stroke];
    
    UIImage *circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return circle;
}

@end
