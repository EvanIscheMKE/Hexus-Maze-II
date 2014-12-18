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

+ (SKEmitterNode *)starEmitter
{
    CGPoint particlePosition = CGPointMake(
                                           CGRectGetWidth([[UIScreen mainScreen] bounds]) / 2,
                                           CGRectGetHeight([[UIScreen mainScreen] bounds]) / 2
                                           );
    
    SKEmitterNode *emitter = [SKEmitterNode node];
    [emitter setParticleBirthRate:50];
    [emitter setParticleTexture:[SKTexture textureWithImage:[[self class] starImage]]];
    [emitter setParticleColor:[SKColor flatEmeraldColor]];
    [emitter setParticleLifetime:2.0f];
    [emitter setAlpha:.5];
    [emitter setName:@"STARKEY"];
    [emitter setParticleAlphaRange:.5f];
    [emitter setParticlePosition:particlePosition];
    [emitter setParticleSpeed:300.0f];
    [emitter setEmissionAngle:89.0f];
    [emitter setParticleScale:1.0f];
    [emitter setEmissionAngleRange:350.0f];
    [emitter setParticleBlendMode:SKBlendModeAlpha];
    [emitter setParticleColorBlendFactor:1.0];
    [emitter advanceSimulationTime:.5f];
    [emitter setYAcceleration:0];
    
    return emitter;
}

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

+ (UIImage *)starImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0f, 30.0f), NO, [[UIScreen mainScreen] scale]);
    
    [[UIColor flatEmeraldColor] setFill];
    UIBezierPath *star = [UIBezierPath bezierPathWithCGPath:[HDHelper starPathForBounds:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)]];
    [star fill];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

@end
