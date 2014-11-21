//
//  HDMapScene.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDGridManager.h"
#import "HDHelper.h"
#import "HDHexagon.h"
#import "HDMapScene.h"
#import "HDHexagonNode.h"
#import "SKColor+HDColor.h"

static const CGFloat kTileHeightInsetMultiplier = .845f;

@interface HDMapScene ()

@property (nonatomic, assign) BOOL contentCreated;

@property (nonatomic, strong) SKNode *gameLayer;

@end

@implementation HDMapScene {

    NSArray *_hexagons;
    NSMutableArray *_selectedHexagons;
    NSUInteger _finishedTileCount;
    CGFloat _kTileSize;
    
}

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
         self.gameLayer = [SKNode node];
        [self addChild:self.gameLayer];
        
        _selectedHexagons = [NSMutableArray array];
        
        _kTileSize = ceilf(CGRectGetWidth([[UIScreen mainScreen] bounds]) / (NumberOfColumns - 1));
        
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
 
    if (hexagon){
        [self setPaused:YES];
        [ADelegate navigateToNewLevel:hexagon.node.label.text.integerValue];
    }
}

- (void)layoutNodesWithGrid:(NSArray *)grid
{
    _hexagons = [NSArray arrayWithArray:grid];
    
    for (HDHexagon *hexagon in grid) {
        
        CGPathRef pathRef = [HDHelper hexagonPathForBounds:CGRectMake(0.0f, 0.0f, _kTileSize, _kTileSize)];
        
        HDHexagonNode *shapeNode = [HDHexagonNode shapeNodeWithPath:pathRef centered:YES];
        [shapeNode setPosition:[self pointForColumn:hexagon.column row:hexagon.row]];
        [hexagon setNode:shapeNode];
        [hexagon setType:HDHexagonTypeRegular];
        [self.gameLayer addChild:shapeNode];
        
        NSInteger levelIndex = [self.gridManager hexagonTypeAtRow:hexagon.row column:hexagon.column];
        [shapeNode updateLabelWithText:[NSString stringWithFormat:@"%ld",levelIndex]
                                 color:[SKColor whiteColor]];
        
    }
}

- (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row
{
    const CGFloat kOriginY = ((row * (_kTileSize * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = ((column * _kTileSize) );
    const CGFloat kAlternateOffset = (row % 2 == 0) ? _kTileSize / 2.f : 0.0f;
    
    return CGPointMake(kAlternateOffset + kOriginX, kOriginY);
}

@end
