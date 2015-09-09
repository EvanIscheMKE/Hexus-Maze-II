//
//  HDCompletionView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/15/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDLabel.h"
#import "HDHelper.h"
#import "HDButton.h"
#import "HDGameButton.h"
#import "HDHexaButton.h"
#import "HDCompletionView.h"
#import "UIColor+ColorAdditions.h"

NSString * const HDShareKey   = @"share";
NSString * const HDRestartKey = @"restart";
NSString * const HDRateKey    = @"rate";

static const NSUInteger numberOfColumns = 4;
@implementation HDCompletionView
{
    NSString *_title;
}

- (instancetype)initWithTitle:(NSString *)title
{
    if (self = [super init]) {
        _title = title;
       [self _setup];
    }
    return self;
}

#pragma mark - Private

- (void)_setup
{
    const CGFloat padding = 9.0f;
    const CGSize vertButtonSize = CGSizeMake(CGRectGetWidth(self.bounds)/1.25f, CGRectGetHeight(self.bounds)/13.5f);
    const CGSize horiButtonSize = CGSizeMake(vertButtonSize.width/2 - padding/2, vertButtonSize.height);
    
    CGRect containerBounds = CGRectMake(0.0f, 0.0f, vertButtonSize.width + padding*2, vertButtonSize.height * 8.35f);
    self.container.frame = containerBounds;
    self.container.center = CGPointMake(CGRectGetMidX(self.bounds), -CGRectGetMidY(self.container.bounds));

    CGRect initialRect = CGRectMake(padding,
                                    CGRectGetHeight(self.container.bounds) - vertButtonSize.height*2 - padding*2,
                                    vertButtonSize.width,
                                    vertButtonSize.height);
    
    CGRect previousRect = CGRectZero;
    for (NSUInteger i = 0; i < numberOfColumns/2; i++) {
        CGRect currentRect = previousRect;
        
        if (i == 0) {
            currentRect = initialRect;
        } else {
            currentRect.origin.y += (vertButtonSize.height + padding);
        }

        HDGameButton *vertBtn = [[HDGameButton alloc] initWithFrame:currentRect];
        vertBtn.buttonColor = (i == 0) ? [UIColor flatSTEmeraldColor]
                                       : [UIColor flatSTLightBlueColor];
        [vertBtn setTitle:[self _stringFromIdx:i] forState:UIControlStateNormal];
        [self.container addSubview:vertBtn];
        
        CGRect horiFrame = CGRectMake((i == 0) ? padding : padding*2 + horiButtonSize.width,
                                      CGRectGetMinY(initialRect) - horiButtonSize.height - padding,
                                      horiButtonSize.width,
                                      horiButtonSize.height);
        HDGameButton *horiBtn = [[HDGameButton alloc] initWithFrame:horiFrame];
        horiBtn.buttonColor = (i == 0) ? [UIColor flatSTRedColor]
                                       : [UIColor flatSTLightBlueColor];
        [horiBtn setTitle:[self _stringFromIdx:2 + i] forState:UIControlStateNormal];
        [self.container addSubview:horiBtn];
        
        previousRect = currentRect;
    }
    
    self.titleLbl.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(self.container.bounds)/24.0f);
    self.titleLbl.text = [_title uppercaseString];
    [self.titleLbl sizeToFit];
    self.titleLbl.center = CGPointMake(CGRectGetMidX(self.container.bounds), CGRectGetMidY(self.titleLbl.bounds) + padding*2.f);
    self.titleLbl.frame = CGRectIntegral(self.titleLbl.frame);
    
    CGRect dbounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.container.bounds) - padding*4, 0.0f);
    self.descriptionLbl.frame = dbounds;
    self.descriptionLbl.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(self.container.bounds)/27.0f);
    self.descriptionLbl.text = NSLocalizedString(@"wow", nil);
    [self.descriptionLbl sizeToFit];
    self.descriptionLbl.center = CGPointMake(CGRectGetMidX(self.container.bounds),
                                             CGRectGetMinY(initialRect) - horiButtonSize.height -  CGRectGetMidY(self.titleLbl.bounds) - padding*1.5f);
    self.descriptionLbl.frame = CGRectIntegral(self.descriptionLbl.frame);
    
    NSUInteger index = 0;
    for (HDGameButton *btn in self.container.subviews) {
        if ([btn isKindOfClass:[HDGameButton class]]) {
            [btn addSoundNamed:HDButtonSound forControlEvent:UIControlEventTouchUpInside];
            btn.index = index;
            btn.selected = YES;
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.font = GAME_FONT_WITH_SIZE(CGRectGetMidY(btn.bounds)/1.25f);
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(_performActivity:) forControlEvents:UIControlEventTouchUpInside];
            index++;
        }
    }
    
    UIImage *image = [UIImage imageNamed:@"3D-Star"];
    
    const CGFloat scale = IS_IPAD ? 1.0f : TRANSFORM_SCALE_X;
    const CGFloat imageSize = (MAX(image.size.width, image.size.height) * .95) * scale;
    const CGFloat startPositionX = floorf(CGRectGetMidX(self.container.bounds) - imageSize);
    const CGFloat basePositionY = floorf(CGRectGetHeight(self.container.bounds)/2.9f);
    for (NSUInteger i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self.container addSubview:imageView];
        
        CGFloat posY = 0.0f;
        
        CGFloat posX = startPositionX + (i * imageSize);
        
        CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
        
        switch (i) {
            case 0:
            case 2:
                posY = basePositionY;
                break;
            default:
                posY = basePositionY - image.size.height/3;
                transform = CGAffineTransformMakeScale(scale + .3f, scale + .3f);
                break;
        }
        imageView.transform = transform;
        imageView.center = CGPointMake(posX, posY);
    }
}

- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    [CATransaction begin]; {
        [CATransaction setAnimationDuration:.05f];
        [CATransaction setCompletionBlock:^{
            
            [self.container.layer removeAllAnimations];
            [CATransaction begin]; {
                [CATransaction setAnimationDuration:.05f];
                [CATransaction setCompletionBlock:^{
                    
                    for (UIView *btn in self.container.subviews) {
                        if ([btn isKindOfClass:[HDGameButton class]]) {
                            HDGameButton *gameBtn = (HDGameButton *)btn;
                            gameBtn.selected = NO;
                        }
                    }
                    
                    for (UIView *view in [self.container subviews]) {
                        if ([view isKindOfClass:[UIImageView class]]) {
                            CAKeyframeAnimation *jiggle = [self jiggleAnimationWithDuration:defaultAnimationDuration repeatCount:1];
                            [view.layer addAnimation:jiggle forKey:jiggle.keyPath];
                        }
                    }
                }];
                
                CAKeyframeAnimation *keyFrameAnimation = [self jiggleAnimationWithDuration:defaultAnimationDuration/2 repeatCount:1];
                [self.container.layer addAnimation:keyFrameAnimation forKey:keyFrameAnimation.keyPath];
                
            } [CATransaction commit];
        }];
        
        CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
        keyFrameAnimation.duration = defaultAnimationDuration;
        keyFrameAnimation.values = @[@(self.container.center.y),
                                     @(CGRectGetMidY(self.bounds) + 20.0f),
                                     @(CGRectGetMidY(self.bounds))];
        keyFrameAnimation.keyTimes = @[@0.0f, @0.2f, @1.0f];
        
        self.container.layer.position = CGPointMake(CGRectGetMidX(self.bounds), [[keyFrameAnimation.values lastObject] floatValue]);
        [self.container.layer addAnimation:keyFrameAnimation forKey:keyFrameAnimation.keyPath];
        
    } [CATransaction commit];
    
    [UIView animateWithDuration:defaultAnimationDuration animations:^{
        self.bgView.alpha = 1.0f;
    }];
}

- (NSString *)_stringFromIdx:(NSUInteger)idx
{
    NSString *numString = [[_title componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    NSString *string = [NSString stringWithFormat:@"%@ %tu",NSLocalizedString(@"level", nil),[numString integerValue] + 1];
    NSArray *strings = @[NSLocalizedString(HDRestartKey, nil),
                         string,
                         NSLocalizedString(HDRateKey, nil),
                         NSLocalizedString(HDShareKey, nil)];
    return [strings objectAtIndex:idx];
}

- (void)_performActivity:(HDGameButton *)sender
{    
    NSInteger index = sender.index;
    if ((index != 3) && (index != 1)) {
         [self dismiss];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(completionView:selectedButtonWithTag:)]) {
        [self.delegate completionView:self selectedButtonWithTag:index];
    }
}

@end
