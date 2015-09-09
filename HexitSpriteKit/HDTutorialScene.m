//
//  HDTutorialScene.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/18/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "HDHelper.h"
#import "HDTutorialScene.h"
#import "HDTileManager.h"
#import "HDMapManager.h"
#import "HDHexaNode.h"
#import "HDHexaObject.h"

@implementation HDTutorialScene

- (void)checkGameStateForTile:(HDHexaObject *)tile
{    
    SKAction *rotation = [SKAction rotateByAngle:(M_PI * 2) duration:.300f];
    [tile.node runAction:rotation completion:^{
        tile.node.zRotation = 0.0f;
    }];
    
    if ([self inPlayTileCount] == 0) {
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(scene:gameEndedWithCompletion:)]) {
            [self.myDelegate scene:self gameEndedWithCompletion:self.dismissAfterCompletion];
        }
    }
}

- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion
{
    [HDHelper completionAnimationWithTiles:self.hexaObjects completion:completion];
}

- (HDHexaObject *)findHexagonContainingPoint:(CGPoint)point
{
    const CGFloat inset = CGRectGetWidth([[[self.hexaObjects firstObject] node] frame])/6;
    for (HDHexaObject *tile in self.hexaObjects) {
        if (CGRectContainsPoint(CGRectInset(tile.node.frame, inset, inset), point)) {
            return tile;
        }
    }
    return nil;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch   = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    HDHexaObject *currentTile  = [self findHexagonContainingPoint:location];
    HDHexaObject *previousTile = [[HDTileManager sharedManager] lastHexagonObject];
    
    if (!currentTile.isSelected && currentTile.state != HDHexagonStateDisabled) {
        if ([self validateNextMoveToHexagon:currentTile fromHexagon:previousTile]) {
            [currentTile selectedAfterRecievingTouches];
            [[HDTileManager sharedManager] addHexagon:currentTile];
            [self checkGameStateForTile:currentTile];
            [self playSoundForHexagon:currentTile vibration:YES];
        }
    }
}

- (void)initialLayoutCompletion
{
    self.userInteractionEnabled = NO;
    [self centerTileGrid];
    [HDHelper entranceAnimationWithTiles:self.hexaObjects completion:^{
        self.userInteractionEnabled = YES;
        if (self.layoutCompletion) {
            self.layoutCompletion();
        }
    }];
}

- (void)updateDataForNextLevel
{
    self.countDownSoundIndex = NO;
    [self.gameLayer removeAllChildren];
    [[HDTileManager sharedManager] clear];
}

@end
