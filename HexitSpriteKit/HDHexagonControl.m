//
//  HDHexagonControl.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHexagonControl.h"
#import "UIColor+FlatColors.h"

static const CGFloat kCurrentPageSize    = 25.0f;
static const CGFloat kPageSize           = 16.0f;
static const CGFloat kPageSpacing        = 34.0f;

@implementation HDHexagonControl

- (instancetype)initWithFrame:(CGRect)frame
{
    CGRect bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
    if (self = [super initWithFrame:bounds]) {
        [self setBackgroundColor:[UIColor flatMidnightBlueColor]];
        [self setCurrentPageTintColor:[UIColor whiteColor]];
        [self setTintColor:[UIColor whiteColor]];
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
    [super drawRect:rect];
    
    const CGFloat kStartOriginX = ceilf(CGRectGetMidX(self.bounds) - ((self.numberOfPages - 1)/2) * kPageSpacing);
    for (NSInteger page = 0; page < self.numberOfPages; page++) {
        
        CGPoint point = CGPointMake(kStartOriginX + (page * kPageSpacing), CGRectGetMidY(self.bounds));
        
        UIBezierPath *hexagon;
        if (self.currentPage == page) {
            
            [self.currentPageTintColor setStroke];
            
            CGRect rect = CGRectMake(
                                     ceilf(point.x - kCurrentPageSize/2),
                                     ceilf(point.y - kCurrentPageSize/2),
                                     kCurrentPageSize,
                                     kCurrentPageSize
                                     );
            
            hexagon = [self _bezierHexagonInFrame:rect];
            
        } else {
            
            [self.tintColor setStroke];
            
            CGRect rect = CGRectMake(
                                     ceilf(point.x - kPageSize/2),
                                     ceilf(point.y - kPageSize/2),
                                     kPageSize,
                                     kPageSize
                                     );
            
            hexagon = [self _bezierHexagonInFrame:rect];
            
        }
        [hexagon setLineWidth:6];
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
