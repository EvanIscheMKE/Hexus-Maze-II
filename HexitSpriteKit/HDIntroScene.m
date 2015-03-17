//
//  HDIntroScene.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 3/13/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDIntroScene.h"
#import "SKColor+HDColor.h"
#import "SKEmitterNode+EmitterAdditions.h"

@interface HDSpriteNode : SKSpriteNode
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) NSUInteger tag;
@property (nonatomic, strong) SKTexture *selectedTexture;
@end

@implementation HDSpriteNode
@end

static CGFloat const kPadding = 5.0f;
@interface HDIntroScene ()
@property (nonatomic, strong) SKAction *firstSound;
@property (nonatomic, strong) SKAction *secondSound;
@property (nonatomic, strong) SKAction *thirdSound;
@property (nonatomic, strong) SKAction *finalSound;
@end

@implementation HDIntroScene {
    NSArray *_nodeContainer;
}

- (instancetype)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        [self _preloadSounds];
        [self _setupChildrenNodes];
    }
    return self;
}

- (void)_preloadSounds {
    self.firstSound  = [SKAction playSoundFileNamed:sound0 waitForCompletion:NO];
    self.secondSound = [SKAction playSoundFileNamed:sound1 waitForCompletion:NO];
    self.thirdSound  = [SKAction playSoundFileNamed:sound2 waitForCompletion:NO];
    self.finalSound  = [SKAction playSoundFileNamed:sound3 waitForCompletion:NO];
}

- (void)_setupChildrenNodes {
    
    NSArray *imagePaths = @[@"WelcomeVC-emerald-122",
                            @"WelcomeVC-emerald-122",
                            @"WelcomeVC-blue-122",
                            @"WelcomeVC-White-122"];
    
    NSArray *selectedImagePaths = @[@"WelcomeVC-emerald-selected-122",
                                    @"WelcomeVC-emerald-selected-122",
                                    @"WelcomeVC-blue-selected-122",
                                    @"WelcomeVC-White-Selected-122"];
    
    const CGFloat kButtonSize = ceil([UIImage imageNamed:@"WelcomeVC-White-122"].size.width * TRANSFORM_SCALE);
    const CGFloat kSpacing = kButtonSize - kPadding;
    const NSUInteger kHexagonCount = 4;
    
    NSMutableArray *_tiles = [NSMutableArray array];
    for (NSUInteger row = 0; row < kHexagonCount; row++) {
        CGPoint position =  CGPointMake((row % 2 == 0) ? -kButtonSize/2 : CGRectGetWidth(self.scene.frame) + kButtonSize/2,
                                       (CGRectGetHeight(self.scene.frame)/2 - ((kHexagonCount-1)/2.0f) * kSpacing) + (kSpacing * row));
        UIImage *texture = [UIImage imageNamed:[imagePaths objectAtIndex:row]];
        HDSpriteNode *hexagon = [[HDSpriteNode alloc] initWithTexture:[SKTexture textureWithImage:texture]];
        hexagon.selectedTexture = [SKTexture textureWithImageNamed:[selectedImagePaths objectAtIndex:row]];
        hexagon.scale = TRANSFORM_SCALE;
        hexagon.position = position;
        hexagon.zRotation = M_PI_2;
        hexagon.tag = kHexagonCount-1-row;
        [_tiles addObject:hexagon];
        [self addChild:hexagon];
        
        NSLog(@"%tu",kHexagonCount-1-row);
        
        if (row == 0) {
            SKSpriteNode *locked = [[SKSpriteNode alloc] initWithImageNamed:@"Locked-45"];
            locked.zRotation = -M_PI_2;
            [hexagon addChild:locked];
        }
    }
    _nodeContainer = _tiles;
}

- (void)_playSoundForTileAtIndex:(NSUInteger)index {
    
    switch (index) {
        case 0:
            [self runAction:self.firstSound];
            break;
        case 1:
            [self runAction:self.secondSound];
            break;
        case 2:
            [self runAction:self.thirdSound];
            break;
        case 3:
            [self runAction:self.finalSound];
            break;
    }
}

- (void)_updateNodesState:(HDSpriteNode *)node {
    
    if (node.selected) {
        return;
    }
    
    if (node.tag != 0) {
        for (HDSpriteNode *nodes in _nodeContainer) {
            if (nodes.tag == node.tag - 1) {
                if (!nodes.selected) {
                    return;
                }
                break;
            }
        }
    }
    
    node.selected = YES;
    [self _playSoundForTileAtIndex:node.tag];
    [self _performEmittersWithColor:[self colorFromIndex:node.tag] position:node.position];
    [node runAction:[SKAction rotateByAngle:M_PI*2 duration:.3] completion:^{
        node.texture = node.selectedTexture;
    }];
    
    if (node.tag == 2) {
        for (HDSpriteNode *nodes in _nodeContainer) {
            [[nodes children] makeObjectsPerformSelector:@selector(removeFromParent)];
        }
    }
    
    if (node.tag == 3) {
        [self _performOutroAnimations];
    }
}

- (void)_performEmittersWithColor:(SKColor *)color position:(CGPoint)position {
    
    SKEmitterNode *first  = [[SKEmitterNode horizontalEmitterColor:color] objectAtIndex:0];
    SKEmitterNode *second = [[SKEmitterNode horizontalEmitterColor:color] objectAtIndex:1];
    
    NSArray *emitters = @[first, second];
    for (SKEmitterNode *emitter in emitters) {
         emitter.position = position;
        [self insertChild:emitter atIndex:0];
        
        NSTimeInterval delayInSeconds = emitter.numParticlesToEmit / emitter.particleBirthRate + emitter.particleLifetime;
        [emitter performSelector:@selector(removeFromParent) withObject:nil afterDelay:delayInSeconds];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch   = [touches anyObject];
    CGPoint position = [touch locationInNode:self];
    for (HDSpriteNode *children in _nodeContainer) {
        if (CGRectContainsPoint(children.frame, position)) {
            [self _updateNodesState:children];
            break;
        }
    }
}

- (void)performIntroAnimationsWithCompletion:(dispatch_block_t)completion {
    for (SKSpriteNode *node in _nodeContainer) {
        [node runAction:[SKAction moveToX:CGRectGetWidth(self.view.bounds)/2 duration:.3] completion:completion];
    }
}

- (SKColor *)colorFromIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return [SKColor whiteColor];
        case 1:
            return [SKColor flatPeterRiverColor];
        case 2:
            return [SKColor flatEmeraldColor];
        case 3:
            return [SKColor flatEmeraldColor];
    }
    return nil;
}

- (void)_performOutroAnimations {
    
    SKAction *scaleUp = [SKAction scaleTo:1.2f duration:.08];
    SKAction *scaleDo = [SKAction scaleTo:0.0f duration:.22f];
    
    NSTimeInterval delayInterval = 0;
    for (HDSpriteNode *node in [[_nodeContainer reverseObjectEnumerator] allObjects]) {
        SKAction *delay   = [SKAction waitForDuration:delayInterval];
        [node runAction:[SKAction sequence:@[delay,scaleUp,scaleDo]]];
        delayInterval += .25f;
    }
    [ADelegate performSelector:@selector(presentLevelViewController)
                    withObject:nil
                    afterDelay:delayInterval + scaleDo.duration + scaleUp.duration];
}

#if 0
- (void)_performOutroAnimation {
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [ADelegate presentLevelViewController];
    }];
    
    NSTimeInterval delay = 0;
    for (HDHexagonButton *subView in _tiles) {
        
        CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        scale.values    = @[@1, @1.1, @0];
        scale.duration  = .3f;
        scale.beginTime = CACurrentMediaTime() + delay;
        scale.removedOnCompletion = NO;
        scale.fillMode  = kCAFillModeForwards;
        [subView.layer addAnimation:scale forKey:scale.keyPath];
        
        delay += .15f;
    }
    [CATransaction commit];
}
#endif

@end
