//
//  HDHintsView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/5/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDHintsView.h"
#import "UIColor+ColorAdditions.h"

NSString * const HDTitleLocalizationKey = @"tips";

static const CGFloat kiPhonePadding = 5.0f;
static const CGFloat kiPadPadding = 10.0f;
static const CGFloat kCornerRadius = 15.0f;
@interface HDHintsView ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HDHintsView{
    NSString *_hintDescription;
    NSString *_title;
    NSArray *_images;
}

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer {
   return (CAShapeLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                  description:(NSString *)description
                       images:(NSArray *)images {
    if (self = [super initWithFrame:frame]) {
        _hintDescription = description;
        _title = title;
        _images = images;
        [self _setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                  description:(NSString *)description
                       images:(NSArray *)images {
    
    return [self initWithFrame:frame
                         title:NSLocalizedString(HDTitleLocalizationKey, nil)
                   description:description
                        images:images];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.shapeLayer.fillColor = backgroundColor.CGColor;
}

#pragma mark - Private

- (void)_setup {
    
    self.shapeLayer.lineWidth = 0;
    self.backgroundColor = [UIColor flatSTDarkNavyColor];
    
    self.imageView = [[UIImageView alloc] initWithImage:[_images firstObject]];
    [self addSubview:self.imageView];
    
    if (_images.count > 1) {
        self.imageView.animationImages = _images;
        self.imageView.animationDuration = 1.0f;
        self.imageView.animationRepeatCount = NSIntegerMax;
        [self.imageView startAnimating];
    }
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = GILLSANS(22.0f);
    self.titleLabel.text = _title;
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.font = GILLSANS_LIGHT(18.0f);
    self.descriptionLabel.text = _hintDescription;
    
    for (UILabel *subViews in @[self.titleLabel, self.descriptionLabel]) {
        subViews.textColor     = [UIColor whiteColor];
        subViews.textAlignment = NSTextAlignmentCenter;
        [self addSubview:subViews];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.shapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                 byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight
                                                       cornerRadii:CGSizeMake(kCornerRadius, kCornerRadius)] CGPath];
    
    const CGFloat kPadding = IS_IPAD ? kiPadPadding : kiPhonePadding;
    
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.titleLabel.bounds) + kPadding);
    self.titleLabel.frame = CGRectIntegral(self.titleLabel.frame);
    
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.center = CGPointMake(CGRectGetMidX(self.bounds),
                                               CGRectGetHeight(self.bounds) - CGRectGetMidY(self.titleLabel.bounds) - kPadding);
    self.descriptionLabel.frame = CGRectIntegral(self.descriptionLabel.frame);
    
    self.imageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    const CGFloat scale = IS_IPAD ? 1.5f : TRANSFORM_SCALE;
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    for (UIView *subViews in self.subviews) {
        if ([subViews isKindOfClass:[UIImageView class]]) {
            subViews.transform = CGAffineTransformIdentity;
        } else {
            subViews.transform = scaleTransform;
        }
    }
}

@end
