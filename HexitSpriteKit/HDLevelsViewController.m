//
//  HDLevelsViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/23/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevelsViewController.h"
#import "HDMapManager.h"
#import "HDHexaButton.h"
#import "HDHelper.h"
#import "UIColor+ColorAdditions.h"
#import "HDLevel.h"
#import "NSMutableArray+UniqueAdditions.h"

static const CGFloat kPadding = 2.0f;
static const CGFloat kTileHeightInsetMultiplier = .855f;

#define kHexaSize [[UIScreen mainScreen] bounds].size.width / 6
#define kHexaSizeiPad [[UIScreen mainScreen] bounds].size.width / 8.25

@implementation HDLevelsContainerView
@end

@implementation HDLevelsView

- (HDLevelsContainerView *)containerView
{
    return self.subviews.firstObject;
}

- (void)performIntroAnimationWithCompletion:(dispatch_block_t)completion
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    
    NSTimeInterval delay = 0.0f;
    for (int row = 0; row < 7; row++) {
        for (HDHexaButton *hexagon in self.containerView.subviews) {
            if (row == hexagon.row) {
                
                [hexagon performSelector:@selector(setHidden:) withObject:0 afterDelay:delay];
                
                CGFloat hexaScale = hexagon.transform.a;
                CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
                scale.duration = .3f;
                scale.values = @[@0.0f, @(hexaScale + .1f), @(hexaScale)];
                scale.keyTimes = @[@0.0f, @.55f, @1.0f];
                scale.beginTime = CACurrentMediaTime() + delay;
                [hexagon.layer addAnimation:scale forKey:scale.keyPath];
                
            }
        }
        delay += .08f;
    }
    [CATransaction commit];
}

- (void)performOutroAnimationWithCompletion:(dispatch_block_t)completion
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    
    for (HDHexaButton *hexagon in self.containerView.subviews) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            hexagon.hidden = YES;
        });
        
        CGFloat hexaScale = hexagon.transform.a;
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale.fromValue = @(hexaScale);
        scale.toValue   = @0;
        scale.duration  = .3f;
        scale.removedOnCompletion = NO;
        scale.fillMode = kCAFillModeForwards;
        [hexagon.layer addAnimation:scale forKey:scale.keyPath];
        
    }
    [CATransaction commit];
}

@end

@interface HDLevelsViewController ()

@end

@implementation HDLevelsViewController
{
    HDLevelsContainerView *_containerView;
    __weak HDLevelsView *_levelsView;
}

- (void)loadView
{
    self.view = [HDLevelsView new];
    _levelsView = (HDLevelsView *)self.view;
    
    CGRect containerFrame = CGRectMake(0.0f,
                                       0.0f,
                                       self.tileSize * (self.columns + 1),
                                      (self.tileSize + kPadding) * kTileHeightInsetMultiplier * self.rows);
    
    _containerView = [[HDLevelsContainerView alloc] initWithFrame:containerFrame];

    [_levelsView addSubview:_containerView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUInteger tagIndex = self.levelRange.location + 1;
    for (int row = 0; row < self.rows; row++) {
        for (int column = 0; column < self.columns; column++) {
            
            HDLevel *level = [[HDMapManager sharedManager] levelAtIndex:tagIndex - 1];
            
            CGRect bounds = CGRectMake(0.0f, 0.0f, self.tileSize + kPadding, self.tileSize + kPadding);
            HDHexaButton *hexagon = [[HDHexaButton alloc] initWithLevelState:level.state];
            hexagon.transform = IS_IPAD ? CGAffineTransformIdentity : CGAffineTransformMakeScale(TRANSFORM_SCALE_X, TRANSFORM_SCALE_X);
            hexagon.frame  = bounds;
            hexagon.row    = row;
            hexagon.hidden = YES;
            hexagon.tag    = tagIndex;
            hexagon.center = [self _pointForColumn:column row:row];
            [hexagon addTarget:self action:@selector(_beginGame:) forControlEvents:UIControlEventTouchUpInside];
            [_containerView addSubview:hexagon];
            
            tagIndex++;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateLevelsForIAP];
    [super viewWillAppear:animated];
    _containerView.center = CGPointMake(CGRectGetMidX(_levelsView.bounds), CGRectGetMidY(_levelsView.bounds));
    

}

- (void)updateLevelsForIAP
{
    NSUInteger tagIndex = self.levelRange.location + 1;
    for (HDHexaButton *subView in _containerView.subviews) {
        HDLevel *level = [[HDMapManager sharedManager] levelAtIndex:tagIndex - 1];
        subView.levelState  = level.state;
        tagIndex++;
    }
}

#pragma mark - Private

- (IBAction)_beginGame:(HDHexaButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(levelsViewController:didSelectLevel:)]) {
         [self.delegate levelsViewController:self didSelectLevel:sender.tag];
    }
}

- (CGPoint)_pointForColumn:(NSInteger)column row:(NSInteger)row
{
    const CGFloat kOriginY = self.tileSize/2 + ((row * (self.tileSize * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = self.tileSize/2 + self.tileSize/4 + ((column * self.tileSize));
    const CGFloat kAlternateOffset = (row % 2 == 0) ? self.tileSize/2 : 0.0f;
    return CGPointMake(kAlternateOffset + kOriginX, kOriginY);
}

#pragma mark - Getter

- (CGFloat)tileSize
{
    return IS_IPAD ? kHexaSizeiPad : kHexaSize;
}

@end
