//
//  UIImage+HDImage.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/7/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "UIImage+HDImage.h"
#import "UIColor+FlatColors.h"

@implementation UIImage (HDImage)

+ (UIImage *)textureImageWithType:(HDHexagonType)type
{

    CGRect rect = CGRectMake(0.0f, 0.0f , 40.0f, 40.0f);
    UIBezierPath *background = [UIBezierPath bezierPathWithRect:rect];
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, [[UIScreen mainScreen] scale]);

    [[UIColor flatPeterRiverColor] setFill];
    [background fill];
    
    [[UIColor lightGrayColor] setFill];
    
    const CGFloat kHexagonSize = 8.f;
    const NSInteger honeycombGridSize = 5;
    for (int y = 0; y < honeycombGridSize; y++) {
        
        CGFloat kAlternateOffset = (y % 2 == 1) ? kHexagonSize / 2.f : 0.0f;
        for (int x = -1; x < honeycombGridSize; x++) {
            
            CGFloat kOriginX = ceilf((x * kHexagonSize) + kAlternateOffset);
            CGFloat kOriginY = ceilf(y * (kHexagonSize));
            
            CGRect rect = CGRectMake(kOriginX, kOriginY, kHexagonSize, kHexagonSize);
            UIBezierPath *hexagon = [[self class] bezierHexagonInFrame:rect];
            [hexagon fill];
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIBezierPath *)bezierHexagonInFrame:(CGRect)frame
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
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) +kPadding, CGRectGetMinY(frame) + (kHeight / 4))];
    [_path closePath];
    
    return _path;
}


@end
