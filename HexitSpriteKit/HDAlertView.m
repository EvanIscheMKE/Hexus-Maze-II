//
//  HDAlertView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 5/4/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDLabel.h"
#import "HDAlertView.h"
#import "HDGameButton.h"
#import "UIColor+ColorAdditions.h"

@implementation HDAlertView
{
    UIImageView *_imageView;
    HDGameButton *_resumeBtn;
}

- (instancetype)initWithTitle:(NSString *)title
                  description:(NSString *)description
                  buttonTitle:(NSString *)buttonTitle
                        image:(UIImage *)image
{
    if (self = [super init]) {
        
        CGRect containerBounds = CGRectInset(self.bounds, CGRectGetWidth(self.bounds)/7.0f, CGRectGetHeight(self.bounds)/3.0f);
        if (IS_IPAD) {
            containerBounds = CGRectInset(self.bounds, CGRectGetWidth(self.bounds)/4.75f, CGRectGetHeight(self.bounds)/2.9f);
        }
        
        self.container.frame = containerBounds;
        self.container.center = CGPointMake(CGRectGetMidX(self.bounds), -CGRectGetMidY(self.container.bounds));
        
        CGRect bounds = CGRectMake(0.0f,
                                   0.0f,
                                   CGRectGetWidth(self.container.bounds) - self.padding*2,
                                   CGRectGetHeight(self.container.bounds)/5.0f);
        _resumeBtn = [[HDGameButton alloc] initWithFrame:bounds];
        _resumeBtn.selected = YES;
        _resumeBtn.buttonColor = [UIColor flatSTEmeraldColor];
        _resumeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _resumeBtn.center = CGPointMake(CGRectGetMidX(self.container.bounds),
                                        CGRectGetHeight(self.container.bounds) - CGRectGetMidY(_resumeBtn.bounds) - self.padding);
        _resumeBtn.titleLabel.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(_resumeBtn.bounds) * .4);
        [_resumeBtn setTitle:buttonTitle forState:UIControlStateNormal];
        [_resumeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_resumeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self.container addSubview:_resumeBtn];
        
        const CGFloat scale = IS_IPAD ? 1.0f : TRANSFORM_SCALE_X;
        const CGFloat imageSize = (MAX(image.size.width, image.size.height) * 1.25f)*scale;
        const CGFloat startPositionX = floorf(CGRectGetMidX(self.container.bounds) - imageSize);
        const CGFloat basePositionY = floorf(CGRectGetHeight(self.container.bounds)/2.625f);
        for (NSUInteger i = 0; i < 3; i++) {
           UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
           [self.container addSubview:imageView];
            
            CGFloat posY = 0.0f;
            CGFloat posX = startPositionX + (i * imageSize);
            
            CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
            switch (i) {
                case 0:
                case 2:
                    posY = basePositionY + image.size.height/4;
                    break;
                default:
                    posY = basePositionY;
                    transform = CGAffineTransformMakeScale(scale + .25f, scale + .25f);
                    break;
            }
            imageView.transform = transform;
            imageView.center = CGPointMake(posX, posY);
        }
        
        self.titleLbl.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(self.container.bounds)/14);
        self.titleLbl.text = [title uppercaseString];
        [self.titleLbl sizeToFit];
        self.titleLbl.center = CGPointMake(CGRectGetMidX(self.container.bounds), CGRectGetMidY(self.titleLbl.bounds) + self.padding);
        self.titleLbl.frame = CGRectIntegral(self.titleLbl.frame);
        
        CGRect dbounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.container.bounds) - self.padding*4, 0.0f);
        self.descriptionLbl.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(self.container.bounds)/15);
        self.descriptionLbl.frame = dbounds;
        self.descriptionLbl.text = description;
        [self.descriptionLbl sizeToFit];
        self.descriptionLbl.center = CGPointMake(CGRectGetMidX(self.container.bounds),
                                               CGRectGetMinY(_resumeBtn.frame) - CGRectGetMidY(self.titleLbl.bounds) - self.padding/1.5);
        self.descriptionLbl.frame = CGRectIntegral(self.descriptionLbl.frame);
        
    }
    return self;
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
                    
                    for (UIView *view in [self.container subviews]) {
                        if ([view isKindOfClass:[UIImageView class]]) {
                            CAKeyframeAnimation *jiggle = [self jiggleAnimationWithDuration:defaultAnimationDuration repeatCount:2];
                            [view.layer addAnimation:jiggle forKey:jiggle.keyPath];
                        }
                    }
                    _resumeBtn.selected = NO;
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

- (CGFloat)padding
{
    return 10.0f;
}

@end
