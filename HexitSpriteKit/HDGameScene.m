//
//  HDGameScene.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/17/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHexagonNode.h"
#import "HDMapManager.h"
#import "HDHexagon.h"
#import "HDHelper.h"
#import "HDGameScene.h"
#import "HDTileManager.h"
#import "HDGameCenterManager.h"

NSString * const HDLostGameKey = @"lostGameAchievement";
@interface HDGameScene ()

@end

@implementation HDGameScene

- (void)restartWithAlert:(BOOL)alert {
    
    if (self.animating) {
        return;
    }
    
    self.animating = YES;
    
    // Display End of game Alert Notification
    if (self.myDelegate && [self.myDelegate  respondsToSelector:@selector(gameRestartedInScene:alert:)]) {
        [self.myDelegate gameRestartedInScene:self alert:alert];
    }

    // Display Achievement for losing level
    [[HDGameCenterManager sharedManager] submitAchievementWithIdenifier:HDLostGameKey
                                                       completionBanner:YES
                                                        percentComplete:100];
    self.countDownSoundIndex = NO;
    
    // Return used starting tile count to ZERO
    self.soundIndex = 0;
    
    // Clear out Arrays
    [[HDTileManager sharedManager] clear];
    
    // Animate out
    [HDHelper completionAnimationWithTiles:self.hexagons completion:^{
        // Animate restart once restored
        for (HDHexagon *hexa in self.hexagons) {
            hexa.node.scale = TRANSFORM_SCALE;
        }
        [HDHelper entranceAnimationWithTiles:self.hexagons completion:^{
            self.animating = NO;
            self.userInteractionEnabled = YES;
        }];
    }];
}

- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion {
    self.space.particleBirthRate = 0;
    [super performExitAnimationsWithCompletion:completion];
}

- (void)nextLevel
{
    self.levelIndex += 1;
    
    if (self.levelIndex > [[HDMapManager sharedManager] numberOfLevels]) {
        return;
    }
    
    // Clear out Arrays
    [[HDTileManager sharedManager] clear];
    
    // We want to start at 0 and count up when the new levels layed out
    self.countDownSoundIndex = NO;
    
    [HDHelper completionAnimationWithTiles:self.hexagons completion:^{
        
        // Reduce Count
        [self.gameLayer removeAllChildren];
        // Call parent to refill model with next level's data, then call us back
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(scene:proceededToLevel:)]) {
            [self.myDelegate scene:self proceededToLevel:self.levelIndex];
        }
    }];
}

- (void)checkGameStateForTile:(HDHexagon *)tile {
    
    if ([self inPlayTileCount] == 0) {
        
        [self startConfettiEmitter];
        [[HDMapManager sharedManager] completedLevelAtIndex:self.levelIndex-1];
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(scene:gameEndedWithCompletion:)]) {
            [self.myDelegate scene:self gameEndedWithCompletion:YES];
        } return;
        
    } else if (self.unlockLastTile) {
        
        for (HDHexagon *hexagon in self.hexagons) {
            if (hexagon.type == HDHexagonTypeEnd) {
                hexagon.state = HDHexagonStateEnabled;
                break;
            }
        }
        
    } else if ([self isGameOverAfterPlacingTile:tile]) {
        
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(scene:gameEndedWithCompletion:)]) {
            [self.myDelegate scene:self gameEndedWithCompletion:NO];
        }
    }
    
    SKAction *rotation = [SKAction rotateByAngle:M_PI*2 duration:.300f];
    SKAction *scaleD   = [SKAction scaleTo:.97f duration:.150f];
    SKAction *scaleU   = [SKAction scaleTo:1.0f duration:.150f];
    
    [tile.node runAction:[SKAction group:@[rotation, [SKAction sequence:@[scaleD, scaleU]]]]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch   = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // Find the node located under the touch
    HDHexagon *currentTile  = [self findHexagonContainingPoint:location];
    HDHexagon *previousTile = [[HDTileManager sharedManager] lastHexagonObject];
    
    if (currentTile.type == HDHexagonTypeStarter && previousTile == nil) {
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(startTileWasSelectedInScene:)]) {
            [self.myDelegate startTileWasSelectedInScene:self];
        }
    }
    
    // If the newly selected node is connected to previously selected node.. prooccceeed
    if (!currentTile.isSelected && currentTile.state != HDHexagonStateDisabled && currentTile) {
        if ([self validateNextMoveToHexagon:currentTile fromHexagon:previousTile]) {
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
        self.animating = YES;
        [HDHelper entranceAnimationWithTiles:self.hexagons completion:^{
            if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(gameWillResetInScene:)]) {
                [self.myDelegate gameWillResetInScene:self];
            }
            
            self.userInteractionEnabled = YES;
            self.animating = NO;
        }];
    }];
}

#pragma mark - <HDHexagonDelegate>

- (void)hexagon:(HDHexagon *)hexagon unlockedCountTile:(HDHexagonType)type
{
    if (!hexagon.isCountTile) {
        return;
    }
    
    // Find next disabled 'count' tile and unlock it
    for (HDHexagon *hexagon in self.hexagons) {
        if (hexagon.type == type + 1 && !hexagon.selected) {
            hexagon.locked = NO;
            return;
        }
    }
}


@end
