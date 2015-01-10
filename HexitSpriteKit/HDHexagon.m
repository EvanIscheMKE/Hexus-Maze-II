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
    return [self initWithRow:0 column:0 type:HDHexagonTypeNone];
}

- (instancetype)initWithRow:(NSInteger)row column:(NSInteger)column type:(HDHexagonType)type
{
    NSParameterAssert(row);
    if (self = [super init]) {
        self.touchesCount = 0;
        self.row    = row;
        self.column = column;
        self.state  = HDHexagonStateEnabled;
        self.type   = type;
    }
    return self;
}

- (void)setNode:(HDHexagonNode *)node
{
    _node = node;
    
    switch (self.type) {
        case HDHexagonTypeEnd:
            self.state = HDHexagonStateDisabled;
            break;
        case HDHexagonTypeOne:
            self.countTile = YES;
            break;
        case HDHexagonTypeTwo:
            [self _disabledTile];
            break;
        case HDHexagonTypeThree:
            [self _disabledTile];
            break;
        case HDHexagonTypeFour:
            [self _disabledTile];
            break;
        case HDHexagonTypeFive:
            [self _disabledTile];
            break;
        case HDHexagonTypeNone:
            self.selected = YES;
            self.state = HDHexagonStateDisabled;
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
                case 1:
                    self.node.texture = [SKTexture textureWithImageNamed:@"Double-OneLeft"];
                    break;
                case 2:
                    self.selected = YES;
                    break;
            } break;
        case HDHexagonTypeTriple:
            switch (self.touchesCount) {
                case 1:
                    self.node.texture = [SKTexture textureWithImageNamed:@"Triple-OneLeft"];
                    break;
                case 2:
                    self.node.texture = [SKTexture textureWithImageNamed:@"Triple-TwoLeft"];
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

- (UIColor *)emitterColor
{
    switch (self.type) {
        case HDHexagonTypeRegular:
            return [UIColor flatPeterRiverColor];
            break;
        case HDHexagonTypeStarter:
            return [UIColor whiteColor];
            break;
        case HDHexagonTypeDouble:
            return [UIColor flatTurquoiseColor];
            break;
        case HDHexagonTypeTriple:
            return [UIColor flatSilverColor];
            break;
        case HDHexagonTypeEnd:
            return [UIColor flatAlizarinColor];
            break;
        case HDHexagonTypeOne:
            return [UIColor flatEmeraldColor];
            break;
        case HDHexagonTypeTwo:
            return [UIColor flatEmeraldColor];
            break;
        case HDHexagonTypeThree:
            return [UIColor flatEmeraldColor];
            break;
        case HDHexagonTypeFour:
            return [UIColor flatEmeraldColor];
            break;
        case HDHexagonTypeFive:
            return [UIColor flatEmeraldColor];
            break;
    }
    return nil;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if ([self selectedImagePath]) {
        self.node.texture = [SKTexture textureWithImage:[UIImage imageNamed:[self selectedImagePath]]];
    }
    
    if (self.countTile && self.delegate) {
        if ([self.delegate respondsToSelector:@selector(hexagon:unlockedCountTile:)] && self.type != HDHexagonTypeFive) {
            [self.delegate hexagon:self unlockedCountTile:self.type];
        }
    }
}

- (void)setLocked:(BOOL)locked
{
    _locked = locked;
    
    if (!locked && self.state != HDHexagonStateEnabled) {
        self.state = HDHexagonStateEnabled;
        self.node.locked = NO;
        [self.node runAction:[SKAction rotateByAngle:M_PI*2 duration:.3f]];
    }
}

- (NSString *)defaultImagePath
{
    switch (self.type) {
        case HDHexagonTypeRegular:
            return @"Stroke-OneTouch";
            break;
        case HDHexagonTypeStarter:
            return @"Stroke-Start";
            break;
        case HDHexagonTypeDouble:
            return @"Default-Double";
            break;
        case HDHexagonTypeTriple:
            return @"Default-Triple";
            break;
        case HDHexagonTypeEnd:
            return @"Default-End";
            break;
        case HDHexagonTypeOne:
            return @"Default-Count";
            break;
        case HDHexagonTypeTwo:
            return @"Default-Count";
            break;
        case HDHexagonTypeThree:
            return @"Default-Count";
            break;
        case HDHexagonTypeFour:
            return @"Default-Count";
            break;
        case HDHexagonTypeFive:
            return @"Default-Count";
            break;
        case HDHexagonTypeNone:
            return @"FillInTile";
            break;
    }
    return nil;
}

- (NSString *)selectedImagePath
{
    switch (self.type) {
        case HDHexagonTypeRegular:
            return @"Selected-OneTouch";
            break;
        case HDHexagonTypeStarter:
            return @"Selected-Start";
            break;
        case HDHexagonTypeDouble:
            return @"Selected-Double";
            break;
        case HDHexagonTypeTriple:
            return @"Selected-Triple";
            break;
        case HDHexagonTypeEnd:
            return @"Selected-End";
            break;
        case HDHexagonTypeOne:
            return @"Selected-Count";
            break;
        case HDHexagonTypeTwo:
            return @"Selected-Count";
            break;
        case HDHexagonTypeThree:
            return @"Selected-Count";
            break;
        case HDHexagonTypeFour:
            return @"Selected-Count";
            break;
        case HDHexagonTypeFive:
            return @"Selected-Count";
            break;
    }
    return nil;
}

- (void)restoreToInitialState
{
    self.node.locked  = NO;
    self.touchesCount = 0;
    self.selected     = NO;
    self.state        = HDHexagonStateEnabled;
    self.node.texture = [SKTexture textureWithImage:[UIImage imageNamed:[self defaultImagePath]]];
    self.node         = self.node;
}

#pragma mark -
#pragma mark - Private

- (void)_disabledTile
{
    self.countTile    = YES;
    self.node.locked  = YES;
    self.state        = HDHexagonStateDisabled;
}


@end
