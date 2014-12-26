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
    HDHexagonStateLocked   = 0,
    HDHexagonStateUnlocked  = 1,
    HDHexagonStateCompleted = 2,
};

@interface HDHexagonView : UIView
@property (nonatomic, getter=isEnabled, assign) BOOL enabled;

@property (nonatomic, strong)  UIView *container;
@property (nonatomic, strong)  UILabel *indexLabel;
@property (nonatomic, strong)  UIImageView *imageView;
@property (nonatomic, readonly) HDHexagonState state;
- (void)setState:(HDHexagonState)state index:(NSInteger)index;
- (instancetype)initWithFrame:(CGRect)frame type:(HDHexagonType)type strokeColor:(UIColor *)strokeColor;
@end
