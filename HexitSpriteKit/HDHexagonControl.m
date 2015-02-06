//
//  HDHexagonControl.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDHexagonControl.h"
#import "UIColor+FlatColors.h"

#define _kCurrentPageSize 25.0f * [[UIScreen mainScreen] bounds].size.width / 375.0f
#define _kPageSize        16.0f * [[UIScreen mainScreen] bounds].size.width / 375.0f
#define _kPageSpacing     34.0f * [[UIScreen mainScreen] bounds].size.width / 375.0f
@implementation HDHexagonControl

- (instancetype)initWithFrame:(CGRect)frame
{
    CGRect bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
    if (self = [super initWithFrame:bounds]) {
        self.backgroundColor      = [UIColor flatWetAsphaltColor];
        self.currentPageTintColor = [UIColor flatPeterRiverColor];
        self.tintColor            = [UIColor whiteColor];
    }
    return self;
}

- (void)setCurrentPage:(NSUInteger)currentPage
{
    _currentPage = MIN(currentPage, self.numberOfPages - 1);
    [self setNeedsDisplay];
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages
{
    _numberOfPages = numberOfPages;
    [self setCurrentPage:MIN(self.currentPage, numberOfPages - 1)];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    const CGFloat kStartOriginX = ceilf(CGRectGetMidX(self.bounds) - (((CGFloat)self.numberOfPages - 1)/2) * _kPageSpacing);
    for (NSInteger page = 0; page < self.numberOfPages; page++) {
        
        CGPoint point = CGPointMake(kStartOriginX + (page * _kPageSpacing), CGRectGetMidY(self.bounds));
        
        UIBezierPath *hexagon;
        if (self.currentPage == page) {
            
            [self.currentPageTintColor setStroke];
            
            CGRect rect = CGRectMake(
                                     ceilf(point.x - _kCurrentPageSize/2),
                                     ceilf(point.y - _kCurrentPageSize/2),
                                     _kCurrentPageSize,
                                     _kCurrentPageSize
                                     );
            
            hexagon = [self _bezierHexagonInFrame:rect];
            
        } else {
            
            [self.tintColor setStroke];
            
            CGRect rect = CGRectMake(
                                     ceilf(point.x - _kPageSize/2),
                                     ceilf(point.y - _kPageSize/2),
                                     _kPageSize,
                                     _kPageSize
                                     );
            
            hexagon = [self _bezierHexagonInFrame:rect];
            
        }
        [hexagon setLineWidth:lroundf(6.0f * CGRectGetWidth(self.bounds)/375)];
        [hexagon stroke];
    }
}

- (UIBezierPath *)_bezierHexagonInFrame:(CGRect)frame
{
    const CGFloat kWidth   = CGRectGetWidth(frame);
    const CGFloat kHeight  = CGRectGetHeight(frame);
    const CGFloat kPadding = kWidth / 8 / 2;
    
    UIBezierPath *_path = [UIBezierPath bezierPath];
    [_path moveToPoint:   CGPointMake(CGRectGetMinX(frame) + (kWidth / 2),        CGRectGetMinY(frame))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + (kWidth - kPadding), CGRectGetMinY(frame) + (kHeight / 4))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + (kWidth - kPadding), CGRectGetMinY(frame) + (kHeight * 3 / 4))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + (kWidth / 2),        CGRectGetMinY(frame) + kHeight)];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + kPadding,            CGRectGetMinY(frame) + (kHeight * .75))];
    [_path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + kPadding,            CGRectGetMinY(frame) + (kHeight / 4))];
    [_path closePath];
    
    return _path;
}

@end
