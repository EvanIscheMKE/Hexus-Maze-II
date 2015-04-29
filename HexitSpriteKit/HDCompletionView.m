//
//  HDCompletionView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/15/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDButton.h"
#import "HDCompletionView.h"
#import "UIColor+ColorAdditions.h"

NSString * const HDNextKey    = @"next";
NSString * const HDShareKey   = @"share";
NSString * const HDRestartKey = @"restart";
NSString * const HDRateKey    = @"rate";

static const CGFloat kIphonePadding = 5.0f;
static const CGFloat kIpadPadding   = 10.0f;
static const CGFloat kCornerRadius  = 15.0f;
@interface HDCompletionView ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HDCompletionView {
    NSString *_timeString;
}

#pragma mark - Layer Class

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer {
    return (CAShapeLayer *)self.layer;
}

#pragma mark - Initalizer

- (instancetype)initWithFrame:(CGRect)frame time:(NSString *)timeString {
    if (self = [super initWithFrame:frame]) {
        _timeString = timeString;
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
    
    self.backgroundColor = [UIColor flatSTDarkNavyColor];
    
    const CGFloat scale = IS_IPAD ? 1.5f : TRANSFORM_SCALE;
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    
    const CGFloat kPadding = IS_IPAD ? kIpadPadding : kIphonePadding;
    
    self.shapeLayer.lineWidth = 0;
    self.shapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                  byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight
                                                        cornerRadii:CGSizeMake(kCornerRadius, kCornerRadius)] CGPath];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.transform = scaleTransform;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = GILLSANS(20.0f);
    self.titleLabel.text = _timeString;
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.titleLabel.bounds) + kPadding);
    self.titleLabel.frame = CGRectIntegral(self.titleLabel.frame);
    [self addSubview:self.titleLabel];
    
    NSString *text = nil;
    UIImage *image = nil;
    
    const NSUInteger numberOfColumns = 4;
    const CGFloat kSpacing = CGRectGetWidth(self.bounds)/5 + kPadding;
    for (NSUInteger i = 0; i < numberOfColumns; i++) {
        switch (i) {
            case 0:
                text = NSLocalizedString(HDNextKey, nil);
                image = [UIImage imageNamed:@"Selected-Count"];
                break;
            case 1:
                text = NSLocalizedString(HDRestartKey, nil);
                image = [UIImage imageNamed:@"Selected-OneTap"];
                break;
            case 2:
                text = NSLocalizedString(HDRateKey, nil);
                image = [UIImage imageNamed:@"Selected-End"];
                break;
            case 3:
                text = NSLocalizedString(HDShareKey, nil);
                image = [UIImage imageNamed:@"Selected-Triple"];
                break;
        }
        
        CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
        HDButton *imageView = [[HDButton alloc] initWithFrame:imageRect];
        imageView.adjustsImageWhenDisabled    = NO;
        imageView.adjustsImageWhenHighlighted = NO;
        imageView.transform = IS_IPAD ? CGAffineTransformIdentity : CGAffineTransformMakeScale(TRANSFORM_SCALE, TRANSFORM_SCALE);
        [imageView setTitle:text forState:UIControlStateNormal];
        [imageView setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [imageView addSoundNamed:@"menuClicked.wav"
                 forControlEvent:UIControlEventTouchUpInside];
        [imageView addTarget:self action:@selector(_performActivity:) forControlEvents:UIControlEventTouchUpInside];
        imageView.center = CGPointMake((CGRectGetMidX(self.bounds) - ((numberOfColumns-1)/2.0f * kSpacing)) + (kSpacing * i),
                                       CGRectGetHeight(self.bounds)/1.85f);
        [imageView setBackgroundImage:image forState:UIControlStateNormal];
        [self addSubview:imageView];
    
        UILabel *description = [[UILabel alloc] init];
        description.transform = scaleTransform;
        description.textColor = [UIColor whiteColor];
        description.textAlignment = NSTextAlignmentCenter;
        description.font = GILLSANS_LIGHT(14.0f);
        description.text = text;
        [description sizeToFit];
        description.center = CGPointMake((CGRectGetMidX(self.bounds) - ((numberOfColumns-1)/2.0f * kSpacing)) + (kSpacing * i),
                                         CGRectGetHeight(self.bounds) - CGRectGetMidY(description.bounds) - kPadding);
        description.frame = CGRectIntegral(description.frame);
        [self addSubview:description];
    }
    
}

- (void)_performActivity:(HDButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(completionView:selectedButtonWithTitle:)]) {
        [self.delegate completionView:self selectedButtonWithTitle:sender.titleLabel.text];
    }
}

@end
