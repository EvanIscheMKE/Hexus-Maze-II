//
//  HDScene.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDScene.h"
#import "HDHelper.h"
#import "HDHexagon.h"
#import "SKColor+HDColor.h"
#import "HDSpriteNode.h"
#import "NSMutableArray+UniqueAdditions.h"
#import "HDMapManager.h"
#import "HDHexagonNode.h"
#import "HDGridManager.h"
#import "HDAlertNode.h"

#define _kTileSize [[UIScreen mainScreen] bounds].size.width / (NumberOfColumns - 1)

static const CGFloat kTileHeightInsetMultiplier = .845f;
@interface HDScene ()<HDHexagonDelegate>

@property (nonatomic, strong) SKAction *selectedSound;
@property (nonatomic, assign) BOOL contentCreated;

@property (nonatomic, strong) SKEmitterNode *stars;

@property (nonatomic, strong) SKNode *gameLayer;
@property (nonatomic, strong) SKNode *tileLayer;

@end

@implementation HDScene {
    
    NSArray *_hexagons;
    NSMutableArray *_selectedHexagons;
    
    NSUInteger _finishedTileCount;
    NSUInteger _startingTileCount;
    NSInteger  _startingTilesUsed;
    
    CGFloat _minViewAreaOriginX;
    CGFloat _maxViewAreaOriginX;
    CGFloat _minViewAreaOriginY;
    CGFloat _maxViewAreaOriginY;
    
    CGFloat _minCenterX;
    CGFloat _maxCenterX;
    CGFloat _minCenterY;
    CGFloat _maxCenterY;
    
}

@dynamic delegate;
- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        _selectedHexagons = [NSMutableArray array];
        
        [self _preloadSounds];
        [self setBackgroundColor:[SKColor flatMidnightBlueColor]];
        
         self.stars = [self _spaceNode];
        [self addChild:self.stars];
        
         self.tileLayer = [SKNode node];
        [self addChild:self.tileLayer];
        
         self.gameLayer = [SKNode node];
        [self addChild:self.gameLayer];
        
        _minCenterX = MAXFLOAT;
        _maxCenterX = 0.0f;
        _minCenterY = MAXFLOAT;
        _maxCenterY = 0.0f;
        
    }
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated){
        [self setContentCreated:YES];
    }
}

- (void)addUnderlyingIndicatorTiles
{
    for (NSInteger row = 0; row < NumberOfRows; row++) {
        for (NSInteger column = 0; column < NumberOfColumns; column++) {
            
            if ([self.gridManager hexagonTypeAtRow:row column:column]) {
                HDSpriteNode *tileNode = [HDSpriteNode spriteNodeWithColor:[UIColor clearColor]
                                                                      size:CGSizeMake(_kTileSize + 6.0f, _kTileSize + 6.0f)];
                [tileNode setRow:row];
                [tileNode setColumn:column];
                [tileNode setPosition:[self _pointForColumn:column row:row]];
                [self.tileLayer addChild:tileNode];
            }
        }
    }
}

- (void)layoutNodesWithGrid:(NSArray *)grid
{
    _startingTileCount = 0;
    _startingTilesUsed = 0;
    
    _finishedTileCount = grid.count;
    
    _hexagons = [NSArray arrayWithArray:grid];
    
    NSMutableArray *shuffledTiles = [_hexagons mutableCopy];
    
    [shuffledTiles shuffle];
    
    NSUInteger zPosition = 100;
    for (HDHexagon *hexagon in grid) {
        
        CGPathRef pathRef = [HDHelper hexagonPathForBounds:CGRectMake(0.0f, 0.0f, _kTileSize, _kTileSize)];
        
        CGPoint center = [self _pointForColumn:hexagon.column row:hexagon.row];
        HDHexagonNode *shapeNode = [HDHexagonNode shapeNodeWithPath:pathRef centered:YES];
        [shapeNode setZPosition:zPosition];
        [shapeNode setHidden:YES];
        [shapeNode setPosition:center];
        [hexagon setDelegate:self];
        [hexagon setNode:shapeNode];
        [hexagon setType:(int)[self.gridManager hexagonTypeAtRow:hexagon.row column:hexagon.column]];
        [self.gameLayer addChild:shapeNode];
        
        if ((center.x) < _minCenterX) { _minCenterX = (center.x); }
        if ((center.x) > _maxCenterX) { _maxCenterX = (center.x); }
        if ((center.y) < _minCenterY) { _minCenterY = (center.y); }
        if ((center.y) > _maxCenterY) { _maxCenterY = (center.y); }
        
        if (hexagon.type == HDHexagonTypeStarter) {
            _startingTileCount++;
        }
        
        zPosition--;
    }
    
   [self _centerTilePositionWithCompletion:^{
       [self _performEnteranceAnimationWithTiles:shuffledTiles handler:nil];
   }];
}

#pragma mark -
#pragma mark - UIRespnder

- (HDHexagon *)findHexagonFromPoint:(CGPoint)point
{
    const CGFloat kHexagonInset = 4.0f;
    HDHexagon *selectedHexagon = nil;
    for (HDHexagon *hex in _hexagons) {
        if (CGRectContainsPoint(CGRectInset(hex.node.frame, kHexagonInset, kHexagonInset), point)) {
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
    
    HDHexagon *hexagon = [self findHexagonFromPoint:location];
    if ([self _validateNextMoveToHexagon:hexagon fromHexagon:[_selectedHexagons lastObject]]) {
        [self.gameLayer runAction:self.selectedSound];
        [_selectedHexagons addUniqueObject:hexagon];
        [hexagon recievedTouches];
        
        [self _checkGameStatusAfterSelectingTile:hexagon];
    }
}

#pragma mark -
#pragma mark - Private

- (CGPoint)_pointForColumn:(NSInteger)column row:(NSInteger)row
{
    const CGFloat kOriginY = ((row * (_kTileSize * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = ((column * _kTileSize) );
    const CGFloat kAlternateOffset = (row % 2 == 0) ? _kTileSize / 2.f : 0.0f;
    
    return CGPointMake(kAlternateOffset + kOriginX, kOriginY);
}

- (void)_centerTilePositionWithCompletion:(dispatch_block_t)completion
{
    _minViewAreaOriginX = ceilf((CGRectGetWidth(self.frame)  - (_maxCenterX - _minCenterX)) / 2);
    _minViewAreaOriginY = ceilf((CGRectGetHeight(self.frame) - (_maxCenterY - _minCenterY)) / 2);
    
    NSInteger index = 0;
    for (HDHexagon *hexagon in _hexagons) {
        
        HDSpriteNode *sprite = [self.tileLayer.children objectAtIndex:index];
        
        CGPoint center = hexagon.node.position;
        
        center.x += (floorf(_minCenterX) > _minViewAreaOriginX) ? -(floorf(_minCenterX) - _minViewAreaOriginX) :
        (_minViewAreaOriginX - floorf(_minCenterX));
        center.y += (floorf(_minCenterY) > _minViewAreaOriginY) ? -(floorf(_minCenterY) - _minViewAreaOriginY) :
        (_minViewAreaOriginY - floorf(_minCenterY));
        
        [hexagon.node setPosition:center];
        [sprite setPosition:center];
        
        index++;
    }
    
    if (completion) {
        completion();
    }
}

- (void)_checkGameStatusAfterSelectingTile:(HDHexagon *)hexagon
{
    if ([self _checkIfAllHexagonsAreSelected]) {
        [self _performCompletionAnimation:^{
            
            
            if ([ADelegate previousLevel]) {
                [[HDMapManager sharedManager] completedLevelAtIndex:[ADelegate previousLevel]];
            }
            
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[[SKColor flatMidnightBlueColor] colorWithAlphaComponent:.25f]
                                                                size:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
            [sprite setAnchorPoint:CGPointZero];
            [self addChild:sprite];
            
        }];
    } else if (![[self _possibleMovesForHexagon:hexagon] count] && _startingTilesUsed == ( _startingTileCount - 1 )){
        
        [self _performCompletionAnimation:^{
            
            HDAlertNode *alertNode = [HDAlertNode spriteNodeWithColor:[SKColor flatMidnightBlueColor] size:self.frame.size];
            [alertNode setPosition:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)];
            [self addChild:alertNode];
            
            [alertNode showAlertNode];
            
        }];
        
    } else if (![[self _possibleMovesForHexagon:hexagon] count]) {
        _startingTilesUsed++;
    }
}

- (void)_performEnteranceAnimationWithTiles:(NSMutableArray *)tiles handler:(dispatch_block_t)handler
{
    NSTimeInterval delay = .05f;
    for (HDHexagon *hex in tiles) {
        [hex.node runAction:[SKAction sequence:@[[SKAction waitForDuration:delay],
                                                 [SKAction scaleTo:.0f duration:0.0f],
                                                 [SKAction unhide],
                                                 [SKAction scaleTo:1.1f duration:.3f],
                                                 [SKAction scaleTo:1.0f duration:.2f]]]];
        delay += .05f;
    }
    
    delay += .5f;
    
    SKAction *duble  = [SKAction sequence: @[[SKAction waitForDuration:delay], [SKAction moveTo:CGPointMake(1.0f, 1.0f) duration:.5f]]];
    SKAction *triple = [SKAction sequence: @[[SKAction waitForDuration:.75f], duble]];
    
    [tiles shuffle];
    for (HDHexagon *hex in tiles) {
        [hex.node runAction:[SKAction runAction:duble  onChildWithName:@"double"]];
        [[hex.node.children firstObject] runAction:[SKAction runAction:triple onChildWithName:@"triple"]];
    }
    
    if (handler) {
        handler();
    }
}

- (void)_performCompletionAnimation:(dispatch_block_t)handler
{
    handler();
}

- (void)_preloadSounds
{
    self.selectedSound = [SKAction playSoundFileNamed:@"104947__glaneur-de-sons__bubble-8.wav"
                                    waitForCompletion:YES];
}

- (BOOL)_checkIfAllHexagonsAreSelected
{
    NSUInteger count = 0;
    for (HDHexagon *hexaon in _hexagons) {
        if (hexaon.selected) {
            count++;
        }
    }
    return (count == _finishedTileCount);
}

- (NSArray *)_possibleMovesForHexagon:(HDHexagon *)hexagon
{
    NSMutableArray *hexagons = [NSMutableArray array];
    
    NSInteger hexagonRow[6];
    hexagonRow[0] = hexagon.row;
    hexagonRow[1] = hexagon.row;
    hexagonRow[2] = hexagon.row + 1;
    hexagonRow[3] = hexagon.row + 1;
    hexagonRow[4] = hexagon.row - 1;
    hexagonRow[5] = hexagon.row - 1;
    
    NSInteger hexagonColumn[6];
    hexagonColumn[0] = hexagon.column + 1;
    hexagonColumn[1] = hexagon.column - 1;
    hexagonColumn[2] = hexagon.column;
    hexagonColumn[3] = hexagon.column + ((hexagon.row % 2 == 0) ? 1 : -1);
    hexagonColumn[4] = hexagon.column;
    hexagonColumn[5] = hexagon.column + ((hexagon.row % 2 == 0) ? 1 : -1);
    
    for (int i = 0; i < 6; i++) {
        for (HDHexagon *current in _hexagons) {
            if (!current.isSelected && current.state == HDHexagonStateEnabled) {
                if (current.row == hexagonRow[i] && current.column == hexagonColumn[i]) {
                    [hexagons addObject:current];
                    break;
                }
            }
        }
    }
    return hexagons;
}

- (BOOL)_validateNextMoveToHexagon:(HDHexagon *)toHexagon fromHexagon:(HDHexagon *)fromHexagon
{
    if ( toHexagon.node == nil || (( ![_selectedHexagons count] ) && toHexagon.type != HDHexagonTypeStarter ))
        return NO;
    
    NSArray *possibleMoves = [self _possibleMovesForHexagon:fromHexagon];
    if ([possibleMoves containsObject:toHexagon] || toHexagon.type == HDHexagonTypeStarter) {
        
        for (HDSpriteNode *hexagonSprite in self.tileLayer.children) {
            [hexagonSprite updateTextureFromHexagonType:HDHexagonTypeNone];
        }
        
        NSArray *possibleMovesFromNewlySelectedTile = [self _possibleMovesForHexagon:toHexagon];
        for (HDHexagon *hexagonShape in possibleMovesFromNewlySelectedTile) {
            for (HDSpriteNode *hexagonSprite in self.tileLayer.children) {
                if (hexagonShape.row == hexagonSprite.row && hexagonShape.column == hexagonSprite.column) {
                    [hexagonSprite updateTextureFromHexagonType:hexagonShape.type ];
                    break;
                }
            }
        }
        return YES;
    }
    return NO;
}

- (SKEmitterNode *)_spaceNode
{
    SKTexture *texture = [SKTexture textureWithImageNamed:@"spark.png"];
    SKEmitterNode *stars = [SKEmitterNode node];
    [stars setEmissionAngle:(275.f * M_PI) / 180];
    [stars setParticleColor:[SKColor whiteColor]];
    [stars setParticleColorBlendFactor:.66f];
    [stars setParticleRotation:3.458f];
    [stars setParticleRotationRange:.39f];
    [stars setParticleRotationSpeed:1.79f];
    [stars setParticleTexture:texture];
    [stars setParticleBirthRate:20];
    [stars setParticleLifetime:15];
    [stars setParticleLifetimeRange:2];
    [stars setParticleScale:.07f];
    [stars setParticleScaleRange:.1f];
    [stars setXAcceleration:2.0f];
    [stars setYAcceleration:3.0f];
    [stars setParticleAlpha:.9f];
    [stars setParticleAlphaRange:.2f];
    [stars setParticleAlphaSpeed:.29f];
    [stars setParticlePosition:CGPointMake(0.0, CGRectGetHeight(self.frame))];
    [stars setParticlePositionRange:CGVectorMake(1000.0f, 0.0f)];
    [stars setParticleSpeed:40];
    [stars setParticleSpeedRange:80];
    [stars advanceSimulationTime:10.0f];
    [stars setParticleBlendMode:SKBlendModeAlpha];
    
    return stars;
}

#pragma mark -
#pragma mark - <HDHexagonDelegate>

- (void)unlockFollowingHexagonType:(HDHexagonType)type
{
    for (HDHexagon *hexagon in _hexagons) {
        if (hexagon.type == type + 1) {
            [hexagon setState:HDHexagonStateEnabled];
            [hexagon.node setFillColor:[SKColor flatEmeraldColor]];
            [hexagon.node.label setFontColor:[SKColor flatMidnightBlueColor]];
        }
    }
}

- (void)update:(NSTimeInterval)currentTime
{
    [_stars setParticleColor:((arc4random() % 2) == 0) ? [UIColor whiteColor] : [UIColor flatPeterRiverColor]];
}

@end
