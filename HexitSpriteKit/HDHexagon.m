//
//  HDHexagon.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHexagon.h"
#import "SKColor+HDColor.h"
#import "HDHexagonNode.h"

@implementation HDHexagon{
    NSInteger _recievedTouchesCount;
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setType:(HDHexagonType)type
{
    _type = type;
    
    switch (type) {
        case HDHexagonTypeRegular:
            [self.node setStrokeColor:[SKColor flatPeterRiverColor]];
            [self.node setFillColor:[SKColor flatMidnightBlueColor]];
            break;
        case HDHexagonTypeStarter:
            [self.node setFillColor:[SKColor flatPeterRiverColor]];
            [self.node setStrokeColor:[SKColor flatPeterRiverColor]];
            break;
        case HDHexagonTypeDouble:
            [self addDoubleHexagonShapeNode];
            [self.node setStrokeColor:[SKColor flatTurquoiseColor]];
            [self.node setFillColor:[SKColor flatMidnightBlueColor]];
            break;
        case HDHexagonTypeTriple:
            [self addDoubleHexagonShapeNode];
            [self addTripleHexagonShapeNode];
            [self.node setStrokeColor:[SKColor flatSilverColor]];
            [self.node setFillColor:[SKColor flatMidnightBlueColor]];
            break;
        case HDHexagonTypeOne:
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
            [self.node setFillColor:self.node.strokeColor];
            [self.node updateLabelWithText:@"1"];
            break;
        case HDHexagonTypeTwo:
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
            [self.node setFillColor:[SKColor flatMidnightBlueColor]];
            [self.node updateLabelWithText:@"2"];
            break;
        case HDHexagonTypeThree:
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
            [self.node setFillColor:[SKColor flatMidnightBlueColor]];
            [self.node updateLabelWithText:@"3"];
            break;
        case HDHexagonTypeFour:
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
            [self.node setFillColor:[SKColor flatMidnightBlueColor]];
            [self.node updateLabelWithText:@"4"];
            break;
        case HDHexagonTypeFive:
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
            [self.node setFillColor:[SKColor flatMidnightBlueColor]];
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
                    [self.node setFillColor:self.node.strokeColor];
                    break;
                case 2:
                    [self setSelected:YES];
                    break;
            } break;
        case HDHexagonTypeTriple:
            switch (_recievedTouchesCount) {
                case 1:
                   
                    break;
                case 2:
                    
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
                break;
            case HDHexagonTypeDouble:
                [self.node removeAllChildren];
                break;
            case HDHexagonTypeTriple:
                [self.node removeAllChildren];
                break;
            case HDHexagonTypeOne:
                [self.node setFillColor:self.node.strokeColor];
                break;
            case HDHexagonTypeTwo:
                [self.node setFillColor:self.node.strokeColor];
                break;
            case HDHexagonTypeThree:
                [self.node setFillColor:self.node.strokeColor];
                break;
            case HDHexagonTypeFour:
                [self.node setFillColor:self.node.strokeColor];
                break;
            case HDHexagonTypeFive:
                [self.node setFillColor:self.node.strokeColor];
                break;
        }
    }
}

- (void)addDoubleHexagonShapeNode
{
    const CGFloat kHexagonInset = 6.0f;
    const CGFloat kTileSizeWithInset = CGRectGetHeight(CGRectInset(self.node.frame, kHexagonInset, kHexagonInset));
    
    SKShapeNode *hexagon = [SKShapeNode shapeNodeWithPath:[[self hexagonPathForBounds:CGRectMake(0.0f, 0.0, kTileSizeWithInset, kTileSizeWithInset)] CGPath]];
    [hexagon setAntialiased:YES];
    [hexagon setPosition:CGPointMake(kHexagonInset - 1, kHexagonInset - 1)];
    [hexagon setStrokeColor:self.node.strokeColor];
    [hexagon setFillColor:[SKColor redColor]];
    [hexagon setLineWidth:self.node.lineWidth];
    [self.node addChild:hexagon];
}

- (void)addTripleHexagonShapeNode
{
    const CGFloat kHexagonInset = 6.0f;
    const CGFloat kTileSizeWithInset = CGRectGetHeight(CGRectInset([(SKShapeNode *)[[self.node children] lastObject] frame], kHexagonInset,
                                                                                                                             kHexagonInset ) );
    
    SKShapeNode *hexagon = [SKShapeNode shapeNodeWithPath:[[self hexagonPathForBounds:CGRectMake(0.0f, 0.0, kTileSizeWithInset, kTileSizeWithInset)] CGPath]];
    [hexagon setAntialiased:YES];
    [hexagon setPosition:CGPointMake(kHexagonInset - 1, kHexagonInset - 1)];
    [hexagon setStrokeColor:self.node.strokeColor];
    [hexagon setFillColor:[SKColor yellowColor]];
    [hexagon setLineWidth:self.node.lineWidth];
    [[[self.node children] lastObject] addChild:hexagon];
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

@end
