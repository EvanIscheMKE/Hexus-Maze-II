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
            break;
        case HDHexagonTypeStarter:
            [self.node setFillColor:[SKColor flatPeterRiverColor]];
            [self.node setStrokeColor:[SKColor flatPeterRiverColor]];
            break;
        case HDHexagonTypeDouble:
            [self.node setStrokeColor:[SKColor flatTurquoiseColor]];
            [self addSubSKShapeNode];
            break;
        case HDHexagonTypeTriple:
            [self.node setStrokeColor:[SKColor flatSilverColor]];
            break;
        case HDHexagonTypeOne:
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
            [self.node updateLabelWithText:@"1"];
            break;
        case HDHexagonTypeTwo:
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
            [self.node updateLabelWithText:@"2"];
            break;
        case HDHexagonTypeThree:
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
            [self.node updateLabelWithText:@"3"];
            break;
        case HDHexagonTypeFour:
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
            [self.node updateLabelWithText:@"4"];
            break;
        case HDHexagonTypeFive:
            [self.node setStrokeColor:[SKColor flatEmeraldColor]];
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
                [self.node setFillColor:[SKColor flatPeterRiverColor]];
                break;
            case HDHexagonTypeStarter:
                [self.node setFillColor:[SKColor flatPeterRiverColor]];
                break;
            case HDHexagonTypeDouble:
                [self.node setFillColor:[SKColor flatTurquoiseColor]];
                break;
            case HDHexagonTypeTriple:
                [self.node setFillColor:[SKColor flatSilverColor]];
                break;
            case HDHexagonTypeOne:
                [self.node setFillColor:[SKColor flatEmeraldColor]];
                break;
            case HDHexagonTypeTwo:
                [self.node setFillColor:[SKColor flatEmeraldColor]];
                break;
            case HDHexagonTypeThree:
                [self.node setFillColor:[SKColor flatEmeraldColor]];
                break;
            case HDHexagonTypeFour:
                [self.node setFillColor:[SKColor flatEmeraldColor]];
                break;
            case HDHexagonTypeFive:
                [self.node setFillColor:[SKColor flatEmeraldColor]];
                break;
        }
    }
}

- (void)addSubSKShapeNode
{
    const CGFloat kTileSizeWithInset = CGRectGetHeight(self.node.frame) - 12.0f;
    SKShapeNode *hexagon = [SKShapeNode shapeNodeWithPath:[[self hexagonPathForBounds:CGRectMake(0.0f, 0.0, kTileSizeWithInset, kTileSizeWithInset)] CGPath]];
    [hexagon setPosition:CGPointMake(5.0f, 5.0f)];
    [hexagon setStrokeColor:self.node.strokeColor];
    [hexagon setFillColor:[SKColor redColor]];
    [hexagon setLineWidth:self.node.lineWidth];
    [self.node addChild:hexagon];
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
