//
//  HDHexagonView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HDHexagonType) {
    HDHexagonTypeFlat  = 0,
    HDHexagonTypePoint = 1,
};

typedef NS_ENUM(NSUInteger, HDHexagonState) {
    HDHexagonStateLocked    = 0,
    HDHexagonStateUnlocked  = 1,
    HDHexagonStateCompleted = 2,
};

@interface HDHexagonView : UIView

@property (nonatomic, getter=isEnabled, assign) BOOL enabled;

@property (nonatomic, readonly)  UIView *container;
@property (nonatomic, readonly)  UILabel *indexLabel;
@property (nonatomic, readonly)  UIImageView *imageView;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;

@property (nonatomic, assign) HDHexagonState state;

- (instancetype)initWithFrame:(CGRect)frame strokeColor:(UIColor *)strokeColor;

@end
