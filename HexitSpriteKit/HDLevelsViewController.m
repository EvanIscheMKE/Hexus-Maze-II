//
//  HDLevelsViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/23/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevelsViewController.h"
#import "HDMapManager.h"
#import "HDHexagonView.h"
#import "HDHelper.h"
#import "UIColor+FlatColors.h"
#import "HDLevel.h"
#import "NSMutableArray+UniqueAdditions.h"

static const CGFloat kPadding = 4.0f;
static const CGFloat kTileHeightInsetMultiplier = .855f;

#define kHexaSize [[UIScreen mainScreen] bounds].size.width / 6.0f

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
    const NSTimeInterval kIncreaseInterval = .03f;
    NSTimeInterval delay = 0;
    for (HDHexagonView *hexa in [[self.containerView.subviews mutableCopy] shuffle]) {
        
        [hexa performSelector:@selector(setHidden:) withObject:0 afterDelay:delay];
        
        CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        [scale setValues:@[@0.0f,@1.1f,@1.0f]];
        [scale setDuration:.3f];
        [scale setBeginTime:CACurrentMediaTime() + delay];
        [hexa.layer addAnimation:scale forKey:@"ScaleIn"];
        
        delay += kIncreaseInterval;
    }
    [CATransaction commit];
}

- (void)performOutroAnimationWithCompletion:(dispatch_block_t)completion
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    const NSTimeInterval kIncreaseInterval = .03f;
    NSTimeInterval delay = 0.0f;
    for (HDHexagonView *hexa in [[self.containerView.subviews mutableCopy] shuffle]) {
        
        CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        scale.values = @[@1.0f,@1.1f,@0.0f];
        scale.duration = .3f;
        scale.removedOnCompletion = NO;
        scale.fillMode = kCAFillModeForwards;
        scale.beginTime = CACurrentMediaTime() + delay;
        [hexa.layer addAnimation:scale forKey:@"ScaleOut"];
        
        delay += kIncreaseInterval;
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

+ (CGPoint)_pointForColumn:(NSInteger)column row:(NSInteger)row
{
    // Find position from Column/Row
    const CGFloat kOriginY = ((row * (kHexaSize * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = kHexaSize/4 + ((column * kHexaSize));
    const CGFloat kAlternateOffset = (row % 2 == 0) ? kHexaSize / 2 : 0.0f;
    
    return CGPointMake(kAlternateOffset + kOriginX, kOriginY);
}

- (HDLevelsContainerView *)levelsContainerView
{
    return (HDLevelsContainerView *)self.view;
}

- (HDLevelsView *)levelsView
{
    return (HDLevelsView *)self.view;
}

- (void)loadView
{
    self.view = [HDLevelsView new];
    _levelsView = (HDLevelsView *)self.view;
    
    CGRect containerFrame =  CGRectMake(0.0f, 0.0f, kHexaSize * self.columns, kHexaSize * kTileHeightInsetMultiplier * (self.rows - 1));
    _containerView = [[HDLevelsContainerView alloc] initWithFrame:containerFrame];
    [_levelsView addSubview:_containerView];
}

- (void)viewDidLoad
{
    NSMutableArray *pageArray = [NSMutableArray arrayWithCapacity:self.columns*self.rows];
    NSUInteger tagIndex = self.levelRange.location + 1;
    for (int row = 0; row < self.rows; row++)
    {
        for (int column = 0; column < self.columns; column++)
        {
            HDLevel *level = [[HDMapManager sharedManager] levelAtIndex:tagIndex - 1];
            
            CGRect bounds = CGRectMake(0.0f, 0.0f, kHexaSize - kPadding, kHexaSize - kPadding);
            HDHexagonView *hexagon = [[HDHexagonView alloc] initWithFrame:bounds
                                                                     type:HDHexagonTypePoint
                                                              strokeColor:[UIColor flatPeterRiverColor]];
            hexagon.tag = tagIndex;
            hexagon.hidden = YES;
            hexagon.center = [HDLevelsViewController _pointForColumn:column row:row];
             
            [pageArray addObject:hexagon];
            [_containerView addSubview:hexagon];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_beginGame:)];
            tap.numberOfTapsRequired = 1;
            [hexagon addGestureRecognizer:tap];
            
            if (level.completed)
            {
                [hexagon setState:HDHexagonStateCompleted index:tagIndex];
            }
            else if (!level.completed && level.isUnlocked)
            {
                [hexagon setState:HDHexagonStateUnlocked index:tagIndex];
            }
            else
            {
                [hexagon setState:HDHexagonStateLocked index:tagIndex];
            }
            tagIndex++;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.userInteractionEnabled = YES;
    _containerView.center = CGPointMake(CGRectGetMidX(_levelsView.bounds), CGRectGetMidY(_levelsView.bounds));
}

- (void)_beginGame:(UITapGestureRecognizer *)sender
{
    self.view.userInteractionEnabled = NO;
    [self.delegate levelsViewController:self didSelectLevel:[sender.view tag]];
}

@end
