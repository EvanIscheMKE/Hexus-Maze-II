//
//  HDHexagonNode.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHexagonNode.h"
#import "SKColor+HDColor.h"

@interface HDHexagonNode ()
@property (nonatomic, strong) SKLabelNode *label;
@end

@implementation HDHexagonNode

- (instancetype)init
{
    if (self = [super init]) {
        
        CGRect rect = CGRectMake(0.0, 0.0, 40.0, 40.0);
        SKTexture *texture = [SKTexture textureWithImage:[self maskImage:[self textureImage] toPath:[self hexagonPathForBounds:rect]]];
        [self setFillTexture:texture];
     
    }
    return self;
}

- (void)updateLabelWithText:(NSString *)text
{
    if (!self.label) {
        self.label = [SKLabelNode labelNodeWithText:text];
        [self.label setFontName:@"GillSans-Light"];
        [self.label setFontSize:18.0f];
        [self.label setFontColor:[SKColor blackColor]];
        [self.label setPosition:CGPointMake(20.0f, 13.0f)];
        [self addChild:self.label];
    }
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    [super setStrokeColor:strokeColor];
    [self setFillColor:strokeColor];
}

- (UIImage *)maskImage:(UIImage *)originalImage toPath:(UIBezierPath *)path {
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, 0);
    [path addClip];
    [originalImage drawAtPoint:CGPointZero];
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return maskedImage;
}

- (UIImage *)textureImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40.0f, 40.0f), NO, [[UIScreen mainScreen] scale]);
    
    [[[UIColor lightGrayColor] colorWithAlphaComponent:.6] setFill];
    
    const CGFloat kHexagonSize = 8.f;
    const NSInteger honeycombGridSize = 5;
    
    for (int y = 0; y < honeycombGridSize; y++) {
        
        CGFloat kAlternateOffset = (y % 2 == 1) ? kHexagonSize / 2.f : 0.0f;
        for (int x = -1; x < honeycombGridSize; x++) {
            
            CGFloat kOriginX = ceilf((x * kHexagonSize) + kAlternateOffset);
            CGFloat kOriginY = ceilf(y * (kHexagonSize));
            
            CGRect rect = CGRectMake(kOriginX, kOriginY, kHexagonSize, kHexagonSize);
            UIBezierPath *hexagon = [self bezierHexagonInFrame:rect];
            [hexagon fill];
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIBezierPath *)hexagonPathForBounds:(CGRect)bounds
{
    CGFloat const kWidth   = CGRectGetWidth(bounds);
    CGFloat const kHeight  = CGRectGetHeight(bounds);
    CGFloat const kPadding = kWidth / 8 / 2;
    
    UIBezierPath *_path = [UIBezierPath bezierPath];
    [_path moveToPoint:CGPointMake(kWidth / 2, 0)];
    [_path addLineToPoint:CGPointMake(kWidth - kPadding, kHeight / 4)];
    [_path addLineToPoint:CGPointMake(kWidth - kPadding, kHeight * 3 / 4)];
    [_path addLineToPoint:CGPointMake(kWidth / 2, kHeight)];
    [_path addLineToPoint:CGPointMake(kPadding, kHeight * 3 / 4)];
    [_path addLineToPoint:CGPointMake(kPadding, kHeight / 4)];
    [_path closePath];
    
    return _path;
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
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) +kPadding, CGRectGetMinY(frame) + (kHeight / 4))];
    [_path closePath];
    
    return _path;
}

@end
