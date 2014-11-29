//
//  HDSpaceView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/24/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDSpaceView.h"
#import "UIColor+FlatColors.h"

@interface HDSpaceView ()
@property (nonatomic, strong) CAEmitterLayer *emitterLayer;
@end

@implementation HDSpaceView {
    BOOL _animate;
}
@synthesize animate = _animate;

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.shouldAnimteWhenMovedToSuperView = YES;

        self.emitterLayer = [CAEmitterLayer new];
        [self.emitterLayer setEmitterPosition:CGPointMake(CGRectGetMidX(self.bounds), 0.0f)];
        [self.emitterLayer setEmitterSize:self.bounds.size];
        [self.emitterLayer setEmitterShape:kCAEmitterLayerLine];
        self.emitterLayer.renderMode = kCAEmitterLayerPoints;
        self.emitterLayer.emitterMode = kCAEmitterLayerUnordered;
        
        CAGradientLayer *gradientLayer = self.gradientLayer;
        gradientLayer.colors = @[(id)[UIColor flatMidnightBlueColor].CGColor,
                                 (id)[[UIColor flatMidnightBlueColor] colorWithAlphaComponent:.5f].CGColor];
        gradientLayer.locations = @[@(.65),@(1.25)];
        
        [self.layer addSublayer:self.emitterLayer];
        [self.layer setMasksToBounds:YES];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.emitterLayer.frame = self.bounds;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    NSLog(@"%@ doesn't work.", NSStringFromSelector(_cmd));
}

- (void)setAnimate:(BOOL)animate
{
    if (animate == _animate) {
        return;
    }
    
    if (animate) {
        [self.emitterLayer setEmitterCells:@[[self _buildSpaceEmitterCellWithColor:[UIColor whiteColor]],
                                             [self _buildSpaceEmitterCellWithColor:[UIColor flatPeterRiverColor]]]];
    } else {
        [self.emitterLayer setEmitterCells:nil];
    }
    
    [self willChangeValueForKey:@"animate"];
    _animate = animate;
    [self didChangeValueForKey:@"animate"];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        self.animate = NO;
    } else if (self.shouldAnimteWhenMovedToSuperView) {
        self.animate = YES;
    }
}

- (CAGradientLayer *)gradientLayer
{
    return  (CAGradientLayer *)self.layer;
}

- (CAEmitterCell *)_buildSpaceEmitterCellWithColor:(UIColor *)color
{
    CAEmitterCell *star = [CAEmitterCell emitterCell];
    [star setContents: (__bridge id)[[UIImage imageNamed:@"spark.png"] CGImage]];
    [star setSpeed:1];
    [star setName:@"space"];
    [star setBirthRate:8];
    [star setLifetime:15];
    [star setLifetimeRange:2];
    [star setColor:[color CGColor]];
    [star setVelocity: 40];
    [star setVelocityRange: 80];
    [star setEmissionLongitude:M_PI + (M_PI_4 /2)];
    [star setYAcceleration:3.0f];
    [star setXAcceleration:2.0f];
    [star setAlphaRange:.0f];
    [star setAlphaSpeed:.0f];
    [star setScale:.07f];
    [star setScaleRange: 0.1f];
    [star setSpinRange: 10.0];
    
    return star;
}

@end
