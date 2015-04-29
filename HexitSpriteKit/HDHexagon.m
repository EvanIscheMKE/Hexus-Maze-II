//
//  HDHexagon.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDHexagon.h"
#import "SKColor+ColorAdditions.h"
#import "HDHexagonNode.h"

NSString * const HDDoubleKey = @"double";
NSString * const HDTripleKey = @"triple";

@interface HDHexagon ()
@property (nonatomic, assign) NSInteger touchesCount;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
@end

@implementation HDHexagon

- (instancetype)init {
    return [self initWithRow:0 column:0 type:HDHexagonTypeRegular];
}

- (instancetype)initWithRow:(NSInteger)row column:(NSInteger)column type:(HDHexagonType)type {
    NSParameterAssert(row);
    NSParameterAssert(type);
    if (self = [super init]) {
        self.touchesCount = 0;
        self.row    = row;
        self.column = column;
        self.state  = HDHexagonStateEnabled;
        self.type   = type;
    }
    return self;
}

#pragma mark - Setter

- (void)setNode:(HDHexagonNode *)node {
    _node = node;
    [self _setup];
}

#pragma mark - Public

- (BOOL)selectedAfterRecievingTouches {
    
    if (self.isSelected) {
        return YES;
    };
    
    self.touchesCount++;
    
    switch (self.type) {
        case HDHexagonTypeDouble:
            switch (self.touchesCount) {
                case 1: {
                    self.node.texture = [SKTexture textureWithImageNamed:@"Double-OneLeft"];
                    break;
                } case 2:
                    self.selected = YES;
                    break;
            } break;
        case HDHexagonTypeTriple:
            switch (self.touchesCount) {
                case 1: {
                    self.node.texture = [SKTexture textureWithImageNamed:@"Triple-TwoLeft"];
                    break;
                } case 2: {
                    self.node.texture = [SKTexture textureWithImageNamed: @"Triple-OneLeft"];
                    break;
                } case 3:
                    self.selected = YES;
                    break;
            } break;
        default:
            self.selected = YES;
            break;
    }
    return self.selected;
}

- (UIColor *)emitterColor {
    
    switch (self.type) {
        case HDHexagonTypeRegular:
            return [UIColor flatPeterRiverColor];
        case HDHexagonTypeStarter:
            return [UIColor whiteColor];
        case HDHexagonTypeDouble:
            return [UIColor flatTurquoiseColor];
        case HDHexagonTypeTriple:
            return [UIColor flatSilverColor];
        case HDHexagonTypeEnd:
            return [UIColor flatAlizarinColor];
        case HDHexagonTypeOne:
        case HDHexagonTypeTwo:
        case HDHexagonTypeThree:
        case HDHexagonTypeFour:
        case HDHexagonTypeFive:
            return [UIColor flatEmeraldColor];
        default:
            break;
    }
    return nil;
}

- (void)setSelected:(BOOL)selected {
    
    _selected = selected;
    if ([self selectedImagePath]) {
        self.node.texture = [SKTexture textureWithImage:[UIImage imageNamed:[self selectedImagePath]]];
    }
    
    if (selected) {
        if (self.countTile && self.delegate) {
            if ([self.delegate respondsToSelector:@selector(hexagon:unlockedCountTile:)] && self.type != HDHexagonTypeFive) {
                [self.delegate hexagon:self unlockedCountTile:self.type];
            }
        }
    }
}

- (void)setLocked:(BOOL)locked {
    
    _locked = locked;
    if (!locked) {
        self.state = HDHexagonStateEnabled;
        self.node.locked = NO;
        [self.node runAction:[SKAction rotateByAngle:M_PI*2 duration:.300f]];
    }
}

- (NSString *)defaultImagePath {
    switch (self.type) {
        case HDHexagonTypeRegular:
            return @"Default-OneTap";
        case HDHexagonTypeStarter:
            return @"Default-Start";
        case HDHexagonTypeDouble:
            return @"Default-Double";
        case HDHexagonTypeTriple:
            return @"Default-Triple";
        case HDHexagonTypeEnd:
            return @"Default-End";
        case HDHexagonTypeNone:
            return @"Default-Mine";
        default:
            return @"Default-Count";
    }
    return nil;
}

- (NSString *)selectedImagePath {
    switch (self.type) {
        case HDHexagonTypeRegular:
            return  @"Selected-OneTap";
        case HDHexagonTypeStarter:
            return @"Selected-Start";
        case HDHexagonTypeDouble:
            return @"Selected-Double";
        case HDHexagonTypeTriple:
            return @"Selected-Triple";
        case HDHexagonTypeEnd:
            return @"Selected-End";
        case HDHexagonTypeNone:
            return @"Default-Mine";
        default:
            return @"Selected-Count";
    }
    return nil;
}

- (void)restoreToInitialState {
    self.node.locked  = NO;
    self.touchesCount = 0;
    self.selected     = NO;
    self.state        = HDHexagonStateEnabled;
    self.node.texture = [SKTexture textureWithImage:[UIImage imageNamed:[self defaultImagePath]]];
    [self _setup];
}

#pragma mark - Private

- (void)_disableTile {
    self.state       = HDHexagonStateDisabled;
    self.countTile   = YES;
    self.node.locked = YES;
}

- (void)_setup {
    switch (self.type) {
        case HDHexagonTypeEnd:
            self.state = HDHexagonStateDisabled;
            break;
        case HDHexagonTypeOne:
            self.countTile = YES;
            break;
        case HDHexagonTypeTwo:
        case HDHexagonTypeThree:
        case HDHexagonTypeFour:
        case HDHexagonTypeFive:
            [self _disableTile];
            break;
        case HDHexagonTypeNone:
            self.selected = YES;
            self.state = HDHexagonStateDisabled;
            break;
        default:
            break;
    }
}

@end
