//
//  HDPageControl.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/30/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDPageControl.h"
#import "UIColor+FlatColors.h"

@interface HDPageControl ()

@end

@implementation HDPageControl

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUserInteractionEnabled:NO];
    }
    return self;
}

- (void)updateHexagons
{
    for (int i = 0; i < [self.subviews count]; i++) {
        UIView *hexagon = [self.subviews objectAtIndex:i];
        
        CAShapeLayer *mask = [CAShapeLayer layer];
        [mask setFrame:hexagon.bounds];
        [mask setPath:[HDHelper hexagonPathForBounds:hexagon.bounds]];
        
        [hexagon.layer setMask:mask];
        
        if (i == self.currentPage) {
            
            CGAffineTransform scale = CGAffineTransformMakeScale(1.3f, 1.3f);
            scale = CGAffineTransformTranslate(scale, .65f, -.65f);
            [hexagon setTransform:scale];
            [hexagon setBackgroundColor:self.currentPageIndicatorTintColor];
        } else {
            [hexagon setTransform:CGAffineTransformIdentity];
            [hexagon setBackgroundColor:[UIColor flatCloudsColor]];
        }
    }
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    [self updateHexagons];
}

@end
