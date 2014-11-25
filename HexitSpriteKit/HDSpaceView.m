//
//  HDSpaceView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/24/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDSpaceView.h"
#import "UIColor+FlatColors.h"

@implementation HDSpaceView {
    CAEmitterCell *_stars;
}

+ (Class)layerClass
{
    return [CAEmitterLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [UIColor flatMidnightBlueColor];
        
        _stars = [self _spaceEmitterCell];
     
        CAEmitterLayer *spaceLayer = (CAEmitterLayer *)self.layer;
        [spaceLayer setEmitterPosition:CGPointMake(CGRectGetMidX(self.bounds), 0.0f)];
        [spaceLayer setEmitterSize:self.bounds.size];
        [spaceLayer setEmitterShape:kCAEmitterLayerLine];
        [spaceLayer setEmitterCells:@[_stars]];
        
//        [[NSRunLoop mainRunLoop] addTimer:[ NSTimer scheduledTimerWithTimeInterval:.05f target:self
//                                                                          selector:@selector(changeEmitterColor)
//                                                                          userInfo:nil
//                                                                           repeats:YES]
//                                  forMode:NSRunLoopCommonModes];
        
    }
    return self;
}

- (void)changeEmitterColor
{
    NSLog(@"CALLED");
    [_stars setColor: (arc4random() % 2) == 0 ? [[UIColor whiteColor] CGColor] : [[UIColor flatPeterRiverColor] CGColor]];
}

- (CAEmitterCell *)_spaceEmitterCell
{
    CAEmitterCell *star = [CAEmitterCell emitterCell];
    [star setContents: (__bridge id)[[UIImage imageNamed:@"spark.png"] CGImage]];
    [star setSpeed:1];
    [star setName:@"space"];
    [star setBirthRate:45];
    [star setLifetime:15];
    [star setLifetimeRange:2];
    [star setColor:[[UIColor whiteColor] CGColor]];
    [star setVelocity: 40];
    [star setVelocityRange: 80];
    [star setEmissionLongitude:M_PI + (M_PI_4 /2)];
    [star setYAcceleration:3.0f];
    [star setXAcceleration:2.0f];
    [star setAlphaRange:.2f];
    [star setAlphaSpeed:.29f];
    [star setScale:.07f];
    [star setScaleRange: 0.1f];
    [star setSpinRange: 10.0];
    
    return star;
}

@end
