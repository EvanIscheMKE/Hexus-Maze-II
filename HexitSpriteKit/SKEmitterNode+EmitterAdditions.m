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

+ (NSArray *)horizontalEmitterColor:(SKColor *)color {

    NSMutableArray *emitters = [NSMutableArray array];
    for (NSUInteger i = 0; i < 2; i++) {
        SKEmitterNode *emitter = [SKEmitterNode node];
        emitter.emissionAngle = i == 0 ? 0 : M_PI;
        emitter.numParticlesToEmit = 20;
        emitter.particleBirthRate = emitter.numParticlesToEmit*1.75;
        emitter.particleTexture = [SKTexture textureWithImageNamed:@"hexagon"];
        emitter.particleColor = color;
        emitter.particleLifetime = 2.0f;
        emitter.particleAlpha = .5f;
        emitter.particlePosition = CGPointMake(0.0, 0.0);
        emitter.particleSpeed = 700.0f;
        emitter.particleScale = 3.5f;
        emitter.particleBlendMode = SKBlendModeAlpha;
        [emitter setParticleColorBlendFactor:1.2];
        [emitter advanceSimulationTime:.72f];
        emitter.yAcceleration = 0;
        emitter.zPosition = 0;
        [emitters addObject:emitter];
    }
    return emitters;
}

+ (NSArray *)verticalEmitterColor:(SKColor *)color {
    
    NSMutableArray *emitters = [NSMutableArray array];
    for (NSUInteger i = 0; i < 2; i++) {
        SKEmitterNode *emitter = [SKEmitterNode node];
        emitter.emissionAngle = i == 0 ? M_PI_2 : -M_PI_2;
        emitter.numParticlesToEmit = 20;
        emitter.particleBirthRate = emitter.numParticlesToEmit*1.75;
        emitter.particleTexture   = [SKTexture textureWithImageNamed:@"hexagon"];
        emitter.particleColor     = color;
        emitter.particleLifetime  = 2.0f;
        emitter.particlePosition  = CGPointMake(0.0, 0.0);
        emitter.particleSpeed     = 700.0f;
        emitter.particleAlpha     = .5f;
        emitter.particleAlphaRange = .2f;
        emitter.particleScale     = 2.0f;
        emitter.particleBlendMode = SKBlendModeAlpha;
        emitter.particleColorBlendFactor = 1.0f;
        [emitter advanceSimulationTime:.75f];
        emitter.yAcceleration = 0;
        emitter.zPosition     = 0;
        [emitters addObject:emitter];
    }
    return emitters;
}

@end
