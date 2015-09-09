//
//  HDLayoverView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 5/7/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDLabel.h"
#import "HDLayoverView.h"

@implementation HDLayoverView

- (instancetype)init
{
    if (self = [super init]) {
        
        self.retainSelf = self;
        
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        keyWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        [keyWindow tintColorDidChange];
        
        self.frame = keyWindow.bounds;
    
        self.bgView = [[UIView alloc] initWithFrame:self.bounds];
        self.bgView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:.5f];
        self.bgView.alpha = 0.0f;
        
        self.container = [[UIView alloc] init];
        self.container.layer.cornerRadius = 10.0f;
        self.container.backgroundColor = [UIColor colorWithRed:(3/255.0f) green:(30/255.0f) blue:(43/255.0f) alpha:1.0f];
        
        for (UIView *subView in @[self.bgView, self.container]) {
            [self addSubview:subView];
        }
        
        self.titleLbl = [[HDLabel alloc] init];
        self.titleLbl.textColor = [UIColor whiteColor];
        self.titleLbl.font = GAME_FONT_WITH_SIZE(19.0f);
        
        self.descriptionLbl = [[HDLabel alloc] init];
        self.descriptionLbl.textColor = [UIColor whiteColor];
        self.descriptionLbl.font = GAME_FONT_WITH_SIZE(14.0f);
        self.descriptionLbl.lineBreakMode = NSLineBreakByWordWrapping;
        self.descriptionLbl.numberOfLines = 0;
        
        for (HDLabel *subViews in @[self.titleLbl, self.descriptionLbl]) {
            subViews.textAlignment = NSTextAlignmentCenter;
            [self.container addSubview:subViews];
        }
        
    }
    return self;
}

- (CAKeyframeAnimation *)jiggleAnimationWithDuration:(NSTimeInterval)duration repeatCount:(CGFloat)count
{
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    keyFrameAnimation.duration = defaultAnimationDuration/2;
    keyFrameAnimation.repeatCount = count;
    keyFrameAnimation.values = @[@0.0f, @(M_PI_4/5), @(-M_PI_4/5), @0.0f];
    keyFrameAnimation.keyTimes = @[@0.0f, @0.33f, @.66f, @1.0f];
    return keyFrameAnimation;
}

- (void)dismiss
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [CATransaction begin]; {
        [CATransaction setAnimationDuration:.03f];
        [CATransaction setCompletionBlock:^{
            
            [self.container.layer removeAllAnimations];
            [self removeFromSuperview];
            
            self.retainSelf = nil;
            if (self.completionBlock) {
                self.completionBlock();
            }
        }];
        
        CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
        keyFrameAnimation.duration = defaultAnimationDuration;
        keyFrameAnimation.values = @[@(self.container.center.y),
                                     @(self.container.center.y - 10.0f),
                                     @(CGRectGetHeight(self.bounds) + CGRectGetMidY(self.container.bounds))];
        keyFrameAnimation.keyTimes = @[@0.0f, @0.8f, @1.0f];
        
        self.container.layer.position = CGPointMake(CGRectGetMidX(self.bounds), [[keyFrameAnimation.values lastObject] floatValue]);
        [self.container.layer addAnimation:keyFrameAnimation forKey:keyFrameAnimation.keyPath];
        
    } [CATransaction commit];
    
    keyWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    [UIView animateWithDuration:defaultAnimationDuration animations:^{
        [keyWindow tintColorDidChange];
        self.bgView.alpha = 0;
    }];
}

- (void)show
{
    NSAssert(NO, @" '%@' must be overridden in a subclass",NSStringFromSelector(_cmd));
}

@end
