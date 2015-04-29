//
//  HDGameButton.m
//  SixSquare
//
//  Created by Evan Ische on 4/24/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDGameButton.h"

@interface HDGameButton ()
@property (nonatomic, strong) UIButton *content;
@property (nonatomic, strong) UIButton *bottom;
@end

@implementation HDGameButton {
    BOOL _animating;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        CGRect contentBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)*.9f);
        
        self.cornerRadius = 4.0f;
        
        self.content = [UIButton buttonWithType:UIButtonTypeCustom];
        self.bottom  = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSUInteger index = 0;
        for (UIButton *button  in @[self.bottom,self.content]) {
            
            CGPoint position;
            switch (index) {
                case 0:
                    position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetMidY(contentBounds));
                    break;
                case 1:
                    position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(contentBounds));
                    break;
                default:
                    break;
            }
            
            button.userInteractionEnabled = NO;
            button.frame = contentBounds;
            button.center = position;
            button.layer.cornerRadius = self.cornerRadius;
            [self addSubview:button];
            
            index++;
        }
        
        self.content.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.adjustsImageWhenHighlighted = NO;
        self.adjustsImageWhenDisabled    = NO;
        
        [self setTitleColor:[UIColor whiteColor]
                   forState:UIControlStateNormal];
        
        [self addTarget:self
                 action:@selector(_touchDown:)
       forControlEvents:UIControlEventTouchDown];
        
        [self addTarget:self
                 action:@selector(_touchUpInside:)
       forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_animating) {
        return;
    }
    
    CGRect contentBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)*.875f);
    
    NSUInteger index = 0;
    for (UIButton *button in @[self.bottom, self.content]) {
        
        button.frame = contentBounds;
        
        CGPoint position;
        switch (index) {
            case 0:
                position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetMidY(contentBounds));
                break;
            case 1:
                position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(contentBounds));
                break;
            default:
                break;
        }
        
        button.center = position;
        
        index++;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
   
    _cornerRadius = cornerRadius;
    if (!self.bottom) {
        return;
    }
    
     _cornerRadius = cornerRadius;
    for (UIButton *button in @[self.bottom, self.content]) {
        button.layer.cornerRadius = _cornerRadius;
    }
}

- (UIColor *)buttonBaseColor {
    return [self.bottom backgroundColor];
}

- (void)setButtonColor:(UIColor *)buttonColor {
    _buttonColor = buttonColor;
    [self.content setBackgroundColor:buttonColor];
    [self.bottom setBackgroundColor:[buttonColor colorWithAlphaComponent:.7f]];
}

#pragma mark - Actions

- (IBAction)_touchDown:(id)sender {
    _animating = YES;
    self.content.center = self.bottom.center;
}

- (IBAction)_touchUpInside:(id)sender {
    CGPoint position = self.content.center;
    position.y = CGRectGetMidY(self.content.bounds);
    self.content.center = position;
    _animating = NO;
}

#pragma mark - Override Getters

- (UILabel *)titleLabel {
    return self.content.titleLabel;
}

#pragma mark - Override Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    NSAssert(NO, @"Method '%@' does nothing!", NSStringFromSelector(_cmd));
}

- (void)setAdjustsImageWhenDisabled:(BOOL)adjustsImageWhenDisabled {
    [super setAdjustsImageWhenDisabled:adjustsImageWhenDisabled];
    [self.content setAdjustsImageWhenDisabled:adjustsImageWhenDisabled];
}

- (void)setAdjustsImageWhenHighlighted:(BOOL)adjustsImageWhenHighlighted {
    [super setAdjustsImageWhenHighlighted:adjustsImageWhenHighlighted];
    [self.content setAdjustsImageWhenHighlighted:adjustsImageWhenHighlighted];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [self.content setBackgroundImage:image forState:state];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    [self.content setImage:image forState:state];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    [self.content setTitleColor:color forState:state];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [self.content setTitle:title forState:state];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self.content setSelected:selected];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self.content setEnabled:enabled];
}

@end
