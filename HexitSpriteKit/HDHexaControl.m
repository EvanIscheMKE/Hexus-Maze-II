//
//  HDHexagonControl.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDHexaControl.h"
#import "UIColor+ColorAdditions.h"

static const CGFloat scaleAddition = .25f;

@interface HDHexaControl ()
@property (nonatomic, assign) CGFloat pageSpacing;
@end

@implementation HDHexaControl

- (instancetype)initWithFrame:(CGRect)frame {
    CGRect bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
    if (self = [super initWithFrame:bounds]) {
        self.backgroundColor = [UIColor clearColor];
        self.currentPageImage = [UIImage imageNamed:@"PageViewIndicator"];
        self.pageImage = self.currentPageImage;
        self.pageSpacing = self.currentPageImage.size.width * self.scale * 1.3f;
    }
    return self;
}

- (void)_setup {
    
    if (self.numberOfPages == 0) {
        return;
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromParent)];
    
    const CGFloat kStartOriginX = ceilf(CGRectGetMidX(self.bounds) - ((self.numberOfPages - 1)/2.0f) * self.pageSpacing);
    for (NSInteger page = 0; page < self.numberOfPages; page++) {
        CGPoint point = CGPointMake(kStartOriginX + (page * self.pageSpacing), CGRectGetMidY(self.bounds));
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.currentPageImage];
        imageView.transform = CGAffineTransformMakeScale(self.scale, self.scale);
        imageView.tag = page;
        imageView.center = point;
        [self addSubview:imageView];
    }
}

- (void)_update {
    
    CGAffineTransform currentScale = CGAffineTransformMakeScale(self.scale + scaleAddition, self.scale + scaleAddition);
    CGAffineTransform scale = IS_IPAD ? CGAffineTransformIdentity : CGAffineTransformMakeScale(TRANSFORM_SCALE_X, TRANSFORM_SCALE_X);
    
    NSUInteger index = 0;
    for (UIImageView *subview in self.subviews) {
        [UIView animateWithDuration:.2 animations:^{
            subview.transform = (index == self.currentPage) ? currentScale : scale;
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
    self.currentPage = MIN(self.currentPage, numberOfPages - 1);
}

- (CGFloat)scale {
    return (IS_IPAD ? 1.0f : TRANSFORM_SCALE_X);
}

#pragma mark - UIResponder 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInView:self];
    
    for (UIImageView *imageView in self.subviews) {
        if (CGRectContainsPoint(imageView.frame, position)) {
            const NSUInteger selectedIndex = imageView.tag;
            self.currentPage = selectedIndex;
            if (self.delegate && [self.delegate respondsToSelector:@selector(hexaControl:pageIndexWasSelected:)]) {
                [self.delegate hexaControl:self pageIndexWasSelected:selectedIndex];
            }
            break;
        }
    }
}

@end
