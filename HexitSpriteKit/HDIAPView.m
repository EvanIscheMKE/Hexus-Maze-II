//
//  HDIAPView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 5/19/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDIAPView.h"
#import "HDLabel.h"
#import "HDGameButton.h"
#import "UIColor+ColorAdditions.h"

@implementation HDIAPView

- (instancetype)initWithMessage:(NSString *)message
{
    if (self = [super init]) {
        
        CGRect containerBounds = CGRectInset(self.bounds, CGRectGetWidth(self.bounds)/7.0f, CGRectGetHeight(self.bounds)/3.f);
        if (IS_IPAD) {
            containerBounds = CGRectInset(self.bounds, CGRectGetWidth(self.bounds)/4.75f, CGRectGetHeight(self.bounds)/2.9f);
        }
        
        self.container.frame = containerBounds;
        self.container.center = CGPointMake(CGRectGetMidX(self.bounds), -CGRectGetMidY(self.container.bounds));
        
        const CGFloat buttonWidth = ceilf(CGRectGetWidth(self.container.bounds) - self.padding*2);
        const CGFloat buttonHeight = ceilf(CGRectGetHeight(self.container.bounds)/4.5f);
        const CGFloat startPositionY = CGRectGetHeight(self.container.bounds) - buttonHeight*1.5f - self.padding*2;
        
        for (NSUInteger i = 0; i < 2; i++) {
            CGRect bounds = CGRectMake(0.0f, 0.0f, buttonWidth, buttonHeight);
            HDGameButton *btn = [[HDGameButton alloc] initWithFrame:bounds];
            btn.tag = i;
            btn.center = CGPointMake(CGRectGetMidX(self.container.bounds), startPositionY + (i * (buttonHeight + self.padding)));
            btn.selected = YES;
            btn.buttonColor = (i != 0) ? [UIColor flatSTLightBlueColor] : [UIColor flatSTEmeraldColor];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(btn.bounds) * .4);
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(_makeSelection:) forControlEvents:UIControlEventTouchUpInside];
            [self.container addSubview:btn];
            
            NSString *title;
            switch (i) {
                case 0:
                    title = NSLocalizedString(@"purchase", nil);
                    break;
                default:
                    title = NSLocalizedString(@"dismiss", nil);
                    break;
            }
            [btn setTitle:title forState:UIControlStateNormal];
        }
        
        CGRect dbounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.container.bounds) - self.padding*4, 0.0f);
        self.descriptionLbl.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(self.container.bounds)/12);
        self.descriptionLbl.frame = dbounds;
        self.descriptionLbl.text = message;
        [self.descriptionLbl sizeToFit];
        self.descriptionLbl.center = CGPointMake(CGRectGetMidX(self.container.bounds), CGRectGetHeight(self.container.bounds)/4);
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
                    for (HDGameButton *btn in [self.container subviews]) {
                        if ([btn isKindOfClass:[HDGameButton class]]) {
                            btn.selected = NO;
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

- (void)dismissWithPurchase:(BOOL)purchase
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [CATransaction begin]; {
        [CATransaction setAnimationDuration:.03f];
        [CATransaction setCompletionBlock:^{
            
            [self.container.layer removeAllAnimations];
            [self removeFromSuperview];
            
            self.retainSelf = nil;
            if (purchase) {
                if (self.completionBlock) {
                    self.completionBlock();
                }
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

- (IBAction)_makeSelection:(HDGameButton *)sender
{
    [self dismissWithPurchase:(sender.tag != 1)];
}

- (CGFloat)padding
{
    return 10.0f;
}

@end
