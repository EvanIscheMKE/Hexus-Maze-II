//
//  HDScene.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import AVFoundation;
@import AudioToolbox;

#import "HDScene.h"
#import "HDHelper.h"
#import "HDHexagon.h"
#import "SKColor+HDColor.h"
#import "HDSettingsManager.h"
#import "HDSoundManager.h"
#import "HDGameCenterManager.h"
#import "HDTileManager.h"
#import "SKEmitterNode+EmitterAdditions.h"
#import "NSMutableArray+UniqueAdditions.h"
#import "HDMapManager.h"
#import "HDHexagonNode.h"
#import "HDGridManager.h"
#import "HDAlertNode.h"

#define HEXAGON_TITLE(x) [NSString stringWithFormat:@"HEXAGON%ld",x]

#define kTileSize [[UIScreen mainScreen] bounds].size.width / (NumberOfColumns - 1)

NSString * const HDSoundActionKey = @"SOUND_KEY";

static const CGFloat kTileHeightInsetMultiplier = .845f;
@interface HDScene ()<HDHexagonDelegate, HDAlertnodeDelegate>
@property (nonatomic, strong) NSArray *sounds;
@property (nonatomic, strong) NSArray *hexagons;
@property (nonatomic, assign) BOOL restarting;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL includeEndTile;
@property (nonatomic, assign) BOOL animateTheNeglect;
@property (nonatomic, assign) BOOL countDownSoundIndex;
@property (nonatomic, strong) SKAction *completionZing;
@property (nonatomic, strong) SKNode *gameLayer;
@end

@implementation HDScene {
    CGFloat _minViewAreaOriginX;
    CGFloat _maxViewAreaOriginX;
    CGFloat _minViewAreaOriginY;
    CGFloat _maxViewAreaOriginY;
    CGFloat _minCenterX;
    CGFloat _maxCenterX;
    CGFloat _minCenterY;
    CGFloat _maxCenterY;
    NSInteger _soundIndex;
}

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        self.countDownSoundIndex = NO;
        self.backgroundColor = [SKColor flatWetAsphaltColor];

        self.sounds = [self _preloadedGameSounds];
        self.gameLayer = [SKNode node];
        [self addChild:self.gameLayer];
        
    }
    return self;
}

#pragma mark - Public

- (void)layoutNodesWithGrid:(NSArray *)grid
{
    [self _setup];

    NSInteger index = 0;
    for (HDHexagon *hexagon in grid) {
        
        CGPoint center = [[self class] _pointForColumn:hexagon.column row:hexagon.row];
        HDHexagonNode *hexagonNode = [[HDHexagonNode alloc] initWithImageNamed:hexagon.defaultImagePath];
        hexagonNode.hidden   = NO;
        hexagonNode.scale    = CGRectGetWidth(self.view.bounds)/375.0f;
        hexagonNode.position = center;
        hexagon.node = hexagonNode;
        hexagon.delegate = hexagon.isCountTile ? self : nil;
        [self.gameLayer addChild:hexagonNode];

        [self _updateVariablesForPositionFromPoint:center];
        if (hexagon.type == HDHexagonTypeEnd) {
            self.includeEndTile = YES;
        }
        index++;
    }
    
    self.hexagons = [NSMutableArray arrayWithArray:grid];
    
    // Once all Tiles are layed out, center them
    [self _centerTilePositionWithCompletion:^{
        self.animating = YES;
        [HDHelper entranceAnimationWithTiles:_hexagons completion:^{
            if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(gameWillResetInScene:)]) {
                [self.myDelegate gameWillResetInScene:self];
            }
            self.userInteractionEnabled = YES;
            self.animating = NO;
        }];
    }];
}

- (void)restart
{
    if (self.animating) {
        return;
    }
    
    self.animating = YES;
    
    // Display Achievement for losing level
    [[HDGameCenterManager sharedManager] submitAchievementWithIdenifier:@"lostGameAchievement"
                                                       completionBanner:YES
                                                        percentComplete:100];
    self.countDownSoundIndex = NO;
    
    // Return used starting tile count to ZERO
    _soundIndex = 0;
    
    // Clear out Arrays
    [[HDTileManager sharedManager] clear];
    
    // Animate out
    [HDHelper completionAnimationWithTiles:_hexagons completion:^{
        // Animate restart once restored
        for (HDHexagon *hexa in _hexagons) {
            hexa.node.scale   = ((kTileSize + 2.4f)/49.0f);
        }
        [HDHelper entranceAnimationWithTiles:_hexagons completion:^{
            self.animating = NO;
        }];
    }];
}

- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion
{
    [HDHelper completionAnimationWithTiles:_hexagons completion:completion];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch   = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // Find the node located under the touch
    HDHexagon *currentTile  = [self _findHexagonContainingPoint:location];
    HDHexagon *previousTile = [[HDTileManager sharedManager] lastHexagonObject];
    
    // If the newly selected node is connected to previously selected node.. prooccceeed
    if ([self _validateNextMoveToHexagon:currentTile fromHexagon:previousTile]) {
        [currentTile selectedAfterRecievingTouches];
        [[HDTileManager sharedManager] addHexagon:currentTile];
        [self _performEffectsForTile:currentTile];
        [self _checkGameStateForTile:currentTile];
        [self _playSoundForHexagon:currentTile withVibration:YES];
    }
}

#pragma mark - Private

- (void)_updateVariablesForPositionFromPoint:(CGPoint)center
{
    // Find the largest and smallest possible center position for all tiles
    if ((center.x) < _minCenterX) { _minCenterX = (center.x); }
    if ((center.x) > _maxCenterX) { _maxCenterX = (center.x); }
    if ((center.y) < _minCenterY) { _minCenterY = (center.y); }
    if ((center.y) > _maxCenterY) { _maxCenterY = (center.y); }
}

- (void)_setup
{
    // initalize varibles here instead of initWithSize, so when new levels laid out they're set to zero
    self.userInteractionEnabled = NO;
    
    _soundIndex  = 0;
    _minCenterX  = MAXFLOAT;
    _maxCenterX  = 0.0f;
    _minCenterY  = MAXFLOAT;
    _maxCenterY  = 0.0f;
}

- (void)_performEffectsForTile:(HDHexagon *)tile
{
    SKEmitterNode *emitter = [SKEmitterNode hexaEmitterWithColor:tile.emitterColor
                                                           scale:tile.selected ? 1.f : .5f];
    emitter.position = tile.node.position;
    [self insertChild:emitter atIndex:0];
    
    NSTimeInterval delayInSeconds = emitter.numParticlesToEmit / emitter.particleBirthRate +
    emitter.particleLifetime + emitter.particleLifetimeRange / 2;
    
    [emitter performSelector:@selector(removeFromParent) withObject:nil afterDelay:delayInSeconds];
}

- (NSArray *)_preloadedGameSounds
{
    //Preload any sounds that are going to be played throughout the game
    self.completionZing = [SKAction playSoundFileNamed:@"win.mp3" waitForCompletion:NO];
    
    NSMutableArray *sounds = [NSMutableArray array];
    
    NSArray *notes = @[@"C", @"D", @"E", @"F", @"G", @"A", @"B"];
    
    for (int i = 3; i < 7; i++) {
        for (NSString *note in notes) {
            NSString *filePath = [NSString stringWithFormat:@"%@%d.m4a",note,i];
            SKAction *sound = [SKAction playSoundFileNamed:filePath waitForCompletion:NO];
            [sounds addObject:sound];
        }
    }
    return sounds;
}

- (HDHexagon *)_findHexagonContainingPoint:(CGPoint)point
{
    const CGFloat smallHexagonInset = CGRectGetWidth([[[_hexagons firstObject] node] frame])/6;
    const CGFloat largeHexagonInset = 15.0f;
    HDHexagon *selectedHexagon = nil;
    for (HDHexagon *hex in _hexagons) {
        if (CGRectContainsPoint(CGRectInset(hex.node.frame, smallHexagonInset, smallHexagonInset), point)) {
            selectedHexagon = hex;
        }
    }
    
    if (selectedHexagon.type == HDHexagonTypeNone) {
        if (CGRectContainsPoint(CGRectInset(selectedHexagon.node.frame, largeHexagonInset, largeHexagonInset), point)) {
            [self _checkTileForRestart:selectedHexagon];
            return nil;
        }
    }
    
    return (selectedHexagon.isSelected || selectedHexagon.state == HDHexagonStateDisabled) ? nil : selectedHexagon;
}

- (void)_checkTileForRestart:(HDHexagon *)hexagon
{
    if (self.animating) {
        return;
    }
    
    self.animating = YES;
    
    SKAction *rotation = [SKAction rotateByAngle:M_PI*2 duration:0.3f];
    
    NSUInteger index = 0;
    if (hexagon.type == HDHexagonTypeNone) {
        for (HDHexagon *hexagon in self.hexagons) {
            if (hexagon.type == HDHexagonTypeNone) {
                
                [hexagon.node runAction:rotation];
                SKEmitterNode *emitter = [SKEmitterNode hexaEmitterWithColor:[SKColor flatAlizarinColor] scale:1.5f];
                emitter.position = hexagon.node.position;
                [self insertChild:emitter atIndex:0];
                
                NSTimeInterval delayInSeconds = emitter.numParticlesToEmit / emitter.particleBirthRate +
                emitter.particleLifetime + emitter.particleLifetimeRange / 2;
                [emitter performSelector:@selector(removeFromParent) withObject:nil afterDelay:delayInSeconds];
                
                index++;
            }
        }
        [self performSelector:@selector(setAnimating:) withObject:0   afterDelay:rotation.duration];
        [self performSelector:@selector(restart)       withObject:nil afterDelay:rotation.duration];
    }
}

- (void)_playSoundForHexagon:(HDHexagon *)hexagon withVibration:(BOOL)vibration
{
    [self runAction:[_sounds objectAtIndex:_soundIndex] withKey:HDSoundActionKey];
    
    if (_soundIndex == 0 || _soundIndex == _sounds.count - 1) {
        self.countDownSoundIndex = (_soundIndex != 0);
    }
    
    _soundIndex = self.countDownSoundIndex ? _soundIndex - 1 : _soundIndex + 1;
    
    if (hexagon.isCountTile || hexagon.type == HDHexagonTypeStarter||[self _inPlayTileCount] == 0) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

+ (CGPoint)_pointForColumn:(NSInteger)column row:(NSInteger)row
{
    const CGFloat kOriginY = ((row * (kTileSize * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = ((column * kTileSize));
    const CGFloat kAlternateOffset = (row % 2 == 0) ? kTileSize / 2 : 0.0f;
    
    return CGPointMake(kAlternateOffset + kOriginX, kOriginY);
}

- (void)_centerTilePositionWithCompletion:(dispatch_block_t)completion
{
    // Calculate the correct inset based on max and min cordinates |-20-[][][][][]-20-|
    _minViewAreaOriginX = ceilf((CGRectGetWidth(self.frame)  - (_maxCenterX - _minCenterX)) / 2);
    _minViewAreaOriginY = ceilf((CGRectGetHeight(self.frame) - (_maxCenterY - _minCenterY)) / 2);
    
    NSInteger index = 0;
    for (HDHexagon *hexagon in _hexagons) {
        
        // Offset tiles to center entire map (find the inset + or -, adjust accordingly)
        CGPoint center = hexagon.node.position;
        center.x += (floorf(_minCenterX) > _minViewAreaOriginX) ? -(_minCenterX - _minViewAreaOriginX) : _minViewAreaOriginX - _minCenterX;
        center.y += (floorf(_minCenterY) > _minViewAreaOriginY) ? -(_minCenterY - _minViewAreaOriginY) : _minViewAreaOriginY - _minCenterY;
        
        hexagon.node.defaultPosition = center;
        hexagon.node.position = center;
        
        index++;
    }
    if (completion) {
        completion();
    }
}

- (void)_displayEndOfGameMenu
{
    BOOL lastLevel = (_levelIndex == [[HDMapManager sharedManager] numberOfLevels]);
    
    HDAlertNode *alertNode = [[HDAlertNode alloc] initWithSize:self.frame.size lastLevel:lastLevel];
    alertNode.levelLabel.text = [NSString stringWithFormat:@"%zd", self.levelIndex];
    alertNode.delegate = self;
    alertNode.position = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
    [self addChild:alertNode];
    [alertNode show];
}

- (void)_checkGameStateForTile:(HDHexagon *)tile
{
    if ([self _inPlayTileCount] == 0) {
        
        [tile.node runAction:[SKAction rotateByAngle:M_PI*2 duration:.300f] completion:^{
                [self runAction:self.completionZing withKey:HDSoundActionKey];
        }];
        
        self.animating = YES;
    
        [self _displayEndOfGameMenu];
        [[HDMapManager sharedManager] completedLevelAtIndex:self.levelIndex-1];
        
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(scene:gameEndedWithCompletion:)]) {
            [self.myDelegate scene:self gameEndedWithCompletion:YES];
        }
        
        return;
    } else if (self._unlockLastTile) {
        for (HDHexagon *hexagon in _hexagons) {
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
    [tile.node runAction:[SKAction rotateByAngle:M_PI*2 duration:.300f] completion:nil];
}

- (BOOL)_unlockLastTile
{
    return [self _inPlayTileCount] == 1 && self.includeEndTile;
}

- (BOOL)isGameOverAfterPlacingTile:(HDHexagon *)hexagon
{
    NSUInteger startTileCount         = [self _startTileCount];
    NSUInteger selectedStartTileCount = [self _selectedStartTileCount];
    
    if (startTileCount != selectedStartTileCount) {
        return NO;
    }
    
    NSArray *remainingMoves = [HDHelper possibleMovesForHexagon:hexagon inArray:_hexagons];
    
    if (remainingMoves.count == 0) {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)_selectedStartTileCount
{
    NSUInteger count = 0;
    for (HDHexagon *hexa in _hexagons) {
        if (hexa.type == HDHexagonTypeStarter && hexa.selected) {
            count++;
        }
    }
    return count;
}

- (NSUInteger)_startTileCount
{
    NSUInteger count = 0;
    for (HDHexagon *hexa in _hexagons) {
        if (hexa.type == HDHexagonTypeStarter) {
            count++;
        }
    }
    return count;
}

- (NSUInteger)_inPlayTileCount
{
    NSUInteger count = 0;
    for (HDHexagon *hexaon in _hexagons) {
        if (!hexaon.selected) {
            count++;
        }
    }
    return count;
}

- (BOOL)_validateNextMoveToHexagon:(HDHexagon *)toHexagon fromHexagon:(HDHexagon *)fromHexagon
{
    NSParameterAssert(toHexagon);
    NSParameterAssert(fromHexagon);
    
    if ([[HDTileManager sharedManager] isEmpty] && toHexagon.type != HDHexagonTypeStarter) {
        return NO;
    }
    
    // Find possible moves from currently selected tile
    NSArray *possibleMoves = [HDHelper possibleMovesForHexagon:fromHexagon inArray:_hexagons];
    
    if ([possibleMoves containsObject:toHexagon] || toHexagon.type == HDHexagonTypeStarter) {
        
        //Clear lower indicator images to transparent
        for (HDHexagon *hexagon in _hexagons) {
            [hexagon.node indicatorPositionFromHexagonType:HDHexagonTypeNone];
        }
        
        // Find all possible moves for newly selected tile
        NSArray *possibleMovesFromNewlySelectedTile = [HDHelper possibleMovesForHexagon:toHexagon inArray:_hexagons];
        
        // Display "Possible Move" indicator on tiles found ^
        for (HDHexagon *hexagon in possibleMovesFromNewlySelectedTile) {
            [hexagon.node indicatorPositionFromHexagonType:hexagon.type withTouchesCount:hexagon.touchesCount];
        }
        return YES;
    }
    return NO;
}

- (void)_nextLevel
{
    self.levelIndex += 1;
    
    if (self.levelIndex > [[HDMapManager sharedManager] numberOfLevels]) {
        return;
    }
    
    // Clear out Arrays
    [[HDTileManager sharedManager] clear];
    
    // We want to start at 0 and count up when the new levels layed out
    self.countDownSoundIndex = NO;
    
    [HDHelper completionAnimationWithTiles:_hexagons completion:^{
        
        // Reduce Count
        [self.gameLayer removeAllChildren];
        // Call parent to refill model with next level's data, then call us back
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(scene:proceededToLevel:)]) {
            [self.myDelegate scene:self proceededToLevel:self.levelIndex];
        }
    }];
}

#pragma mark - <HDAlertNodeDelegate>

- (void)alertNodeWasSelected:(HDAlertNode *)alertNode;
{
    [self runAction:[SKAction playSoundFileNamed:HDButtonSound waitForCompletion:NO] withKey:HDSoundActionKey];
}

- (void)alertNode:(HDAlertNode *)alertNode clickedButtonWithTitle:(NSString *)title
{
    self.animating = NO;
    
    if ([title isEqualToString:HDRestartLevelKey]) {
        [self restart];
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(gameWillResetInScene:)]) {
            [self.myDelegate gameWillResetInScene:self]; }
    } else if ([title isEqualToString:HDNextLevelKey]) {
        [self _nextLevel];
    } else if ([title isEqualToString:HDShareKey]) {
        [ADelegate presentShareViewControllerWithLevelIndex:self.levelIndex];
    }  else if ([title isEqualToString:HDGCAchievementsKey]) {
        [ADelegate presentGameCenterControllerForState:GKGameCenterViewControllerStateAchievements];
    } else if ([title isEqualToString:HDGCLeaderboardKey]) {
        [ADelegate presentGameCenterControllerForState:GKGameCenterViewControllerStateLeaderboards];
    } else if ([title isEqualToString:HDRateKey]) {
        [ADelegate rateHEXUS];
    }
}

- (void)runAction:(SKAction *)action withKey:(NSString *)key
{
    // if key is equal to "HDSoundActionKey", check to make sure the sounds on and there's no background music playing
    if ([key isEqualToString:HDSoundActionKey]) {
        if (![[HDSettingsManager sharedManager] sound] || [HDSoundManager isOtherAudioPlaying]) {
            return;
        }
    }
    [super runAction:action withKey:key];
}

#pragma mark - <HDHexagonDelegate>

- (void)hexagon:(HDHexagon *)hexagon unlockedCountTile:(HDHexagonType)type
{
    if (!hexagon.isCountTile) {
        return;
    }
    
    // Find next disabled 'count' tile and unlock it
    for (HDHexagon *hexagon in _hexagons) {
        if (hexagon.type == type + 1 && !hexagon.selected) {
            hexagon.locked = NO;
            return;
        }
    }
}

@end
