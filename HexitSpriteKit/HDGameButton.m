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

@implementation HDGameButton
{
    BOOL _animating;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        CGRect contentBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)*.9f);
        
        self.adjustsImageWhenHighlighted = NO;
        self.adjustsImageWhenDisabled    = NO;
        
        self.bottom = [UIButton buttonWithType:UIButtonTypeCustom];
        self.content = [UIButton buttonWithType:UIButtonTypeCustom];
        self.content.titleLabel.textAlignment = NSTextAlignmentCenter;
        
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
            [self addSubview:button];
            
            index++;
        }
        
        self.cornerRadius = 4.0f;
        
        [self setTitleColor:[UIColor whiteColor]
                   forState:UIControlStateNormal];
        
        [self addTarget:self
                 action:@selector(_touchDown:)
       forControlEvents:UIControlEventTouchDown];
        
        [self addTarget:self
                 action:@selector(_animateTouchUpInside:)
       forControlEvents:UIControlEventTouchUpInside];
        
        [self addTarget:self
                 action:@selector(_animateTouchUpInside:)
       forControlEvents:UIControlEventTouchCancel];
        
        [self addTarget:self
                 action:@selector(_animateTouchUpInside:)
       forControlEvents:UIControlEventTouchDragExit];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_animating) {
        return;
    }
    
    CGRect contentBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)*.9f);
    
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

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    if (!self.bottom) {
        return;
    }
    
    for (UIButton *button in @[self.bottom, self.content]) {
        button.layer.cornerRadius = _cornerRadius;
    }
}

- (UIColor *)buttonBaseColor
{
    return [self.bottom backgroundColor];
}

- (void)setButtonColor:(UIColor *)buttonColor
{
    _buttonColor = buttonColor;
    [self.content setBackgroundColor:buttonColor];
    [self.bottom setBackgroundColor:[buttonColor colorWithAlphaComponent:.7f]];
}

#pragma mark - Actions

- (IBAction)_touchDown:(id)sender
{
    _animating = YES;
    self.content.center = self.bottom.center;
}

- (IBAction)_touchUpInside:(id)sender
{
    CGPoint position = self.content.center;
    position.y = CGRectGetMidY(self.content.bounds);
    self.content.center = position;
    _animating = NO;
}

- (IBAction)_animateTouchUpInside:(id)sender
{
    [UIView animateWithDuration:.3f
                          delay:0.0f
         usingSpringWithDamping:.4f
          initialSpringVelocity:.3f
                        options:0
                     animations:^{
                         
                         CGPoint position = self.content.center;
                         position.y = CGRectGetMidY(self.content.bounds);
                         self.content.center = position;
                         
                     } completion:^(BOOL finished) {
                         _animating = NO;
                     }];
}

#pragma mark - Override Getters

- (UILabel *)titleLabel
{
    return self.content.titleLabel;
}

#pragma mark - Override Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    NSAssert(NO, @"Method '%@' does nothing!", NSStringFromSelector(_cmd));
}

- (void)setAdjustsImageWhenDisabled:(BOOL)adjustsImageWhenDisabled
{
    [super setAdjustsImageWhenDisabled:adjustsImageWhenDisabled];
    [self.content setAdjustsImageWhenDisabled:adjustsImageWhenDisabled];
}

- (void)setAdjustsImageWhenHighlighted:(BOOL)adjustsImageWhenHighlighted
{
    [super setAdjustsImageWhenHighlighted:adjustsImageWhenHighlighted];
    [self.content setAdjustsImageWhenHighlighted:adjustsImageWhenHighlighted];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    [self.content setBackgroundImage:image forState:state];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [self.content setImage:image forState:state];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    [self.content setTitleColor:color forState:state];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [self.content setTitle:[title uppercaseString] forState:state];
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        [self _touchDown:nil];
    } else {
        [self _animateTouchUpInside:nil];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self.content setEnabled:enabled];
}

@end
