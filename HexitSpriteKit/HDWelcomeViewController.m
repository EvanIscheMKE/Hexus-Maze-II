//
//  HDWelcomeViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import  QuartzCore;

#import "HDHexagonButton.h"
#import "HDSoundManager.h"
#import "HDWelcomeViewController.h"
#import "HDTutorialParentViewController.h"
#import "UIColor+FlatColors.h"
#import "CAEmitterCell+HD.h"

@interface HDContainerView : UIView
@property (nonatomic, strong) UIColor *emitterColor;
- (CAEmitterLayer *)emitterLayer;
@end

@implementation HDContainerView

#pragma mark - Emitter

- (CAEmitterLayer *)emitterLayer
{
    return (CAEmitterLayer *)self.layer;
}

+ (Class)layerClass
{
    return [CAEmitterLayer class];
}

- (void)startEmitting
{
    self.emitterLayer.birthRate = 1;
    [self performSelector:@selector(stopEmitting) withObject:nil afterDelay:.1f];
}

- (void)stopEmitting
{
    self.emitterLayer.birthRate = 0;
}

#pragma mark - Setter

- (void)setEmitterColor:(UIColor *)emitterColor
{
    _emitterColor = emitterColor;
    self.emitterLayer.emitterCells = @[[CAEmitterCell hexaEmitterWithColor:emitterColor scale:1]];
}

@end

@interface HDLabelContainer : UIView
- (void)startAnimating;
- (void)stopAnimating;
@end

@implementation HDLabelContainer {
    BOOL _beginAnimationWhenMovedToSuperView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _beginAnimationWhenMovedToSuperView = YES;
        [self _setup];
    }
    return self;
}

#pragma mark - Private

- (void)_setup
{
    CGFloat kPositionX[2];
    kPositionX[0] = CGRectGetWidth(self.bounds) * .25f;
    kPositionX[1] = CGRectGetWidth(self.bounds) * .75f;
    
    for (NSUInteger i = 0; i < 2; i++) {
        UILabel *tap = [[UILabel alloc] init];
        tap.font          = GILLSANS_LIGHT(32.0f);
        tap.textAlignment = NSTextAlignmentCenter;
        tap.textColor     = [UIColor whiteColor];
        tap.text          = NSLocalizedString(@"tap", nil);
        [tap sizeToFit];
        tap.center        = CGPointMake(kPositionX[i], CGRectGetMidY(self.bounds));
        tap.frame         = CGRectIntegral(tap.frame);
        tap.transform = CGAffineTransformMakeScale(CGRectGetWidth(self.bounds)/375.0f, CGRectGetWidth(self.bounds)/375.0f);
        [self addSubview:tap];
    }
}

#pragma mark - Public

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview && _beginAnimationWhenMovedToSuperView) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}

- (void)startAnimating
{
    for (UILabel *subView in self.subviews) {
        CABasicAnimation *scaleX = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        scaleX.fromValue    = @1;
        scaleX.toValue      = @1.2;
        scaleX.duration     = .3f;
        scaleX.repeatCount  = MAXFLOAT;
        scaleX.autoreverses = YES;
        [subView.layer addAnimation:scaleX forKey:scaleX.keyPath];
    }
}

- (void)stopAnimating
{
    for (UILabel *subView in self.subviews) {
        [subView.layer removeAllAnimations];
    }
}

@end

@interface HDWelcomeViewController ()
@property (nonatomic, strong) HDLabelContainer *container;
@end

@implementation HDWelcomeViewController {
    CGFloat _kSpacing;
    __weak HDContainerView *_containerView;
}

- (void)loadView
{
    self.view = [[HDContainerView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _containerView = (HDContainerView *)self.view;
}

- (void)viewDidLoad
{
    [self _setup];
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![self _checkForFirstRun]) {
        [self _performIntroAnimationWithCompletion:nil];
    }
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch   = [touches anyObject];
    CGPoint position = [touch locationInView:self.view];
    
    for (HDHexagonButton *subView in self.view.subviews) {
        if (CGRectContainsPoint(subView.frame, position)) {
            [self _updateTileState:subView];
            break;
        }
    }
}

#pragma mark - Private

- (void)_setup
{
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    
    const CGFloat kButtonSize = ceil(110.0f * CGRectGetWidth(self.view.bounds)/375.0f);
    const NSUInteger kHexaCount = 4;
    
    _kSpacing = kButtonSize - 5.0f; /*Padding*/
    
    CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI/2);
    for (NSUInteger row = 0; row < kHexaCount; row++) {
        CGRect hexaFrame = CGRectMake(0.0f, 0.0f, kButtonSize, kButtonSize);
        HDHexagonButton *hexagon = [[HDHexagonButton alloc] initWithFrame:hexaFrame];
        hexagon.tag = row;
        hexagon.userInteractionEnabled      = NO;
        hexagon.adjustsImageWhenHighlighted = NO;
        hexagon.adjustsImageWhenDisabled    = NO;
        hexagon.center = CGPointMake((row % 2 == 0) ? -kButtonSize/2 : CGRectGetWidth(self.view.bounds) + kButtonSize/2,
                                     (CGRectGetMidY(self.view.bounds) - ((kHexaCount-1)/2.0f) * _kSpacing) + (_kSpacing * row));
        hexagon.transform = rotate;
        [self.view addSubview:hexagon];
        
        switch (row) {
            case 0:
                [hexagon setImage:nil forState:UIControlStateNormal];
                [hexagon setBackgroundImage:[UIImage imageNamed:@"WelcomeVC-White-122"]   forState:UIControlStateNormal];
                [hexagon setBackgroundImage:[UIImage imageNamed:@"WelcomeVC-White-Selected-122"] forState:UIControlStateSelected];
                break;
            case 1:
                [hexagon setImage:nil forState:UIControlStateNormal];
                [hexagon setBackgroundImage:[UIImage imageNamed:@"WelcomeVC-blue-122"]   forState:UIControlStateNormal];
                [hexagon setBackgroundImage:[UIImage imageNamed:@"WelcomeVC-blue-selected-122"] forState:UIControlStateSelected];
                break;
            case 2:
                [hexagon setImage:nil forState:UIControlStateNormal];
                [hexagon setBackgroundImage:[UIImage imageNamed:@"WelcomeVC-emerald-122"]  forState:UIControlStateNormal];
                [hexagon setBackgroundImage:[UIImage imageNamed:@"WelcomeVC-emerald-selected-122"] forState:UIControlStateSelected];
                break;
            default:{
                CGAffineTransform transform = CGAffineTransformConcat(
                                                                      CGAffineTransformMakeScale(CGRectGetWidth(hexagon.bounds) / 64.5f, CGRectGetWidth(hexagon.bounds) / 64.5f),
                                                                      CGAffineTransformMakeRotation(-M_PI/2));
                hexagon.imageView.transform = transform;
                [hexagon setBackgroundImage:[UIImage imageNamed:@"WelcomeVC-emerald-122"]  forState:UIControlStateNormal];
                [hexagon setBackgroundImage:[UIImage imageNamed:@"WelcomeVC-emerald-selected-122"] forState:UIControlStateSelected];
            } break;
        }
    }
    
    CGRect containerRect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), 2.0f);
    self.container = [[HDLabelContainer alloc] initWithFrame:containerRect];
    self.container.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - ((kHexaCount-1)/2.0f) * _kSpacing);
    self.container.alpha = 0;
    [self.view addSubview:self.container];
    
    _containerView.emitterLayer.emitterCells    = @[[CAEmitterCell hexaEmitterWithColor:[UIColor whiteColor] scale:1]];
    _containerView.emitterLayer.emitterSize     = self.view.bounds.size;
    _containerView.emitterLayer.emitterPosition = self.container.center;
    _containerView.emitterLayer.birthRate       = 0;
}

- (void)_performIntroAnimationWithCompletion:(dispatch_block_t)completion
{
    [UIView animateWithDuration:.3f animations:^{
        for (HDHexagonButton *subView in self.view.subviews) {
            if ([subView isKindOfClass:[HDHexagonButton class]]) {
                CGPoint position = subView.center;
                position.x = CGRectGetMidX(self.view.bounds);
                subView.center = position;
            }
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2f animations:^{ self.container.alpha = 1; }];
        if (completion && finished) {
            completion();
        }
    }];
}

- (void)_updateTileState:(HDHexagonButton *)sender
{
    if (!sender.selected) {
        
        if (sender.tag != 0) {
            for (HDHexagonButton *subView in self.view.subviews) {
                if (subView.tag == sender.tag - 1) {
                    if (!subView.selected) {
                        return;
                    }
                    break;
                }
            }
        }
        
        sender.selected = YES;
        
        [self _playSoundForTileAtIndex:sender.tag];
        [self _updateLabelPosition];
        
        if (sender.tag == 3) {
            [UIView animateWithDuration:.3f animations:^{ self.container.alpha = 0; } completion:^(BOOL finished) {
                [self.container removeFromSuperview];
                self.container = nil;
                [self _performOutroAnimation];
            }];
        }
        
        [self _startEmitterAtPosition:self.container.center];
        [self _rotateTile:sender];
        
        if (sender.tag == 2) {
            for (HDHexagonButton *subView in self.view.subviews) {
                if (subView.tag == 3) {
                    [subView setImage:nil forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (void)_updateLabelPosition
{
    [UIView animateWithDuration:.3f animations:^{
        CGPoint position = self.container.center;
        position.y += _kSpacing;
        self.container.center = position;
        NSLog(@"%@",NSStringFromCGPoint(self.container.center));
    }];
}

- (void)_startEmitterAtPosition:(CGPoint)position
{
    _containerView.emitterLayer.emitterPosition = position;
    [_containerView startEmitting];
}

- (void)_rotateTile:(HDHexagonButton *)tile
{
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotation.byValue  = @(M_PI*2);
    rotation.duration = .3f;
    [tile.layer addAnimation:rotation forKey:rotation.keyPath];
}

- (void)_playSoundForTileAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            [[HDSoundManager sharedManager] playSound:sound0];
            break;
        case 1:
            [_containerView setEmitterColor:[UIColor flatPeterRiverColor]];
            [[HDSoundManager sharedManager] playSound:sound1];
            break;
        case 2:
            [_containerView setEmitterColor:[UIColor flatEmeraldColor]];
            [[HDSoundManager sharedManager] playSound:sound2];
            break;
        case 3:
            [_containerView setEmitterColor:[UIColor flatEmeraldColor]];
            [[HDSoundManager sharedManager] playSound:sound3];
            break;
    }
}

- (void)_performOutroAnimation
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
         [ADelegate presentLevelViewController];
    }];
    
    NSTimeInterval delay = 0;
    for (HDHexagonButton *subView in self.view.subviews) {
    
        CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        scale.values    = @[@1, @1.1, @0];
        scale.duration  = .3f;
        scale.beginTime = CACurrentMediaTime() + delay;
        scale.removedOnCompletion = NO;
        scale.fillMode  = kCAFillModeForwards;
        [subView.layer addAnimation:scale forKey:scale.keyPath];
        
        delay += .15f;
    }
    [CATransaction commit];
}

- (BOOL)_checkForFirstRun
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HDFirstRunKey]) {
        [ADelegate presentTutorialViewControllerForFirstRun];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HDFirstRunKey];
        return YES;
    }
    return NO;
}

@end
