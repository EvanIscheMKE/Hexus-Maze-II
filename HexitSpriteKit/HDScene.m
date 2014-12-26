//
//  HDScene.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import AVFoundation;
@import AudioToolbox;

#import "HDRestartNode.h"
#import "HDScene.h"
#import "HDHelper.h"
#import "HDHexagon.h"
#import "SKColor+HDColor.h"
#import "HDSpriteNode.h"
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

@property (nonatomic, strong) SKAction *loop;
@property (nonatomic, strong) SKAction *completionZing;

@property (nonatomic, strong) SKNode *gameLayer;
@property (nonatomic, strong) SKNode *tileLayer;

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
        self.backgroundColor = [SKColor flatMidnightBlueColor];
        
        _selectedHexagons = [NSMutableArray array];
        
        _sounds = [self _preloadedGameSounds];
        
        self.tileLayer = [SKNode node];
        [self addChild:self.tileLayer];
        
        self.gameLayer = [SKNode node];
        [self addChild:self.gameLayer];
        
    }
    return self;
}

- (void)layoutNodesWithGrid:(NSArray *)grid
{
    [self _setup];
    
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
        [HDHelper entranceAnimationWithTiles:[[_hexagons mutableCopy] shuffle] completion:^{
            self.animating = NO;
        }];
    }];
}

- (void)_setup
{
    // initalize varibles here instead of initWithSize, so when new levels laid out they're set to zero
    _soundIndex        = 0;
    _minCenterX        = MAXFLOAT;
    _maxCenterX        = 0.0f;
    _minCenterY        = MAXFLOAT;
    _maxCenterY        = 0.0f;
}

- (void)layoutIndicatorTiles
{
    // Loop through possible nodes, if a node exists create a layer underneath it to display indicator
    for (NSInteger row = 0; row < NumberOfRows; row++)
    {
        for (NSInteger column = 0; column < NumberOfColumns; column++)
        {
            if ([self.gridManager hexagonTypeAtRow:row column:column])
            {
                CGSize tileSize = CGSizeMake(kTileSize, kTileSize);
                HDSpriteNode *tileNode = [HDSpriteNode spriteNodeWithColor:[UIColor clearColor] size:tileSize];
                tileNode.row = row;
                tileNode.column = column;
                tileNode.position = [self _pointForColumn:column row:row];
                [self.tileLayer addChild:tileNode];
            }
        }
    }
}

- (HDSpriteNode *)indicatorTileUnderHexagon:(HDHexagon *)hexagon
{
    // find the tile on the tileLayer that has same position as selected hexagon
    for (HDSpriteNode *indicator in self.tileLayer.children)
    {
        if (indicator.row == hexagon.row && hexagon.column == indicator.column)
        {
            return indicator;
        }
    }
    return nil;
}

#pragma mark - UIResponder

- (HDHexagon *)findHexagonFromPoint:(CGPoint)point
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
    HDHexagon *hexagon = [self findHexagonFromPoint:location];
    
    HDHexagon *previousTile = [_selectedHexagons lastObject];
    
    // If the newly selected node is connected to previously selected node.. prooccceeed
    if ([self _validateNextMoveToHexagon:hexagon fromHexagon:previousTile]) {
        
        [_selectedHexagons addObject:hexagon];
        
        if ([hexagon selectedAfterRecievingTouches]){
            [hexagon.node runAction:[SKAction scaleTo:.9f duration:.15f] completion:^{
                [hexagon.node runAction:[SKAction scaleTo:1.0f duration:.15f]];
            }];
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
            HDSpriteNode *sprite = [self indicatorTileUnderHexagon:hexagon];
            [sprite addChild:[SKEmitterNode hexaEmitterWithColor:hexagon.node.strokeColor scale:hexagon.selected ? .9f : .5f]];
        }
        [self _checkGameStateForTile:hexagon];
        [self _playSoundForHexagon:hexagon withVibration:YES];
    }
}

#pragma mark - Private

- (void)_playSoundForHexagon:(HDHexagon *)hexagon withVibration:(BOOL)vibration
{
    [self runAction:[_sounds objectAtIndex:_soundIndex] withKey:HDSoundActionKey];
    
    if ([self _inPlayTileCount] == 0) {
        [self runAction:self.completionZing withKey:HDSoundActionKey];
    }
    
    if (self.countDownSoundIndex) {
        
        _soundIndex--;
        if (_soundIndex == 0) {
            self.countDownSoundIndex = NO;
        }
    } else {
        
        _soundIndex++;
        if (_soundIndex == _sounds.count - 1) {
            self.countDownSoundIndex = YES;
        }
    }
    
    if (vibration && [[HDSettingsManager sharedManager] vibe]) {
        if (hexagon.isCountTile || hexagon.type == HDHexagonTypeStarter) {
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
        
        HDSpriteNode *sprite = self.tileLayer.children[index];
        
        // Offset tiles to center entire map (find the inset + or -, adjust accordingly)
        CGPoint center = hexagon.node.position;
        center.x += (floorf(_minCenterX) > _minViewAreaOriginX) ? -(_minCenterX - _minViewAreaOriginX) : _minViewAreaOriginX - _minCenterX;
        center.y += (floorf(_minCenterY) > _minViewAreaOriginY) ? -(_minCenterY - _minViewAreaOriginY) : _minViewAreaOriginY - _minCenterY;
        
        [hexagon.node setPosition:center];
        [sprite setPosition:center];
        
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
        
        if ([[HDSettingsManager sharedManager] vibe]) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        [self _gameCompletionAnimationWithCompletion:^{
            HDAlertNode *alertNode = [HDAlertNode spriteNodeWithColor:[UIColor clearColor] size:self.frame.size];
            alertNode.levelLabel.text = [NSString stringWithFormat:@"Level %ld", _levelIndex];
            alertNode.delegate = self;
            alertNode.position = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
            [self addChild:alertNode];
        }];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(scene:gameEndedWithCompletion:)]) {
            [self.delegate scene:self gameEndedWithCompletion:YES];
        }
        
       [[HDMapManager sharedManager] completedLevelAtIndex:self.levelIndex-1];
        
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
        for (HDSpriteNode *hexagonSprite in self.tileLayer.children) {
            [hexagonSprite updateTextureFromHexagonType:HDHexagonTypeNone];
        }
        
        // Find all possible moves for newly selected tile
        NSArray *possibleMovesFromNewlySelectedTile = [HDHelper possibleMovesForHexagon:toHexagon inArray:_hexagons];
        
        // Display "Possible Move" indicator on tiles found ^
        for (HDHexagon *hexagonShape in possibleMovesFromNewlySelectedTile) {
            for (HDSpriteNode *hexagonSprite in self.tileLayer.children) {
                if (hexagonShape.row == hexagonSprite.row && hexagonShape.column == hexagonSprite.column) {
                    [hexagonSprite updateTextureFromHexagonType:hexagonShape.type touchesCount:hexagonShape.touchesCount];
                    break;
                }
            }
        }
        return YES;
    }
    return NO;
}

- (void)_nextLevel
{
    // Clear out Arrays
    [_selectedHexagons removeAllObjects];
    
    // We want to start at 0 and count up when the new levels layed out
    self.countDownSoundIndex = NO;
    
    // Reduce retainCount
    [self.gameLayer removeAllChildren];
    [self.tileLayer removeAllChildren];
    
    self.levelIndex += 1;
    
    // Call parent to refill model with next level's data, then call us back
    if (self.delegate && [self.delegate respondsToSelector:@selector(scene:proceededToLevel:)]) {
        [self.delegate scene:self proceededToLevel:self.levelIndex];
    }
}

#pragma mark - < RESTART >

- (void)_resetVariablesForRestart
{
    self.countDownSoundIndex = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scene:updatedSelectedTileCount:)]) {
        [self.delegate scene:self updatedSelectedTileCount:0];
    }
    
    // Return used starting tile count to ZERO
    _soundIndex = 0;
    
    // Clear out Arrays
    [_selectedHexagons removeAllObjects];
    
    // Clear out lower indicator layer
    for (HDSpriteNode *hexagonSprite in self.tileLayer.children) {
        [hexagonSprite updateTextureFromHexagonType:HDHexagonTypeNone];
    }
}

- (void)_restartFromClearedScreen
{
    if (self.animating) {
        return;
    }
    
    self.animating = YES;
    
    [self _resetVariablesForRestart];
    
    // Shuffle a copy of tiles Array to prepare for animations
    for (HDHexagon *hexa in [[_hexagons mutableCopy] shuffle]) {
        [hexa restoreToInitialState];
    }
    
    // Animate restart once restored
    [HDHelper entranceAnimationWithTiles:[[_hexagons mutableCopy] shuffle] completion:^{
        self.animating = NO;
    }];
}

- (void)restart
{
    if (self.animating) {
        return;
    }
    
    self.animating = YES;
    
    [self _resetVariablesForRestart];

    // Animate out
    [HDHelper completionAnimationWithTiles:[[_hexagons mutableCopy] shuffle] completion:^{
        // Animate restart once restored
        [HDHelper entranceAnimationWithTiles:[[_hexagons mutableCopy] shuffle] completion:^{
            self.animating = NO;
        }];
    }];
}

- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion
{
    // Clear out lower indicator layer
    for (HDSpriteNode *hexagonSprite in self.tileLayer.children) {
        [hexagonSprite updateTextureFromHexagonType:HDHexagonTypeNone];
    }

    // Animate out
    [HDHelper completionAnimationWithTiles:[[_hexagons mutableCopy] shuffle] completion:completion];
}

- (void)_gameCompletionAnimationWithCompletion:(dispatch_block_t)completion
{
    NSTimeInterval delay = 0;
    
    NSMutableArray *shuffle = [_hexagons mutableCopy];
    [shuffle shuffle];
    
    __block NSInteger count = 0;
    for (HDHexagon *hexagon in shuffle) {
        
        // Setup Actions
        SKAction *scaleUp  = [SKAction scaleTo:1.15f duration:.10f];
        SKAction *scale    = [SKAction scaleTo:0.0f duration:0.10f];
        SKAction *wait     = [SKAction waitForDuration:delay];
        SKAction *sequence = [SKAction sequence:@[wait, scaleUp, scale]];
        
        [hexagon.node runAction:sequence completion:^{
            hexagon.node.hidden = YES;
            hexagon.node.scale  = 1.0f;
            
            if (_hexagons.count - 1 == count) {
                
                [self removeAllActions];
                
                if (completion) {
                    completion();
                }
            }
            count++;
        }];
        delay += .1f;
    }
}

#pragma mark - <HDAlertNodeDelegate>

- (void)alertNodeWillDismiss:(HDAlertNode *)alertNode
{
    SKEmitterNode *star = (SKEmitterNode *)[self childNodeWithName:@"STARKEY"];
    star.particleBirthRate = 0.0f;
    [star performSelector:@selector(removeFromParent) withObject:nil afterDelay:1.f];
    [self runAction:[SKAction playSoundFileNamed:HDButtonSound waitForCompletion:NO] withKey:HDSoundActionKey];
}

- (void)alertNode:(HDAlertNode *)alertNode clickedButtonWithTitle:(NSString *)title
{
    self.animating = NO;
    
    if ([title isEqualToString:RESTARTKEY]) {
        [self _restartFromClearedScreen];
        if (self.delegate && [self.delegate respondsToSelector:@selector(gameWillResetInScene:)]) {
            [self.delegate gameWillResetInScene:self];
        }
    } else if ([title isEqualToString:NEXTLEVELKEY]) {
        [self _nextLevel];
        if (self.delegate && [self.delegate respondsToSelector:@selector(gameWillResetInScene:)]) {
            [self.delegate gameWillResetInScene:self];
        }
    } else if ([title isEqualToString:SHAREKEY]) {
        [ADelegate presentShareViewController];
    } else if ([title isEqualToString:ACHIEVEMENTSKEY]) {
        [ADelegate presentGameCenterControllerForState:GKGameCenterViewControllerStateAchievements];
    } else if ([title isEqualToString:LEADERBOARDKEY]) {
        [ADelegate presentGameCenterControllerForState:GKGameCenterViewControllerStateLeaderboards];
    } else if ([title isEqualToString:RATEKEY]) {
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

- (void)unlockCountTileAfterHexagon:(HDHexagonType)type
{
    // Find next disabled 'count' tile and unlock it
    for (HDHexagon *hexagon in _hexagons) {
        if (hexagon.type == type + 1 && !hexagon.selected && hexagon.isCountTile) {
            [hexagon setLocked:NO];
            return;
        }
    }
}

- (NSArray *)_preloadedGameSounds
{
    //Preload any sounds that are going to be played throughout the game
    self.loop = [SKAction playSoundFileNamed:@"C4.m4a" waitForCompletion:YES];
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
