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
#import "UIImage+HDImage.h"
#import "HDHexagonNode.h"
#import "HDGridManager.h"
#import "HDAlertNode.h"

static const CGFloat kTileHeightInsetMultiplier = .845f;

@interface HDScene ()<HDHexagonDelegate>

@property (nonatomic, strong) SKAction *selectedSound;
@property (nonatomic, assign) BOOL contentCreated;

@property (nonatomic, strong) SKNode *gameLayer;
@property (nonatomic, strong) SKNode *tileLayer;

@end

@implementation HDScene {
    
    NSArray *_hexagons;
    NSMutableArray *_selectedHexagons;
    NSUInteger _finishedTileCount;
    CGFloat _kTileSize;
    
    NSUInteger _startingTileCount;
    NSInteger _startingTilesUsed;
    
}

@dynamic delegate;
- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
         self.tileLayer = [SKNode node];
        [self addChild:self.tileLayer];
        
         self.gameLayer = [SKNode node];
        [self addChild:self.gameLayer];
        
        _selectedHexagons = [NSMutableArray array];
        
        _kTileSize = ceilf(CGRectGetWidth([[UIScreen mainScreen] bounds]) / (NumberOfColumns - 1));
        
        [self _preloadSounds];
        [self setBackgroundColor:[SKColor flatMidnightBlueColor]];
    
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
                [tileNode setPosition:[self pointForColumn:column row:row]];
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
    
    for (HDHexagon *hexagon in grid) {
        
        CGPathRef pathRef = [HDHelper hexagonPathForBounds:CGRectMake(0.0f, 0.0f, _kTileSize, _kTileSize)];
        
        HDHexagonNode *shapeNode = [HDHexagonNode shapeNodeWithPath:pathRef centered:YES];
        [shapeNode setPosition:[self pointForColumn:hexagon.column row:hexagon.row]];
        [hexagon setDelegate:self];
        [hexagon setNode:shapeNode];
        [hexagon setType:(int)[self.gridManager hexagonTypeAtRow:hexagon.row column:hexagon.column]];
        [self.gameLayer addChild:shapeNode];
        
        if (hexagon.type == HDHexagonTypeStarter) {
            _startingTileCount++;
        }
    }
}

- (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row
{
    const CGFloat kOriginY = ((row * (_kTileSize * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = ((column * _kTileSize) );
    const CGFloat kAlternateOffset = (row % 2 == 0) ? _kTileSize / 2.f : 0.0f;
    
    return CGPointMake(kAlternateOffset + kOriginX, kOriginY);
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

- (void)_checkGameStatusAfterSelectingTile:(HDHexagon *)hexagon
{
    if ([self _checkIfAllHexagonsAreSelected]) {
        [self _performCompletionAnimation:^{
            NSLog(@"WON");
            
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[[SKColor flatMidnightBlueColor] colorWithAlphaComponent:.25f]
                                                                size:CGSizeMake(self.frame.size.width, self.frame.size.height)];
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

- (void)_performEnteranceAnimation:(dispatch_block_t)handler
{
    handler();
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
            [hexagonSprite updateTextureFromHexagonType:HDHexagonTypeNone direction:HDSpriteDirectionNone];
        }
        
        NSArray *possibleMovesFromNewlySelectedTile = [self _possibleMovesForHexagon:toHexagon];
        for (HDHexagon *hexagonShape in possibleMovesFromNewlySelectedTile) {
            for (HDSpriteNode *hexagonSprite in self.tileLayer.children) {
                if (hexagonShape.row == hexagonSprite.row && hexagonShape.column == hexagonSprite.column) {
                    int direction = [self _directionToTile:hexagonShape fromTile:toHexagon];
                    [hexagonSprite updateTextureFromHexagonType:hexagonShape.type direction:direction];
                    break;
                }
            }
        }
        return YES;
    }
    return NO;
}

- (HDSpriteDirection)_directionToTile:(HDHexagon *)toHexagon fromTile:(HDHexagon *)fromHexagon
{
    BOOL evenLine = (fromHexagon.row % 2 == 0);
    
    if (toHexagon.row == fromHexagon.row) {
        if (toHexagon.column == fromHexagon.column + 1) {
            return HDSpriteDirectionLeft;
        } else if (toHexagon.column == fromHexagon.column - 1){
            return HDSpriteDirectionRight;
        }
    }
    
    if (toHexagon.row == fromHexagon.row + 1) {
        if (toHexagon.column == fromHexagon.column) {
            if (evenLine){
                return HDSpriteDirectionDownRight;
            } else {
                return HDSpriteDirectionDownLeft;
            }
        } else if (toHexagon.column == fromHexagon.column + evenLine ? 1 : -1 ){
            if (evenLine){
                return HDSpriteDirectionDownLeft;
            } else {
                return HDSpriteDirectionDownRight;
            }
        }
    }
    
    if (toHexagon.row == fromHexagon.row - 1) {
        if (toHexagon.column == fromHexagon.column) {
            if (evenLine){
                return HDSpriteDirectionUpRight;
            } else {
                return HDSpriteDirectionUpLeft;
            }
        } else if (toHexagon.column == fromHexagon.column + evenLine ? 1 : -1) {
            if (evenLine){
                return HDSpriteDirectionUpLeft;
            } else {
                return HDSpriteDirectionUpRight;
            }
        }
    }
    return HDSpriteDirectionNone;
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

@end
