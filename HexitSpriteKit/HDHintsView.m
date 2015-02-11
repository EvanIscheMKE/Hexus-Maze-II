//
//  HDHintsView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/5/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHintsView.h"
#import "UIColor+FlatColors.h"

static const CGFloat kPadding = 3.0f;

NSString * const HDTitleLocalizationKey = @"Tips";
@interface HDHintsView ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HDHintsView{
    NSString *_hintDescription;
}

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer
{
   return (CAShapeLayer *)self.layer;
}

- (instancetype)initWithDescription:(NSString *)description
{
    if (self = [super init]) {
        _hintDescription = description;
        [self _setup];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.shapeLayer.fillColor = backgroundColor.CGColor;
}

#pragma mark - Private

- (void)_setup
{
    self.backgroundColor = [UIColor colorWithWhite:.0f alpha:0.8f];
    
    self.shapeLayer.lineWidth = 0;
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-Mine"]];
    [self addSubview:self.imageView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = GILLSANS(22.0f);
    self.titleLabel.text = NSLocalizedString(HDTitleLocalizationKey, nil);
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.font = GILLSANS_LIGHT(18.0f);
    self.descriptionLabel.text = _hintDescription;
    
    for (UILabel *subViews in @[self.titleLabel, self.descriptionLabel]) {
        subViews.textColor     = [UIColor whiteColor];
        subViews.textAlignment = NSTextAlignmentCenter;
        [self addSubview:subViews];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.shapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                 byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight
                                                       cornerRadii:CGSizeMake(15.0f, 15.0f)] CGPath];
    
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.titleLabel.bounds) + kPadding);
    self.titleLabel.frame = CGRectIntegral(self.titleLabel.frame);
    
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.center = CGPointMake(CGRectGetMidX(self.bounds),
                                               CGRectGetHeight(self.bounds) - CGRectGetMidY(self.titleLabel.bounds) - kPadding);
    self.descriptionLabel.frame = CGRectIntegral(self.descriptionLabel.frame);
    
    self.imageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGAffineTransform scale = CGAffineTransformMakeScale(CGRectGetWidth(self.bounds)/375.0f, CGRectGetWidth(self.bounds)/375.0f);
    for (UIView *subViews in self.subviews) {
        subViews.transform = scale;
    }
}

@end
