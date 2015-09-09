//
//  HDGameScene.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/17/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import AVFoundation;

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
{
    HDHexaObject *_currentObj;
}

- (void)restartWithAlert:(NSNumber *)alert
{
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

- (HDHexaObject *)findHexagonContainingPoint:(CGPoint)point
{
    const CGFloat inset = CGRectGetWidth([[[self.hexaObjects firstObject] node] frame])/6;
    for (HDHexaObject *tile in self.hexaObjects) {
        if (CGRectContainsPoint(CGRectInset(tile.node.frame, inset, inset), point)) {
            if (tile.type == HDHexagonTypeNone) {
                if (CGRectContainsPoint(CGRectInset(tile.node.frame, inset + 2.0f, inset + 2.0f), point)) {
                    [self _mineTileWasSelected:tile];
                    return nil;
                }
            }
            return tile;
        }
    }
    return nil;
}

- (void)updateDataForNextLevel
{
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

- (BOOL)unlockFinalNode
{
    BOOL includeEndTile = false;
    for (HDHexaObject *object in self.hexaObjects) {
        if (object.type == HDHexagonTypeEnd) {
            includeEndTile = true;
        }
    }
    return ([self inPlayTileCount] == 1 && includeEndTile);
}

- (void)checkGameStateForTile:(HDHexaObject *)tile
{
    if (self.inPlayTileCount == 0) {
        self.userInteractionEnabled = NO;
        [[HDMapManager sharedManager] completedLevelAtIndex:self.levelIndex-1];
        // GameCenter.reportLevel(index;)
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(scene:gameEndedWithCompletion:)]) {
            [self.myDelegate scene:self gameEndedWithCompletion:YES];
        }
    } else if (self.unlockFinalNode) {
        for (HDHexaObject *hexagon in self.hexaObjects) {
            if (hexagon.type == HDHexagonTypeEnd) {
                hexagon.state = HDHexagonStateEnabled;
                break;
            }
        }
        [self displayPossibleMovesFromHexaObject:_currentObj];
    } else if ([self isGameOverAfterPlacingTile:tile]) {
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(scene:gameEndedWithCompletion:)]) {
            [self.myDelegate scene:self gameEndedWithCompletion:NO];
        }
    }
    SKAction *rotation = [SKAction rotateByAngle:(M_PI * 2) duration:.300f];
    [tile.node runAction:rotation];
}

- (BOOL)isGameOverAfterPlacingTile:(HDHexaObject *)hexagon
{
    NSUInteger startTileCount         = [self _startTileCount];
    NSUInteger selectedStartTileCount = [self _selectedStartTileCount];
    
    if (startTileCount != selectedStartTileCount) {
        return NO;
    }
    
    NSArray *remainingMoves = [HDHelper possibleMovesForHexagon:hexagon inArray:self.hexaObjects];
    if (remainingMoves.count == 0) {
        return YES;
    }
    
    return NO;
}

- (void)minesFromHexaObject:(HDHexaObject *)obj
{
    if (!self.mines) {
        self.mines = [NSMutableArray arrayWithObject:obj];
    }
    
    NSArray *possibleMinesConnectedToSelectedMine = [HDHelper possibleMovesFromMine:obj containedIn:self.hexaObjects];
    for (HDHexaObject *hex in possibleMinesConnectedToSelectedMine) {
        if (![self.mines containsObject:hex]) {
            [self.mines addObject:hex];
            [self minesFromHexaObject:hex];
        }
    }
}

- (void)_mineTileWasSelected:(HDHexaObject *)hexaObj
{
    if (!self.userInteractionEnabled || [self inPlayTileCount] == 0) {
        return;
    }
    
    self.userInteractionEnabled = NO;
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    [self minesFromHexaObject:hexaObj];
    
    NSTimeInterval delay = 0.0f;
    
    __block SKEmitterNode *explosion;
    __block NSTimeInterval particleDurationInSeconds = 0.0f;
    for (HDHexaObject *mine in self.mines) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            mine.node.hidden = YES;
            
            explosion = [SKEmitterNode explosionNode];
            explosion.position = mine.node.position;
            [self.gameLayer addChild:explosion];
            [self runAction:self.explosion withKey:HDSoundActionKey];
            
            if (particleDurationInSeconds == 0.0f) {
                particleDurationInSeconds = explosion.numParticlesToEmit / explosion.particleBirthRate + explosion.particleLifetime;
                [self performSelector:@selector(restartWithAlert:)
                           withObject:@(YES)
                           afterDelay:particleDurationInSeconds/2.f + .1f * self.mines.count];
            }
        });
        delay += .1f;
    }
}

- (NSUInteger)_selectedStartTileCount
{
    NSUInteger count = 0;
    for (HDHexaObject *obj in self.hexaObjects) {
        if (obj.type == HDHexagonTypeStarter && obj.selected) {
            count++;
        }
    }
    return count;
}

- (NSUInteger)_startTileCount
{
    NSUInteger count = 0;
    for (HDHexaObject *obj in self.hexaObjects) {
        if (obj.type == HDHexagonTypeStarter) {
            count++;
        }
    }
    return count;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.userInteractionEnabled) {
        return;
    }
    
    UITouch *touch   = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    HDHexaObject *currentObj  = [self findHexagonContainingPoint:location];
    HDHexaObject *previousObj = [[HDTileManager sharedManager] lastHexagonObject];
    
    if (currentObj.type == HDHexagonTypeStarter && previousObj == nil) {
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(startTileWasSelectedInScene:)]) {
            [self.myDelegate startTileWasSelectedInScene:self];
        }
    }
    
    if (!currentObj.isSelected && currentObj.state != HDHexagonStateDisabled && currentObj) {
        if ([self validateNextMoveToHexagon:currentObj fromHexagon:previousObj]) {
            _currentObj = currentObj;
            [currentObj selectedAfterRecievingTouches];
            [[HDTileManager sharedManager] addHexagon:currentObj];
            [self checkGameStateForTile:currentObj];
            [self playSoundForHexagon:currentObj vibration:YES];
        }
    }
}

- (void)initialLayoutCompletion
{
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

- (void)hexagon:(HDHexaObject *)hexagon unlockedCountTile:(HDHexagonType)type
{    
    if (!hexagon.isCountTile) {
        return;
    }
    
    for (HDHexaObject *obj in self.hexaObjects) {
        if ((obj.type == type + 1) && !obj.selected) {
            
            obj.locked = NO;
            obj.state = HDHexagonStateEnabled;
            [obj.node removeFromParent];
            [self.gameLayer addChild:obj.node];
            
            const CGFloat currentScale = obj.node.xScale;
            SKAction *rotation = [SKAction rotateByAngle:M_PI*2 duration:.400f];
            SKAction *scaleUp = [SKAction scaleTo:currentScale + .4f duration:.175f];
            SKAction *scaleDo = [SKAction scaleTo:currentScale duration:.300f];
            SKAction *sequence = [SKAction sequence:@[scaleUp, scaleDo]];
            SKAction *groupAnimation = [SKAction group:@[sequence,rotation]];
            [obj.node runAction:groupAnimation];
            
            break;
        }
    }
    [self displayPossibleMovesFromHexaObject:_currentObj];
}

@end
