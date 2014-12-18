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

- (void)updateTextureFromHexagonType:(HDHexagonType)type
{
    return [self updateTextureFromHexagonType:type touchesCount:0];
}

- (void)updateTextureFromHexagonType:(HDHexagonType)type touchesCount:(NSInteger)count;
{
    if (type == HDHexagonTypeNone) {
        [self setTexture:nil];
    } else {
        [self setTexture:[SKTexture textureWithImage:[self _imageWithType:type touchesCount:count]]];
    }
}

- (UIImage *)_imageWithType:(HDHexagonType)type touchesCount:(NSInteger)count
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [[UIScreen mainScreen] scale]);
    
    [[UIColor whiteColor] setStroke];
    [[UIColor whiteColor] setFill];
    
    const CGFloat kInsetSmall = CGRectGetWidth(self.frame) / 2.5f;
    
    CGRect bounds = CGRectMake(
                               0.0f,
                               0.0f,
                               self.frame.size.width,
                               self.frame.size.height
                               );
    
    CGRect indicatorFrame = CGRectInset(bounds, kInsetSmall, kInsetSmall);
    
    switch (type) {
        case HDHexagonTypeDouble:
            switch (count) {
                case 0:
                    indicatorFrame.origin.x += 1.0f;
                    indicatorFrame.origin.y -= 1.0f;
                    break;
            }
            break;
        case HDHexagonTypeTriple:
            switch (count) {
                case 0:
                    indicatorFrame.origin.x += 2.0f;
                    indicatorFrame.origin.y -= 2.0f;
                    break;
                case 1:
                    indicatorFrame.origin.x += 1.0f;
                    indicatorFrame.origin.y -= 1.0f;
                    break;
            }
            break;
    }
    
    UIBezierPath *hexagon = [self bezierHexagonInFrame:indicatorFrame];
    [hexagon setLineWidth:4];
    [hexagon stroke];

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
    [_path moveToPoint:   CGPointMake(CGRectGetMinX(frame) + (kWidth / 2),        CGRectGetMinY(frame))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + (kWidth - kPadding), CGRectGetMinY(frame) + (kHeight / 4))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + (kWidth - kPadding), CGRectGetMinY(frame) + (kHeight * 3 / 4))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + (kWidth / 2),        CGRectGetMinY(frame) + kHeight)];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + kPadding,            CGRectGetMinY(frame) + (kHeight * 3 / 4))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + kPadding,            CGRectGetMinY(frame) + (kHeight / 4))];
    [_path closePath];
    
    return _path;
}

@end
