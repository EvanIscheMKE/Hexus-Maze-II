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

#define _kPageSpacing  34.0f
@interface HDHexagonControl ()
@property (nonatomic, assign) CGFloat pageSpacing;
@end

@implementation HDHexagonControl

- (instancetype)initWithFrame:(CGRect)frame {
    
    CGRect bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
    if (self = [super initWithFrame:bounds]) {
        self.backgroundColor = [UIColor clearColor];
        self.currentPageImage = [UIImage imageNamed:@"Control-Emerald-Start"];
        self.pageImage = [UIImage imageNamed:@"Control-Emerald-Start"];
    }
    return self;
}

- (void)_setup {
    
    if (self.numberOfPages == 0) {
        return;
    }

    self.pageSpacing = self.currentPageImage.size.width*1.3f;
    
    const CGFloat kStartOriginX = ceilf(CGRectGetMidX(self.bounds) - (((CGFloat)self.numberOfPages - 1)/2) * self.pageSpacing);
    for (NSInteger page = 0; page < self.numberOfPages; page++) {
        CGPoint point = CGPointMake(kStartOriginX + (page * self.pageSpacing), CGRectGetMidY(self.bounds));
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.currentPageImage];
        imageView.center = point;
        [self addSubview:imageView];
    }
}

- (void)_update {
    
    NSUInteger index = 0;
    for (UIImageView *subview in self.subviews) {
        [UIView animateWithDuration:.2 animations:^{
            subview.transform = index == self.currentPage ? CGAffineTransformMakeScale(1.275f, 1.275f) : CGAffineTransformIdentity;
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
