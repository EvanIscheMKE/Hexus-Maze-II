//
//  SKEmitterNode+EmitterAdditions.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/11/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDTextureManager.h"
#import "UIColor+ColorAdditions.h"
#import "SKEmitterNode+EmitterAdditions.h"

@implementation SKEmitterNode (EmitterAdditions)

+ (SKEmitterNode *)explosionNode {
    
    SKEmitterNode *explosion = [[SKEmitterNode alloc] init];
    explosion.particleTexture = [[HDTextureManager sharedManager] textureForKeyPath:@"ExplosionTexture"];
    explosion.numParticlesToEmit = 180;
    explosion.particleBirthRate  = 180;
    explosion.particleLifetime   = 1.5f;
    explosion.emissionAngleRange = M_PI*2;
    explosion.particleRotationRange = M_PI*2;
    explosion.particleSpeed      = 100.0f;
    explosion.particleSpeedRange = 50.0f;
    explosion.particleScale      = .9f;
    explosion.particleScaleSpeed = -.6f;
    [explosion advanceSimulationTime:.925f];
    explosion.particleColorBlendFactor = 1.0f;
    return explosion;
}

@end
