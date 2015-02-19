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

#define kTileSize [[UIScreen mainScreen] bounds].size.width / (NumberOfColumns - 1)// + .5

NSString * const HDSoundActionKey = @"SOUND_KEY";

static const CGFloat kTileHeightInsetMultiplier = .845f;
@interface HDScene ()<HDHexagonDelegate>
@property (nonatomic, strong) NSArray *sounds;
@property (nonatomic, assign) BOOL restarting;
@property (nonatomic, assign) BOOL animateTheNeglect;
@property (nonatomic, strong) SKNode *gameLayer;
@property (nonatomic, strong) SKEmitterNode *confetti;
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
}

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        self.gameLayer = [SKNode node];
        [self addChild:self.gameLayer];
        
        self.countDownSoundIndex = NO;
        self.backgroundColor = [SKColor flatWetAsphaltColor];
        self.sounds = [self _preloadedGameSounds];
    }
    return self;
}

#pragma mark - Public

- (void)layoutNodesWithGrid:(NSArray *)grid completion:(dispatch_block_t)completion
{
    if (completion) {
        self.layoutCompletion = [completion copy];
    }
    
    self.hexagons = [NSMutableArray arrayWithArray:grid];
    [self _setup];
    
    NSInteger index = 0;
    for (HDHexagon *hexagon in grid) {
        
        CGPoint center = [[self class] _pointForColumn:hexagon.column row:hexagon.row];
        HDHexagonNode *hexagonNode = [[HDHexagonNode alloc] initWithImageNamed:hexagon.defaultImagePath];
        hexagonNode.scale    = CGRectGetWidth(self.view.bounds)/375.0f;
        hexagonNode.position = center;
        hexagon.node         = hexagonNode;
        hexagon.delegate     = hexagon.isCountTile ? self : nil;
        
        [self.gameLayer addChild:hexagonNode];
        [self _updateVariablesForPositionFromPoint:center];
        
        if (hexagon.type == HDHexagonTypeEnd) {
            self.includeEndTile = YES;
        }
        index++;
    }
    [self initialSetupCompletion];
}

- (void)initialSetupCompletion {
  
     NSAssert(NO, @"'%@' must be overrriden in a subclass",NSStringFromSelector(_cmd));
}

- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion {
    [HDHelper completionAnimationWithTiles:_hexagons completion:completion];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
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
            [currentTile selectedAfterRecievingTouches];
            [[HDTileManager sharedManager] addHexagon:currentTile];
            [self performEffectsForTile:currentTile];
            [self checkGameStateForTile:currentTile];
            [self playSoundForHexagon:currentTile vibration:YES];
        }
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

- (void)performEffectsForTile:(HDHexagon *)tile
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
    NSArray *notes = @[@"C", @"D", @"E", @"F", @"G", @"A", @"B"];
 
    NSMutableArray *sounds = [NSMutableArray array];
    for (int i = 3; i < 7; i++) {
        for (NSString *note in notes) {
            NSString *filePath = [NSString stringWithFormat:@"%@%d.m4a",note,i];
            SKAction *sound = [SKAction playSoundFileNamed:filePath waitForCompletion:NO];
            [sounds addObject:sound];
        }
    }
    return sounds;
}

- (HDHexagon *)findHexagonContainingPoint:(CGPoint)point
{
    const CGFloat smallHexagonInset = CGRectGetWidth([[[_hexagons firstObject] node] frame])/6;
    HDHexagon *selectedHexagon = nil;
    for (HDHexagon *hex in _hexagons) {
        if (CGRectContainsPoint(CGRectInset(hex.node.frame, smallHexagonInset, smallHexagonInset), point)) {
            selectedHexagon = hex;
        }
    }
    
    return selectedHexagon;
}

- (void)playSoundForHexagon:(HDHexagon *)hexagon vibration:(BOOL)vibration
{
    [self runAction:[_sounds objectAtIndex:_soundIndex] withKey:HDSoundActionKey];
    
    if (_soundIndex == 0 || _soundIndex == _sounds.count - 1) {
        self.countDownSoundIndex = (_soundIndex != 0);
    }
    
    _soundIndex = self.countDownSoundIndex ? _soundIndex - 1 : _soundIndex + 1;
    
    if (hexagon.isCountTile || hexagon.type == HDHexagonTypeStarter||[self inPlayTileCount] == 0) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)centerTilePositionWithCompletion:(dispatch_block_t)completion
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

- (void)startConfettiEmitter {
    
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"Confetti" ofType:@"sks"];
    self.confetti = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.confetti.position = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame));
    self.confetti.particleColor = [SKColor flatPeterRiverColor];
    self.confetti.particleColorSequence = nil;
    self.confetti.particleColorBlendFactor = 1.0f;
    [self.confetti advanceSimulationTime:.3f];
    [self insertChild:self.confetti atIndex:[self.children indexOfObject:self.gameLayer] - 1];
    
    [self startTileAnimationForCompletion];
}

- (void)startTileAnimationForCompletion {
    
    NSTimeInterval delay = 0;
    for (HDHexagon *subView in [[self.hexagons mutableCopy] shuffle]) {
        
        [subView.node removeAllActions];
        
        SKAction *wait  = [SKAction waitForDuration:delay];
        SKAction *cycle = [SKAction animateWithTextures:@[[SKTexture textureWithImageNamed:subView.defaultImagePath],
                                                          [SKTexture textureWithImageNamed:subView.selectedImagePath]]
                                           timePerFrame:.25f];
        SKAction *rotate = [SKAction rotateToAngle:arc4random() % 15 duration:1.0f];
        
        [subView.node runAction:[SKAction sequence:@[wait, cycle, rotate]]];
        
        delay += .1;
    }
    [self performSelector:@selector(startTileAnimationForCompletion) withObject:nil afterDelay:delay + 1.0f];
}

- (void)removeConfettiEmitter {
    
    [self.confetti removeFromParent];
    self.confetti = nil;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    for (HDHexagon *subView in self.hexagons) {
        [subView.node removeAllActions];
        subView.node.zRotation = 0;
    }
}

- (void)update:(NSTimeInterval)currentTime {
    
    if (self.confetti) {
        self.confetti.particleColor = [@[[SKColor flatPeterRiverColor],
                                         [SKColor whiteColor],
                                         [SKColor flatEmeraldColor],
                                         [SKColor flatAlizarinColor],
                                         [SKColor flatSilverColor]] objectAtIndex:arc4random() % 5];
    }
}

- (void)checkGameStateForTile:(HDHexagon *)tile {
    
    NSAssert(NO, @"'%@' must be overrriden in a subclass",NSStringFromSelector(_cmd));
}

- (void)nextLevel {
    
   NSAssert(NO, @"'%@' must be overrriden in a subclass",NSStringFromSelector(_cmd));
}

- (BOOL)unlockLastTile {
    return [self inPlayTileCount] == 1 && self.includeEndTile;
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

- (NSUInteger)inPlayTileCount {
    
    NSUInteger count = 0;
    for (HDHexagon *hexaon in _hexagons) {
        if (!hexaon.selected) {
            count++;
        }
    }
    return count;
}

- (BOOL)validateNextMoveToHexagon:(HDHexagon *)toHexagon fromHexagon:(HDHexagon *)fromHexagon
{
    if ([[HDTileManager sharedManager] isEmpty] && toHexagon.type != HDHexagonTypeStarter) {
        return NO;
    }
    
    // Find possible moves from currently selected tile
    NSArray *possibleMoves = [HDHelper possibleMovesForHexagon:fromHexagon inArray:_hexagons];
    
    //bitmask her.
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

#pragma mark - Class

+ (CGPoint)_pointForColumn:(NSInteger)column row:(NSInteger)row
{
    const CGFloat kOriginY = ((row * (kTileSize * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = ((column * kTileSize));
    const CGFloat kAlternateOffset = (row % 2 == 0) ? kTileSize / 2 : 0.0f;
    
    return CGPointMake(kAlternateOffset + kOriginX, kOriginY);
}

@end
