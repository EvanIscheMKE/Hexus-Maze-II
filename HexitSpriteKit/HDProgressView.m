//
//  HDProgressView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/15/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDProgressView.h"
#import "UIColor+FlatColors.h"

static const CGFloat kPadding = 5.0f;

@implementation HDProgressView{
    NSInteger _remainingTileCount;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame tileTypes:[NSArray array]];
}

- (instancetype)initWithFrame:(CGRect)frame tileTypes:(NSArray *)tileTypes
{
    if (self = [super initWithFrame:frame]) {
        
        [self setOpaque:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        
         self.countLabel = [[UILabel alloc] init];
        [self.countLabel setText:@"50"];
        [self.countLabel setTextColor:[UIColor flatConcreteColor]];
        [self.countLabel setFont:GILLSANS_LIGHT(20.0f)];
        [self.countLabel sizeToFit];
        [self.countLabel setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) + kPadding)];
        [self addSubview:self.countLabel];
        
    }
    return self;
}

- (void)setRemainingTileCount:(NSInteger)remainingTileCount
{
    _remainingTileCount = remainingTileCount;
    
    [self.countLabel setText:[NSString stringWithFormat:@"%ld", _remainingTileCount]];
    [self.countLabel sizeToFit];
    [self.countLabel setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) + kPadding)];
}

- (void)decreaseTileCountByUno
{
    [self setRemainingTileCount:MAX(self.remainingTileCount - 1, 0)];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [[UIColor flatCloudsColor] setFill];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path setLineWidth:6.0f];
    [path moveToPoint:CGPointMake(0.0f, CGRectGetHeight(self.bounds) / 1.5)];
    [path addArcWithCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) / 1.5)
                    radius:30
                startAngle:M_PI
                  endAngle:0
                 clockwise:YES];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) / 1.5)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    [path addLineToPoint:CGPointMake(0.0f, CGRectGetHeight(self.bounds))];
    [path fill];
}

@end
