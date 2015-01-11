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

static const CGFloat kLargeCurrentPageSize = 25.0f;
static const CGFloat kLargerPageSize       = 16.0f;
static const CGFloat kLargePageSpacing     = 34.0f;

static const CGFloat kSmallCurrentPageSize = 20.0f;
static const CGFloat kSmallPageSize        = 12.0f;
static const CGFloat kSmallPageSpacing     = 28.0f;

@implementation HDHexagonControl{
    CGFloat _kPageSpacing;
    CGFloat _kCurrentPageSize;
    CGFloat _kPageSize;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    CGRect bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
    if (self = [super initWithFrame:bounds]) {
        
        _kPageSize        = [HDHelper isWideScreen] ? kLargerPageSize : kSmallPageSize;
        _kCurrentPageSize = [HDHelper isWideScreen] ? kLargeCurrentPageSize : kSmallCurrentPageSize;
        _kPageSpacing     = [HDHelper isWideScreen] ? kLargePageSpacing : kSmallPageSpacing;
        
        self.backgroundColor = [UIColor flatWetAsphaltColor];
        self.currentPageTintColor = [UIColor whiteColor];
        self.tintColor = [UIColor whiteColor];
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
        [hexagon setLineWidth:[HDHelper isWideScreen] ? 6.0f : 4.0f];
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
