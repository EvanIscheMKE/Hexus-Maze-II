//
//  HDAlertView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/27/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDInfoView.h"
#import "HDAlertView.h"

@interface HDAlertView ()
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) HDInfoView *infoView;
@property (nonatomic, strong) HDAlertView *retainedSelf;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@end

@implementation HDAlertView

- (instancetype)init
{
    if (self = [super init]) {
        self.frame = [[UIScreen mainScreen] bounds];
        self.retainedSelf = self;
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        [self _setup];
    }
    return self;
}

- (void)_setup
{
    self.container = [[UIView alloc] initWithFrame:self.bounds];
    self.container.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    self.container.alpha = .0f;
    [self addSubview:self.container];
    
    CGFloat kInsetX = CGRectGetWidth(self.bounds) / 15;
    CGFloat kInsetY = CGRectGetHeight(self.bounds) / 6;
    
    CGRect containerFrame = CGRectMake(0.0f,
                                       -400.0f,
                                       CGRectGetWidth(self.bounds) - kInsetX*2,
                                       CGRectGetHeight(self.bounds) - kInsetY*2
                                       );
    
    self.infoView = [[HDInfoView alloc] initWithFrame:containerFrame];
    [self addSubview:self.infoView];
}

- (void)setInfoView:(HDInfoView *)infoView
{
    _infoView = infoView;
}

- (void)show
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    
    [UIView animateWithDuration:.3f animations:^{
        self.container.alpha = 1.0f;
    }];
    
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.infoView snapToPoint:self.center];
    snap.damping = 1.0f;
    [self.animator addBehavior:snap];
}

- (void)_dismiss
{
    [self.animator removeAllBehaviors];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.infoView]];
    [itemBehavior addAngularVelocity:M_PI forItem:self.infoView];
    [self.animator addBehavior:itemBehavior];
    
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.infoView]];
    gravityBehavior.gravityDirection = CGVectorMake(0.0f, 12.0f);
    [self.animator addBehavior:gravityBehavior];
    
    [UIView animateWithDuration:.8f animations:^{
        self.container.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.retainedSelf = nil;
        if (self.completion) {
            self.completion();
        }
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[touches allObjects] lastObject];
    CGPoint position = [touch locationInView:self];
    
    if (!CGRectContainsPoint(self.infoView.frame, position)) {
        [self _dismiss];
    }
}

@end
