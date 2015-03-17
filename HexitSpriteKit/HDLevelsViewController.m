//
//  HDLevelsViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/23/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevelsViewController.h"
#import "HDMapManager.h"
#import "HDHexagonButton.h"
#import "HDHelper.h"
#import "UIColor+FlatColors.h"
#import "HDLevel.h"
#import "NSMutableArray+UniqueAdditions.h"

static const CGFloat kPadding = 2.0f;
static const CGFloat kTileHeightInsetMultiplier = .855f;

#define kHexaSize [[UIScreen mainScreen] bounds].size.width / 6
#define kHexaSizeiPad [[UIScreen mainScreen] bounds].size.width / 8.25

@implementation HDLevelsContainerView
@end

@implementation HDLevelsView

- (HDLevelsContainerView *)containerView {
    return self.subviews.firstObject;
}

- (void)performIntroAnimationWithCompletion:(dispatch_block_t)completion {
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    
    for (int row = 0; row < 7; row++) {
        for (HDHexagonButton *hexagon in self.containerView.subviews) {
            if (row == hexagon.row) {
                
                [hexagon performSelector:@selector(setHidden:) withObject:0 afterDelay:row * .1f];
                CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
                scale.values    = @[@0.0f, @1.1f, @1.0f];
                scale.duration  = .3f;
                scale.beginTime = CACurrentMediaTime() + row * .1f;
                [hexagon.layer addAnimation:scale forKey:scale.keyPath];
                
            }
        }
    }
    [CATransaction commit];
}

- (void)performOutroAnimationWithCompletion:(dispatch_block_t)completion {
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    
    for (HDHexagonButton *hexa in self.containerView.subviews) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            hexa.hidden = YES;
        });
        
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale.fromValue = @1;
        scale.toValue   = @0;
        scale.duration  = .3f;
        scale.removedOnCompletion = NO;
        scale.fillMode = kCAFillModeForwards;
        [hexa.layer addAnimation:scale forKey:scale.keyPath];
        
    }
    [CATransaction commit];
}

@end

@interface HDLevelsViewController ()

@end

@implementation HDLevelsViewController {
    HDLevelsContainerView *_containerView;
    __weak HDLevelsView *_levelsView;
}

- (HDLevelsContainerView *)levelsContainerView {
    return (HDLevelsContainerView *)self.view;
}

- (HDLevelsView *)levelsView {
    return (HDLevelsView *)self.view;
}

- (void)loadView {
    self.view = [HDLevelsView new];
    _levelsView = (HDLevelsView *)self.view;
    
    CGRect containerFrame =  CGRectMake(0.0f,
                                        0.0f,
                                        self.tileSize * (self.columns + 1),
                                        (self.tileSize + kPadding) * kTileHeightInsetMultiplier * self.rows);
    
    _containerView = [[HDLevelsContainerView alloc] initWithFrame:containerFrame];
    [_levelsView addSubview:_containerView];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSUInteger tagIndex = self.levelRange.location + 1;
    for (int row = 0; row < self.rows; row++) {
        for (int column = 0; column < self.columns; column++) {
            
            HDLevel *level = [[HDMapManager sharedManager] levelAtIndex:tagIndex - 1];
            CGRect bounds = CGRectMake(0.0f, 0.0f, self.tileSize + kPadding, self.tileSize + kPadding);
            HDHexagonButton *hexagon = [[HDHexagonButton alloc] initWithFrame:bounds];
            [hexagon addTarget:self action:@selector(_beginGame:) forControlEvents:UIControlEventTouchDown];
            hexagon.levelState  = level.state;
            hexagon.row    = row;
            hexagon.hidden = YES;
            hexagon.index  = tagIndex;
            hexagon.tag    = tagIndex;
            hexagon.center = [self _pointForColumn:column row:row];
            [_containerView addSubview:hexagon];
            
            tagIndex++;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateState];
    [super viewWillAppear:animated];
    _containerView.center = CGPointMake(CGRectGetMidX(_levelsView.bounds), CGRectGetMidY(_levelsView.bounds));
}

- (void)updateState {
    NSUInteger tagIndex = self.levelRange.location + 1;
    for (HDHexagonButton *subView in _containerView.subviews) {
        HDLevel *level = [[HDMapManager sharedManager] levelAtIndex:tagIndex - 1];
        subView.levelState  = level.state;
        subView.index  = tagIndex;
        tagIndex++;
    }
}

#pragma mark - Private

- (void)_beginGame:(HDHexagonButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(levelsViewController:didSelectLevel:)]) {
         [self.delegate levelsViewController:self didSelectLevel:sender.tag];
    }
}

- (CGPoint)_pointForColumn:(NSInteger)column row:(NSInteger)row {
    
    const CGFloat kOriginY = self.tileSize/2 + ((row * (self.tileSize * kTileHeightInsetMultiplier)) );
    const CGFloat kOriginX = self.tileSize/2 + self.tileSize/4 + ((column * self.tileSize));
    const CGFloat kAlternateOffset = (row % 2 == 0) ? self.tileSize/2 : 0.0f;
    return CGPointMake(kAlternateOffset + kOriginX, kOriginY);
}

#pragma mark - Getter

- (CGFloat)tileSize {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? kHexaSizeiPad : kHexaSize;
}

@end
