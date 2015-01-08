//
//  HDHexagonView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDHelper.h"
#import "HDHexagonView.h"
#import "UIColor+FlatColors.h"

@interface HDHexagonView ()
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation HDHexagonView {
    UIColor *_hexaStroke;
}

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (CAShapeLayer *)hexaLayer
{
    return (CAShapeLayer *)self.layer;
}

- (id)initWithFrame:(CGRect)frame strokeColor:(UIColor *)strokeColor
{
    if (self = [super initWithFrame:frame]) {
        _hexaStroke = strokeColor;
        [self _setup];
    }
    return self;
}

- (void)_setup
{
    self.hexaLayer.path        = [HDHelper hexagonPathForBounds:self.bounds];
    self.hexaLayer.fillColor   = [[UIColor flatWetAsphaltColor] CGColor];
    self.hexaLayer.strokeColor = [_hexaStroke CGColor];
    self.hexaLayer.lineWidth   = 8.0f;
    
    self.container = [[UIView alloc] initWithFrame:self.bounds];
    self.container.userInteractionEnabled = YES;
    [self addSubview:self.container];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.userInteractionEnabled = NO;
    self.imageView.contentMode = UIViewContentModeCenter;
    [self.container addSubview:self.imageView];
    
    self.indexLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.indexLabel.userInteractionEnabled = NO;
    self.indexLabel.hidden        = YES;
    self.indexLabel.font          = GILLSANS(CGRectGetWidth(self.bounds)/3);
    self.indexLabel.textAlignment = NSTextAlignmentCenter;
    self.indexLabel.textColor     = [UIColor flatWetAsphaltColor];
    [self.container addSubview:self.indexLabel];
}

#pragma mark - Setters

- (void)setIndex:(NSInteger)index
{
    _index = index;
    
    self.indexLabel.text = [NSString stringWithFormat:@"%zd", index];
    self.container.tag = index;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    NSAssert(NO, @"Use setFill: or setStroke: %@",NSStringFromSelector(_cmd));
}

- (void)setState:(HDHexagonState)state
{
    _state = state;
    
    NSLog(@"%lu",state);
    
    if (state != HDHexagonStateLocked) {
        
        self.hexaLayer.fillColor   = [[UIColor flatPeterRiverColor] CGColor];
        self.hexaLayer.strokeColor = [[UIColor flatPeterRiverColor] CGColor];;
        self.indexLabel.hidden = NO;
        
        // Move text down to make room for completion start
        CGPoint labelPosition = self.indexLabel.center;
        labelPosition.y = CGRectGetHeight(self.bounds) * .7f;
        self.indexLabel.center = labelPosition;
        
        // Move imageviews center point up to make room for image
        CGPoint imagePosition = self.imageView.center;
        imagePosition.y = CGRectGetHeight(self.bounds) * .25f;
        
        self.imageView.center = imagePosition;
        self.imageView.image  = [UIImage imageNamed:(state == HDHexagonStateCompleted) ? @"WhiteStar-" : @"BlueStar-"];
        
        return;
    }
    self.hexaLayer.strokeColor = [[UIColor flatEmeraldColor] CGColor];
    self.imageView.image = [UIImage imageNamed:@"Locked"];
}

@end
