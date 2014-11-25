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
            textureImage = [self _imageWithSize:self.size direction:direction type:type];
            break;
        case HDHexagonTypeStarter:
            textureImage = [self _imageWithSize:self.size direction:direction type:type];
            break;
        case HDHexagonTypeDouble:
            textureImage = [self _imageWithSize:self.size direction:direction type:type];
            break;
        case HDHexagonTypeTriple:
            textureImage = [self _imageWithSize:self.size direction:direction type:type];
            break;
        case HDHexagonTypeOne:
            textureImage = [self _imageWithSize:self.size direction:direction type:type];
            break;
        case HDHexagonTypeTwo:
            textureImage = [self _imageWithSize:self.size direction:direction type:type];
            break;
        case HDHexagonTypeThree:
            textureImage = [self _imageWithSize:self.size direction:direction type:type];
            break;
        case HDHexagonTypeFour:
            textureImage = [self _imageWithSize:self.size direction:direction type:type];
            break;
        case HDHexagonTypeFive:
            textureImage = [self _imageWithSize:self.size direction:direction type:type];
            break;
        case HDHexagonTypeNone:
            [self setTexture:[SKTexture textureWithImage:[self _plainTransparentBackground]]];
            return;
    }
    [self setTexture:[SKTexture textureWithImage:textureImage]];
}

- (UIImage *)_plainTransparentBackground
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    
    UIImage *circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return circle;
}

- (UIImage *)_imageWithSize:(CGSize)size direction:(HDSpriteDirection)direction type:(HDHexagonType)type
{
    CGRect imageFrame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    
    
//    switch (type) {
//        case HDHexagonTypeStarter:
             [[UIColor whiteColor] setStroke];
             [[UIColor whiteColor] setFill];
//             break;
//        case HDHexagonTypeRegular:
//            [[UIColor flatPeterRiverColor] setStroke];
//            [[UIColor flatPeterRiverColor] setFill];
//            break;
//        case HDHexagonTypeDouble:
//            [[UIColor flatTurquoiseColor] setStroke];
//            [[UIColor flatTurquoiseColor] setFill];
//            break;
//        case HDHexagonTypeTriple:
//            [[UIColor flatSilverColor] setStroke];
//            [[UIColor flatSilverColor] setFill];
//            break;
//        case HDHexagonTypeOne:
//            [[UIColor flatEmeraldColor] setStroke];
//            [[UIColor flatEmeraldColor] setFill];
//            break;
//        case HDHexagonTypeTwo:
//            [[UIColor flatEmeraldColor] setStroke];
//            [[UIColor flatEmeraldColor] setFill];
//            break;
//        case HDHexagonTypeThree:
//            [[UIColor flatEmeraldColor] setStroke];
//            [[UIColor flatEmeraldColor] setFill];
//            break;
//        case HDHexagonTypeFour:
//            [[UIColor flatEmeraldColor] setStroke];
//            [[UIColor flatEmeraldColor] setFill];
//            break;
//        case HDHexagonTypeFive:
//            [[UIColor flatEmeraldColor] setStroke];
//            [[UIColor flatEmeraldColor] setFill];
//           break;
//    }
    
    UIBezierPath *hexagon = [self bezierHexagonInFrame:CGRectInset(imageFrame, 20.0f, 20.0f)];
    [hexagon fill];
    
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
    
    [line setLineWidth:3];
    [line stroke];
    
    UIImage *circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return circle;
}

- (UIBezierPath *)bezierHexagonInFrame:(CGRect)frame
{
    const CGFloat kWidth   = CGRectGetWidth(frame);
    const CGFloat kHeight  = CGRectGetHeight(frame);
    const CGFloat kPadding = kWidth / 8 / 2;
    
    UIBezierPath *_path = [UIBezierPath bezierPath];
    [_path moveToPoint:CGPointMake(CGRectGetMinX(frame) + (kWidth / 2), CGRectGetMinY(frame))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + (kWidth - kPadding),CGRectGetMinY(frame) + (kHeight / 4))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + (kWidth - kPadding), CGRectGetMinY(frame) + (kHeight * 3 / 4))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + (kWidth / 2),CGRectGetMinY(frame) + kHeight)];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + kPadding, CGRectGetMinY(frame) + (kHeight * 3 / 4))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + kPadding, CGRectGetMinY(frame) + (kHeight / 4))];
    [_path closePath];
    
    return _path;
}

@end
