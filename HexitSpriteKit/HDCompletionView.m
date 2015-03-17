//
//  HDCompletionView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/15/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDCompletionView.h"

NSString * const HDNextKey    = @"Next";
NSString * const HDShareKey   = @"Share";
NSString * const HDRestartKey = @"Restart";
NSString * const HDRateKey    = @"Rate";

static const CGFloat kPadding = 5.0f;
static const CGFloat kCornerRadius = 15.0f;
@interface HDCompletionView ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HDCompletionView

#pragma mark - Layer Class

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer {
    return (CAShapeLayer *)self.layer;
}

#pragma mark - Initalizer

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}

#pragma mark - Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.shapeLayer.fillColor = backgroundColor.CGColor;
}

#pragma mark - Private

- (void)_setup {
    
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:.5f];
    CGAffineTransform scale = CGAffineTransformMakeScale(TRANSFORM_SCALE, TRANSFORM_SCALE);
    
    self.shapeLayer.lineWidth = 0;
    self.shapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                  byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight
                                                        cornerRadii:CGSizeMake(kCornerRadius, kCornerRadius)] CGPath];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.transform = scale;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = GILLSANS(22.0f);
    self.titleLabel.text = @"Amazing!";
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.titleLabel.bounds) + kPadding);
    self.titleLabel.frame = CGRectIntegral(self.titleLabel.frame);
    [self addSubview:self.titleLabel];
    
    const NSUInteger numberOfColumns = 4;
    const CGFloat kSpacing = CGRectGetWidth(self.bounds)/5 + kPadding;
    for (NSUInteger i = 0; i < numberOfColumns; i++) {
        
        NSString *text = nil;
        UIImage *image = nil;
        
        switch (i) {
            case 0:
                text = HDNextKey;
                image = [UIImage imageNamed:@"Selected-Count"];
                break;
            case 1:
                text = HDRestartKey;
                image = [UIImage imageNamed:@"Selected-OneTap"];
                break;
            case 2:
                text = HDRateKey;
                image = [UIImage imageNamed:@"Selected-End"];
                break;
            case 3:
                text = HDShareKey;
                image = [UIImage imageNamed:@"Selected-Triple"];
                break;
        }
        
        CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
        UIButton *imageView = [[UIButton alloc] initWithFrame:imageRect];
        imageView.adjustsImageWhenDisabled    = NO;
        imageView.adjustsImageWhenHighlighted = NO;
        imageView.transform = scale;
        [imageView setTitle:text forState:UIControlStateNormal];
        [imageView setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [imageView addTarget:self action:@selector(_performActivity:) forControlEvents:UIControlEventTouchDown];
        imageView.center = CGPointMake((CGRectGetMidX(self.bounds) - ((numberOfColumns-1)/2.0f * kSpacing)) + (kSpacing * i),
                                       CGRectGetHeight(self.bounds)/1.85f);
        [imageView setBackgroundImage:image forState:UIControlStateNormal];
        [self addSubview:imageView];
    
        UILabel *description = [[UILabel alloc] init];
        description.transform = scale;
        description.textColor = [UIColor whiteColor];
        description.textAlignment = NSTextAlignmentCenter;
        description.font = GILLSANS_LIGHT(18.0f);
        description.text = text;
        [description sizeToFit];
        description.center = CGPointMake((CGRectGetMidX(self.bounds) - ((numberOfColumns-1)/2.0f * kSpacing)) + (kSpacing * i),
                                         CGRectGetHeight(self.bounds) - CGRectGetMidY(description.bounds) - kPadding);
        description.frame = CGRectIntegral(description.frame);
        [self addSubview:description];
    }
}

- (void)_performActivity:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(completionView:selectedButtonWithTitle:)]) {
        [self.delegate completionView:self selectedButtonWithTitle:sender.titleLabel.text];
    }
}

@end
