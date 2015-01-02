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
#import "SKEmitterNode+EmitterAdditions.h"
#import "NSMutableArray+UniqueAdditions.h"
#import "HDMapManager.h"
#import "HDHexagonNode.h"
#import "HDGridManager.h"
#import "HDAlertNode.h"

#define HEXAGON_TITLE(x) [NSString stringWithFormat:@"HEXAGON%ld",x]

#define kTileSize [[UIScreen mainScreen] bounds].size.width / (NumberOfColumns - 1)

NSString * const HDSoundActionKey = @"SOUND_KEY";

static const CGFloat kPadding = 2.0f;
static const CGFloat kTileHeightInsetMultiplier = .845f;
@interface HDScene ()<HDHexagonDelegate, HDAlertnodeDelegate>

@property (nonatomic, strong) NSArray *sounds;
@property (nonatomic, strong) NSArray *hexagons;
@property (nonatomic, strong) NSMutableArray *selectedHexagons;

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL includeEndTile;
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
        
        _selectedHexagons = [NSMutableArray array];
        
        _sounds = [self _preloadedGameSounds];
        
        self.gameLayer = [SKNode node];
        [self addChild:self.gameLayer];
        
    }
    return self;
}

- (void)layoutNodesWithGrid:(NSArray *)grid
{
    [self _setup];
    
    self.userInteractionEnabled = NO;
    
    _hexagons = [NSArray arrayWithArray:grid];
    
    CGPathRef pathRef = [HDHelper hexagonPathForBounds:CGRectMake(0.0f, 0.0f, kTileSize - kPadding, kTileSize - kPadding)];
    
    NSInteger index = 0;
    for (HDHexagon *hexagon in grid) {
        
        // For each each hexagon model, create a shapenode and assign it to the model
        CGPoint center = [self _pointForColumn:hexagon.column row:hexagon.row];
        HDHexagonNode *shapeNode = [HDHexagonNode shapeNodeWithPath:pathRef centered:YES];
        shapeNode.hidden   = YES;
        shapeNode.position = center;
        shapeNode.name     = HEXAGON_TITLE((long)index);
        [self.gameLayer addChild:shapeNode];
        
        hexagon.node = shapeNode;
        hexagon.type = (int)[self.gridManager hexagonTypeAtRow:hexagon.row column:hexagon.column];
        hexagon.delegate = hexagon.isCountTile ? self : nil;
        
        // Find the largest and smallest possible center position for all tiles, will be used to center map
        if ((center.x) < _minCenterX) { _minCenterX = (center.x); }
        if ((center.x) > _maxCenterX) { _maxCenterX = (center.x); }
        if ((center.y) < _minCenterY) { _minCenterY = (center.y); }
        if ((center.y) > _maxCenterY) { _maxCenterY = (center.y); }
        
        if (hexagon.type == HDHexagonTypeEnd) {
            self.includeEndTile = YES;
        }
        index++;
    }
    
    // Once all Tiles are layed out, center them
    [self _centerTilePositionWithCompletion:^{
        self.animating = YES;
        [HDHelper entranceAnimationWithTiles:_hexagons completion:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(gameWillResetInScene:)]) {
                [self.delegate gameWillResetInScene:self];
            }
            self.userInteractionEnabled = YES;
            self.animating = NO;
        }];
    }];
}

- (void)_setup
{
    // initalize varibles here instead of initWithSize, so when new levels laid out they're set to zero
    _soundIndex  = 0;
    _minCenterX  = MAXFLOAT;
    _maxCenterX  = 0.0f;
    _minCenterY  = MAXFLOAT;
    _maxCenterY  = 0.0f;
}

#pragma mark - UIResponder

- (HDHexagon *)findHexagonContainingPoint:(CGPoint)point
{
    const CGFloat kHexagonInset = 2.0f;
    HDHexagon *selectedHexagon = nil;
    for (HDHexagon *hex in _hexagons)
    {
        if (CGRectContainsPoint(CGRectInset(hex.node.frame, kHexagonInset, kHexagonInset), point))
        {
            selectedHexagon = hex;
        }
    }
    return (selectedHexagon.isSelected || selectedHexagon.state == HDHexagonStateDisabled) ? nil : selectedHexagon;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch   = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // Find the node located under the touch
    HDHexagon *hexagon = [self findHexagonContainingPoint:location];
    
    HDHexagon *previousTile = [_selectedHexagons lastObject];
    
    // If the newly selected node is connected to previously selected node.. prooccceeed
    if ([self _validateNextMoveToHexagon:hexagon fromHexagon:previousTile]) {
        
        [_selectedHexagons addObject:hexagon];
        
        if ([hexagon selectedAfterRecievingTouches]){
            if (self.delegate && [self.delegate respondsToSelector:@selector(scene:updatedSelectedTileCount:)]){
                [self.delegate scene:self updatedSelectedTileCount:_hexagons.count - [self _inPlayTileCount]];
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(multipleTouchTileWasTouchedInScene:)]){
                [self.delegate multipleTouchTileWasTouchedInScene:self];
            }
        }
        
        // Check if FX are on before adding emitter effects
        if ([[HDSettingsManager sharedManager] fx]) {
            [hexagon.node addChild:[SKEmitterNode hexaEmitterWithColor:hexagon.node.strokeColor scale:hexagon.selected ? .9f : .5f]];
        }
        
        [self _checkGameStateForTile:hexagon];
        [self _playSoundForHexagon:hexagon withVibration:YES];
    }
}

#pragma mark - Private

- (void)_playSoundForHexagon:(HDHexagon *)hexagon withVibration:(BOOL)vibration
{
    [self runAction:[_sounds objectAtIndex:_soundIndex] withKey:HDSoundActionKey];
    
    if (_soundIndex == 0 || _soundIndex == _sounds.count - 1) {
        self.countDownSoundIndex = _soundIndex == 0 ? NO : YES;
    }
    
    _soundIndex = self.countDownSoundIndex ? _soundIndex - 1 : _soundIndex + 1;
    
    if (vibration && [[HDSettingsManager sharedManager] vibe]) {
        if (hexagon.isCountTile || hexagon.type == HDHexagonTypeStarter||[self _inPlayTileCount] == 0) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}

- (CGPoint)_pointForColumn:(NSInteger)column row:(NSInteger)row
{
    const CGFloat kOriginY = ((row * (kTileSize * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = ((column * kTileSize));
    const CGFloat kAlternateOffset = (row % 2 == 0) ? kTileSize/2 : 0.0f;
    
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

- (void)_checkGameStateForTile:(HDHexagon *)tile
{
    if ([self _inPlayTileCount] == 0) {
        // Won Game
        
        self.animating = YES;
        
        [self runAction:self.completionZing withKey:HDSoundActionKey];
        [tile.node runAction:[SKAction scaleTo:.9f duration:.1f] completion:^{
            [tile.node runAction:[SKAction scaleTo:1.0f duration:.1f] completion:^{
                
                
                BOOL lastLevel = (_levelIndex == [[HDMapManager sharedManager] numberOfLevels]);
                HDAlertNode *alertNode = [[HDAlertNode alloc] initWithColor:[UIColor clearColor]
                                                                       size:self.frame.size
                                                                  lastLevel:lastLevel];
                
                alertNode.levelLabel.text = [NSString stringWithFormat:@"Level %ld", _levelIndex];
                alertNode.delegate = self;
                alertNode.position = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
                [self addChild:alertNode];
                [alertNode show];
                
            }];
        }];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(scene:gameEndedWithCompletion:)]) {
            [self.delegate scene:self gameEndedWithCompletion:YES];
        }
        
        [[HDMapManager sharedManager] completedLevelAtIndex:self.levelIndex-1];
        
        return;
        
    } else if ([self _inPlayTileCount] == 1 && self.includeEndTile) {
        
        for (HDHexagon *hexagon in _hexagons) {
            if (hexagon.type == HDHexagonTypeEnd) {
                hexagon.state = HDHexagonStateEnabled;
                break;
            }
        }
        
    } else if ([self isGameOverAfterPlacingTile:tile]) {
        // Lost Game
        if (self.delegate && [self.delegate respondsToSelector:@selector(scene:gameEndedWithCompletion:)]) {
            [self.delegate scene:self gameEndedWithCompletion:NO];
        }
    }
    [tile.node runAction:[SKAction scaleTo:.9f duration:.1f] completion:^{
        [tile.node runAction:[SKAction scaleTo:1.0f duration:.1f]];
    }];
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
    if ( toHexagon.node == nil || (( ![_selectedHexagons count] ) && toHexagon.type != HDHexagonTypeStarter ))
    return NO;
    
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
    [_selectedHexagons removeAllObjects];
    
    // We want to start at 0 and count up when the new levels layed out
    self.countDownSoundIndex = NO;
    
    [HDHelper completionAnimationWithTiles:_hexagons completion:^{
        // Reduce retainCount
        [self.gameLayer removeAllChildren];
        
        // Call parent to refill model with next level's data, then call us back
        if (self.delegate && [self.delegate respondsToSelector:@selector(scene:proceededToLevel:)]) {
            [self.delegate scene:self proceededToLevel:self.levelIndex];
        }
    }];
}

#pragma mark - Restart

- (void)restart
{
    if (self.animating) {
        return;
    }
    
    self.animating = YES;
    
    self.countDownSoundIndex = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scene:updatedSelectedTileCount:)]) {
        [self.delegate scene:self updatedSelectedTileCount:0];
    }
    
    // Return used starting tile count to ZERO
    _soundIndex = 0;
    
    // Clear out Arrays
    [_selectedHexagons removeAllObjects];

    // Animate out
    [HDHelper completionAnimationWithTiles:_hexagons completion:^{
        // Animate restart once restored
        [HDHelper entranceAnimationWithTiles:_hexagons completion:^{
            self.animating = NO;
        }];
    }];
}

- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion
{
    // Animate out
    [HDHelper completionAnimationWithTiles:_hexagons completion:completion];
}

#pragma mark - <HDAlertNodeDelegate>

- (void)alertNode:(HDAlertNode *)alertNode clickedButtonWithTitle:(NSString *)title
{
    self.animating = NO;
    
    if ([title isEqualToString:HDRestartLevelKey]) {
        [self restart];
        if (self.delegate && [self.delegate respondsToSelector:@selector(gameWillResetInScene:)]) {
            [self.delegate gameWillResetInScene:self]; }
    } else if ([title isEqualToString:HDNextLevelKey]) {
        [self _nextLevel];
    } else if ([title isEqualToString:HDShareKey]) {
        [ADelegate presentShareViewControllerWithLevelIndex:self.levelIndex];
    } else if ([title isEqualToString:HDGCAchievementsKey]) {
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

#pragma mark -
#pragma mark - <HDHexagonDelegate>

- (void)hexagon:(HDHexagon *)hexagon unlockedCountTile:(HDHexagonType)type
{
    // Find next disabled 'count' tile and unlock it
    for (HDHexagon *hexagon in _hexagons) {
        if (hexagon.type == type + 1 && !hexagon.selected && hexagon.isCountTile) {
            hexagon.locked = NO;
            return;
        }
    }
}

- (NSArray *)_preloadedGameSounds
{
    //Preload any sounds that are going to be played throughout the game
    self.completionZing = [SKAction playSoundFileNamed:@"win.mp3" waitForCompletion:YES];
    
    NSMutableArray *sounds = [NSMutableArray array];
    
    NSArray *notes = @[@"C", @"D", @"E", @"F", @"G", @"A", @"B"];
    
    for (int i = 3; i < 7; i++) {
        for (NSString *note in notes) {
            NSString *filePath = [NSString stringWithFormat:@"%@%d.m4a",note,i];
            [sounds addObject:[SKAction playSoundFileNamed:filePath waitForCompletion:YES]];
        }
    }
    return sounds;
}

@end
