//
//  Hexagon.m
//  Hexagon
//
//  Created by Evan Ische on 10/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHexagonView.h"

@interface HDHexagonView ()

@end

@implementation HDHexagonView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        
        [self setOpaque:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        
        CAShapeLayer *layer = (CAShapeLayer *)self.layer;
        [layer setPath:[[self hexagonPathForBounds:self.bounds] CGPath]];
        [layer setLineWidth:1.5f];
        
         self.textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [self.textLabel setFont:GILLSANS(32.0f)];
        [self.textLabel setTextColor:[UIColor whiteColor]];
        [self.textLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.textLabel];

    }
    return self;
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


@end
