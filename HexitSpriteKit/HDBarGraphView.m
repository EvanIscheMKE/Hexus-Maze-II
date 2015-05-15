//
//  HDBarGraphView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 5/15/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "UIColor+ColorAdditions.h"
#import "HDBarGraphView.h"
#import "HDShapeView.h"

@implementation HDBarGraphView {
    HDShapeView *_shapeView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        CGRect bounds = CGRectInset(self.bounds, CGRectGetWidth(self.bounds)/8.0f, CGRectGetMidY(self.bounds) - 3.0f);
        _shapeView = [[HDShapeView alloc] initWithFrame:bounds];
        [self addSubview:_shapeView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [[UIColor flatSTDarkNavyColor] setFill];
    CGRect bounds = CGRectInset(self.bounds, CGRectGetWidth(self.bounds)/8.0f, CGRectGetMidY(self.bounds) - 2.0f);
    UIRectFill(bounds);
}

@end
