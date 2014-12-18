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

@interface HDHexagon ()
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
@end

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
            [self.node setStrokeColor:[SKColor flatPeterRiverColor] fillColor:[SKColor clearColor]];
            break;
        case HDHexagonTypeStarter:
            [self.node setStrokeColor:[SKColor whiteColor] fillColor:[SKColor clearColor]];
            break;
        case HDHexagonTypeDouble:
            [self.node setStrokeColor:[SKColor flatTurquoiseColor] fillColor:[SKColor clearColor]];
            [self.node addDoubleNodeWithStroke:self.node.strokeColor fill:[SKColor clearColor]];
            break;
        case HDHexagonTypeTriple:
            [self.node setStrokeColor:[SKColor flatSilverColor] fillColor:[SKColor clearColor]];
            [self.node addDoubleNodeWithStroke:self.node.strokeColor fill:[SKColor clearColor]];
            [self.node addTripleNodeWithStroke:self.node.strokeColor fill:[SKColor clearColor]];
            break;
        case HDHexagonTypeEnd:
            [self.node endTile];
            [self setState:HDHexagonStateDisabled];
            [self.node setStrokeColor:[SKColor whiteColor] fillColor:[SKColor clearColor]];
            break;
        case HDHexagonTypeOne:
            [self setCountTile:YES];
            [self.node setStrokeColor:[SKColor flatEmeraldColor] fillColor:[SKColor clearColor]];
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

- (void)recievedTouches
{
    if (self.isSelected) return;
    
    [self.node runAction:[SKAction scaleTo:.9f duration:.15f] completion:^{
        [self.node runAction:[SKAction scaleTo:1.0f duration:.15f]];
    }];
    
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
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"transform" object:nil];
                    SKShapeNode *shapeNode = (SKShapeNode *)[self.node childNodeWithName:DOUBLE_KEY];
                    [shapeNode removeFromParent];
                } break;
                case 2:
                    [self setSelected:YES];
                    break;
            } break;
        case HDHexagonTypeTriple:
            switch (_recievedTouchesCount) {
                case 1:
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"transform" object:nil];
                    [[[(SKShapeNode *)[[self.node children] lastObject] children] firstObject] removeFromParent];
                    break;
                case 2:
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"transform" object:nil];
                    [self.node removeAllChildren];
                    break;
                case 3:
                    [self setSelected:YES];
                    break;
            } break;
        case HDHexagonTypeEnd:
            [self setSelected:YES];
            break;
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateCompletedTileCountNotification" object:nil];
        
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
        [self setState:HDHexagonStateEnabled];
        [self.node setFillColor:[SKColor clearColor]];
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
    
    [self setState:HDHexagonStateEnabled];
    [self setType:self.type];
}

#pragma mark -
#pragma mark - <PRIVATE>

- (void)_disabledTileWithCountIndex:(NSInteger)count
{
    [self setCountTile:YES];
    [self setState:HDHexagonStateDisabled];
    [self.node setStrokeColor:[SKColor flatEmeraldColor] fillColor:[SKColor clearColor]];
    [self.node setLocked:YES];
}

- (void)_countTileWasSelectedForType:(HDHexagonType)type
{
    [self.node setFillColor:self.node.strokeColor];
    if ([self.delegate respondsToSelector:@selector(unlockCountTileAfterHexagon:)] && type != HDHexagonTypeFive) {
        [self.delegate unlockCountTileAfterHexagon:type];
    }
}

@end
