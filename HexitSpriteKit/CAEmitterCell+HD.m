//
//  CAEmitterCell+HD.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 1/31/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "CAEmitterCell+HD.h"

@implementation CAEmitterCell (EmitterAdditions)

+ (CAEmitterCell *)hexaEmitterWithColor:(UIColor *)color scale:(CGFloat)scale
{
    CAEmitterCell *emitter = [CAEmitterCell emitterCell];
    emitter.scale = scale;
    emitter.birthRate = 25;
    emitter.lifetime = 1;
    emitter.contents = (id)[UIImage imageNamed:@"hexagon"].CGImage;
    emitter.color = color.CGColor;
    emitter.emissionRange = M_PI*2;
    emitter.alphaRange = .7f;
    emitter.velocity = 900;
    
    return emitter;
}


@end
