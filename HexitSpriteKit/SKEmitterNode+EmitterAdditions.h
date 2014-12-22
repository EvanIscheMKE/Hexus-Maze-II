//
//  SKEmitterNode+EmitterAdditions.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/11/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKEmitterNode (EmitterAdditions)

+ (SKEmitterNode *)starEmitter;
+ (SKEmitterNode *)hexaEmitterWithColor:(UIColor *)skColor scale:(CGFloat)scale;

@end