//
//  HDWelcomeViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/5/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import iAd;
@import QuartzCore;

#import "HDSoundManager.h"
#import "HDWelcomeViewController.h"
#import "HDTutorialParentViewController.h"
#import "HDHexagonView.h"
#import "UIColor+FlatColors.h"

static const NSUInteger kHexaCount = 4;
#define kPadding  [[UIScreen mainScreen] bounds].size.width < 321.0f ? 2.0f : 4.0f
#define kHexaSize [[UIScreen mainScreen] bounds].size.width / 3.75f

@interface HDWelcomeView ()
@end

@implementation HDWelcomeView

#pragma mark - Animations

+ (void)performScaleOnView:(UIView *)view
{
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @1.0f;
    scale.toValue   = @.9f;
    scale.duration  = .15f;
    scale.autoreverses = YES;
    [view.layer addAnimation:scale forKey:@"scale"];
}

- (void)performExitAnimationsWithCompletion:(dispatch_block_t)completion
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    
    for (id hexagon in self.subviews) {
        
        if (![hexagon isKindOfClass:[HDHexagonView class]]) {
            continue;
        }
        
        HDHexagonView *hexa = (HDHexagonView *)hexagon;
        
        if ([hexa.layer animationKeys].count) {
            [hexa.layer removeAllAnimations];
        }
        
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale.toValue   = @0;
        scale.duration  = .2f;
        scale.removedOnCompletion = NO;
        scale.fillMode  = kCAFillModeForwards;
        [hexa.layer addAnimation:scale forKey:@"scale34"];

    }
    [CATransaction commit];
}

- (void)performIntroAnimationsWithCompletion:(dispatch_block_t)completion
{
    
    HDHexagonView *first  = [self.subviews objectAtIndex:2];
    HDHexagonView *second = [self.subviews firstObject];
    HDHexagonView *third  = [self.subviews objectAtIndex:3];
    HDHexagonView *fourth = [self.subviews objectAtIndex:1];
    
    NSString *keyPath[4];
    keyPath[0] = @"position.x";
    keyPath[1] = @"position.y";
    keyPath[2] = @"position.y";
    keyPath[3] = @"position.x";
    
    CGFloat toValue[4];
    toValue[0] = first.center.x;
    toValue[1] = second.center.y;
    toValue[2] = third.center.y;
    toValue[3] = fourth.center.x;
    
    CGFloat fromValue[4];
    fromValue[0] = CGRectGetWidth(self.bounds) + kHexaSize / 2;
    fromValue[1] = -kHexaSize / 2;
    fromValue[2] = CGRectGetHeight(self.bounds) + kHexaSize / 2;
    fromValue[3] = -kHexaSize / 2;
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    
    NSInteger index = 0;
    NSTimeInterval delay = 0;
    for (HDHexagonView *view in @[first, second, third, fourth]) {
        
        [view performSelector:@selector(setHidden:) withObject:0 afterDelay:delay];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath[index]];
        animation.toValue   = @(toValue[index]);
        animation.fromValue = @(fromValue[index]);
        animation.duration  = .15f;
        animation.beginTime = CACurrentMediaTime() + delay;
        [view.layer addAnimation:animation forKey:[NSString stringWithFormat:@"%@%f",keyPath[index],delay]];
        
        index++;
        delay += animation.duration;
    }
    
    [CATransaction commit];
}

@end

@interface HDWelcomeViewController ()
@property (nonatomic, weak) HDWelcomeView *welcomeView;
@property (nonatomic, strong) UIButton *settings;
@end

@implementation HDWelcomeViewController {
    NSArray *_soundsArray;
    NSArray *_hexaArray;
}

- (instancetype)init
{
    if (self = [super init]) {
        _soundsArray = @[HDC3, HDD3, HDE3, HDF3];
    }
    return self;
}

#pragma mark - View Cycle

- (void)loadView
{
    CGRect welcomeViewFrame = [[UIScreen mainScreen] bounds];
    self.view = [[HDWelcomeView alloc] initWithFrame:welcomeViewFrame];
    self.welcomeView = (HDWelcomeView *)self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor flatWetAsphaltColor];
    
    CGFloat size = kHexaSize;
    CGFloat pad  = kPadding;
    
    NSMutableArray *hexaArray = [NSMutableArray arrayWithCapacity:kHexaCount];
    
    const CGFloat startingPositionY = CGRectGetMidY(self.view.bounds) - (kHexaCount - 1) / 2.0f * kHexaSize;
    for (int i = 0; i < kHexaCount; i++) {
        
        CGPoint centerPoint = CGPointMake(
                                          CGRectGetMidX(self.view.bounds),
                                          startingPositionY + (i * kHexaSize)
                                          );
        
        CGRect hexaBounds = CGRectMake(0.0f, 0.0f, size - pad, size - pad);
        HDHexagonView *hexagon = [[HDHexagonView alloc] initWithFrame:hexaBounds
                                                          strokeColor:[UIColor whiteColor]];
        hexagon.tag     = i;
        hexagon.enabled = (i == 0);
        hexagon.center  = centerPoint;
        hexagon.indexLabel.textColor = [UIColor flatWetAsphaltColor];
        hexagon.indexLabel.font      = GILLSANS(CGRectGetMidX(hexagon.bounds));
        [hexaArray addObject:hexagon];
        [self.view addSubview:hexagon];
        
        CAShapeLayer *hexaLayer = (CAShapeLayer *)hexagon.layer;
        hexaLayer.lineWidth = hexaLayer.lineWidth + pad;//Subtact above, then add here, increase line width without changing bound size
    }
    
    _hexaArray = hexaArray;

    CGRect settingsBounds = CGRectMake(0.0f, 0.0f, 30.0f, 30.0f);
    self.settings = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settings.frame = settingsBounds;
    [self.settings addTarget:ADelegate action:@selector(presentSettingsViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.settings setBackgroundImage:[UIImage imageNamed:@"SettingsIcon-"] forState:UIControlStateNormal];
    self.settings.backgroundColor = [UIColor flatWetAsphaltColor];
    self.settings.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                  CGRectGetHeight(self.view.bounds) + CGRectGetMidY(self.settings.bounds));
    self.settings.frame  = CGRectIntegral(self.settings.frame);
    [self.view addSubview:self.settings];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _prepareForIntroAnimations];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.welcomeView performIntroAnimationsWithCompletion:^{
        [self _showActivityAnimated:YES];
    }];
    
////    if (![[NSUserDefaults standardUserDefaults] boolForKey:HDFirstRunKey]) {
//        HDTutorialParentViewController *controller = [[HDTutorialParentViewController alloc] init];
//        [self.navigationController presentViewController:controller animated:NO completion:nil];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HDFirstRunKey];
////    }
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Touches
    UITouch *touch   = [[touches allObjects] lastObject];
    CGPoint location = [touch locationInView:self.view];
    
    // Loop through all possible targets, find which view contains the current point
    HDHexagonView *_hexaView;
    for (HDHexagonView *hexaView in _hexaArray) {
        if (CGRectContainsPoint(hexaView.frame, location)) {
            _hexaView = hexaView.isEnabled && hexaView.userInteractionEnabled ? hexaView : nil;
            break;
        }
    }
    
    // If the current point's location isnt in any view's frame, return
    if (_hexaView) {
        [self _updateStateForTile:_hexaView atIndex:_hexaView.tag];
    }
}

#pragma mark - Private

- (void)_hideActivityAnimated:(BOOL)animated
{
    dispatch_block_t animation = ^{
        self.settings.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                           CGRectGetHeight(self.view.bounds) + CGRectGetMidY(self.settings.bounds));
    };
    
    if (animation) {
        [UIView animateWithDuration:.3f animations:animation];
    } else {
        animation();
    }
}

- (void)_showActivityAnimated:(BOOL)animated
{
    dispatch_block_t animation = ^{
        
        self.settings.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                           CGRectGetHeight(self.view.bounds) - CGRectGetMidY(self.settings.bounds) - 15.0f);
    };
    
    if (animated) {
        [UIView animateWithDuration:.3f animations:animation];
    } else {
        animation();
    }
}

- (void)_presentSettingsViewController
{
    [self _hideActivityAnimated:YES];
    [self.welcomeView performExitAnimationsWithCompletion:^{
        [ADelegate presentSettingsViewController];
    }];
}

- (void)_updateStateForTile:(HDHexagonView *)hexaView atIndex:(NSUInteger)index
{
    CAShapeLayer *hexaLayer = (CAShapeLayer *)hexaView.layer;
    
    hexaView.enabled = NO;
    hexaView.userInteractionEnabled = NO;
    hexaLayer.fillColor = hexaLayer.strokeColor;
    
    [HDWelcomeView performScaleOnView:hexaView];
    [[_hexaArray objectAtIndex:MIN(index + 1, 3)] setEnabled:YES];
    
    [[HDSoundManager sharedManager] playSound:_soundsArray[MIN(index, 3)]];
    
    if (index == 3) {
        [self _hideActivityAnimated:YES];
        [self.welcomeView performExitAnimationsWithCompletion:^{
            
            [ADelegate presentLevelViewController];
        }];
    }
}

- (void)_prepareForIntroAnimations
{
    [self _hideActivityAnimated:NO];
    
    NSUInteger index = 0;
    for (id hexagon in _hexaArray) {
        
        if (![hexagon isKindOfClass:[HDHexagonView class]]) {
            continue;
        }
        
        HDHexagonView *hexa     = (HDHexagonView *)hexagon;
        CAShapeLayer *hexaLayer = (CAShapeLayer *)hexa.layer;
        
        [hexa.layer removeAllAnimations];
        
        hexa.hidden = YES;
        hexa.enabled = (index == 0);
        hexa.userInteractionEnabled = YES;
        
        hexaLayer.fillColor = [[UIColor flatWetAsphaltColor] CGColor];
        
        switch (index) {
            case 0:
                hexaLayer.strokeColor = [[UIColor whiteColor] CGColor];
                break;
            case 1:
                hexaLayer.strokeColor = [[UIColor flatPeterRiverColor] CGColor];
                break;
            case 2:
                hexaLayer.strokeColor = [[UIColor flatPeterRiverColor] CGColor];
                break;
            case 3:
                hexaLayer.strokeColor = [[UIColor flatEmeraldColor] CGColor];
                break;
        }
        index++;
    }
}

@end
