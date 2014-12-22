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

static const CGFloat kPadding  = 4.0f;
static const CGFloat kHexaSize = 100.0f;

static const NSUInteger kHexaCount = 4;

@interface HDWelcomeViewController ()
@property (nonatomic, strong) UIView *tapLabelsContainer;
@end

@implementation HDWelcomeViewController {
    NSArray *_hexaArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setCanDisplayBannerAds:YES];
    [self.view setBackgroundColor:[UIColor flatMidnightBlueColor]];
    [self _setup];
}

- (void)_setup
{
    NSMutableArray *hexaArray = [NSMutableArray arrayWithCapacity:kHexaCount];
    
    //
    const CGFloat startingPositionY = CGRectGetMidY(self.view.bounds) - ((CGFloat)kHexaCount - 1) / 2 * kHexaSize;
    for (int i = 0; i < kHexaCount; i++) {
        
        CGPoint centerPoint = CGPointMake(
                                          CGRectGetMidX(self.view.bounds),
                                          startingPositionY + (i * kHexaSize)
                                          );
        
        CGRect hexaBounds = CGRectMake(0.0f, 0.0f, kHexaSize - kPadding, kHexaSize -kPadding);
        HDHexagonView *hexagon = [[HDHexagonView alloc] initWithFrame:hexaBounds
                                                                 type:HDHexagonTypeFlat // Flat on top, instead of sitting up
                                                          strokeColor:[UIColor whiteColor]];
        [hexagon setTag:i];
        [hexagon setEnabled:(i == 0)];
        [hexagon setCenter:centerPoint];
        [hexagon.indexLabel setTextColor:[UIColor flatMidnightBlueColor]];
        [hexagon.indexLabel setFont:GILLSANS(CGRectGetMidX(hexagon.bounds))];
        [hexaArray addObject:hexagon];
        [self.view addSubview:hexagon];
        
        CAShapeLayer *hexaLayer = (CAShapeLayer *)hexagon.layer;
        [hexaLayer setLineWidth:hexaLayer.lineWidth + kPadding];//Subtact above, then add here, increase line width without changing bound size
    }
    
    _hexaArray = hexaArray;
    
    // Create a container view to contain the 'tap' labels, animate this down screen instead of multiple labels
    CGRect  tapFrame  = CGRectMake(0.0f, 0.0f, CGRectGetMidX(self.view.bounds), 2.0f);
    self.tapLabelsContainer = [[UIView alloc] initWithFrame:tapFrame];
    [self.tapLabelsContainer setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tapLabelsContainer];
    
    //Create two labels, one positioned on each side of the hexagon that needs to be 'tappped'
    for (int i = 0; i < 2; i++) {
    
        CGPoint tapLabelPosition = CGPointMake(
                                               (i == 0) ? 0.0f : CGRectGetWidth(self.tapLabelsContainer.bounds),
                                               CGRectGetMidY(self.tapLabelsContainer.bounds)
                                               );
        
        UILabel *tap = [[UILabel alloc] init];
        [tap setTextAlignment:NSTextAlignmentCenter];
        [tap setTextColor:[UIColor whiteColor]];
        [tap setText:NSLocalizedString(@"TAP", nil)];
        [tap setFont:GILLSANS(26.0f)];
        [tap sizeToFit];
        [tap setCenter:tapLabelPosition];
        [self.tapLabelsContainer addSubview:tap];
    }
}

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
        if (CGRectContainsPoint(hexaView.frame, location) && hexaView.isEnabled) {
            _hexaView = hexaView;
        }
    }
    
    // If the current point's location isnt in any view's frame, return
    if (!_hexaView) {
        return;
    }
    
    [_hexaView setEnabled:NO];
    
    CAShapeLayer *hexaLayer = (CAShapeLayer *)_hexaView.layer;
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [scale setFromValue:@1.0f];
    [scale setToValue:@.9f];
    [scale setDuration:.15f];
    [scale setAutoreverses:YES];
    [hexaLayer addAnimation:scale forKey:@"scale"];
    
    [hexaLayer setFillColor:hexaLayer.strokeColor];
    
    switch (_hexaView.tag) {
        case 0:
            [self _animateTapLabelPosition];
            [_hexaView.indexLabel setText:@"E"];
            [[HDSoundManager sharedManager] playSound:HDC3];
            [[_hexaArray objectAtIndex:1] setEnabled:YES];
            break;
        case 1: {
            
            [_hexaView.indexLabel setText:@"X"];
            [[_hexaArray objectAtIndex:2] setEnabled:YES];
            [[HDSoundManager sharedManager] playSound:HDD3];
            
            HDHexagonView *hexa = [_hexaArray lastObject];
            [self _performRotationOnView:hexa];
            [self _animateTapLabelPosition];
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hexa.imageView setImage:nil];
            });
            
        }  break;
        case 2:
            [_hexaView.indexLabel setText:@"U"];
            [[HDSoundManager sharedManager] playSound:HDE3];
            [[_hexaArray objectAtIndex:3] setEnabled:YES];
            [self _animateTapLabelPosition];
            break;
        case 3:
            [_hexaView.indexLabel setText:@"S"];
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            [[HDSoundManager sharedManager] playSound:HDF3];
            [ADelegate performSelector:@selector(presentContainerViewController) withObject:nil afterDelay:.3f];
            
            [UIView animateWithDuration:.3f animations:^{
                [self.tapLabelsContainer setAlpha:0.0f];
            }];
            
            break;
    }
    [_hexaView setUserInteractionEnabled:NO];
}

- (void)_performRotationOnView:(UIView *)view
{
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [rotate setDuration:.3];
    [rotate setFromValue:@0];
    [rotate setToValue:@(M_PI * 4)];
    [view.layer addAnimation:rotate forKey:@"rotate"];
}

- (void)_animateTapLabelPosition
{
    [UIView animateWithDuration:.3f
                     animations:^{
                         CGRect tapRect = self.tapLabelsContainer.frame;
                         tapRect.origin.y += kHexaSize;
                         [self.tapLabelsContainer setFrame:tapRect];
                     }];
}

- (void)_prepareForIntroAnimations
{
    CGPoint tapCenter = CGPointMake(
                                    CGRectGetMidX(self.view.bounds),
                                    CGRectGetMidY(self.view.bounds) - ((CGFloat)kHexaCount - 1) / 2 * kHexaSize
                                    );
    
    [self.tapLabelsContainer setCenter:tapCenter];
    [self.tapLabelsContainer setAlpha:0.0f];
    
    NSUInteger index = 0;
    for (HDHexagonView *hexa in _hexaArray) {
        
        [hexa setHidden:YES];
        [hexa setEnabled:(index == 0)];
        [hexa setUserInteractionEnabled:YES];
        
        CAShapeLayer *hexaLayer = (CAShapeLayer *)hexa.layer;
        [hexaLayer setFillColor:[[UIColor flatMidnightBlueColor] CGColor]];
        
        switch (index) {
            case 0:
                [hexaLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
                break;
            case 1:
                [hexaLayer setStrokeColor:[[UIColor flatEmeraldColor] CGColor]];
                break;
            case 2:
                [hexaLayer setStrokeColor:[[UIColor flatPeterRiverColor] CGColor]];
                break;
            case 3:
                [hexaLayer setStrokeColor:[[UIColor flatEmeraldColor] CGColor]];
                [hexa.imageView setImage:[UIImage imageNamed:@"Lock45"]];
                break;
        }
        index++;
    }
}

- (void)_performIntroAnimations
{
    HDHexagonView *third = [_hexaArray objectAtIndex:2];
    [third setHidden:NO];
    
    CABasicAnimation *thirdA = [CABasicAnimation animationWithKeyPath:@"position.x"];
    [thirdA setToValue:@(third.center.x)];
    [thirdA setFromValue:@(CGRectGetWidth(self.view.bounds) + kHexaSize/2)];
    [thirdA setDuration:.5f];
    [third.layer addAnimation:thirdA forKey:@"ThirdTileAnimationKey"];
    
    HDHexagonView *first = [_hexaArray firstObject];
    [first performSelector:@selector(setHidden:) withObject:0 afterDelay:thirdA.duration];
    
    CABasicAnimation *firstA = [CABasicAnimation animationWithKeyPath:@"position.y"];
    [firstA setToValue:@(first.center.y)];
    [firstA setFromValue:@(-kHexaSize/2)];
    [firstA setDuration:thirdA.duration];
    [firstA setBeginTime:CACurrentMediaTime() + thirdA.duration];
    [first.layer addAnimation:firstA forKey:@"FirstTileAnimationKey"];
    
    HDHexagonView *fourth = [_hexaArray lastObject];
    [fourth performSelector:@selector(setHidden:) withObject:0 afterDelay:thirdA.duration + firstA.duration];
    
    CABasicAnimation *fourthA = [CABasicAnimation animationWithKeyPath:@"position.y"];
    [fourthA setToValue:@(fourth.center.y)];
    [fourthA setFromValue:@(CGRectGetHeight(self.view.bounds)+kHexaSize/2)];
    [fourthA setDuration:thirdA.duration];
    [fourthA setBeginTime:CACurrentMediaTime() + thirdA.duration + firstA.duration];
    [fourth.layer addAnimation:fourthA forKey:@"FourthTileAnimationKey"];
    
    HDHexagonView *second = [_hexaArray objectAtIndex:1];
    [second performSelector:@selector(setHidden:) withObject:0 afterDelay:thirdA.duration + firstA.duration + fourthA.duration];
    
    CABasicAnimation *secondA = [CABasicAnimation animationWithKeyPath:@"position.x"];
    [secondA setToValue:@(second.center.x)];
    [secondA setFromValue:@(-kHexaSize/2)];
    [secondA setDuration:thirdA.duration];
    [secondA setBeginTime:CACurrentMediaTime() + thirdA.duration + firstA.duration + fourthA.duration];
    [second.layer addAnimation:secondA forKey:@"SecondTileAnimationKey"];
    
    NSTimeInterval delay = thirdA.duration + firstA.duration + fourthA.duration + secondA.duration;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:.3f animations:^{
            [self.tapLabelsContainer setAlpha:1.0f];
        }];
        
        for (UILabel *label in self.tapLabelsContainer.subviews) {
            CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
            [scale setByValue:@.3f];
            [scale setToValue:@1.3f];
            [scale setDuration:.4f];
            [scale setRepeatCount:MAXFLOAT];
            [scale setAutoreverses:YES];
            [label.layer addAnimation:scale forKey:@"scale"];
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _prepareForIntroAnimations];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self _performIntroAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
