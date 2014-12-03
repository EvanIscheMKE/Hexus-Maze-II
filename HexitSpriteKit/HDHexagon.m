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

static const CGFloat kHexagonInset = 6.0f;

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
            [self _doubleHexagonShapeNodeWithStroke:self.node.strokeColor
                                               fill:[self _translucentColor:self.node.strokeColor]];
           break;
        case HDHexagonTypeTriple:
            [self.node setStrokeColor:[SKColor flatSilverColor] fillColor:[SKColor clearColor]];
            [self _doubleHexagonShapeNodeWithStroke:self.node.strokeColor
                                               fill:[SKColor clearColor]];
            [self _tripleHexagonShapeNodeWithStroke:self.node.strokeColor
                                               fill:[self _translucentColor:self.node.strokeColor]];
            break;
        case HDHexagonTypeOne:
            [self.node setStrokeColor:[SKColor flatEmeraldColor] fillColor:[self _translucentColor:[SKColor flatEmeraldColor]]];
            [self.node updateLabelWithText:@"1" color:[SKColor flatEmeraldColor]];
            break;
        case HDHexagonTypeTwo:
            [self _setupTileForDisabledStateWithIndex:2];
            break;
        case HDHexagonTypeThree:
            [self _setupTileForDisabledStateWithIndex:3];
            break;
        case HDHexagonTypeFour:
            [self _setupTileForDisabledStateWithIndex:4];
            break;
        case HDHexagonTypeFive:
            [self _setupTileForDisabledStateWithIndex:5];
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
                    SKShapeNode *shapeNode = (SKShapeNode *)[self.node childNodeWithName:@"double"];
                    [shapeNode setFillColor:shapeNode.strokeColor];
                    SKAction *position = [SKAction moveByX:-1 y:-1 duration:.3f];
                    SKAction *scale = [SKAction scaleTo:.0f duration:.3f];
                    [shapeNode runAction:[SKAction group:@[position, scale]] completion:^{
                        [self.node setFillColor:[self _translucentColor:self.node.strokeColor]];
                        [shapeNode removeFromParent];
                    }];
                } break;
                case 2:
                    [self setSelected:YES];
                    break;
            } break;
        case HDHexagonTypeTriple:
            switch (_recievedTouchesCount) {
                case 1:{
                    [[[(SKShapeNode *)[[self.node children] lastObject] children] firstObject] removeFromParent];
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

- (void)unlock
{
    if (self.state == HDHexagonStateEnabled) {
        return;
    }
    [self setState:HDHexagonStateEnabled];
    [self.node setFillColor:[self _translucentColor:[SKColor flatEmeraldColor]]];
    [self.node runAction:[SKAction rotateByAngle:M_PI * 2 duration:.2f]];
}

- (void)returnToPreviousState
{
    switch (self.type) {
        case HDHexagonTypeRegular:
            [self setSelected:NO];
            [self.node setFillColor:[self _translucentColor:[SKColor flatPeterRiverColor]]];
            break;
        case HDHexagonTypeStarter:
            [self setSelected:NO];
            [self.node setFillColor:[self _translucentColor:[SKColor whiteColor]]];
            [self.node updateLabelWithText:@"S" color:[UIColor whiteColor]];
            break;
        case HDHexagonTypeDouble:
            
             _recievedTouchesCount--;
            switch (_recievedTouchesCount) {
                case 1:
                    [self _doubleHexagonShapeNodeWithStroke:self.node.strokeColor
                                                       fill:[self _translucentColor:self.node.strokeColor]];
                    break;
                case 2:
                    [self setSelected:NO];
                    [self.node setFillColor:[self _translucentColor:self.node.strokeColor]];
                    break;
          } break;
        case HDHexagonTypeTriple:
            
            _recievedTouchesCount--;
            switch (_recievedTouchesCount) {
                case 1:
                    [self _tripleHexagonShapeNodeWithStroke:self.node.strokeColor
                                                       fill:[self _translucentColor:self.node.strokeColor]];
                    break;
                case 2:
                    [self _doubleHexagonShapeNodeWithStroke:self.node.strokeColor
                                                       fill:[self _translucentColor:self.node.strokeColor]];
                    break;
                case 3:
                    [self setSelected:NO];
                    [self.node setFillColor:[self _translucentColor:self.node.strokeColor]];
                    break;
            } break;
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

- (void)restoreToInitialState
{
    _recievedTouchesCount = 0;
    
    [self setSelected:NO];
    [self.node removeAllChildren];
    [self setState:HDHexagonStateEnabled];
    
    [self.node.label removeFromParent];
    [self.node setLabel:nil];
    
    [self setType:self.type];
}

#pragma mark - 
#pragma mark - < PRIVATE >

- (UIColor *)_translucentColor:(UIColor *)color
{
    const CGFloat kAlpha = .35f;
    return [color colorWithAlphaComponent:kAlpha];
}

- (void)_setupTileForDisabledStateWithIndex:(NSInteger)index
{
    [self setState:HDHexagonStateDisabled];
    [self.node setStrokeColor:[SKColor flatEmeraldColor]];
    [self.node setFillColor:[self _translucentColor:self.node.strokeColor]];
    [self.node updateLabelWithText:[NSString stringWithFormat:@"%ld",index] color:[SKColor flatEmeraldColor]];
}

- (void)_countTileWasSelectedForType:(HDHexagonType)type
{
    [self.node setFillColor:self.node.strokeColor];
    [self.node.label removeFromParent];
    if ([self.delegate respondsToSelector:@selector(unlockFollowingHexagonType:)]) {
        [self.delegate unlockFollowingHexagonType:type];
    }
}

- (void)_doubleHexagonShapeNodeWithStroke:(UIColor *)stroke fill:(UIColor *)fill
{
    const CGFloat kTileSizeWithInset = CGRectGetHeight(CGRectInset(self.node.frame, kHexagonInset, kHexagonInset));
    
    CGPathRef pathRef = [HDHelper hexagonPathForBounds:CGRectMake(0.0f, 0.0f, kTileSizeWithInset, kTileSizeWithInset)];
    SKShapeNode *hexagon = [SKShapeNode shapeNodeWithPath:pathRef centered:YES];
    [hexagon setName:DOUBLE_KEY];
    [hexagon setAntialiased:YES];
    [hexagon setPosition:CGPointZero];
    [hexagon setStrokeColor:self.node.strokeColor];
    [hexagon setFillColor:[self _translucentColor:self.node.strokeColor]];
    [hexagon setLineWidth:self.node.lineWidth];
    [self.node addChild:hexagon];
}

- (void)_tripleHexagonShapeNodeWithStroke:(UIColor *)stroke fill:(UIColor *)fill
{
    CGRect rectWithInset = CGRectInset([(SKShapeNode *)[[self.node children] lastObject] frame], kHexagonInset, kHexagonInset);
    const CGFloat kTileSizeWithInset = CGRectGetHeight(rectWithInset);
    
    CGPathRef pathRef = [HDHelper hexagonPathForBounds:CGRectMake(0.0f, 0.0f, kTileSizeWithInset, kTileSizeWithInset)];
    SKShapeNode *hexagon = [SKShapeNode shapeNodeWithPath:pathRef centered:YES];
    [hexagon setName:TRIPLE_KEY];
    [hexagon setAntialiased:YES];
    [hexagon setPosition:CGPointZero];
    [hexagon setStrokeColor:self.node.strokeColor];
    [hexagon setFillColor:[self _translucentColor:self.node.strokeColor]];
    [hexagon setLineWidth:self.node.lineWidth];
   [[[self.node children] lastObject] addChild:hexagon];
}

@end
