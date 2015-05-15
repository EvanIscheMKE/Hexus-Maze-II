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
#import "HDHexaObject.h"
#import "HDTextureManager.h"
#import "UIColor+ColorAdditions.h"
#import "HDSettingsManager.h"
#import "HDSoundManager.h"
#import "HDGameCenterManager.h"
#import "HDTileManager.h"
#import "UIImage+ImageAdditions.h"
#import "SKEmitterNode+EmitterAdditions.h"
#import "NSMutableArray+UniqueAdditions.h"
#import "HDMapManager.h"
#import "HDHexaNode.h"
#import "HDGridManager.h"

#define tileSizeiPad   [[UIScreen mainScreen] bounds].size.width / (NumberOfColumns + .5)
#define tileSizeiPhone [[UIScreen mainScreen] bounds].size.width / (NumberOfColumns - 1.0f)

NSString * const HDSoundActionKey = @"soundActionKey";

static const CGFloat kTileHeightInsetMultiplier = .845f;
@interface HDScene ()<HDHexagonDelegate>
@end

@implementation HDScene {
    
    NSArray *_sounds;
    
    CGFloat _minViewAreaOriginX;
    CGFloat _maxViewAreaOriginX;
    CGFloat _minViewAreaOriginY;
    CGFloat _maxViewAreaOriginY;
    
    CGFloat _minCenterX;
    CGFloat _maxCenterX;
    CGFloat _minCenterY;
    CGFloat _maxCenterY;
    
    SKAction *_explosion;

    SKNode *_gameLayer;
}

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor flatSTDarkBlueColor];
        
        _countDownSoundIndex = NO;
        _sounds = [self _preloadedGameSounds];
        _explosion = [SKAction playSoundFileNamed:@"Explosion.wav" waitForCompletion:NO];
        
        _gameLayer = [SKNode node];
        [self addChild:_gameLayer];
    }
    return self;
}

#pragma mark - Public

- (void)layoutNodesWithGrid:(NSArray *)grid
                 completion:(dispatch_block_t)completion {
    
    _soundIndex  = 0;
    
    _mines = nil;
    
    self.userInteractionEnabled = NO;
    self.layoutCompletion = [completion copy];
    self.hexaObjects = [NSMutableArray arrayWithArray:grid];
    
    const CGFloat scale = IS_IPAD ? 1.0f : TRANSFORM_SCALE_X;
    
    _maxCenterX = 0.0f;
    _maxCenterY = 0.0f;
    _minCenterY = MAXFLOAT;
    _minCenterX = MAXFLOAT;
    
    for (HDHexaObject *hexagon in grid) {
        
        SKTexture *texture = [[HDTextureManager sharedManager] textureForKeyPath:hexagon.defaultImagePath];
        if (texture == nil) {
            texture = [SKTexture textureWithImageNamed:hexagon.defaultImagePath];
        }
        
        CGPoint center = [[self class] _pointForColumn:hexagon.column row:hexagon.row];
        HDHexaNode *sprite = [[HDHexaNode alloc] initWithTexture:texture];
        sprite.position  = center;
        sprite.scale     = scale;
        hexagon.node     = sprite;
        hexagon.delegate = hexagon.isCountTile ? self : nil;
        [_gameLayer addChild:sprite];
        
        if ((center.x) < _minCenterX) { _minCenterX = (center.x); }
        if ((center.x) > _maxCenterX) { _maxCenterX = (center.x); }
        if ((center.y) < _minCenterY) { _minCenterY = (center.y); }
        if ((center.y) > _maxCenterY) { _maxCenterY = (center.y); }
        
    }
    [self initialLayoutCompletion];
}

- (void)initialLayoutCompletion {
     NSAssert(NO, @" '%@' must be overrriden in a subclass",NSStringFromSelector(_cmd));
}

- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion {
    [HDHelper completionAnimationWithTiles:_hexaObjects completion:^{
        
        self.hexaObjects = nil;
        self.mines = nil;
        [self.gameLayer.children makeObjectsPerformSelector:@selector(removeFromParent)];
        [self.gameLayer removeFromParent];
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSAssert(NO, @" '%@' must be overrriden in a subclass",NSStringFromSelector(_cmd));
}

#pragma mark - Private

- (NSArray *)_preloadedGameSounds {
    
    const NSUInteger minor = 3;
    const NSUInteger major = 7;
    
    NSArray *notes = @[@"C", @"D", @"E", @"F", @"G", @"A", @"B"];

    NSMutableArray *sounds = [NSMutableArray array];
    for (NSUInteger i = minor; i < major; i++) {
        for (NSString *note in notes) {
            NSString *filePath = [NSString stringWithFormat:@"%@%tu.m4a",note,i];
            SKAction *sound = [SKAction playSoundFileNamed:filePath waitForCompletion:NO];
            [sounds addObject:sound];
        }
    }
    return sounds;
}

- (HDHexaObject *)findHexagonContainingPoint:(CGPoint)point {
    
    const CGFloat inset = CGRectGetWidth([[[_hexaObjects firstObject] node] frame])/6;
    for (HDHexaObject *tile in _hexaObjects) {
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

- (void)minesFromHexaObject:(HDHexaObject *)obj {
    
    if (!_mines) {
        _mines = [NSMutableArray arrayWithObject:obj];
    }
    
    NSArray *possibleMinesConnectedToSelectedMine = [HDHelper possibleMovesFromMine:obj containedIn:self.hexaObjects];
    
    for (HDHexaObject *hex in possibleMinesConnectedToSelectedMine) {
        if (![_mines containsObject:hex]) {
            [_mines addObject:hex];
            [self minesFromHexaObject:hex];
        }
    }
}

- (void)_mineTileWasSelected:(HDHexaObject *)hexaObj{
    
    if (!self.userInteractionEnabled || [self inPlayTileCount] == 0) {
        return;
    }
    
    self.userInteractionEnabled = NO;
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    [self minesFromHexaObject:hexaObj];

    NSTimeInterval delay = 0.0f;
    
    __block SKEmitterNode *explosion;
    __block NSTimeInterval particleDurationInSeconds = 0.0f;
    for (HDHexaObject *mine in _mines) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            mine.node.hidden = YES;
            
            explosion = [SKEmitterNode explosionNode];
            explosion.position = mine.node.position;
            [self.gameLayer addChild:explosion];
            [self runAction:_explosion withKey:HDSoundActionKey];
            
            if (particleDurationInSeconds == 0.0f) {
                particleDurationInSeconds = explosion.numParticlesToEmit / explosion.particleBirthRate + explosion.particleLifetime;
                [self performSelector:@selector(restartWithAlert:)
                           withObject:@(YES)
                           afterDelay:particleDurationInSeconds/2.f + .1f * _mines.count];
            }
        });
        delay += .1f;
    }
}

- (void)restartWithAlert:(NSNumber *)alert {
    NSAssert(NO, @"'%@' must be overrriden in a subclass",NSStringFromSelector(_cmd));
}

- (void)playSoundForHexagon:(HDHexaObject *)hexagon vibration:(BOOL)vibration {
    
    [self runAction:[_sounds objectAtIndex:_soundIndex] withKey:HDSoundActionKey];
    
    if (_soundIndex == 0 || _soundIndex == _sounds.count - 1) {
        self.countDownSoundIndex = (_soundIndex != 0);
    }
    
    _soundIndex = self.countDownSoundIndex ? _soundIndex - 1 : _soundIndex + 1;
    
    if (hexagon.isCountTile || hexagon.type == HDHexagonTypeStarter) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)centerTileGrid {

    _minViewAreaOriginX = ceilf((CGRectGetWidth(self.frame)  - (_maxCenterX - _minCenterX)) / 2);
    _minViewAreaOriginY = ceilf((CGRectGetHeight(self.frame) - (_maxCenterY - _minCenterY)) / 2);
    
    BOOL maxXViewingArea = (floorf(_minCenterX) > _minViewAreaOriginX);
    BOOL maxYViewingArea = (floorf(_minCenterY) > _minViewAreaOriginY);
    
    const CGFloat positionX = maxXViewingArea ? -(_minCenterX - _minViewAreaOriginX) : _minViewAreaOriginX - _minCenterX;
    const CGFloat positionY = maxYViewingArea ? -(_minCenterY - _minViewAreaOriginY) : _minViewAreaOriginY - _minCenterY;

    for (HDHexaObject *hexagon in _hexaObjects) {
        
        CGPoint center = hexagon.node.position;
        center.x += floorf(positionX);
        center.y += floorf(positionY + 12.0f);
        
        hexagon.node.defaultPosition = center;
        hexagon.node.position = center;
    }
}

- (void)checkGameStateForTile:(HDHexaObject *)tile {
    NSAssert(NO, @"'%@' must be overrriden in a subclass",NSStringFromSelector(_cmd));
}

- (void)updateDataForNextLevel {
   NSAssert(NO, @"'%@' must be overrriden in a subclass",NSStringFromSelector(_cmd));
}

- (BOOL)unlockLastTile {
    
    BOOL includeEndTile = false;
    for (HDHexaObject *object in self.hexaObjects) {
        if (object.type == HDHexagonTypeEnd) {
            includeEndTile = true;
        }
    }
    return ([self inPlayTileCount] == 1 && includeEndTile);
}

- (BOOL)isGameOverAfterPlacingTile:(HDHexaObject *)hexagon {
    
    NSUInteger startTileCount         = [self _startTileCount];
    NSUInteger selectedStartTileCount = [self _selectedStartTileCount];
    
    if (startTileCount != selectedStartTileCount) {
        return NO;
    }
    
    NSArray *remainingMoves = [HDHelper possibleMovesForHexagon:hexagon inArray:_hexaObjects];
    
    if (remainingMoves.count == 0) {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)_selectedStartTileCount {
    NSUInteger count = 0;
    for (HDHexaObject *hexa in _hexaObjects) {
        if (hexa.type == HDHexagonTypeStarter && hexa.selected) {
            count++;
        }
    }
    return count;
}

- (NSUInteger)_startTileCount {
    NSUInteger count = 0;
    for (HDHexaObject *hexa in _hexaObjects) {
        if (hexa.type == HDHexagonTypeStarter) {
            count++;
        }
    }
    return count;
}

- (NSUInteger)inPlayTileCount {
    NSUInteger count = 0;
    for (HDHexaObject *hexaon in _hexaObjects) {
        if (!hexaon.selected) {
            count++;
        }
    }
    return count;
}

- (BOOL)validateNextMoveToHexagon:(HDHexaObject *)toHexagon fromHexagon:(HDHexaObject *)fromHexagon {
    
    if ([[HDTileManager sharedManager] isEmpty] && toHexagon.type != HDHexagonTypeStarter) {
        return NO;
    }
    
    NSArray *possibleMoves = [HDHelper possibleMovesForHexagon:fromHexagon inArray:_hexaObjects];
    if ([possibleMoves containsObject:toHexagon] || toHexagon.type == HDHexagonTypeStarter) {
        
        for (HDHexaObject *obj in self.hexaObjects) {
            obj.node.displayNextMoveIndicator = NO;
        }
        
        NSArray *possibleMovesForNewlySelectedTile = [HDHelper possibleMovesForHexagon:toHexagon inArray:_hexaObjects];
        for (HDHexaObject *obj in possibleMovesForNewlySelectedTile) {
            
            HDTileDirection direction = [HDHelper tileDirectionsToTile:toHexagon fromTile:obj];
            [obj.node displayNextMoveIndicatorWithColor:[HDHelper colorFromType:obj.type touchCount:obj.touchesCount]
                                              direction:direction
                                               animated:possibleMovesForNewlySelectedTile.count >= 4];
            obj.node.displayNextMoveIndicator = YES;
        }
        
        return YES;
    }
    return NO;
}

- (void)runAction:(SKAction *)action withKey:(NSString *)key {
    
    if ([key isEqualToString:HDSoundActionKey]) {
        if (![[HDSettingsManager sharedManager] sound]) {
            return;
        }
    }
    [super runAction:action withKey:key];
}

#pragma mark - Class

+ (CGPoint)_pointForColumn:(NSInteger)column row:(NSInteger)row {
    const CGFloat kOriginY = ((row * ([[self class] tileSize] * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = ((column * [[self class] tileSize]));
    const CGFloat kAlternateOffset = (row % 2 == 0) ? [[self class] tileSize] / 2 : 0.0f;
    return CGPointMake(kAlternateOffset + kOriginX, kOriginY);
}

+ (CGFloat)tileSize {
    return IS_IPAD ? tileSizeiPad : tileSizeiPhone;
}

@end
