//
//  ViewController.m
//  SideMenuExample
//
//  Created by Evan Ische on 10/15/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDMenuViewController.h"
#import "UIColor+FlatColors.h"
#import "HDHexagon.h"
#import "HDConstants.h"

static CGFloat const kAnimationOffsetX = 180.0f;
@interface HDMenuViewController ()<UIGestureRecognizerDelegate>

@end

@interface HDMenuViewController ()

@property (nonatomic, copy)   CompletionBlock completion;
@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftGestureRecognizer;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *rightGestureRecognizer;

@property (nonatomic, setter=setExpanded:, assign) BOOL isExpanded;
@end

@implementation HDMenuViewController{
    BOOL _isExpanded;
}

@synthesize isExpanded = _isExpanded;
- (instancetype)initWithRootViewController:(UIViewController *)controller handler:(CompletionBlock)block
{
    NSParameterAssert(controller);
    if (self = [super init]) {
        [self setRootViewController:controller];
        [self setCompletion:block];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect titleRect = CGRectMake(0.0f, 60.0f, 165.0f, 30.0f);
    UILabel *title = [[UILabel alloc] initWithFrame:titleRect];
    [title setTextAlignment:NSTextAlignmentRight];
    [title setText:@"HEXIT"];
    [title setFont:GILLSANS(28.0f)];
    [title setTextColor:[UIColor whiteColor]];
    [self.view addSubview:title];
    
    [self layoutMenuButtons];
    [self.view setBackgroundColor:[UIColor flatPeterRiverColor]];
    [self.view addSubview:self.rootViewController.view];
    
    self.leftGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(_toggleHDMenuViewController:)];
    [self.leftGestureRecognizer setEdges:UIRectEdgeLeft];
    [self.leftGestureRecognizer setDelegate:self];
    [self.rootViewController.view addGestureRecognizer:self.leftGestureRecognizer];
    
    self.rightGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(_toggleHDMenuViewController:)];
    [self.rightGestureRecognizer setEdges:UIRectEdgeRight];
    [self.rightGestureRecognizer setDelegate:self];
    [self.rootViewController.view addGestureRecognizer:self.rightGestureRecognizer];
    
    [self addChildViewController:self.rootViewController];
    [self.rootViewController didMoveToParentViewController:self];
}

- (void)layoutMenuButtons
{
    self.buttonList = [NSMutableArray arrayWithCapacity:3];
    
    CGRect firstRect = CGRectMake(20.0f, 150.0f, 140.0f, 35.0f);
    
    CGRect previousRect = CGRectZero;
    
    for (int y = 0; y < 2; y++) {
        
        CGRect currectRect = previousRect;
        
        if (y == 0) {
            currectRect = firstRect;
        } else {
            currectRect.origin.y += 50.0f;
        }
        
        UIButton *hexagon = [UIButton buttonWithType:UIButtonTypeCustom];
        [hexagon setFrame:currectRect];
        [[hexagon titleLabel] setFont:GILLSANS_LIGHT(18.0f)];
        [[hexagon titleLabel] setTextAlignment:NSTextAlignmentCenter];
        [hexagon setBackgroundColor:[UIColor flatMidnightBlueColor]];
        [hexagon.layer setCornerRadius:10.0f];
        [self.buttonList addObject:hexagon];
        [self.view addSubview:hexagon];
        
        switch (y) {
            case 0:
                [hexagon setTitle:@"Retry" forState:UIControlStateNormal];
                [hexagon setBackgroundColor:[UIColor flatTurquoiseColor]];
                [hexagon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                break;
            case 1:
                [hexagon setTitle:@"Map" forState:UIControlStateNormal];
                [hexagon setBackgroundColor:[UIColor flatEmeraldColor]];
                [hexagon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                break;
        }
        
        previousRect = hexagon.frame;
    }
    
    if (_completion) {
        _completion(self.buttonList);
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setExpanded:(BOOL)isExpanded
{
    if (_isExpanded == isExpanded) {
        return;
    }
    
     _isExpanded = isExpanded;
    
    if (_isExpanded) {
        [self _expandAnimated:YES];
    } else {
        [self _closeAnimated:YES];
    }
}

- (void)_closeAnimated:(BOOL)flag
{
    dispatch_block_t closeAnimation = ^{
        CGRect rect = self.rootViewController.view.frame;
        rect.origin.x = 0;
        [self.rootViewController.view setFrame:rect];
    };
    
    if (!flag) {
        closeAnimation();
    } else {
        [UIView animateWithDuration:.3f
                         animations:closeAnimation
                         completion:nil];
    }
}

- (void)_expandAnimated:(BOOL)flag
{
    dispatch_block_t expandAnimation = ^{
        CGRect rect = self.rootViewController.view.frame;
        rect.origin.x += kAnimationOffsetX;
        [self.rootViewController.view setFrame:rect];
    };
    
    if (!flag) {
        expandAnimation();
    } else {
        [UIView animateWithDuration:.3f
                         animations:expandAnimation
                         completion:nil];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    BOOL allowTouch = NO;
    if (gestureRecognizer == self.leftGestureRecognizer && self.isExpanded == NO) {
         allowTouch = YES;
    } else if (gestureRecognizer == self.rightGestureRecognizer && self.isExpanded == YES) {
         allowTouch = YES;
    }
    return allowTouch;
}

- (void)_toggleHDMenuViewController:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
       self.isExpanded = !self.isExpanded;
    }
}

@end

@implementation UIViewController (HDMenuViewController)

- (void)toggleHDMenu:(id)sender
{
    UIResponder *nextResponder = self.nextResponder;
    while ((nextResponder = nextResponder.nextResponder)) {
        if ([(HDMenuViewController *)nextResponder respondsToSelector:@selector(_toggleHDMenuViewController:)]) {
            [(HDMenuViewController *)nextResponder _toggleHDMenuViewController:nil];
            return;
        }
    }
}

@end
