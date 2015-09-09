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
@property (nonatomic, strong) SKAction *explosion;
@end

@implementation HDScene
{
    NSArray *_sounds;
    
    CGFloat _minViewAreaOriginX;
    CGFloat _minViewAreaOriginY;
    
    CGFloat _minCenterX;
    CGFloat _maxCenterX;
    CGFloat _minCenterY;
    CGFloat _maxCenterY;

    SKNode *_gameLayer;
}

- (instancetype)initWithSize:(CGSize)size
{
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
                 completion:(dispatch_block_t)completion
{
    self.userInteractionEnabled = NO;
    self.layoutCompletion = [completion copy];
    self.hexaObjects = [NSMutableArray arrayWithArray:grid];
    
    _mines = nil;
    _soundIndex = 0;
    
    _maxCenterX = 0.0f;
    _maxCenterY = 0.0f;
    _minCenterY = MAXFLOAT;
    _minCenterX = MAXFLOAT;
    
    const CGFloat scale = IS_IPAD ? 1.0f : TRANSFORM_SCALE_X;
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

- (void)initialLayoutCompletion
{
     NSAssert(NO, @" '%@' must be overrriden in a subclass",NSStringFromSelector(_cmd));
}

- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion
{
    [HDHelper completionAnimationWithTiles:_hexaObjects completion:^{
        [self.gameLayer.children makeObjectsPerformSelector:@selector(removeFromParent)];
        [self.gameLayer removeFromParent];
        if (completion) {
            completion();
        }
    }];
    self.mines = nil;
    self.hexaObjects = nil;
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSAssert(NO, @" Method '%@' must be overrriden in a subclass",NSStringFromSelector(_cmd));
}

#pragma mark - Private

- (NSArray *)_preloadedGameSounds
{
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

- (HDHexaObject *)findHexagonContainingPoint:(CGPoint)point
{
    NSAssert(NO, @" Method '%@' must be overrriden in a subclass", NSStringFromSelector(_cmd));
    return nil;
}

- (void)restartWithAlert:(NSNumber *)alert
{
    NSAssert(NO, @"'%@' must be overrriden in a subclass",NSStringFromSelector(_cmd));
}

- (void)playSoundForHexagon:(HDHexaObject *)hexagon vibration:(BOOL)vibration
{
    [self runAction:[_sounds objectAtIndex:_soundIndex] withKey:HDSoundActionKey];
    
    if (_soundIndex == 0 || _soundIndex == _sounds.count - 1) {
        self.countDownSoundIndex = (_soundIndex != 0);
    }
    
    _soundIndex = self.countDownSoundIndex ? _soundIndex - 1 : _soundIndex + 1;
    if (hexagon.isCountTile || hexagon.type == HDHexagonTypeStarter) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)centerTileGrid
{
    _minViewAreaOriginX = ceilf((CGRectGetWidth(self.frame)  - (_maxCenterX - _minCenterX)) / 2);
    _minViewAreaOriginY = ceilf((CGRectGetHeight(self.frame) - (_maxCenterY - _minCenterY)) / 2);
    
    BOOL maxXViewingArea = (floorf(_minCenterX) > _minViewAreaOriginX);
    BOOL maxYViewingArea = (floorf(_minCenterY) > _minViewAreaOriginY);
    
    const CGFloat positionX = maxXViewingArea ? -(_minCenterX - _minViewAreaOriginX) : _minViewAreaOriginX - _minCenterX;
    const CGFloat positionY = maxYViewingArea ? -(_minCenterY - _minViewAreaOriginY) : _minViewAreaOriginY - _minCenterY;

    for (HDHexaObject *hexagon in _hexaObjects) {
        
        CGPoint center = hexagon.node.position;
        center.x += floorf(positionX);
        center.y += floorf(positionY + 5.0f);
        
        hexagon.node.defaultPosition = center;
        hexagon.node.position = center;
    }
}

- (void)checkGameStateForTile:(HDHexaObject *)tile
{
     NSAssert(NO, @"'%@' must be overrriden in a subclass",NSStringFromSelector(_cmd));
}

- (void)updateDataForNextLevel
{
     NSAssert(NO, @"'%@' must be overrriden in a subclass",NSStringFromSelector(_cmd));
}

- (NSUInteger)inPlayTileCount
{
    NSUInteger count = 0;
    for (HDHexaObject *hexaon in _hexaObjects) {
        if (!hexaon.selected) {
            count++;
        }
    }
    return count;
}

- (BOOL)validateNextMoveToHexagon:(HDHexaObject *)toHexagon fromHexagon:(HDHexaObject *)fromHexagon
{
    if ([[HDTileManager sharedManager] isEmpty] && (toHexagon.type != HDHexagonTypeStarter)) {
        return NO;
    }
    
    NSArray *possibleMoves = [HDHelper possibleMovesForHexagon:fromHexagon inArray:_hexaObjects];
    if ([possibleMoves containsObject:toHexagon] || toHexagon.type == HDHexagonTypeStarter) {
        [self displayPossibleMovesFromHexaObject:toHexagon];
        return YES;
    }
    return NO;
}

- (void)displayPossibleMovesFromHexaObject:(HDHexaObject *)fromObj
{
    for (HDHexaObject *obj in self.hexaObjects) {
        obj.node.displayNextMoveIndicator = NO;
    }
    
    NSArray *possibleMovesForNewlySelectedTile = [HDHelper possibleMovesForHexagon:fromObj inArray:_hexaObjects];
    for (HDHexaObject *obj in possibleMovesForNewlySelectedTile) {
        
        HDTileDirection direction = [HDHelper tileDirectionsToTile:fromObj fromTile:obj];
        [obj.node displayNextMoveIndicatorWithColor:[HDHelper colorFromType:obj.type touchCount:obj.touchesCount]
                                          direction:direction
                                           animated:possibleMovesForNewlySelectedTile.count >= 4];
        obj.node.displayNextMoveIndicator = YES;
    }
}

- (void)runAction:(SKAction *)action withKey:(NSString *)key
{
    if ([key isEqualToString:HDSoundActionKey]) {
        if (![[HDSettingsManager sharedManager] sound]) {
            return;
        }
    }
    [super runAction:action withKey:key];
}

#pragma mark - Class

+ (CGPoint)_pointForColumn:(NSInteger)column row:(NSInteger)row
{
    const CGFloat kOriginY = ((row * ([[self class] tileSize] * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = ((column * [[self class] tileSize]));
    const CGFloat kAlternateOffset = (row % 2 == 0) ? [[self class] tileSize] / 2 : 0.0f;
    return CGPointMake(kAlternateOffset + kOriginX, kOriginY);
}

+ (CGFloat)tileSize
{
    return IS_IPAD ? tileSizeiPad : tileSizeiPhone;
}

@end
