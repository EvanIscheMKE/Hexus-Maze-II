//
//  HDScene.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import AVFoundation;

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

#define HEXAGON_TITLE(x) [NSString stringWithFormat:@"HEXAGON%ld",x]

#define _kTileSize [[UIScreen mainScreen] bounds].size.width / (NumberOfColumns - 1)

static const CGFloat kTileHeightInsetMultiplier = .845f;
@interface HDScene ()<HDHexagonDelegate>

@property (nonatomic, strong) SKAction *selectedSound;

@property (nonatomic, assign) BOOL animating;

@property (nonatomic, strong) SKNode *gameLayer;
@property (nonatomic, strong) SKNode *tileLayer;

@end

@implementation HDScene {
    
    NSArray *_hexagons;
    NSMutableArray *_selectedHexagons;
    NSMutableArray *_moves;
    
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
        
        _moves            = [NSMutableArray array];
        _selectedHexagons = [NSMutableArray array];
        
        [self _preloadSounds];
        [self setBackgroundColor:[SKColor flatMidnightBlueColor]];
        
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
    for (NSInteger row = 0; row < NumberOfRows; row++) {
        for (NSInteger column = 0; column < NumberOfColumns; column++) {
            
            if ([self.gridManager hexagonTypeAtRow:row column:column]) {
                
                CGSize tileSize = CGSizeMake(_kTileSize, _kTileSize);
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
    _startingTileCount = 0;
    _startingTilesUsed = 0;
    
    _finishedTileCount = grid.count;
    
    _hexagons = [NSArray arrayWithArray:grid];
    
    NSMutableArray *shuffledTiles = [_hexagons mutableCopy];
    [shuffledTiles shuffle];
    
    NSInteger index = 0;
    for (HDHexagon *hexagon in grid) {
        
        // Loop through and creat a shapenode for HDHexagon class
        CGPathRef pathRef = [HDHelper hexagonPathForBounds:CGRectMake(0.0f, 0.0f, _kTileSize, _kTileSize)];
        
        CGPoint center = [self _pointForColumn:hexagon.column row:hexagon.row];
        HDHexagonNode *shapeNode = [HDHexagonNode shapeNodeWithPath:pathRef centered:YES];
        [shapeNode setHidden:YES];
        [shapeNode setPosition:center];
        [shapeNode setName:HEXAGON_TITLE(index)];
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
        [self _performEntranceAnimationWithTiles:shuffledTiles delay:0 completion:nil];
    }];
}

- (void)restart
{
    if (self.animating) {
        return;
    }
    
    self.animating = YES;
    
    // Return count to ZERO
    _startingTileCount = 0;
    _startingTilesUsed = 0;
    
    // Clear out Array
    _selectedHexagons = [NSMutableArray array];
    
    // Shuffle a copy of tiles Array to prepare for animations
    NSMutableArray *shuffledTiles = [_hexagons mutableCopy];
    [shuffledTiles shuffle];
    
    // Restore tiles to their inital state
    NSTimeInterval delay = 0.0f;
    for (HDHexagon *tile in shuffledTiles) {
        [tile.node runAction: [SKAction sequence:@[[SKAction waitForDuration:delay],[SKAction scaleTo:0.0f duration:.3f]]]];
        [tile restoreToInitialState];
        delay += .025f;
    }
    
    // Clear out lower indicator layer
    for (HDSpriteNode *hexagonSprite in self.tileLayer.children) {
        [hexagonSprite updateTextureFromHexagonType:HDHexagonTypeNone];
    }
    
    //Animate restart once animating outs completed
    [self _performEntranceAnimationWithTiles:shuffledTiles delay:delay completion:^{
        [self setAnimating:NO];
    }];
}

- (void)reversePreviousMove
{
    if (!_moves.count || self.animating) {
        return;
    }
    
    [self setAnimating:YES];
    
    // Loop through tiles to find node that matches the last selected node and restore to previous state
    for (HDHexagon *hexaNode in _hexagons) {
        if ([hexaNode.node.name isEqualToString:[_moves lastObject]]) {
            [hexaNode returnToPreviousState];
            break;
        }
    }
    
    //
    [_moves removeLastObject];
    [_selectedHexagons removeLastObject];
    
    //Clear lower indicator images to transparent
    for (HDSpriteNode *hexagonSprite in self.tileLayer.children) {
        [hexagonSprite updateTextureFromHexagonType:HDHexagonTypeNone];
    }
    
    // Find all possible moves for newly selected tile
    NSArray *possibleMovesFromNewlySelectedTile = [self _possibleMovesForHexagon:[_selectedHexagons lastObject]];
    
    // Display "Possible Move" indicator on tiles found ^
    for (HDHexagon *hexagonShape in possibleMovesFromNewlySelectedTile) {
        for (HDSpriteNode *hexagonSprite in self.tileLayer.children) {
            if (hexagonShape.row == hexagonSprite.row && hexagonShape.column == hexagonSprite.column) {
                [hexagonSprite updateTextureFromHexagonType:hexagonShape.type touchesCount:hexagonShape.touchesCount];
                break;
            }
        }
    }
    [self setAnimating:NO];
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
        
        [_moves addObject:hexagon.node.name];
        [self.gameLayer runAction:self.selectedSound];
        [_selectedHexagons addObject:hexagon];
        [hexagon recievedTouches];
        
        [self _checkGameStatusAfterSelectingTile:hexagon];
        
    }
}

#pragma mark -
#pragma mark - < Private >

- (CGPoint)_pointForColumn:(NSInteger)column row:(NSInteger)row
{
    const CGFloat kOriginY = ((row * (_kTileSize * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = ((column * _kTileSize) );
    const CGFloat kAlternateOffset = (row % 2 == 0) ? _kTileSize / 2.f : 0.0f;
    
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

- (void)_checkGameStatusAfterSelectingTile:(HDHexagon *)hexagon
{
    
    /*
     
     WORK ON THIS
     
     LOOP THROUGH AND CHECK EACH NODE FOR
     
    */
    
    if ([self _checkIfAllHexagonsAreSelected]) {
        [self _performCompletionAnimation:^{
            // Won Game
            
            if ([ADelegate previousLevel]) {
                [[HDMapManager sharedManager] completedLevelAtIndex:[ADelegate previousLevel]];
            }
            
            HDAlertNode *alertNode = [HDAlertNode spriteNodeWithColor:[UIColor clearColor] size:self.frame.size];
            [alertNode setPosition:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)];
            [self addChild:alertNode];
            
            [alertNode show];
        }];
    } else if (![[self _possibleMovesForHexagon:hexagon] count] && _startingTilesUsed == ( _startingTileCount - 1 )){
        
        [self _performCompletionAnimation:^{
            // Lost Game
            
            HDAlertNode *alertNode = [HDAlertNode spriteNodeWithColor:[UIColor clearColor] size:self.frame.size];
            [alertNode setPosition:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)];
            [self addChild:alertNode];
            
            [alertNode show];
            
        }];
        
    } else if (![[self _possibleMovesForHexagon:hexagon] count]) {
        // Some count iVar that i dont remeber what it does ;)
        _startingTilesUsed++;
    }
}

- (void)_performEntranceAnimationWithTiles:(NSMutableArray *)tiles delay:(NSTimeInterval)delay completion:(dispatch_block_t)handler
{
    /* KEEP READING TRYING TO FIND A BETTER WAY TO DO THIS */
    
    NSUInteger count = tiles.count;
    
    NSTimeInterval _delay = delay;
    
    // Setup actions for base tiles
    SKAction *show  = [SKAction unhide];
    SKAction *scale = [SKAction scaleTo:0.0f  duration:0.0f];
    SKAction *pop   = [SKAction scaleTo:1.15f duration:.3f];
    SKAction *size  = [SKAction scaleTo:1.0f  duration:.3f];
    
    // setup actions for children nodes
    SKAction *doubleTouch = [SKAction moveTo:CGPointMake(1.0f, 1.0f) duration:.5f];
    SKAction *tripleTouch = [SKAction sequence: @[[SKAction waitForDuration:.75f], doubleTouch]];
    
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
                                 completion = (.5f > completion) ? .5f : current;
                                 [[hexa.node childNodeWithName:DOUBLE_KEY] runAction:doubleTouch];
                                 
                                 if ([[[hexa.node children] lastObject] childNodeWithName:TRIPLE_KEY]) {
                                     completion = (1.0f > completion) ? 1.0f : current;
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
        _delay += .05f;
    }
}

- (void)_performCompletionAnimation:(dispatch_block_t)handler
{
    
    if (handler) {
       handler();
    }
}

- (void)_preloadSounds
{
    //Preload any sounds that are going to be played throughout the game
    self.selectedSound = [SKAction playSoundFileNamed:@"menuClicked.wav" waitForCompletion:YES];
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


#pragma mark -
#pragma mark - <HDHexagonDelegate>

- (void)unlockFollowingHexagonType:(HDHexagonType)type
{
    // Find next disabled tile and unlock it
    for (HDHexagon *hexagon in _hexagons) {
        if (hexagon.type == type + 1) {
            [hexagon unlock];
            break;
        }
    }
}

@end
