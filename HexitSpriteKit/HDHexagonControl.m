//
//  HDHexagonControl.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDHexagonControl.h"
#import "UIColor+ColorAdditions.h"

#define _kPageSpacing  34.0f

const CGFloat TRANSFORM_ADDITION = .25F;
@interface HDHexagonControl ()
@property (nonatomic, assign) CGFloat pageSpacing;
@end

@implementation HDHexagonControl

- (instancetype)initWithFrame:(CGRect)frame {
    
    CGRect bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
    if (self = [super initWithFrame:bounds]) {
        self.backgroundColor = [UIColor clearColor];
        self.currentPageImage = [UIImage imageNamed:@"PageViewIndicator"];
        self.pageImage = self.currentPageImage;
    }
    return self;
}

- (void)_setup {
    
    const CGFloat scale = IS_IPAD ? 1.0f : TRANSFORM_SCALE;
    self.pageSpacing = self.currentPageImage.size.width*scale*1.3f;
    if (self.numberOfPages == 0) {
        return;
    }
    
    const CGFloat kStartOriginX = ceilf(CGRectGetMidX(self.bounds) - (((CGFloat)self.numberOfPages - 1)/2) * self.pageSpacing);
    for (NSInteger page = 0; page < self.numberOfPages; page++) {
        CGPoint point = CGPointMake(kStartOriginX + (page * self.pageSpacing), CGRectGetMidY(self.bounds));
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.currentPageImage];
        imageView.transform = IS_IPAD ? CGAffineTransformIdentity : CGAffineTransformMakeScale(TRANSFORM_SCALE, TRANSFORM_SCALE);
        imageView.center = point;
        [self addSubview:imageView];
    }
}

- (void)_update {
    
    const CGFloat scaleMultiplier = IS_IPAD ? 1.0f : TRANSFORM_SCALE;
    CGAffineTransform currentScale = CGAffineTransformMakeScale(scaleMultiplier + TRANSFORM_ADDITION, scaleMultiplier + TRANSFORM_ADDITION);
    CGAffineTransform scale = IS_IPAD ? CGAffineTransformIdentity : CGAffineTransformMakeScale(TRANSFORM_SCALE, TRANSFORM_SCALE);
    
    NSUInteger index = 0;
    for (UIImageView *subview in self.subviews) {
        [UIView animateWithDuration:.2 animations:^{
            subview.transform = index == self.currentPage ? currentScale : scale;
        }];
        index++;
    }
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    _currentPage = MIN(currentPage, self.numberOfPages - 1);
    [self _update];
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    [self _setup];
    [self setCurrentPage:MIN(self.currentPage, numberOfPages - 1)];
}

@end
