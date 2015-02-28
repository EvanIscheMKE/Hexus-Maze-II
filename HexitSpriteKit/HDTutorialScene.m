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
        //[self startConfettiEmitter];
        [[HDMapManager sharedManager] completedLevelAtIndex:self.levelIndex-1];
        
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(scene:gameEndedWithCompletion:)]) {
            [self.myDelegate scene:self gameEndedWithCompletion:self.partyAtTheEnd];
        }
    }
    [tile.node runAction:[SKAction rotateByAngle:M_PI*2 duration:.300f] completion:nil];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch   = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // Find the node located under the touch
    HDHexagon *currentTile  = [self findHexagonContainingPoint:location];
    HDHexagon *previousTile = [[HDTileManager sharedManager] lastHexagonObject];
    
    // If the newly selected node is connected to previously selected node.. prooccceeed
    if (!currentTile.isSelected && currentTile.state != HDHexagonStateDisabled && currentTile) {
        if ([self validateNextMoveToHexagon:currentTile fromHexagon:previousTile]) {
            
            if (currentTile.type == HDHexagonTypeStarter) {
                [self.myDelegate startTileWasSelectedInScene:self];
            }
            
            [currentTile selectedAfterRecievingTouches];
            [[HDTileManager sharedManager] addHexagon:currentTile];
            [self performEffectsForTile:currentTile];
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

- (void)nextLevel
{
    // Clear out Arrays
    [[HDTileManager sharedManager] clear];
    
    // We want to start at 0 and count up when the new levels layed out
    self.countDownSoundIndex = NO;
    
    [self.gameLayer removeAllChildren];
}


@end
