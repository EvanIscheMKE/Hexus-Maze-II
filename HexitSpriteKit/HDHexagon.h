//
//  HDHexagon.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/3/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;
#import <Foundation/Foundation.h>

@class HDHexagonNode;

typedef NS_ENUM(NSUInteger, HDHexagonType) {
    HDHexagonTypeRegular = 1,
    HDHexagonTypeDouble  = 2,
    HDHexagonTypeTriple  = 3,
    HDHexagonTypeOne     = 4,
    HDHexagonTypeTwo     = 5,
    HDHexagonTypeThree   = 6,
    HDHexagonTypeFour    = 7,
    HDHexagonTypeFive    = 8,
    HDHexagonTypeStarter = 9,
    HDHexagonTypeNone    = 10,
    HDHexagonTypeEnd     = 11,
};

typedef NS_ENUM(NSUInteger, HDHexagonState) {
    HDHexagonStateEnabled  = 1,
    HDHexagonStateDisabled = 2,
    HDHexagonStateNone     = 0
};

extern NSString * const HDDoubleKey;
extern NSString * const HDTripleKey;

static const NSInteger NumberOfRows    = 18;
static const NSInteger NumberOfColumns = 9;

@class HDHexagonNode;
@protocol HDHexagonDelegate;
@interface HDHexagon : NSObject
@property (nonatomic, readonly) NSInteger touchesCount;
@property (nonatomic, getter=isCountTile, assign) BOOL countTile;
@property (nonatomic, getter=isSelected,  assign)  BOOL selected;
@property (nonatomic, getter=isLocked,    assign)  BOOL locked;
@property (nonatomic, weak) id<HDHexagonDelegate> delegate;
@property (nonatomic, strong) HDHexagonNode *node;
@property (nonatomic, assign) HDHexagonState state;
@property (nonatomic, assign) HDHexagonType type;
@property (nonatomic, readonly) NSInteger column;
@property (nonatomic, readonly) NSInteger row;
- (instancetype)initWithRow:(NSInteger)row column:(NSInteger)column type:(HDHexagonType)type NS_DESIGNATED_INITIALIZER;
- (UIColor *)emitterColor;
- (NSString *)defaultImagePath;
- (NSString *)selectedImagePath;
- (BOOL)selectedAfterRecievingTouches;
- (void)restoreToInitialState;
@end

@protocol HDHexagonDelegate <NSObject>
@optional
- (void)hexagon:(HDHexagon *)hexagon unlockedCountTile:(HDHexagonType)type;
@end
