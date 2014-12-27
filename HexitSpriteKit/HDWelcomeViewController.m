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
#define kPadding  [[UIScreen mainScreen] bounds].size.width <= 321.0f ? 2.0f : 4.0f
#define kHexaSize [[UIScreen mainScreen] bounds].size.width / 3.75f

@interface HDWelcomeView ()
@property (nonatomic, strong) UIView *labelContainer;
@end

@implementation HDWelcomeView {
    NSArray *_hexaArray;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}

#pragma mark - Private

- (void)_setup
{
    CGFloat size = kHexaSize;
    CGFloat pad  = kPadding;
    
    NSMutableArray *hexaArray = [NSMutableArray arrayWithCapacity:kHexaCount];
    
    const CGFloat startingPositionY = CGRectGetMidY(self.bounds) - (kHexaCount - 1) / 2.0f * kHexaSize;
    for (int i = 0; i < kHexaCount; i++) {
        
        CGPoint centerPoint = CGPointMake(
                                          CGRectGetMidX(self.bounds),
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
        hexagon.indexLabel.font = GILLSANS(CGRectGetMidX(hexagon.bounds));
        [hexaArray addObject:hexagon];
        [self addSubview:hexagon];
        
        CAShapeLayer *hexaLayer = (CAShapeLayer *)hexagon.layer;
        hexaLayer.lineWidth = hexaLayer.lineWidth + pad;//Subtact above, then add here, increase line width without changing bound size
    }
    
    _hexaArray = hexaArray;
    
    // Create a container view to contain the 'tap' labels, animate this down screen instead of multiple labels
    CGRect  containerFrame  = CGRectMake(0.0f, 0.0f, CGRectGetMidX(self.bounds), 2.0f);
    self.labelContainer = [[UIView alloc] initWithFrame:containerFrame];
    self.labelContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:self.labelContainer];
    
    //Create two labels, one positioned on each side of the hexagon that needs to be 'tappped'
    for (int i = 0; i < 2; i++) {
        
        CGPoint tapLabelPosition = CGPointMake(
                                               (i == 0) ? 0.0f : CGRectGetWidth(self.labelContainer.bounds),
                                               CGRectGetMidY(self.labelContainer.bounds)
                                               );
        
        UILabel *tap = [[UILabel alloc] init];
        tap.textAlignment = NSTextAlignmentCenter;
        tap.textColor = [UIColor whiteColor];
        tap.text = NSLocalizedString(@"TAP", nil);
        tap.font = GILLSANS(CGRectGetWidth(self.labelContainer.bounds)/2/3);
        [tap sizeToFit];
        tap.center = tapLabelPosition;
        [self.labelContainer addSubview:tap];
    }
}

#pragma mark - Animations

+ (void)_performRotationOnView:(UIView *)view completion:(dispatch_block_t)completion
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotate.duration = .3f;
    rotate.fromValue = @0;
    rotate.toValue = @(M_PI * 4);
    [view.layer addAnimation:rotate forKey:@"rotate"];
    
    [CATransaction commit];
}

+ (void)_performScaleOnView:(UIView *)view
{
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @1.0f;
    scale.toValue   = @.9f;
    scale.duration  = .15f;
    scale.autoreverses = YES;
    [view.layer addAnimation:scale forKey:@"scale"];
}

- (void)_animateTapLabelPosition
{
    [UIView animateWithDuration:.3f
                     animations:^{
                         CGRect tapRect = self.labelContainer.frame;
                         tapRect.origin.y += kHexaSize;
                         self.labelContainer.frame = tapRect;
                     }];
}

- (void)prepareForIntroAnimations
{
    CGPoint tapCenter = CGPointMake(
                                    CGRectGetMidX(self.bounds),
                                    CGRectGetMidY(self.bounds) - ((CGFloat)kHexaCount - 1) / 2 * kHexaSize
                                    );
    
    self.labelContainer.center = tapCenter;
    self.labelContainer.alpha  = 0.0f;
    
    NSUInteger index = 0;
    for (HDHexagonView *hexa in _hexaArray) {
        
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

- (void)_performExitAnimationsWithCompletion:(dispatch_block_t)completion
{
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    
    NSTimeInterval delay = 0;
    for (HDHexagonView *hexa in _hexaArray) {
        
        [hexa.layer removeAllAnimations];
        
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale.toValue   = @0;
        scale.beginTime = CACurrentMediaTime() + delay;
        scale.duration  = .2f;
        scale.removedOnCompletion = NO;
        scale.fillMode  = kCAFillModeForwards;
        [hexa.layer addAnimation:scale forKey:@"scale34"];
        
        delay += .05;
    }
    
    [CATransaction commit];
}

- (void)performIntroAnimationsWithCompletion:(dispatch_block_t)completion
{
    dispatch_block_t finalAnimation = ^{
        
        [UIView animateWithDuration:.3f animations:^{
            self.labelContainer.alpha = 1.0f;
        } completion:^(BOOL finished) {
            if (completion) {
                 completion();
            }
        }];
        
        for (UILabel *label in self.labelContainer.subviews) {
            CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
            scale.byValue  = @.3f;
            scale.toValue  = @1.3f;
            scale.duration = .3f;
            scale.repeatCount  = MAXFLOAT;
            scale.autoreverses = YES;
            [label.layer addAnimation:scale forKey:@"scale"];
        }
    };
    
    dispatch_block_t fourthAnimation = ^{
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:finalAnimation];
        
        HDHexagonView *fourth = [_hexaArray objectAtIndex:1];
        fourth.hidden = NO;
        
        CABasicAnimation *fourthAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
        fourthAnimation.toValue   = @(fourth.center.x);
        fourthAnimation.fromValue = @(-kHexaSize/2);
        fourthAnimation.duration  = .15f;
        [fourth.layer addAnimation:fourthAnimation forKey:@"SecondTileAnimationKey"];
        
        [CATransaction commit];
        
    };
    
    dispatch_block_t thirdAnimation = ^{
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:fourthAnimation];
        
        HDHexagonView *third = [_hexaArray lastObject];
        third.hidden = NO;
        
        CABasicAnimation *thirdAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        thirdAnimation.toValue   = @(third.center.y);
        thirdAnimation.fromValue = @(CGRectGetHeight(self.bounds)+kHexaSize/2);
        thirdAnimation.duration  = .15f;
        [third.layer addAnimation:thirdAnimation forKey:@"FourthTileAnimationKey"];
        
        [CATransaction commit];
        
    };
    
    dispatch_block_t secondAnimation = ^{
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:thirdAnimation];
        
        HDHexagonView *second = [_hexaArray firstObject];
        second.hidden = NO;
        
        CABasicAnimation *secondAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        secondAnimation.toValue = @(second.center.y);
        secondAnimation.fromValue = @(-kHexaSize/2);
        secondAnimation.duration = .15f;
        [second.layer addAnimation:secondAnimation forKey:@"FirstTileAnimationKey"];
        
        [CATransaction commit];
    };
    
    dispatch_block_t firstAnimation = ^{
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:secondAnimation];
        
        HDHexagonView *first = [_hexaArray objectAtIndex:2];
        first.hidden = NO;
        
        CABasicAnimation *firstAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
        firstAnimation.toValue   = @(first.center.x);
        firstAnimation.fromValue = @(CGRectGetWidth(self.bounds) + kHexaSize/2);
        firstAnimation.duration  = .15f;
        [first.layer addAnimation:firstAnimation forKey:@"ThirdTileAnimationKey"];
        
        [CATransaction commit];
        
    };
    firstAnimation();
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch   = [[touches allObjects] lastObject];
    CGPoint location = [touch locationInView:self];
    
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

- (void)_updateStateForTile:(HDHexagonView *)hexaView atIndex:(NSUInteger)index
{
    CAShapeLayer *hexaLayer = (CAShapeLayer *)hexaView.layer;
    
    hexaView.enabled = NO;
    hexaView.userInteractionEnabled = NO;
    hexaLayer.fillColor = hexaLayer.strokeColor;
    
    [self _animateTapLabelPosition];
    [HDWelcomeView _performScaleOnView:hexaView];
    [[_hexaArray objectAtIndex:MIN(index + 1, 3)] setEnabled:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(welcomeView:playSoundAtIndex:)]) {
        [self.delegate welcomeView:self playSoundAtIndex:index];
    }
    
    switch (index) {
        case 1:{
            [HDWelcomeView _performRotationOnView:(HDHexagonView *)[_hexaArray lastObject] completion:^{
                [[(HDHexagonView *)[_hexaArray lastObject] layer] removeAllAnimations];
                [(HDHexagonView *)[_hexaArray lastObject] imageView].image = nil;
            }];
          } break;
        case 3:
            [UIView animateWithDuration:.2f animations:^{
                self.labelContainer.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self _performExitAnimationsWithCompletion:^{
                    if (self.delegate && [self.delegate respondsToSelector:@selector(welcomeView:dismissAnimated:)]) {
                        [self.delegate welcomeView:self dismissAnimated:YES];
                    }
                }];
            }];
            break;
    }
}

@end

@interface HDWelcomeViewController ()<HDWelcomeViewDelegate>
@property (nonatomic, strong) HDWelcomeView *welcomeView;
@end

@implementation HDWelcomeViewController

- (void)loadView
{
   CGRect welcomeViewFrame = [[UIScreen mainScreen] bounds];
    self.welcomeView = [[HDWelcomeView alloc] initWithFrame:welcomeViewFrame];
    self.welcomeView.delegate = self;
    self.view = self.welcomeView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.canDisplayBannerAds  = YES;
    self.view.backgroundColor = [UIColor flatMidnightBlueColor];
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

#pragma mark - <HDWelcomeViewDelegate>

- (void)welcomeView:(HDWelcomeView *)welcomeView dismissAnimated:(BOOL)animated
{
    [ADelegate presentContainerViewController];
}

- (void)welcomeView:(HDWelcomeView *)welcomeView playSoundAtIndex:(NSUInteger)index
{
    NSString *soundPath = nil;
    switch (index) {
        case 0:
            soundPath = HDC3;
            break;
        case 1:
            soundPath = HDD3;
            break;
        case 2:
            soundPath = HDE3;
            break;
        case 3:
            soundPath = HDF3;
            break;
        default:
            NSAssert(NO, @"%@",NSStringFromSelector(_cmd));
            break;
    }
    [[HDSoundManager sharedManager] playSound:soundPath];
}

@end
