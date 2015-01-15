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
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIButton *remove;
@end

@implementation HDTileDescriptorView{
    NSString *_title;
    NSString *_description;
    UIImage  *_tileImage;
}

- (instancetype)initWithTitle:(NSString *)title
                  description:(NSString *)description
                        image:(UIImage *)image
{
    if (self = [super init]) {
        
        NSParameterAssert(title);
        NSParameterAssert(description);
        NSParameterAssert(image);
       
        _title       = title;
        _description = description;
        _tileImage   = image;
        
        self.frame = [self _keyWindow].frame;
        self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:.75f];
        self.alpha = 0.0f;
        
        [self _setup];
    }
    return self;
}

#pragma mark - Private

- (UIWindow *)_keyWindow
{
    return [UIApplication sharedApplication].keyWindow;
}

- (void)_setup
{
    [self _keyWindow].tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    [[self _keyWindow] tintColorDidChange];
    
    self.imageView = [[UIImageView alloc] initWithImage:_tileImage];
    self.imageView.center = self.center;
    [self addSubview:self.imageView];
    
    self.descriptorLabel = [[UILabel alloc] init];
    self.descriptorLabel.text = _description;
    self.descriptorLabel.font = GILLSANS_LIGHT(25.0f);
    
    self.headerLabel = [[UILabel alloc] init];
    self.headerLabel.text = _title;
    self.headerLabel.font = GILLSANS_LIGHT(42.0f);
    
    for (UILabel *subView in @[self.headerLabel, self.descriptorLabel]) {
        subView.textAlignment = NSTextAlignmentCenter;
        subView.textColor = [UIColor whiteColor];
        [subView sizeToFit];
        [self addSubview:subView];
    }
    
    self.remove = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.remove addTarget:self action:@selector(_performDismissal) forControlEvents:UIControlEventTouchUpInside];
    self.remove.translatesAutoresizingMaskIntoConstraints = NO;
    self.remove.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.remove.titleLabel.font = GILLSANS(26.0f);
    [self.remove setTitle:@"X" forState:UIControlStateNormal];
    [self.remove setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:self.remove];
    
    UIButton *removeButton = self.remove;
    NSDictionary *metrics = @{ @"height": @40.0f , @"inset": @20.0f };
    NSDictionary *views = NSDictionaryOfVariableBindings(removeButton);
    
    NSArray *verticalConstraint =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[removeButton(height)]"
                                            options:0
                                            metrics:metrics
                                              views:views];
    [self addConstraints:verticalConstraint];
    
    NSArray *horizontalConstraint =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:[removeButton(height)]-inset-|"
                                            options:0
                                            metrics:metrics
                                              views:views];
    [self addConstraints:horizontalConstraint];
}

- (void)_performDismissal
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(descriptorViewClickedDismissalButton:)]) {
        [self.delegate descriptorViewClickedDismissalButton:self];
    }
}

#pragma mark - Public

- (void)show
{
    [UIView animateWithDuration:.300f animations:^{
        self.alpha = 1.0f;
    }];
    [[self _keyWindow] addSubview:self];
}

- (void)dismiss
{
     [self _keyWindow].tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    [[self _keyWindow] tintColorDidChange];
    [self removeFromSuperview];
}

@end
