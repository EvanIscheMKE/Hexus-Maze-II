//
//  HDScene.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/2/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDScene.h"
#import "HDHexagon.h"
#import "SKColor+HDColor.h"
#import "NSMutableArray+UniqueAdditions.h"
#import "UIImage+HDImage.h"
#import "HDHexagonNode.h"
#import "HDLevels.h"

static const CGFloat kTileHeightInsetMultiplier = .825f;

@interface HDScene ()
@property (nonatomic, strong) SKNode *gameLayer;
@property (nonatomic, assign) BOOL contentCreated;

@property (strong, nonatomic) SKAction *selectedSound;
@end

@implementation HDScene {
    
    NSArray *_hexagons;
    NSMutableArray *_selectedHexagons;
    NSUInteger _finishedTileCount;
    CGFloat _kTileSize;
    
}

@dynamic delegate;

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
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

- (void)layoutNodesWithGrid:(NSArray *)grid
{
    _finishedTileCount = grid.count;
    
    _hexagons = [[NSArray alloc] initWithArray:grid];
    for (HDHexagon *hexagon in grid) {
        
        CGPathRef pathRef = [[self hexagonPathForBounds:CGRectMake(0.0f, 0.0f, _kTileSize, _kTileSize)] CGPath];
        HDHexagonNode *shapeNode = [HDHexagonNode shapeNodeWithPath:pathRef centered:NO];
        [shapeNode setPosition:[self pointForColumn:hexagon.column row:hexagon.row]];
        [shapeNode setLineWidth:2.0f];
        [hexagon setNode:shapeNode];
        [hexagon setType:[[self.levels hexagonTypeAtRow:hexagon.row column:hexagon.column] intValue]];
        [self.gameLayer addChild:shapeNode];
        
    }
}

- (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row
{
    const CGFloat kOriginY = ((row * (_kTileSize * kTileHeightInsetMultiplier)) - (_kTileSize / 2));
    const CGFloat kOriginX = ((column * _kTileSize) - (_kTileSize / 2));
    const CGFloat kAlternateOffset = (row % 2 == 0) ? _kTileSize / 2.f : 0.0f;
    
    return CGPointMake(kAlternateOffset + kOriginX, kOriginY);
}

- (UIBezierPath *)hexagonPathForBounds:(CGRect)bounds
{
    const CGFloat kPadding = CGRectGetWidth(bounds) / 8 / 2;
    UIBezierPath *_path = [UIBezierPath bezierPath];
    [_path moveToPoint:CGPointMake(CGRectGetWidth(bounds) / 2, 0)];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) - kPadding, CGRectGetHeight(bounds) / 4)];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) - kPadding, CGRectGetHeight(bounds) * 3 / 4)];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) / 2, CGRectGetHeight(bounds))];
    [_path addLineToPoint:CGPointMake(kPadding, CGRectGetHeight(bounds) * 3 / 4)];
    [_path addLineToPoint:CGPointMake(kPadding, CGRectGetHeight(bounds) / 4)];
    [_path closePath];
    
    return _path;
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
   return (selectedHexagon.isSelected) ? nil : selectedHexagon;
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
    
    if ( hexagon == nil || ( ( ![_selectedHexagons count] ) && hexagon.type != HDHexagonTypeStarter ) )
        return;
    
    if ( [self _validateNextMoveToHexagon:hexagon fromHexagon:[_selectedHexagons lastObject] ] || (hexagon.type == HDHexagonTypeStarter) ) {
        [self.gameLayer runAction:self.selectedSound];
        [_selectedHexagons addUniqueObject:hexagon];
        [hexagon.node setFillColor:[SKColor redColor]];
        [hexagon recievedTouches];

        if ([self _checkIfAllHexagonsAreSelected] && [self.delegate respondsToSelector:@selector(gameOverWithCompletion:)]) {
            [self.delegate gameOverWithCompletion:YES];
        }
    }
}

- (void)performEntranceAnimation:(dispatch_block_t)handler
{
    
}

- (void)performCompletionAnimation:(dispatch_block_t)handler
{
    
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

- (BOOL)_validateNextMoveToHexagon:(HDHexagon *)toHexagon fromHexagon:(HDHexagon *)fromHexagon
{
    if (toHexagon.row == fromHexagon.row) {
        if (ABS((toHexagon.column  - fromHexagon.column)) == 1) {
            return YES;
        }
    }
 
    BOOL evenLine = (fromHexagon.row % 2 == 0);
    if ( (toHexagon.row == (fromHexagon.row + 1)) || (toHexagon.row == (fromHexagon.row - 1)) ) {
        if (toHexagon.column == (fromHexagon.column) || toHexagon.column == (fromHexagon.column + (evenLine ? 1 : -1) ) ) {
            return YES;
        }
    }
    
    return NO;
}

@end
