//
//  HDTileDescriptorView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 1/14/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDTileDescriptorView.h"

@interface HDTileDescriptorView ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *descriptorLabel;
@property (nonatomic, strong) UIButton *remove;
@end

@implementation HDTileDescriptorView {
    NSString *_description;
    UIImage  *_tileImage;
}

- (instancetype)initWithDescription:(NSString *)description
                              image:(UIImage *)image
{
    NSParameterAssert(description);
    NSParameterAssert(image);
    if (self = [super init]) {
        _description = description;
        _tileImage   = image;
        
        self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:.75f];
        
        [self _setup];
    }
    return self;
}

#pragma mark - Private

- (void)_setup
{
    self.imageView = [[UIImageView alloc] initWithImage:_tileImage];
    [self addSubview:self.imageView];
    
    self.descriptorLabel = [[UILabel alloc] init];
    self.descriptorLabel.text  = _description;
    self.descriptorLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptorLabel.textColor     = [UIColor whiteColor];
    self.descriptorLabel.numberOfLines = 0;
    [self addSubview:self.descriptorLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.imageView.transform = CGAffineTransformMakeScale((CGRectGetWidth(self.bounds)-80.0f)/375.0f,
                                                          (CGRectGetWidth(self.bounds)-80.0f)/375.0f);
    
    CGRect boundsWithInset = CGRectInset(self.bounds, 20.0f, 0.0f);
    self.descriptorLabel.font  = GILLSANS(CGRectGetHeight(self.bounds)/22);
    self.descriptorLabel.frame = boundsWithInset;
    [self.descriptorLabel sizeToFit];
    self.descriptorLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds)/1.35f);
    self.descriptorLabel.frame  = CGRectIntegral(self.descriptorLabel.frame);
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeFromSuperview];
}

@end
