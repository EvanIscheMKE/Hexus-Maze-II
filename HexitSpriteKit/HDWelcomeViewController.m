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
#import "HDHexagonView.h"
#import "UIColor+FlatColors.h"

static const NSUInteger kHexaCount = 4;
#define kPadding  [[UIScreen mainScreen] bounds].size.width < 321.0f ? 2.0f : 4.0f
#define kHexaSize [[UIScreen mainScreen] bounds].size.width / 3.75f

@interface HDWelcomeView ()
@end

@implementation HDWelcomeView

#pragma mark - Animations

- (UIView *)_labelContainer
{
    for (UIView *label in self.subviews) {
        if ([label isKindOfClass:[UIView class]]) {
            return label;
        }
    }
    return nil;
}

+ (void)performRotationOnView:(UIView *)view completion:(dispatch_block_t)completion
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotate.duration  = .15f;
    rotate.fromValue = @0;
    rotate.toValue   = @(M_PI*2);
    [view.layer addAnimation:rotate forKey:@"rotate"];
    
    [CATransaction commit];
}

+ (void)performScaleOnView:(UIView *)view
{
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @1.0f;
    scale.toValue   = @.9f;
    scale.duration  = .15f;
    scale.autoreverses = YES;
    [view.layer addAnimation:scale forKey:@"scale"];
}

- (void)animateTapLabelPosition
{
    [UIView animateWithDuration:.3f
                     animations:^{
                         CGRect tapRect = self._labelContainer.frame;
                         tapRect.origin.y += kHexaSize;
                         self._labelContainer.frame = tapRect;
                     }];
}

- (void)prepareForIntroAnimations
{
    CGPoint tapCenter = CGPointMake(
                                    CGRectGetMidX(self.bounds),
                                    CGRectGetMidY(self.bounds) - ((CGFloat)kHexaCount - 1) / 2 * kHexaSize
                                    );
    
    self._labelContainer.center = tapCenter;
    self._labelContainer.alpha  = 0.0f;
    
    NSUInteger index = 0;
    for (id hexagon in self.subviews) {
        
        if (![hexagon isKindOfClass:[HDHexagonView class]]) {
            continue;
        }
        
        HDHexagonView *hexa = (HDHexagonView *)hexagon;
        
        [hexa.layer removeAllAnimations];
        
        hexa.hidden = YES;
        hexa.enabled = (index == 0);
        hexa.userInteractionEnabled = YES;
        
        CAShapeLayer *hexaLayer = (CAShapeLayer *)hexa.layer;
        hexaLayer.fillColor = [[UIColor flatMidnightBlueColor] CGColor];
        
        switch (index) {
            case 0:
                hexaLayer.strokeColor = [[UIColor whiteColor] CGColor];
                break;
            case 1:
                hexaLayer.strokeColor = [[UIColor flatEmeraldColor] CGColor];
                break;
            case 2:
                hexaLayer.strokeColor = [[UIColor flatPeterRiverColor] CGColor];
                break;
            case 3:
                hexaLayer.strokeColor = [[UIColor flatEmeraldColor] CGColor];
                hexa.imageView.image  = [UIImage imageNamed:@"Lock45"];
                break;
        }
        index++;
    }
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
        scale.duration  = .3f;
        scale.removedOnCompletion = NO;
        scale.fillMode  = kCAFillModeForwards;
        [hexa.layer addAnimation:scale forKey:@"scale34"];

    }
    
    [CATransaction commit];
}

- (dispatch_block_t)_continuousAnimationsBlock
{
    dispatch_block_t continuousAnimations = ^{
        
        for (UILabel *label in self._labelContainer.subviews) {
            CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
            scale.byValue      = @.3f;
            scale.toValue      = @1.3f;
            scale.duration     = .3f;
            scale.repeatCount  = MAXFLOAT;
            scale.autoreverses = YES;
            [label.layer addAnimation:scale forKey:@"scale"];
        }
        [UIView animateWithDuration:.3f animations:^{
            self._labelContainer.alpha = 1.0f;
        } completion:nil];
    };
    return continuousAnimations;
}

- (void)performIntroAnimationsWithCompletion:(dispatch_block_t)completion
{
    dispatch_block_t finalAnimation = [self _continuousAnimationsBlock];
        
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
    [CATransaction setCompletionBlock:finalAnimation];
    
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

@interface HDWelcomeViewController ()<ADBannerViewDelegate>
@property (nonatomic, strong) UIView *labelContainer;
@property (nonatomic, weak) HDWelcomeView *welcomeView;
@end

@implementation HDWelcomeViewController {
    NSArray *_soundsArray;
    NSArray *_hexaArray;
}

- (void)loadView
{
    CGRect welcomeViewFrame = [[UIScreen mainScreen] bounds];
    self.view = [[HDWelcomeView alloc] initWithFrame:welcomeViewFrame];
    self.welcomeView = (HDWelcomeView *)self.view;
    
    _soundsArray = @[HDC3, HDD3, HDE3, HDF3];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor flatMidnightBlueColor];
    
    ADBannerView *bannerView = [[ADBannerView alloc] init];
    bannerView.delegate = self;
    [self.view addSubview:bannerView];
    
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
                                                                 type:HDHexagonTypeFlat /* Flat on top, instead of sitting up */
                                                          strokeColor:[UIColor whiteColor]];
        hexagon.tag     = i;
        hexagon.enabled = (i == 0);
        hexagon.center  = centerPoint;
        hexagon.indexLabel.textColor = [UIColor flatMidnightBlueColor];
        hexagon.indexLabel.font      = GILLSANS(CGRectGetMidX(hexagon.bounds));
        [hexaArray addObject:hexagon];
        [self.view addSubview:hexagon];
        
        CAShapeLayer *hexaLayer = (CAShapeLayer *)hexagon.layer;
        hexaLayer.lineWidth = hexaLayer.lineWidth + pad;//Subtact above, then add here, increase line width without changing bound size
    }
    
    // Create a container view to contain the 'tap' labels, animate this down screen instead of multiple labels
    CGRect  containerFrame  = CGRectMake(0.0f, 0.0f, CGRectGetMidX(self.view.bounds), 2.0f);
    self.labelContainer = [[UIView alloc] initWithFrame:containerFrame];
    self.labelContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.labelContainer];
    
    //Create two labels, one positioned on each side of the hexagon that needs to be 'tappped'
    for (int i = 0; i < 2; i++) {
        
        CGPoint tapLabelPosition = CGPointMake(
                                               (i == 0) ? 0.0f : CGRectGetWidth(self.labelContainer.bounds),
                                               CGRectGetMidY(self.labelContainer.bounds)
                                               );
        
        UILabel *tap = [[UILabel alloc] init];
        tap.textAlignment = NSTextAlignmentCenter;
        tap.textColor = [UIColor whiteColor];
        tap.text      = NSLocalizedString(@"TAP", nil);
        tap.font      = GILLSANS(CGRectGetWidth(self.labelContainer.bounds)/2/3);
        [tap sizeToFit];
        tap.center    = tapLabelPosition;
        [self.labelContainer addSubview:tap];
    }
    
    _hexaArray = hexaArray;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.welcomeView prepareForIntroAnimations];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.welcomeView performIntroAnimationsWithCompletion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
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

- (void)_updateStateForTile:(HDHexagonView *)hexaView atIndex:(NSUInteger)index
{
    CAShapeLayer *hexaLayer = (CAShapeLayer *)hexaView.layer;
    
    hexaView.enabled = NO;
    hexaView.userInteractionEnabled = NO;
    hexaLayer.fillColor = hexaLayer.strokeColor;
    
    [self.welcomeView animateTapLabelPosition];
    [HDWelcomeView performScaleOnView:hexaView];
    [[_hexaArray objectAtIndex:MIN(index + 1, 3)] setEnabled:YES];
    
    [[HDSoundManager sharedManager] playSound:_soundsArray[index]];
    
    switch (index) {
        case 1:{
            [HDWelcomeView performRotationOnView:(HDHexagonView *)[_hexaArray lastObject] completion:^{
                [[(HDHexagonView *)[_hexaArray lastObject] layer] removeAllAnimations];
                [(HDHexagonView *)[_hexaArray lastObject] imageView].image = nil;
            }];
        } break;
        case 3:

            [UIView animateWithDuration:.2f animations:^{
                self.labelContainer.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self.welcomeView performExitAnimationsWithCompletion:^{
                    [ADelegate presentContainerViewController];
                }];
            }];
            break;
    }
}

@end
