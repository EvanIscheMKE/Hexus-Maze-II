//
//  SKEmitterNode+EmitterAdditions.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/11/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "UIColor+FlatColors.h"
#import "SKEmitterNode+EmitterAdditions.h"

@implementation SKEmitterNode (EmitterAdditions)

+ (SKEmitterNode *)hexaEmitterWithColor:(UIColor *)skColor scale:(CGFloat)scale
{
    // shoots little hexagons when node is selected
    SKEmitterNode *emitter = [SKEmitterNode node];
    [emitter setNumParticlesToEmit:20];
    [emitter setParticleBirthRate:20];
    [emitter setParticleTexture:[SKTexture textureWithImageNamed:@"hexagon.png"]];
    [emitter setParticleColor:skColor];
    [emitter setParticleLifetime:1.0f];
    [emitter setParticleAlphaRange:.5f];
    [emitter setParticlePosition:CGPointMake(0.0, 0.0)];
    [emitter setParticleSpeed:500.0f];
    [emitter setEmissionAngle:89.0f];
    [emitter setParticleScale:scale];
    [emitter setEmissionAngleRange:350.0f];
    [emitter setParticleBlendMode:SKBlendModeAlpha];
    [emitter setParticleColorBlendFactor:1.0];
    [emitter advanceSimulationTime:.65f];
    [emitter setYAcceleration:0];
    
    return emitter;
}

@end
