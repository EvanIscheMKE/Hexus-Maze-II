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
#import "HDHexagonNode.h"
#import "HDHexagon.h"

@implementation HDTutorialScene

- (void)checkGameStateForTile:(HDHexagon *)tile {
    
    if ([self inPlayTileCount] == 0) {
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(scene:gameEndedWithCompletion:)]) {
            [self.myDelegate scene:self gameEndedWithCompletion:self.partyAtTheEnd];
        }
    }
    
    [tile.node removeAllActions];
    
    self.animating = YES;
    
    const CGFloat currentScale = tile.node.xScale;
    
    SKAction *rotation  = [SKAction rotateByAngle:M_PI*2
                                        duration:.300f];
    
    SKAction *scaleDown = [SKAction scaleTo:currentScale - .1f
                                   duration:rotation.duration/2];
    
    SKAction *scaleUp   = [SKAction scaleTo:currentScale
                                   duration:rotation.duration/2];
    
    SKAction *sequence  = [SKAction sequence:@[scaleDown, scaleUp]];
    
    [tile.node runAction:[SKAction group:@[rotation, sequence]]
              completion:^{
        self.animating = NO;
    }];
}

- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HDHelper completionAnimationWithTiles:self.hexagons
                                    completion:completion];
    });
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch   = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // Find the node located under the touch
    HDHexagon *currentTile  = [self findHexagonContainingPoint:location];
    HDHexagon *previousTile = [[HDTileManager sharedManager] lastHexagonObject];
    
    // If the newly selected node is connected to previously selected node.. prooccceeed
    if (!currentTile.isSelected && currentTile.state != HDHexagonStateDisabled && currentTile) {
        if ([self validateNextMoveToHexagon:currentTile fromHexagon:previousTile]) {
            
            if (currentTile.type == HDHexagonTypeStarter) {
                if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(startTileWasSelectedInScene:)]) {
                   [self.myDelegate startTileWasSelectedInScene:self];
                }
            }
            
            [currentTile selectedAfterRecievingTouches];
            [[HDTileManager sharedManager] addHexagon:currentTile];
            [self checkGameStateForTile:currentTile];
            [self playSoundForHexagon:currentTile vibration:YES];
        }
    }
}

- (void)initialSetupCompletion {
    // Once all Tiles are layed out, center them
    [self centerTilePositionWithCompletion:^{
        self.userInteractionEnabled = NO;
        [HDHelper entranceAnimationWithTiles:self.hexagons completion:^{
            self.userInteractionEnabled = YES;
            if (self.layoutCompletion) {
                self.layoutCompletion();
            }
        }];
    }];
}

- (void)nextLevel {
    self.countDownSoundIndex = NO;
    [self.gameLayer removeAllChildren];
    [[HDTileManager sharedManager] clear];
}


@end
