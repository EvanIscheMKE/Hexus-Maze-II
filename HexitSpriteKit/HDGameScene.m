//
//  HDGameScene.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/17/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHexaNode.h"
#import "HDMapManager.h"
#import "HDHexaObject.h"
#import "HDHelper.h"
#import "HDGameScene.h"
#import "HDTileManager.h"
#import "HDGameCenterManager.h"
#import "SKColor+ColorAdditions.h"
#import "SKEmitterNode+EmitterAdditions.h"

@implementation HDGameScene

- (void)restartWithAlert:(NSNumber *)alert {
    
    if (self.animating) {
        return;
    }
    
    self.userInteractionEnabled = NO;
    self.animating = YES;
    self.mines = nil;
    self.countDownSoundIndex = NO;
    self.soundIndex = 0;
    
    [self.gameLayer.children makeObjectsPerformSelector:@selector(setHidden:) withObject:0];
    [[HDGameCenterManager sharedManager] submitAchievementWithIdenifier:HDFailureKey
                                                       completionBanner:YES
                                                        percentComplete:completion];
    
    [[HDTileManager sharedManager] clear];
    [HDHelper completionAnimationWithTiles:self.hexaObjects completion:^{
        for (HDHexaObject *hexa in self.hexaObjects) {
            hexa.node.scale = IS_IPAD ? 1.0f :TRANSFORM_SCALE_X;
        }
        [HDHelper entranceAnimationWithTiles:self.hexaObjects completion:^{
            self.animating = NO;
            self.userInteractionEnabled = YES;
        }];
    }];
    
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(gameRestartedInScene:alert:)]) {
        [self.myDelegate gameRestartedInScene:self alert:[alert boolValue]];
    }
}

- (void)updateDataForNextLevel {
    
    self.levelIndex += 1;
    if (self.levelIndex > [[HDMapManager sharedManager] numberOfLevels]) {
        return;
    }
    
    self.countDownSoundIndex = NO;
    
    [[HDTileManager sharedManager] clear];
    [HDHelper completionAnimationWithTiles:self.hexaObjects completion:^{
        [self.gameLayer removeAllChildren];
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(scene:proceededToLevel:)]) {
            [self.myDelegate scene:self proceededToLevel:self.levelIndex];
        }
    }];
}

- (void)checkGameStateForTile:(HDHexaObject *)tile {
    
    if ([self inPlayTileCount] == 0) {
        self.userInteractionEnabled = NO;
        [[HDMapManager sharedManager] completedLevelAtIndex:self.levelIndex-1];
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(scene:gameEndedWithCompletion:)]) {
            [self.myDelegate scene:self gameEndedWithCompletion:YES];
        }
    } else if (self.unlockLastTile) {
        for (HDHexaObject *hexagon in self.hexaObjects) {
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
    SKAction *rotation = [SKAction rotateByAngle:(M_PI * 2) duration:.300f];
    [tile.node runAction:rotation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!self.userInteractionEnabled) {
        return;
    }
    
    UITouch *touch   = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    HDHexaObject *currentTile  = [self findHexagonContainingPoint:location];
    HDHexaObject *previousTile = [[HDTileManager sharedManager] lastHexagonObject];
    
    if (currentTile.type == HDHexagonTypeStarter && previousTile == nil) {
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(startTileWasSelectedInScene:)]) {
            [self.myDelegate startTileWasSelectedInScene:self];
        }
    }
    
    if (!currentTile.isSelected && currentTile.state != HDHexagonStateDisabled && currentTile) {
        if ([self validateNextMoveToHexagon:currentTile fromHexagon:previousTile]) {
            [currentTile selectedAfterRecievingTouches];
            [[HDTileManager sharedManager] addHexagon:currentTile];
            [self checkGameStateForTile:currentTile];
            [self playSoundForHexagon:currentTile vibration:YES];
        }
    }
}

- (void)initialLayoutCompletion {
    
    self.animating = YES;
    
    [self centerTileGrid];
    [HDHelper entranceAnimationWithTiles:self.hexaObjects completion:^{
        self.animating = NO;
        self.userInteractionEnabled = YES;
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(gameWillResetInScene:)]) {
            [self.myDelegate gameWillResetInScene:self];
        }
    }];
}

#pragma mark - <HDHexagonDelegate>

- (void)hexagon:(HDHexaObject *)hexagon unlockedCountTile:(HDHexagonType)type {
    
    if (!hexagon.isCountTile) {
        return;
    }
    
    for (HDHexaObject *obj in self.hexaObjects) {
        if ((obj.type == type + 1) && !obj.selected) {
            
            obj.locked = NO;
            SKAction *rotation = [SKAction rotateByAngle:M_PI*2 duration:.400f];
            SKAction *scaleUp = [SKAction scaleTo:1.4f duration:.175f];
            SKAction *scaleDo = [SKAction scaleTo:1.0f duration:.300f];
            SKAction *sequence = [SKAction sequence:@[scaleUp, scaleDo]];
            SKAction *groupAnimation = [SKAction group:@[sequence,rotation]];
            [obj.node runAction:groupAnimation];
            return;
        }
    }
}


@end
