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

typedef enum {
    HDHexagonTypeRegular = 1,
    HDHexagonTypeDouble  = 2,
    HDHexagonTypeTriple  = 3,
    HDHexagonTypeOne     = 4,
    HDHexagonTypeTwo     = 5,
    HDHexagonTypeThree   = 6,
    HDHexagonTypeFour    = 7,
    HDHexagonTypeFive    = 8,
    HDHexagonTypeStarter = 9
} HDHexagonType;

typedef enum {
    HDHexagonStateEnabled  = 3,
    HDHexagonStateDisabled = 4,
    HDHexagonStateNone     = 0
} HDHexagonState;

@class HDHexagonNode;

static const NSInteger NumberOfRows    = 18;
static const NSInteger NumberOfColumns = 9;

@protocol HDHexagonDelegate;
@interface HDHexagon : NSObject

@property (nonatomic, getter=isSelected, assign) BOOL selected;
@property (nonatomic, weak) id<HDHexagonDelegate> delegate;
@property (nonatomic, strong) HDHexagonNode *node;

@property (nonatomic, assign) HDHexagonState state;
@property (nonatomic, assign) HDHexagonType type;

@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;

- (void)recievedTouches;

@end

@protocol HDHexagonDelegate <NSObject>

- (void)unlockFollowingHexagonType:(HDHexagonType)type;

@end
