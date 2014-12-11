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

NSString * const DOUBLE_KEY = @"double";
NSString * const TRIPLE_KEY = @"triple";
@implementation HDHexagon{
    NSInteger _recievedTouchesCount;
}

- (instancetype)init
{
    return [self initWithRow:0 column:0];
}

- (instancetype)initWithRow:(NSInteger)row column:(NSInteger)column
{
    if (self = [super init]) {
        
        NSParameterAssert(row);
        NSParameterAssert(column);
        
        _recievedTouchesCount = 0;
        
        [self setRow:row];
        [self setColumn:column];
        [self setState:HDHexagonStateEnabled];
    }
    return self;
}

- (NSInteger)touchesCount
{
    return _recievedTouchesCount;
}

- (void)setType:(HDHexagonType)type
{
    if (self.node == nil) {
        return;
    }
    
    _type = type;
    
    switch (type) {
        case HDHexagonTypeRegular:
        [self.node setStrokeColor:[SKColor flatPeterRiverColor] fillColor:[self _translucentColor:[SKColor flatPeterRiverColor]]];
        break;
        case HDHexagonTypeStarter:
        [self.node setStrokeColor:[SKColor whiteColor] fillColor:[self _translucentColor:[UIColor whiteColor]]];
        [self.node updateLabelWithText:@"S" color:[SKColor whiteColor]];
        break;
        case HDHexagonTypeDouble:
        [self.node setStrokeColor:[SKColor flatTurquoiseColor] fillColor:[SKColor clearColor]];
        [self.node addDoubleNodeWithStroke:self.node.strokeColor fill:[self _translucentColor:self.node.strokeColor]];
        break;
        case HDHexagonTypeTriple:
        [self.node setStrokeColor:[SKColor flatSilverColor] fillColor:[SKColor clearColor]];
        [self.node addDoubleNodeWithStroke:self.node.strokeColor fill:[SKColor clearColor]];
        [self.node addTripleNodeWithStroke:self.node.strokeColor fill:[self _translucentColor:self.node.strokeColor]];
        break;
        case HDHexagonTypeOne:
        [self setCountTile:YES];
        [self.node setStrokeColor:[SKColor flatEmeraldColor] fillColor:[self _translucentColor:[SKColor flatEmeraldColor]]];
        [self.node updateLabelWithText:@"1" color:[SKColor flatEmeraldColor]];
        break;
        case HDHexagonTypeTwo:
        [self _disabledTileWithCount:2];
        break;
        case HDHexagonTypeThree:
        [self _disabledTileWithCount:3];
        break;
        case HDHexagonTypeFour:
        [self _disabledTileWithCount:4];
        break;
        case HDHexagonTypeFive:
        [self _disabledTileWithCount:5];
        break;
    }
}

- (void)recievedTouches
{
    if (self.isSelected) return;
    
    _recievedTouchesCount++;
    
    switch (self.type) {
        case HDHexagonTypeRegular:
        [self setSelected:YES];
        break;
        case HDHexagonTypeStarter:
        [self setSelected:YES];
        break;
        case HDHexagonTypeDouble:
        switch (_recievedTouchesCount) {
            case 1:{
                SKShapeNode *shapeNode = (SKShapeNode *)[self.node childNodeWithName:DOUBLE_KEY];
                [self.node setFillColor:[self _translucentColor:self.node.strokeColor]];
                [shapeNode removeFromParent];
                
            } break;
            case 2:
            [self setSelected:YES];
            break;
        } break;
        case HDHexagonTypeTriple:
        switch (_recievedTouchesCount) {
            case 1:{
                [[[(SKShapeNode *)[[self.node children] lastObject] children] firstObject] removeFromParent];
                [(SKShapeNode *)[self.node childNodeWithName:DOUBLE_KEY] setFillColor:[self _translucentColor:self.node.strokeColor]];
            } break;
            case 2:
            [self.node removeAllChildren];
            [self.node setFillColor:[self _translucentColor:self.node.strokeColor]];
            break;
            case 3:
            [self setSelected:YES];
            break;
        } break;
        case HDHexagonTypeOne:
        [self setSelected:YES];
        break;
        case HDHexagonTypeTwo:
        [self setSelected:YES];
        break;
        case HDHexagonTypeThree:
        [self setSelected:YES];
        break;
        case HDHexagonTypeFour:
        [self setSelected:YES];
        break;
        case HDHexagonTypeFive:
        [self setSelected:YES];
        break;
    }
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
            [self.node.label removeFromParent];
            [self.node setLabel:nil];
            break;
            case HDHexagonTypeDouble:
            [self.node setFillColor:self.node.strokeColor];
            break;
            case HDHexagonTypeTriple:
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
        [self setState:HDHexagonStateEnabled];
        [self.node setFillColor:[self _translucentColor:[SKColor flatEmeraldColor]]];
        [self.node runAction:[SKAction rotateByAngle:-(M_PI * 2) duration:.2f]];
        [self.node setLocked:NO];
    }
}

- (void)restoreToInitialState
{
    _recievedTouchesCount = 0;
    
    [self setSelected:NO];
    [self.node setLocked:NO];
    [self.node removeAllChildren];
    [self.node setLabel:nil];
    
    [self setState:HDHexagonStateEnabled];
    [self setType:self.type];
}

#pragma mark -
#pragma mark - <PRIVATE>

- (UIColor *)_translucentColor:(UIColor *)color
{
    return [color colorWithAlphaComponent:.35f];
}

- (void)_disabledTileWithCount:(NSInteger)count
{
    [self setCountTile:YES];
    [self setState:HDHexagonStateDisabled];
    [self.node setStrokeColor:[SKColor flatEmeraldColor] fillColor:[self _translucentColor:[SKColor flatEmeraldColor]]];
    [self.node updateLabelWithText:[NSString stringWithFormat:@"%ld",count] color:[SKColor flatEmeraldColor]];
    [self.node setLocked:YES];
}

- (void)_countTileWasSelectedForType:(HDHexagonType)type
{
    [self.node setFillColor:self.node.strokeColor];
    [self.node.label removeFromParent];
    [self.node setLabel:nil];
    if ([self.delegate respondsToSelector:@selector(unlockFollowingHexagonType:)] && type != HDHexagonTypeFive) {
        [self.delegate unlockFollowingHexagonType:type];
    }
}

@end
