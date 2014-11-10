//
//  ViewController.m
//  SideMenuExample
//
//  Created by Evan Ische on 10/15/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDMenuViewController.h"
#import "HDGameViewController.h"
#import "HDLevelViewController.h"
#import "UIColor+FlatColors.h"
#import "HDHexagon.h"
#import "HDConstants.h"

static CGFloat const kAnimationOffsetX = 180.0f;

@interface HDMenuViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *buttonList;
@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftGestureRecognizer;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *rightGestureRecognizer;

@property (nonatomic, setter=setExpanded:, assign) BOOL isExpanded;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UIPushBehavior* pushBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;

@end

@implementation HDMenuViewController{
    BOOL _isExpanded;
}

@synthesize isExpanded = _isExpanded;
- (instancetype)initWithRootViewController:(UIViewController *)controller
{
    NSParameterAssert(controller);
    if (self = [super init]) {
        [self setRootViewController:controller];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _layoutSideMenuSelectors];
    
    [self.view addSubview:self.rootViewController.view];
    [self.view setBackgroundColor:[UIColor flatPeterRiverColor]];
    
    [self addChildViewController:self.rootViewController];
    [self.rootViewController didMoveToParentViewController:self];
    
    [self _initalizePhysicsAnimators];
    [self _initalizeGestureRecognizers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 
#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.leftGestureRecognizer && self.isExpanded == NO) {
         return YES;
    } else if (gestureRecognizer == self.rightGestureRecognizer && self.isExpanded == YES) {
         return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark - Private

- (void)_setFrontViewController:(UIViewController *)controller animated:(BOOL)animated
{
    [(UINavigationController *)self.rootViewController setViewControllers:@[controller] animated:animated];
}

- (void)_restartPreviousLevelOnGameController
{
    HDGameViewController *controller = (HDGameViewController *)self.rootViewController.childViewControllers.lastObject;
    [self _setFrontViewController:[[HDGameViewController alloc] initWithLevel:controller.level] animated:NO];
}

- (void)_presentLevelViewController
{
    NSArray *children = self.rootViewController.childViewControllers;
    if (![[children lastObject] isKindOfClass:[HDLevelViewController class]]) {
        HDLevelViewController *controller = [[HDLevelViewController alloc] init];
        [self _setFrontViewController:controller animated:YES];
    }
}

- (void)_bounceHDSideMenuController
{
    [self.pushBehavior setPushDirection:CGVectorMake(!self.isExpanded ? 45.0f : -45.0f , 0.0f)];
    [self.pushBehavior setActive:YES];
}

- (void)_toggleHDMenuViewController:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.view];
    location.y = CGRectGetMidY(self.view.bounds);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.rootViewController.view attachedToAnchor:location];
        [self.animator removeBehavior:self.gravityBehavior];
        [self.animator addBehavior:self.attachmentBehavior];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        [self.attachmentBehavior setAnchorPoint:location];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        [self.animator removeBehavior:self.attachmentBehavior];
        [self setAttachmentBehavior:nil];
        
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        
        NSInteger gravityVectorX = 0;
        if (velocity.x > 0) {
            gravityVectorX = 1;
            [self setExpanded:YES];
        } else {
            gravityVectorX = -1;
            [self setExpanded:NO];
        }
        
        [self.gravityBehavior setGravityDirection:CGVectorMake(gravityVectorX, 0)];
        [self.animator addBehavior:self.gravityBehavior];
        
        [self.pushBehavior setPushDirection:CGVectorMake(velocity.x / 20.0f, 0)];
        [self.pushBehavior setActive:YES];
        
    }
}

- (void)_layoutSideMenuSelectors
{
    self.buttonList = [NSMutableArray arrayWithCapacity:3];
    
    CGRect titleRect = CGRectMake(0.0f, 60.0f, 165.0f, 30.0f);
    UILabel *title = [[UILabel alloc] initWithFrame:titleRect];
    [title setTextAlignment:NSTextAlignmentRight];
    [title setText:@"HEXIT"];
    [title setFont:GILLSANS(28.0f)];
    [title setTextColor:[UIColor whiteColor]];
    [self.view addSubview:title];
    
    NSMutableArray *buttons = [NSMutableArray array];
    
    UIButton *retry = [UIButton buttonWithType:UIButtonTypeCustom];
    [retry setTitle:@"Retry" forState:UIControlStateNormal];
    [retry setBackgroundColor:[UIColor flatTurquoiseColor]];
    [retry addTarget:self action:@selector(_restartPreviousLevelOnGameController) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *map = [UIButton buttonWithType:UIButtonTypeCustom];
    [map setBackgroundColor:[UIColor flatEmeraldColor]];
    [map setTitle:@"Map" forState:UIControlStateNormal];
    [map addTarget:self action:@selector(_presentLevelViewController) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *button in @[retry, map]) {
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [[button titleLabel] setFont:GILLSANS_LIGHT(18.0f)];
        [[button titleLabel] setTextAlignment:NSTextAlignmentCenter];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.layer setCornerRadius:10.0f];
        [buttons addObject:button];
        [self.view addSubview:button];
    }
    
    NSDictionary *dictionary = NSDictionaryOfVariableBindings(retry, map);
    
    NSArray *tConstraint  = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-130-[retry]"    options:0 metrics:nil views:dictionary];
    NSArray *vConstraint  = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[retry]-20-[map]" options:0 metrics:nil views:dictionary];
    
    NSArray *hMConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[map]"       options:0 metrics:nil views:dictionary];
    NSArray *hRConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[retry]"     options:0 metrics:nil views:dictionary];
    
    NSArray *mWidth       = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[map(140)]"       options:0 metrics:nil views:dictionary];
    NSArray *RWidth       = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[retry(140)]"     options:0 metrics:nil views:dictionary];
    
    NSArray *mHeight      = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[map(40)]"        options:0 metrics:nil views:dictionary];
    NSArray *RHeight      = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[retry(40)]"      options:0 metrics:nil views:dictionary];

    for (NSArray *constraint in @[tConstraint, vConstraint, hMConstraint, hRConstraint, mWidth, RWidth, mHeight, RHeight]) {
        [self.view addConstraints:constraint];
    }
    
    self.buttonList = buttons;
}

- (void)_initalizeGestureRecognizers
{
    self.leftGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(_toggleHDMenuViewController:)];
    [self.leftGestureRecognizer setEdges:UIRectEdgeLeft];
    [self.leftGestureRecognizer setDelegate:self];
    [self.rootViewController.view addGestureRecognizer:self.leftGestureRecognizer];
    
    self.rightGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(_toggleHDMenuViewController:)];
    [self.rightGestureRecognizer setEdges:UIRectEdgeRight];
    [self.rightGestureRecognizer setDelegate:self];
    [self.rootViewController.view addGestureRecognizer:self.rightGestureRecognizer];
}

- (void)_initalizePhysicsAnimators
{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.rootViewController.view]];
    [self.gravityBehavior setGravityDirection:CGVectorMake(-1, 0)];
    [self.animator addBehavior:self.gravityBehavior];
    
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.rootViewController.view] mode:UIPushBehaviorModeInstantaneous];
    [self.pushBehavior setMagnitude:0.0f];
    [self.pushBehavior setAngle:0.0f];
    [self.animator addBehavior:self.pushBehavior];
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[self.rootViewController.view]];
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, 0, 0, -kAnimationOffsetX)];
    [self.animator addBehavior:collisionBehaviour];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.rootViewController.view]];
    [itemBehaviour setElasticity:.45f];
    [self.animator addBehavior:itemBehaviour];
}

@end

@implementation UIViewController (HDMenuViewController)

- (void)setFrontViewController:(UIViewController *)controller animated:(BOOL)animated
{
    UIResponder *nextResponder = self.nextResponder;
    while ((nextResponder = nextResponder.nextResponder)) {
        if ([(HDMenuViewController *)nextResponder respondsToSelector:@selector(_setFrontViewController:animated:)]) {
            [(HDMenuViewController *)nextResponder _setFrontViewController:controller animated:animated];
            return;
        }
    }
}

- (void)bounceFrontViewController:(id)sender
{
    UIResponder *nextResponder = self.nextResponder;
    while ((nextResponder = nextResponder.nextResponder)) {
        if ([(HDMenuViewController *)nextResponder respondsToSelector:@selector(_bounceHDSideMenuController)]) {
            [(HDMenuViewController *)nextResponder _bounceHDSideMenuController];
            return;
        }
    }
}

@end
