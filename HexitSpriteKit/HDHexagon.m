//
//  HDHexagon.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDHexagon.h"
#import "SKColor+HDColor.h"
#import "HDHexagonNode.h"

NSString * const HDDoubleKey = @"double";
NSString * const HDTripleKey = @"triple";

@interface HDHexagon ()
@property (nonatomic, assign) NSInteger touchesCount;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
@end

@implementation HDHexagon

- (instancetype)init
{
    return [self initWithRow:0 column:0];
}

- (instancetype)initWithRow:(NSInteger)row column:(NSInteger)column
{
    NSParameterAssert(row);
    if (self = [super init]) {
        self.touchesCount = 0;
        self.row    = row;
        self.column = column;
        self.state  = HDHexagonStateEnabled;
    }
    return self;
}

- (void)setType:(HDHexagonType)type
{
    if (self.node == nil) {
        return;
    }
    
    _type = type;
    
    switch (type) {
        case HDHexagonTypeRegular:
            [self.node setStrokeColor:[SKColor flatPeterRiverColor]
                            fillColor:[SKColor flatMidnightBlueColor]];
            break;
        case HDHexagonTypeStarter:
            [self.node setStrokeColor:[SKColor whiteColor]
                            fillColor:[SKColor flatMidnightBlueColor]];
            break;
        case HDHexagonTypeDouble:
            [self.node setStrokeColor:[SKColor flatTurquoiseColor]
                            fillColor:[SKColor flatMidnightBlueColor]];
            
            [self.node addDoubleNodeWithStroke:self.node.strokeColor
                                          fill:[SKColor flatMidnightBlueColor]];
            break;
        case HDHexagonTypeTriple:
            [self.node setStrokeColor:[SKColor flatSilverColor]
                            fillColor:[SKColor flatMidnightBlueColor]];
            
            [self.node addDoubleNodeWithStroke:self.node.strokeColor
                                          fill:[SKColor flatMidnightBlueColor]];
            
            [self.node addTripleNodeWithStroke:self.node.strokeColor
                                          fill:[SKColor flatMidnightBlueColor]];
            break;
        case HDHexagonTypeEnd:
            self.state = HDHexagonStateDisabled;
            [self.node setStrokeColor:[SKColor flatAlizarinColor]
                            fillColor:[SKColor flatMidnightBlueColor]];
            break;
        case HDHexagonTypeOne:
            self.countTile = YES;
            [self.node setStrokeColor:[SKColor flatEmeraldColor]
                            fillColor:[SKColor flatMidnightBlueColor]];
            break;
        case HDHexagonTypeTwo:
            [self _disabledTileWithCountIndex:2];
            break;
        case HDHexagonTypeThree:
            [self _disabledTileWithCountIndex:3];
            break;
        case HDHexagonTypeFour:
            [self _disabledTileWithCountIndex:4];
            break;
        case HDHexagonTypeFive:
            [self _disabledTileWithCountIndex:5];
            break;
    }
}

- (BOOL)selectedAfterRecievingTouches
{
    if (self.isSelected) {
        return YES;
    };
    
    self.touchesCount++;
    
    switch (self.type) {
        case HDHexagonTypeRegular:
            self.selected = YES;
            break;
        case HDHexagonTypeStarter:
            self.selected = YES;
            break;
        case HDHexagonTypeDouble:
            switch (self.touchesCount) {
                case 1:{
                    SKShapeNode *shapeNode = (SKShapeNode *)[self.node childNodeWithName:HDDoubleKey];
                    [shapeNode removeFromParent];
                } break;
                case 2:
                    self.selected = YES;
                    break;
            } break;
        case HDHexagonTypeTriple:
            switch (self.touchesCount) {
                case 1:
                    [[[(SKShapeNode *)[[self.node children] lastObject] children] firstObject] removeFromParent];
                    break;
                case 2:
                    [self.node removeAllChildren];
                    break;
                case 3:
                    self.selected = YES;
                    break;
            } break;
        case HDHexagonTypeEnd:
            self.selected = YES;
            break;
        case HDHexagonTypeOne:
            self.selected = YES;
            break;
        case HDHexagonTypeTwo:
            self.selected = YES;
            break;
        case HDHexagonTypeThree:
            self.selected = YES;
            break;
        case HDHexagonTypeFour:
            self.selected = YES;
            break;
        case HDHexagonTypeFive:
            self.selected = YES;
            break;
    }
    return self.selected;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if (selected) {
        switch (self.type) {
            case HDHexagonTypeRegular:
                [self.node setFillColor:self.node.strokeColor];
                break;
            case HDHexagonTypeStarter:
                [self.node setFillColor:self.node.strokeColor];
                break;
            case HDHexagonTypeDouble:
                [self.node setFillColor:self.node.strokeColor];
                break;
            case HDHexagonTypeTriple:
                [self.node setFillColor:self.node.strokeColor];
                break;
            case HDHexagonTypeEnd:
                [self.node setFillColor:self.node.strokeColor];
                break;
            case HDHexagonTypeOne:
                [self _countTileWasSelectedForType:HDHexagonTypeOne];
                break;
            case HDHexagonTypeTwo:
                [self _countTileWasSelectedForType:HDHexagonTypeTwo];
                break;
            case HDHexagonTypeThree:
                [self _countTileWasSelectedForType:HDHexagonTypeThree];
                break;
            case HDHexagonTypeFour:
                [self _countTileWasSelectedForType:HDHexagonTypeFour];
                break;
            case HDHexagonTypeFive:
                [self _countTileWasSelectedForType:HDHexagonTypeFive];
                break;
        }
    }
}

- (void)setLocked:(BOOL)locked
{
    _locked = locked;
    
    if (!locked && self.state != HDHexagonStateEnabled) {
        self.state = HDHexagonStateEnabled;
        self.node.fillColor = [SKColor clearColor];
        [self.node runAction:[SKAction rotateByAngle:-(M_PI * 2) duration:.2f]];
        self.node.locked = NO;
    }
}

- (void)restoreToInitialState
{
    [self.node removeAllChildren];
    self.touchesCount = 0;
    self.selected     = NO;
    self.node.locked  = NO;
    self.state        = HDHexagonStateEnabled;
    self.type         = self.type;
}

#pragma mark -
#pragma mark - Private

- (void)_disabledTileWithCountIndex:(NSInteger)count
{
    self.countTile   = YES;
    self.node.locked = YES;
    self.state = HDHexagonStateDisabled;
    [self.node setStrokeColor:[SKColor flatEmeraldColor] fillColor:[SKColor clearColor]];
}

- (void)_countTileWasSelectedForType:(HDHexagonType)type
{
    [self.node setFillColor:self.node.strokeColor];
    if ([self.delegate respondsToSelector:@selector(hexagon:unlockedCountTile:)] && type != HDHexagonTypeFive) {
        [self.delegate hexagon:self unlockedCountTile:type];
    }
}

@end
