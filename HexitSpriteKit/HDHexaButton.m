//
//  HDHexagonView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevel.h"
#import "HDHelper.h"
#import "HDHexaButton.h"
#import "UIColor+ColorAdditions.h"

static const CGFloat paddingLarge = 6.0f;
static const CGFloat paddingSmall = 4.0f;
@implementation HDHexaButton {
    UIButton *_contentImageView;
    UIImageView *_shadowImageView;
    HDLevelState _state;
}

- (instancetype)initWithLevelState:(HDLevelState)levelState
{
    _levelState = _state;
    
    NSString *_contentImagePath;
    NSString *_shadowImagePath;
    
    switch (levelState) {
        case HDLevelStateCompleted:
        case HDLevelStateLocked:
            _contentImagePath = @"Upper-Grid-Locked";
            _shadowImagePath  = @"Lower-Grid-Locked";
            break;
        case HDLevelStateUnlocked:
            _contentImagePath = @"Upper-Grid-Unlocked";
            _shadowImagePath  = @"Lower-Grid-Unlocked";
            break;
        default:
            break;
    }
    return [self initWithImage:[UIImage imageNamed:_contentImagePath]
                   shadowImage:[UIImage imageNamed:_shadowImagePath]];
}

- (instancetype)initWithImage:(UIImage *)image
                  shadowImage:(UIImage *)shadowImage
{
    const CGFloat padding = IS_IPAD ? paddingLarge : paddingSmall;
    if (self = [super initWithFrame:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height + padding)]) {
        
        self.adjustsImageWhenDisabled    = NO;
        self.adjustsImageWhenHighlighted = NO;
        
        CGRect contentBounds = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
        _contentImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_contentImageView setBackgroundImage:image forState:UIControlStateNormal];
        [_contentImageView setImage:[self imageForLevelState:_levelState] forState:UIControlStateNormal];
        _contentImageView.frame = contentBounds;
        _contentImageView.center = CGPointMake(CGRectGetMidX(self.bounds),
                                               CGRectGetMidY(_contentImageView.bounds));
        
        _shadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
        _shadowImageView.center = CGPointMake(CGRectGetMidX(self.bounds),
                                              CGRectGetHeight(self.bounds) - CGRectGetMidY(_shadowImageView.bounds));
        
        for (id subview in @[_shadowImageView, _contentImageView]) {
            [subview setUserInteractionEnabled:NO];
            [self addSubview:subview];
        }
        
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

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        [self _touchDown:nil];
    } else {
        [self _animateTouchUpInside:nil];
    }
}

#pragma mark - Actions

- (IBAction)_touchDown:(id)sender
{
    _contentImageView.center = _shadowImageView.center;
}

- (IBAction)_touchUpInside:(id)sender
{
    CGPoint position = _contentImageView.center;
    position.y = CGRectGetMidY(_contentImageView.bounds);
    _contentImageView.center = position;
}

- (IBAction)_animateTouchUpInside:(id)sender
{
    [UIView animateWithDuration:.3f
                          delay:0.0f
         usingSpringWithDamping:.4f
          initialSpringVelocity:.3f
                        options:0
                     animations:^{
                         
                         CGPoint position = _contentImageView.center;
                         position.y = CGRectGetMidY(_contentImageView.bounds);
                         _contentImageView.center = position;
                         
                     } completion:nil];
}

#pragma mark - Helper

- (UIImage *)imageForLevelState:(HDLevelState)state
{
    switch (state) {
        case HDLevelStateCompleted:
            return [UIImage imageNamed:@"Star-Grid"];
        case HDLevelStateLocked:
            return [UIImage imageNamed:@"Locked-Grid"];
            break;
        default:
            return nil;
    }
}

#pragma mark - Setter

- (void)setLevelState:(HDLevelState)levelState
{
    _levelState = levelState;
    
    NSString *_contentImagePath;
    NSString *_shadowImagePath;
    switch (levelState) {
        case HDLevelStateCompleted:
        case HDLevelStateLocked:
            _contentImagePath = @"Upper-Grid-Locked";
            _shadowImagePath  = @"Lower-Grid-Locked";
            break;
        case HDLevelStateUnlocked:
            _contentImagePath = @"Upper-Grid-Unlocked";
            _shadowImagePath  = @"Lower-Grid-Unlocked";
            break;
        default:
            break;
    }
    
    [self _touchDown:nil];
    [_contentImageView setImage:[self imageForLevelState:levelState]
                       forState:UIControlStateNormal];
    [_contentImageView setBackgroundImage:[UIImage imageNamed:_contentImagePath]
                                 forState:UIControlStateNormal];
    _shadowImageView.image = [UIImage imageNamed:_shadowImagePath];
    
    [self performSelector:@selector(_animateTouchUpInside:) withObject:nil afterDelay:.15f];
}

@end
