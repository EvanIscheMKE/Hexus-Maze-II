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
        [self setRow:row];
        [self setColumn:column];
        [self setState:HDHexagonStateEnabled];
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
            [self.node setStrokeColor:[SKColor flatPeterRiverColor]];
            [self.node setFillColor:[[SKColor flatPeterRiverColor] colorWithAlphaComponent:.25f]];
            break;
        case HDHexagonTypeStarter:
            [self.node setStrokeColor:[SKColor flatPeterRiverColor]];
            [self.node setFillColor:[[SKColor flatPeterRiverColor] colorWithAlphaComponent:.25f]];
            [self.node updateLabelWithText:@"S" color:[SKColor flatPeterRiverColor]];
            break;
        case HDHexagonTypeDouble:{
            [self.node setStrokeColor:[SKColor flatTurquoiseColor]];
            [self.node setFillColor:[SKColor clearColor]];
            [self _doubleHexagonShapeNodeWithStroke:self.node.strokeColor
                                               fill:[self.node.strokeColor colorWithAlphaComponent:.25f]];
        }  break;
        case HDHexagonTypeTriple:
            [self.node setStrokeColor:[SKColor flatSilverColor]];
            [self.node setFillColor:[SKColor clearColor]];
            [self _doubleHexagonShapeNodeWithStroke:self.node.strokeColor
                                              fill:[SKColor clearColor]];
            [self _tripleHexagonShapeNodeWithStroke:self.node.strokeColor
                                               fill:[self.node.strokeColor colorWithAlphaComponent:.25f]];
            break;
        case HDHexagonTypeOne:
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
            [self.node setFillColor:self.node.strokeColor];
            [self.node updateLabelWithText:@"1" color:[SKColor flatMidnightBlueColor]];
            break;
        case HDHexagonTypeTwo:
            [self setState:HDHexagonStateDisabled];
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
            [self.node setFillColor:[self.node.strokeColor colorWithAlphaComponent:.25f]];
            [self.node updateLabelWithText:@"2"];
            break;
        case HDHexagonTypeThree:
            [self setState:HDHexagonStateDisabled];
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
            [self.node setFillColor:[self.node.strokeColor colorWithAlphaComponent:.25f]];
            [self.node updateLabelWithText:@"3"];
            break;
        case HDHexagonTypeFour:
            [self setState:HDHexagonStateDisabled];
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
            [self.node setFillColor:[self.node.strokeColor colorWithAlphaComponent:.25f]];
            [self.node updateLabelWithText:@"4"];
            break;
        case HDHexagonTypeFive:
            [self setState:HDHexagonStateDisabled];
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
            [self.node setFillColor:[self.node.strokeColor colorWithAlphaComponent:.25f]];
            [self.node updateLabelWithText:@"5"];
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
                case 1:
                    [self.node removeAllChildren];
                    [self.node setFillColor:[self.node.strokeColor colorWithAlphaComponent:.4f]];
                    break;
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
                    [self.node setFillColor:[self.node.strokeColor colorWithAlphaComponent:.4f]];
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
    if (selected) {
        _selected = selected;
        
        switch (self.type) {
            case HDHexagonTypeRegular:
                [self.node setFillColor:self.node.strokeColor];
                break;
            case HDHexagonTypeStarter:
                [self.node setFillColor:self.node.strokeColor];
                [self.node.label setText:@""];
                [self.node setLabel:nil];
                break;
            case HDHexagonTypeDouble:
                [self.node setFillColor:self.node.strokeColor];
                break;
            case HDHexagonTypeTriple:
                [self.node setFillColor:self.node.strokeColor];
                break;
            case HDHexagonTypeOne:
                [self.node setFillColor:self.node.strokeColor];
                if ([self.delegate respondsToSelector:@selector(unlockFollowingHexagonType:)]) {
                    [self.delegate unlockFollowingHexagonType:HDHexagonTypeOne];
                } break;
            case HDHexagonTypeTwo:
                [self.node setFillColor:self.node.strokeColor];
                if ([self.delegate respondsToSelector:@selector(unlockFollowingHexagonType:)]) {
                    [self.delegate unlockFollowingHexagonType:HDHexagonTypeTwo];
                } break;
            case HDHexagonTypeThree:
                [self.node setFillColor:self.node.strokeColor];
                if ([self.delegate respondsToSelector:@selector(unlockFollowingHexagonType:)]) {
                    [self.delegate unlockFollowingHexagonType:HDHexagonTypeThree];
                } break;
            case HDHexagonTypeFour:
                [self.node setFillColor:self.node.strokeColor];
                if ([self.delegate respondsToSelector:@selector(unlockFollowingHexagonType:)]) {
                    [self.delegate unlockFollowingHexagonType:HDHexagonTypeFour];
                } break;
            case HDHexagonTypeFive:
                [self.node setFillColor:self.node.strokeColor];
                if ([self.delegate respondsToSelector:@selector(unlockFollowingHexagonType:)]) {
                    [self.delegate unlockFollowingHexagonType:HDHexagonTypeFive];
                } break;
        }
    }
}

- (void)_doubleHexagonShapeNodeWithStroke:(UIColor *)stroke
                                     fill:(UIColor *)fill
{
    const CGFloat kTileSizeWithInset = CGRectGetHeight(CGRectInset(self.node.frame, kHexagonInset, kHexagonInset));
    
    
    CGPathRef pathRef = [HDHelper hexagonPathForBounds:CGRectMake(0.0f, 0.0, kTileSizeWithInset, kTileSizeWithInset)];
    
    SKShapeNode *hexagon = [SKShapeNode shapeNodeWithPath:pathRef centered:YES];
    [hexagon setAntialiased:YES];
    [hexagon setPosition:CGPointMake(1.f,1.f)];
    [hexagon setStrokeColor:self.node.strokeColor];
    [hexagon setFillColor:[self.node.strokeColor colorWithAlphaComponent:.25f]];
    [hexagon setLineWidth:self.node.lineWidth];
    [self.node addChild:hexagon];
}

- (void)_tripleHexagonShapeNodeWithStroke:(UIColor *)stroke
                                    fill:(UIColor *)fill
{
    CGRect rectWithInset = CGRectInset([(SKShapeNode *)[[self.node children] lastObject] frame], kHexagonInset, kHexagonInset);
    const CGFloat kTileSizeWithInset = CGRectGetHeight(rectWithInset);
    
    
    CGPathRef pathRef = [HDHelper hexagonPathForBounds:CGRectMake(0.0f, 0.0, kTileSizeWithInset, kTileSizeWithInset)];
    
    SKShapeNode *hexagon = [SKShapeNode shapeNodeWithPath:pathRef centered:YES];
    [hexagon setAntialiased:YES];
    [hexagon setPosition:CGPointMake(1.f, 1.f)];
    [hexagon setStrokeColor:self.node.strokeColor];
    [hexagon setFillColor:[self.node.strokeColor colorWithAlphaComponent:.25f]];
    [hexagon setLineWidth:self.node.lineWidth];
   [[[self.node children] lastObject] addChild:hexagon];
}

@end
