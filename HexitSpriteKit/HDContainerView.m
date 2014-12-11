//
//  HDSpaceView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/24/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDHelper.h"
#import "HDContainerView.h"
#import "UIColor+FlatColors.h"
#import "UIBezierPath+HDBezierPath.h"

@interface HDContainerView ()

@end

@implementation HDContainerView {
    NSArray *_hexaArray;
    BOOL _animate;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setBackgroundColor:[UIColor flatMidnightBlueColor]];
        
        self.shouldAnimteWhenMovedToSuperView = YES;

        NSMutableArray *hexaArray = [NSMutableArray new];
        
        for (int i = 0; i < 15; i++) {
            CGRect hexaBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds) / 3, CGRectGetWidth(self.bounds) / 3);
            CAShapeLayer *hexagon = [CAShapeLayer layer];
            [hexagon setFillColor:[[[UIColor flatPeterRiverColor] colorWithAlphaComponent:.125f] CGColor]];
            [hexagon setBounds:hexaBounds];
            [hexagon setPosition:self.center];
            [hexagon setPath:[HDHelper hexagonPathForBounds:hexaBounds]];
            [self.layer addSublayer:hexagon];
            [hexaArray addObject:hexagon];
        }
        
        _hexaArray = hexaArray;
        
    }
    return self;
}

- (void)setAnimate:(BOOL)animate
{
    if (animate == _animate) {
        return;
    }
    
    if (animate) {
        [self _animateHexAlongPath];
    } else {
        [self _removeAnimation];
    }
    
    [self willChangeValueForKey:@"animate"];
    _animate = animate;
    [self didChangeValueForKey:@"animate"];
}

- (void)_removeAnimation
{
    for (CAShapeLayer *hexa in _hexaArray) {
        [hexa removeAllAnimations];
    }
}

- (void)_animateHexAlongPath
{
    for (CAShapeLayer *hexa in _hexaArray) {
        
        UIBezierPath *randomPath = [UIBezierPath randomPathFromBounds:self.bounds];
        
        CAKeyframeAnimation *path = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        [path setPath:[randomPath CGPath]];
        [path setDuration:120.0f];
        [path setRepeatCount:HUGE_VALF];
        [hexa addAnimation:path forKey:nil];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        self.animate = NO;
    } else if (self.shouldAnimteWhenMovedToSuperView) {
        self.animate = YES;
    }
}

@end
