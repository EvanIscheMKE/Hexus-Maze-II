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
#import "HDSpriteNode.h"
#import "NSMutableArray+UniqueAdditions.h"
#import "UIBezierPath+HDBezierPath.h"
#import "HDMapManager.h"
#import "HDHexagonNode.h"
#import "HDGridManager.h"
#import "HDAlertNode.h"

#define HEXAGON_TITLE(x) [NSString stringWithFormat:@"HEXAGON%ld",x]

#define kBackgroundHexSize [[UIScreen mainScreen] bounds].size.width / 3

#define kTileSize [[UIScreen mainScreen] bounds].size.width / (NumberOfColumns - 1)

static const CGFloat kTileHeightInsetMultiplier = .845f;
@interface HDScene ()<HDHexagonDelegate, HDAlertnodeDelegate>

@property (nonatomic, strong) SKAction *c2;
@property (nonatomic, strong) SKAction *d2;
@property (nonatomic, strong) SKAction *e2;
@property (nonatomic, strong) SKAction *f2;
@property (nonatomic, strong) SKAction *g2;
@property (nonatomic, strong) SKAction *a2;
@property (nonatomic, strong) SKAction *b2;

@property (nonatomic, strong) SKAction *c3;
@property (nonatomic, strong) SKAction *d3;
@property (nonatomic, strong) SKAction *e3;
@property (nonatomic, strong) SKAction *f3;
@property (nonatomic, strong) SKAction *g3;
@property (nonatomic, strong) SKAction *a3;
@property (nonatomic, strong) SKAction *b3;

@property (nonatomic, strong) SKAction *c4;
@property (nonatomic, strong) SKAction *d4;
@property (nonatomic, strong) SKAction *e4;
@property (nonatomic, strong) SKAction *f4;
@property (nonatomic, strong) SKAction *g4;
@property (nonatomic, strong) SKAction *a4;
@property (nonatomic, strong) SKAction *b4;

@property (nonatomic, strong) SKAction *c5;
@property (nonatomic, strong) SKAction *d5;
@property (nonatomic, strong) SKAction *e5;
@property (nonatomic, strong) SKAction *f5;
@property (nonatomic, strong) SKAction *g5;
@property (nonatomic, strong) SKAction *a5;
@property (nonatomic, strong) SKAction *b5;

@property (nonatomic, strong) SKAction *c6;
@property (nonatomic, strong) SKAction *d6;
@property (nonatomic, strong) SKAction *e6;
@property (nonatomic, strong) SKAction *f6;
@property (nonatomic, strong) SKAction *g6;
@property (nonatomic, strong) SKAction *a6;
@property (nonatomic, strong) SKAction *b6;

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL countDownForSoundIndex;
@property (nonatomic, assign) BOOL tilesAnimatedToCompleted;

@property (nonatomic, strong) SKNode *gameLayer;
@property (nonatomic, strong) SKNode *tileLayer;

@end

@implementation HDScene {
    
    NSArray *_sounds;
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
    
    NSInteger _soundIndex;
    
}

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        self.countDownForSoundIndex = NO;
        
        [self _addBackgroundEffects];
        [self setBackgroundColor:[SKColor flatMidnightBlueColor]];
        
        _selectedHexagons = [NSMutableArray array];
        
        _sounds = [self _preloadSounds];
    
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

- (void)addUnderlyingIndicatorTiles
{
    // Loop through possible nodes, if a node exists create a layer underneath it to display indicator
    for (NSInteger row = 0; row < NumberOfRows; row++) {
        
        for (NSInteger column = 0; column < NumberOfColumns; column++) {
            
            if ([self.gridManager hexagonTypeAtRow:row column:column]) {
                
                CGSize tileSize = CGSizeMake(kTileSize, kTileSize);
                HDSpriteNode *tileNode = [HDSpriteNode spriteNodeWithColor:[UIColor clearColor] size:tileSize];
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
    _soundIndex = 0;
    _startingTileCount = 0;
    _startingTilesUsed = 0;
    
    _finishedTileCount = grid.count;
    
    _hexagons = [NSArray arrayWithArray:grid];
    
    NSMutableArray *shuffledTiles = [_hexagons mutableCopy];
    [shuffledTiles shuffle];
    
    NSInteger index = 0;
    for (HDHexagon *hexagon in grid) {
        
        // Loop through and create a shapenode for HDHexagon class
        CGPathRef pathRef = [HDHelper hexagonPathForBounds:CGRectMake(0.0f, 0.0f, kTileSize, kTileSize)];
        
        CGPoint center = [self _pointForColumn:hexagon.column row:hexagon.row];
        HDHexagonNode *shapeNode = [HDHexagonNode shapeNodeWithPath:pathRef centered:YES];
        [shapeNode setHidden:YES];
        [shapeNode setPosition:center];
        [shapeNode setName:HEXAGON_TITLE((long)index)];
        [hexagon setDelegate:self];
        [hexagon setNode:shapeNode];
        [hexagon setType:(int)[self.gridManager hexagonTypeAtRow:hexagon.row column:hexagon.column]];
        [self.gameLayer addChild:shapeNode];
        
        // Find the largest and smallest possible center position for all tiles, will be used to center map
        if ((center.x) < _minCenterX) { _minCenterX = (center.x); }
        if ((center.x) > _maxCenterX) { _maxCenterX = (center.x); }
        if ((center.y) < _minCenterY) { _minCenterY = (center.y); }
        if ((center.y) > _maxCenterY) { _maxCenterY = (center.y); }
        
        if (hexagon.type == HDHexagonTypeStarter) {
            _startingTileCount++;
        }
        index++;
    }
    
    // Once all Tiles are layed out, center them
    [self _centerTilePositionWithCompletion:^{
        [self _performEntranceAnimationWithTiles:shuffledTiles completion:nil];
    }];
}

- (HDSpriteNode *)lowerSpriteNodeForHexagon:(HDHexagon *)hexagon
{
    for (HDSpriteNode *hexa in self.tileLayer.children) {
        if (hexa.row == hexagon.row && hexagon.column == hexa.column) {
            return hexa;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark - UIResp0nder

- (HDHexagon *)findHexagonFromPoint:(CGPoint)point
{
    const CGFloat kHexagonInset = 2.0f;
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
    
    // Find the node located under the touch
    HDHexagon *hexagon = [self findHexagonFromPoint:location];
    
    HDHexagon *previousTile = [_selectedHexagons lastObject];
    
    // If the newly selected node is connected to previously selected node.. prooccceeed
    if ([self _validateNextMoveToHexagon:hexagon fromHexagon:previousTile]) {
        
        [hexagon.node runAction:[SKAction scaleTo:.9f duration:.15f] completion:^{
            [hexagon.node runAction:[SKAction scaleTo:1.0f duration:.15f]];
        }];
        
        [_selectedHexagons addObject:hexagon];
        [hexagon recievedTouches];
        
        HDSpriteNode *sprite = [self lowerSpriteNodeForHexagon:hexagon];
        [sprite addChild:[self _hexaEmitterWithColor:hexagon.node.strokeColor
                                               scale:hexagon.selected ? .9f : .5f
                                                time:.65f
                                        numParticles:20]];
        
        [self _checkGameState:hexagon];
        [self _playSoundAndVibration:hexagon];
    }
}

#pragma mark -
#pragma mark - <PRIVATE>

- (void)_playSoundAndVibration:(HDHexagon *)hexagon
{
    [self runAction:[_sounds objectAtIndex:_soundIndex]];
    
    if (self.countDownForSoundIndex) {
        _soundIndex--;
        
        if (_soundIndex == 0) {
            [self setCountDownForSoundIndex:NO];
        }
    } else {
        _soundIndex++;
        
        if (_soundIndex == _sounds.count - 1) {
            [self setCountDownForSoundIndex:YES];
        }
    }
    
    switch (hexagon.type) {
        case HDHexagonTypeStarter:
             AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
        case HDHexagonTypeOne:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
        case HDHexagonTypeTwo:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
        case HDHexagonTypeThree:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
        case HDHexagonTypeFour:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
        case HDHexagonTypeFive:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
    }
}

- (void)_addBackgroundEffects
{
    SKTexture *blueTexture = [SKTexture textureWithImage:[self _backgroundHexagonWithColor:[UIColor flatPeterRiverColor]]];
    for (int i = 0; i < 15; i++) {
        
        SKSpriteNode *hexa = [SKSpriteNode spriteNodeWithTexture:blueTexture];
        [hexa setHidden:YES];
        [self addChild:hexa];
        
        CGRect randomBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        
        UIBezierPath *randomPath = [UIBezierPath randomPathFromBounds:randomBounds];
        
        SKAction *chanePositionRandomly = [SKAction followPath:[randomPath CGPath] asOffset:NO orientToPath:NO duration:100.0f];
        [hexa runAction:[SKAction sequence:@[[SKAction unhide],[SKAction repeatActionForever:chanePositionRandomly]]]];
    }
}

- (CGPoint)_pointForColumn:(NSInteger)column row:(NSInteger)row
{
    const CGFloat kOriginY = ((row * (kTileSize * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = ((column * kTileSize) );
    const CGFloat kAlternateOffset = (row % 2 == 0) ? kTileSize / 2.f : 0.0f;
    
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

- (void)_checkGameState:(HDHexagon *)hexagon
{
    if ([self _checkIfAllHexagonsAreSelected]) {
        // Won Game
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [[HDMapManager sharedManager] completedLevelAtIndex:_levelIndex];
        
        // Wait For Alertnode to be halfway through animating before adding emittercell
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self insertChild:[self _starEmitterNode] atIndex:0];
//        });
        
        
        NSTimeInterval delay = 2.0f;
            for (HDHexagon *hexagon in [[_selectedHexagons reverseObjectEnumerator] allObjects]) {
                
                SKAction *scale    = [SKAction scaleTo:0.0f duration:0.10f];
                SKAction *wait     = [SKAction waitForDuration:delay];
                SKAction *sequence = [SKAction sequence:@[wait, scale]];

                [hexagon.node runAction:sequence completion:^{
                    SKColor *oldStrokeColor = hexagon.node.strokeColor;
                    
                    [self _playSoundAndVibration:hexagon];
                    
                    [hexagon.node setStrokeColor:[SKColor clearColor] fillColor:[SKColor clearColor]];
                    [hexagon.node setScale:1.0f];
                    [hexagon.node addChild:[self _hexaEmitterWithColor:oldStrokeColor
                                                                 scale:1.5f
                                                                  time:1.5f
                                                          numParticles:15]];
                }];
                
                delay += .1f;
            }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            HDAlertNode *alertNode = [HDAlertNode spriteNodeWithColor:[UIColor clearColor] size:self.frame.size];
            [alertNode.levelLabel setText:[NSString stringWithFormat:@"Level %ld", _levelIndex]];
            [alertNode setDelegate:self];
            [alertNode setPosition:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)];
            [self addChild:alertNode];
            [alertNode show];
 
        });
        
        return;
    }
    
    //    if (hexagon.type == HDHexagonTypeStarter) {
    //        _startingTilesUsed++;
    //    }
    //
    //    // Find out how many tiles are left in play
    //    NSInteger count = 0;
    //    for (HDHexagon *hexa in _hexagons) {
    //        if (hexa.selected) {
    //            count++;
    //        }
    //    }
    //
    //    NSInteger tilesLeft = _finishedTileCount - count;
    //
    //    // Loop through array to find out if any tile has no posbbile moves left, proceed accordingly
    //    HDHexagon *current = nil;
    //    for (HDHexagon *hexa in _hexagons) {
    //        if (!hexa.selected) {
    //            if (![self _possibleMovesForHexagon:hexa].count && _startingTilesUsed ==  _startingTileCount && tilesLeft != 1) {
    //                current = hexa;
    //                break;
    //            }
    //        }
    //    }
    //
    //    if (current) {
    //            // When animation completes, restart to give use hint to use the damn thanggg
    //    }
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
    
    // C-Shit, finding all possible tiles that are connected to 'hexagon'
    NSInteger hexagonRow[6];
    hexagonRow[0] = hexagon.row;
    hexagonRow[1] = hexagon.row;
    hexagonRow[2] = hexagon.row + 1;
    hexagonRow[3] = hexagon.row + 1;
    hexagonRow[4] = hexagon.row - 1;
    hexagonRow[5] = hexagon.row - 1;
    
    NSInteger hexagonColumn[6];
    hexagonColumn[0] = hexagon.column + 1; // R== , C++
    hexagonColumn[1] = hexagon.column - 1; // R== , C--
    hexagonColumn[2] = hexagon.column;     // R++ , C==
    hexagonColumn[3] = hexagon.column + ((hexagon.row % 2 == 0) ? 1 : -1);
    hexagonColumn[4] = hexagon.column;     // R-- , C==
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
    
    // Find possible moves from currently selected tile
    NSArray *possibleMoves = [self _possibleMovesForHexagon:fromHexagon];
    
    if ([possibleMoves containsObject:toHexagon] || toHexagon.type == HDHexagonTypeStarter) {
        
        //Clear lower indicator images to transparent
        for (HDSpriteNode *hexagonSprite in self.tileLayer.children) {
            [hexagonSprite updateTextureFromHexagonType:HDHexagonTypeNone];
        }
        
        // Find all possible moves for newly selected tile
        NSArray *possibleMovesFromNewlySelectedTile = [self _possibleMovesForHexagon:toHexagon];
        
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

- (void)_naviageToNextLevel
{
    _minCenterX = MAXFLOAT;
    _maxCenterX = 0.0f;
    _minCenterY = MAXFLOAT;
    _maxCenterY = 0.0f;
    
    // Clear out Arrays
    [_selectedHexagons removeAllObjects];
    
    self.countDownForSoundIndex = NO;
    
    // Reduce retainCount
    [self.gameLayer removeAllChildren];
    [self.tileLayer removeAllChildren];
    
    // Call parent to refill model with next level's data, then call us back
    [[NSNotificationCenter defaultCenter] postNotificationName:HDNextLevelNotification object:nil];
}

#pragma mark -
#pragma mark - < RESTART >

- (void)restart
{
    if (self.animating) {
        return;
    }
    
    self.animating = YES;
    self.countDownForSoundIndex = NO;
    
    // Return used starting tile count to ZERO
    _startingTilesUsed = 0;
    
    _soundIndex = 0;
    
    // Clear out Arrays
    [_selectedHexagons removeAllObjects];
    
    // Shuffle a copy of tiles Array to prepare for animations
    __block NSMutableArray *shuffledTiles = [_hexagons mutableCopy];
    [shuffledTiles shuffle];
    
    // Clear out lower indicator layer
    for (HDSpriteNode *hexagonSprite in self.tileLayer.children) {
        [hexagonSprite updateTextureFromHexagonType:HDHexagonTypeNone];
    }
    
    // Animate out
    [self _performCompletionAnimationWithTiles:shuffledTiles completion:^{
        
        // Restore tiles to their inital state once off screen
        for (HDHexagon *hexa in _hexagons) {
            [hexa.node setScale:1.0f];
            [hexa restoreToInitialState];
        }
        
        // Animate restart once restored
        [self _performEntranceAnimationWithTiles:shuffledTiles completion:^{
            [self setAnimating:NO];
        }];
    }];
}

#pragma mark -
#pragma mark - < ANIMATIONS >

- (void)_performEntranceAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)handler
{
    NSUInteger count = tiles.count;
    
    NSTimeInterval _delay = 0;
    
    // Setup actions for base tiles
    SKAction *show  = [SKAction unhide];
    SKAction *scale = [SKAction scaleTo:0.0f  duration:0.0f];
    SKAction *pop   = [SKAction scaleTo:1.15f duration:.2f];
    SKAction *size  = [SKAction scaleTo:1.0f  duration:.2f];
    
    // setup actions for children nodes
    SKAction *doubleTouch = [SKAction moveTo:CGPointMake(1.0f, 1.0f) duration:.3f];
    SKAction *tripleTouch = [SKAction sequence: @[[SKAction waitForDuration:.4f], doubleTouch]];
    
    // Animate regular, start, and base tiles onto node with pop effect
    __block NSInteger index = 0;
    for (HDHexagon *hex in tiles) {
        
        NSArray *sequence =  @[[SKAction waitForDuration:_delay], scale, show, pop, size];
        
        [hex.node runAction:[SKAction sequence:sequence]
                 completion:^{
                     if (index == count - 1) {
                         
                         // Once base animation is complete, check for children and animate them in
                         NSTimeInterval completion = 0.0f;
                         for (HDHexagon *hexa in tiles) {
                             
                             NSTimeInterval current = completion;
                             if ([hexa.node childNodeWithName:DOUBLE_KEY]) {
                                 completion = (.3f > completion) ? .3f : current;
                                 [[hexa.node childNodeWithName:DOUBLE_KEY] runAction:doubleTouch];
                                 
                                 if ([[[hexa.node children] lastObject] childNodeWithName:TRIPLE_KEY]) {
                                     completion = (.7f > completion) ? .7f : current;
                                     [[[[hexa.node children] lastObject] childNodeWithName:TRIPLE_KEY] runAction:tripleTouch];
                                 }
                             }
                         }
                         
                         // after animations complete, call completion block
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(completion * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             if (handler) {
                                 handler();
                             }
                         });
                     }
                     index++;
                 }];
        _delay += .025f;
    }
}

- (void)_performCompletionAnimationWithTiles:(NSArray *)tiles completion:(dispatch_block_t)handler
{
    // Array count --;
    NSUInteger countTo = tiles.count -1;
    
    // Scale to zero
    SKAction *scale = [SKAction scaleTo:0.0f duration:.2f];
    
    // Loop through tiles and scale to zilch
    __block NSInteger index = 0;
    NSTimeInterval delay = 0.0f;
    for (HDHexagon *tile in tiles) {
        
        // Setup actions
        SKAction *wait     = [SKAction waitForDuration:delay];
        SKAction *hide     = [SKAction hide];
        SKAction *sequence = [SKAction sequence:@[wait, scale, hide]];
        
        [tile.node runAction:sequence
                  completion:^{
                    
                      if (index == countTo) {
                          if (handler) {
                              handler();
                          }
                      }
                      index++;
                  }];
        delay += .025f;
    }
}

#pragma mark - 
#pragma mark - <HDAlertNodeDelegate>

- (void)alertNodeWillDismiss:(HDAlertNode *)alertNode
{
    [self runAction:self.c4];
    [[[self children] firstObject] removeFromParent];
}

- (void)alertNode:(HDAlertNode *)alertNode clickedButtonAtIndex:(NSInteger)index
{
    if (index == 0) {
        [self _naviageToNextLevel];
        return;
    }
    [self restart];
}

#pragma mark -
#pragma mark - <HDHexagonDelegate>

- (void)unlockFollowingHexagonType:(HDHexagonType)type
{
    // Find next disabled 'count' tile and unlock it
    for (HDHexagon *hexagon in _hexagons) {
        if (hexagon.type == type + 1 && !hexagon.selected && hexagon.isCountTile) {
            [hexagon setLocked:NO];
            return;
        }
    }
}

- (UIImage *)_backgroundHexagonWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(kBackgroundHexSize, kBackgroundHexSize), NO, [[UIScreen mainScreen] scale]);
    
    [[color colorWithAlphaComponent:.1f] setFill];
    
    CGRect bezierBounds = CGRectMake(0.0f, 0.0f, kBackgroundHexSize, kBackgroundHexSize);
    
    UIBezierPath *hexagonBeizer = [UIBezierPath bezierPathWithCGPath:[HDHelper hexagonPathForBounds:bezierBounds]];
    
    [hexagonBeizer fill];
    
    UIImage *hexagon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return hexagon;
}

#pragma mark-
#pragma mark - Emitter Cells

- (SKEmitterNode *)_starEmitterNode
{
    // stars shooting from center point.. used on level completion
    SKEmitterNode *emitter = [SKEmitterNode node];
    [emitter setParticleBirthRate:100];
    [emitter setParticleTexture:[SKTexture textureWithImageNamed:@"star.png"]];
    [emitter setParticleColor:[SKColor flatEmeraldColor]];
    [emitter setParticleLifetime:2.0f];
    [emitter setAlpha:.5];
    [emitter setParticleAlphaRange:.5f];
    [emitter setParticlePosition:CGPointMake(CGRectGetWidth(self.frame) / 2, (CGRectGetHeight(self.frame) / 2))];
    [emitter setParticleSpeed:300.0f];
    [emitter setEmissionAngle:89.0f];
    [emitter setParticleScale:1.0f];
    [emitter setEmissionAngleRange:350.0f];
    [emitter setParticleBlendMode:SKBlendModeAlpha];
    [emitter setParticleColorBlendFactor:1.0];
    [emitter advanceSimulationTime:.5f];
    [emitter setYAcceleration:0];
    
    return emitter;
}

- (SKEmitterNode *)_hexaEmitterWithColor:(UIColor *)skColor scale:(CGFloat)scale time:(NSTimeInterval)time numParticles:(NSUInteger)num
{
    // shoots little hexagons when node is selected
    SKEmitterNode *emitter = [SKEmitterNode node];
    [emitter setNumParticlesToEmit:num];
    [emitter setParticleBirthRate:num];
    [emitter setParticleTexture:[SKTexture textureWithImageNamed:@"hexagon.png"]];
    [emitter setParticleColor:skColor];
    [emitter setParticleLifetime:1.0f];
    [emitter setParticleAlphaRange:.5f];
    [emitter setParticlePosition:CGPointMake(0.0, 0.0)];
    [emitter setParticleSpeed:500.0f];
    [emitter setEmissionAngle:89.0f];
    [emitter setParticleScale:scale];
    [emitter setEmissionAngleRange:350.0f];
    [emitter setParticleBlendMode:SKBlendModeAlpha];
    [emitter setParticleColorBlendFactor:1.0];
    [emitter advanceSimulationTime:time];
    [emitter setYAcceleration:0];
    
    return emitter;
}


- (NSArray *)_preloadSounds
{
    //Preload any sounds that are going to be played throughout the game
    
    //    // #2's
    //    self.c2 = [SKAction playSoundFileNamed:@"C2.m4a" waitForCompletion:YES];
    //    self.d2 = [SKAction playSoundFileNamed:@"D2.m4a" waitForCompletion:YES];
    //    self.e2 = [SKAction playSoundFileNamed:@"E2.m4a" waitForCompletion:YES];
    //    self.f2 = [SKAction playSoundFileNamed:@"F2.m4a" waitForCompletion:YES];
    //    self.g2 = [SKAction playSoundFileNamed:@"G2.m4a" waitForCompletion:YES];
    //    self.a2 = [SKAction playSoundFileNamed:@"A2.m4a" waitForCompletion:YES];
    //    self.b2 = [SKAction playSoundFileNamed:@"B2.m4a" waitForCompletion:YES];
    
    // #3's
    self.c3 = [SKAction playSoundFileNamed:@"C3.m4a" waitForCompletion:YES];
    self.d3 = [SKAction playSoundFileNamed:@"D3.m4a" waitForCompletion:YES];
    self.e3 = [SKAction playSoundFileNamed:@"E3.m4a" waitForCompletion:YES];
    self.f3 = [SKAction playSoundFileNamed:@"F3.m4a" waitForCompletion:YES];
    self.g3 = [SKAction playSoundFileNamed:@"G3.m4a" waitForCompletion:YES];
    self.a3 = [SKAction playSoundFileNamed:@"A3.m4a" waitForCompletion:YES];
    self.b3 = [SKAction playSoundFileNamed:@"B3.m4a" waitForCompletion:YES];
    
    // #4's
    self.c4 = [SKAction playSoundFileNamed:@"C4.m4a" waitForCompletion:YES];
    self.d4 = [SKAction playSoundFileNamed:@"D4.m4a" waitForCompletion:YES];
    self.e4 = [SKAction playSoundFileNamed:@"E4.m4a" waitForCompletion:YES];
    self.f4 = [SKAction playSoundFileNamed:@"F4.m4a" waitForCompletion:YES];
    self.g4 = [SKAction playSoundFileNamed:@"G4.m4a" waitForCompletion:YES];
    self.a4 = [SKAction playSoundFileNamed:@"A4.m4a" waitForCompletion:YES];
    self.b4 = [SKAction playSoundFileNamed:@"B4.m4a" waitForCompletion:YES];
    
    // #5's
    self.c5 = [SKAction playSoundFileNamed:@"C5.m4a" waitForCompletion:YES];
    self.d5 = [SKAction playSoundFileNamed:@"D5.m4a" waitForCompletion:YES];
    self.e5 = [SKAction playSoundFileNamed:@"E5.m4a" waitForCompletion:YES];
    self.f5 = [SKAction playSoundFileNamed:@"F5.m4a" waitForCompletion:YES];
    self.g5 = [SKAction playSoundFileNamed:@"G5.m4a" waitForCompletion:YES];
    self.a5 = [SKAction playSoundFileNamed:@"A5.m4a" waitForCompletion:YES];
    self.b5 = [SKAction playSoundFileNamed:@"B5.m4a" waitForCompletion:YES];
    
    // #6's
    self.c6 = [SKAction playSoundFileNamed:@"C6.m4a" waitForCompletion:YES];
    self.d6 = [SKAction playSoundFileNamed:@"D6.m4a" waitForCompletion:YES];
    self.e6 = [SKAction playSoundFileNamed:@"E6.m4a" waitForCompletion:YES];
    self.f6 = [SKAction playSoundFileNamed:@"F6.m4a" waitForCompletion:YES];
    self.g6 = [SKAction playSoundFileNamed:@"G6.m4a" waitForCompletion:YES];
    self.a6 = [SKAction playSoundFileNamed:@"A6.m4a" waitForCompletion:YES];
    self.b6 = [SKAction playSoundFileNamed:@"B6.m4a" waitForCompletion:YES];
    
    return @[
             self.c3, self.d3, self.e3, self.f3, self.g3, self.a3, self.b3,
             self.c4, self.d4, self.e4, self.f4, self.g4, self.a4, self.b4,
             self.c5, self.d5, self.e5, self.f5, self.g5, self.a5, self.b5,
             self.c6, self.d6, self.e6, self.f6, self.g6, self.a6, self.b6];
}
@end
