//
//  HDHexagon.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDHexaObject.h"
#import "SKColor+ColorAdditions.h"
#import "HDHexaNode.h"
#import "HDTextureManager.h"

@interface HDHexaObject ()
@property (nonatomic, assign) NSInteger touchesCount;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
@end

@implementation HDHexaObject

- (instancetype)init
{
    return [self initWithRow:0 column:0 type:HDHexagonTypeRegular];
}

- (instancetype)initWithRow:(NSInteger)row column:(NSInteger)column type:(HDHexagonType)type
{
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

- (void)setNode:(HDHexaNode *)node
{
    _node = node;
    [self _setup];
}

#pragma mark - Public

- (BOOL)selectedAfterRecievingTouches
{
    if (self.isSelected) {
        return YES;
    };
    
    self.touchesCount++;
    switch (self.type) {
        case HDHexagonTypeDouble:
            switch (self.touchesCount) {
                case 1: {
                    self.node.texture = [[HDTextureManager sharedManager] textureForKeyPath:@"Default-OneTap"];
                    break;
                } case 2:
                    self.selected = YES;
                    break;
            } break;
        case HDHexagonTypeTriple:
            switch (self.touchesCount) {
                case 1: {
                    self.node.texture = [[HDTextureManager sharedManager] textureForKeyPath:@"Default-Double"];
                    break;
                } case 2: {
                    self.node.texture = [[HDTextureManager sharedManager] textureForKeyPath:@"Default-OneTap"];
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

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if ([self selectedImagePath]) {
        self.node.texture = [[HDTextureManager sharedManager] textureForKeyPath:[self selectedImagePath]];
    }
    
    if (selected) {
        if (self.countTile) {
            if ([self.delegate respondsToSelector:@selector(hexagon:unlockedCountTile:)] && self.type != HDHexagonTypeFive) {
                [self.delegate hexagon:self unlockedCountTile:self.type];
            }
        }
    }
}

- (void)setLocked:(BOOL)locked
{
    _locked = locked;
    if (!locked) {
        self.state = HDHexagonStateEnabled;
        self.node.locked = NO;
    }
}

- (NSString *)defaultImagePath
{
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

- (NSString *)selectedImagePath
{
    if (self.type == HDHexagonTypeNone) {
        return @"Default-Mine";
    }
    return @"Selected-Tile";
}

- (void)restoreToInitialState
{
    [[self.node children] makeObjectsPerformSelector:@selector(removeFromParent)];
    
    self.node.locked  = NO;
    self.touchesCount = 0;
    self.selected     = NO;
    self.state        = HDHexagonStateEnabled;
    self.node.texture = [[HDTextureManager sharedManager] textureForKeyPath:[self defaultImagePath]];
    [self _setup];
}

#pragma mark - Private

- (void)_disableTile
{
    self.state       = HDHexagonStateDisabled;
    self.countTile   = YES;
    self.node.locked = YES;
}

- (void)_setup
{
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
