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

@interface HDSettingsContainer : UIView
@property (nonatomic, readonly, strong) NSArray *settingButtons;
@end

@implementation HDSettingsContainer{
    NSMutableArray *_buttons;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor flatPeterRiverColor]];
    }
    return self;
}

- (NSArray *)settingButtons
{
    if (_buttons) {
        return _buttons;
    }
    
    _buttons = [NSMutableArray array];
    
    UIButton *buttonOne = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonOne setBackgroundImage:[UIImage imageNamed:@"Volume"] forState:UIControlStateNormal];
    [buttonOne setBackgroundImage:[UIImage imageNamed:@"Volume"] forState:UIControlStateSelected];
    
    UIButton *buttonTwo = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonTwo setBackgroundImage:[UIImage imageNamed:@"Volume"] forState:UIControlStateNormal];
    [buttonTwo setBackgroundImage:[UIImage imageNamed:@"Volume"] forState:UIControlStateSelected];
    
    UIButton *buttonThree = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonThree setBackgroundImage:[UIImage imageNamed:@"Volume"] forState:UIControlStateNormal];
    [buttonThree setBackgroundImage:[UIImage imageNamed:@"Volume"] forState:UIControlStateSelected];
    
    UILabel *labelOne = [[UILabel alloc] init];
    [labelOne setText:@"Effects"];
    [self addSubview:labelOne];
    
    UILabel *labelTwo = [[UILabel alloc] init];
    [labelTwo setText:@"Sounds"];
    [self addSubview:labelTwo];
    
    UILabel *labelThree = [[UILabel alloc] init];
    [labelThree setText:@"Vibration"];
    [self addSubview:labelThree];
    
    for (UILabel *label in @[labelOne, labelTwo, labelThree]) {
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:GILLSANS_LIGHT(18.0f)];
        [self addSubview:label];
    }
    
    for (UIButton *selectors in @[buttonOne, buttonTwo, buttonThree]) {
        [selectors setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_buttons addObject:selectors];
        [self addSubview:selectors];
    }
    
    NSDictionary *dictionary = NSDictionaryOfVariableBindings(buttonOne, buttonTwo, buttonThree, labelOne, labelTwo, labelThree);
    
    NSString *vfConstaint = @"V:|-[labelOne(18)]-[buttonOne(30)]-20-[labelTwo(18)]-[buttonTwo(30)]-20-[labelThree(18)]-[buttonThree(30)]";
    for (NSArray *constraint in @[
                    [NSLayoutConstraint constraintsWithVisualFormat:vfConstaint                       options:0 metrics:nil views:dictionary],
                    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[buttonOne(120)]-10-|"   options:0 metrics:nil views:dictionary],
                    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[buttonTwo(120)]-10-|"   options:0 metrics:nil views:dictionary],
                    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[buttonThree(120)]-10-|" options:0 metrics:nil views:dictionary],
                    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[labelOne]"              options:0 metrics:nil views:dictionary],
                    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[labelTwo]"              options:0 metrics:nil views:dictionary],
                    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[labelThree]"            options:0 metrics:nil views:dictionary]]) {
        [self addConstraints:constraint];
    }
    return _buttons;
}

@end

static CGFloat const kAnimationOffsetX = 180.0f;

@interface HDMenuViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *buttonList;
@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftGestureRecognizer;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *rightGestureRecognizer;

@property (nonatomic, setter=setGameInterfaceHidden:, assign) BOOL isGameInterfaceHidden;
@property (nonatomic, setter=setExpanded:, assign) BOOL isExpanded;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UIPushBehavior* pushBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;

@end

@implementation HDMenuViewController{
    BOOL _isExpanded;
    BOOL _isGameInterfaceHidden;
    
    NSDictionary *_dictionary;
    NSArray *_vLC;
}

@synthesize isExpanded = _isExpanded;
@synthesize isGameInterfaceHidden = _isGameInterfaceHidden;
- (instancetype)initWithRootViewController:(UIViewController *)controller
{
    NSParameterAssert(controller);
    if (self = [super init]) {
        [self setGameInterfaceHidden:NO];
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
    [self setGameInterfaceHidden:!_isGameInterfaceHidden];
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
    [self.pushBehavior setPushDirection:CGVectorMake(!self.isExpanded ? 35.0f : -35.0f , 0.0f)];
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
    self.buttonList = [NSMutableArray array];
    
    UILabel *title = [[UILabel alloc] init];
    [title setTranslatesAutoresizingMaskIntoConstraints:NO];
    [title setTextAlignment:NSTextAlignmentLeft];
    [title setText:@"HEXIT"];
    [title setFont:GILLSANS(24.0f)];
    [title setTextColor:[UIColor whiteColor]];
    [self.view addSubview:title];
    
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
        [self.buttonList addObject:button];
        [self.view addSubview:button];
    }
    
    HDSettingsContainer *container = [[HDSettingsContainer alloc] init];
    [container setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[[container settingButtons] firstObject] addTarget:self action:@selector(openURL:) forControlEvents:UIControlEventTouchUpInside];
    [[container settingButtons][1]            addTarget:self action:@selector(openURL:) forControlEvents:UIControlEventTouchUpInside];
    [[[container settingButtons] lastObject]  addTarget:self action:@selector(openURL:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:container];
    
    _dictionary = NSDictionaryOfVariableBindings(retry, map, title, container);
    
    NSArray *vCt = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-130-[retry]-20-[map(==retry)]"  options:0 metrics:nil views:_dictionary];
    NSArray *titleCX      = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[title]"               options:0 metrics:nil views:_dictionary];
    NSArray *titleCY      = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[title]-|"               options:0 metrics:nil views:_dictionary];
    NSArray *hMConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[map(140)]"         options:0 metrics:nil views:_dictionary];
    NSArray *hRConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[retry(==map)]"     options:0 metrics:nil views:_dictionary];
    NSArray *hCConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[container(==map)]" options:0 metrics:nil views:_dictionary];
    
    _vLC  = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[map]-20-[container(200)]" options:0 metrics:nil views:_dictionary];

    for (NSArray *constraint in @[vCt, _vLC, hMConstraint, hRConstraint, hCConstraint, titleCX, titleCY]) {
        [self.view addConstraints:constraint];
    }
}

- (void)_initalizeGestureRecognizers
{
     self.leftGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(_toggleHDMenuViewController:)];
    [self.leftGestureRecognizer setEdges:UIRectEdgeLeft];
    
    self.rightGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(_toggleHDMenuViewController:)];
    [self.rightGestureRecognizer setEdges:UIRectEdgeRight];
    
    for (UIScreenEdgePanGestureRecognizer *edge in @[self.leftGestureRecognizer, self.rightGestureRecognizer]) {
        [edge setDelegate:self];
        [self.rootViewController.view addGestureRecognizer:edge];
    }
}

- (void)_initalizePhysicsAnimators
{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
     self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.rootViewController.view]];
    [self.gravityBehavior setGravityDirection:CGVectorMake(-1, 0)];
    
     self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.rootViewController.view] mode:UIPushBehaviorModeInstantaneous];
    [self.pushBehavior setMagnitude:0.0f];
    [self.pushBehavior setAngle:0.0f];
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.rootViewController.view]];
    [collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, 0, 0, -kAnimationOffsetX)];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.rootViewController.view]];
    [itemBehavior setElasticity:.45f];
    
    for (id animators in @[self.gravityBehavior, self.pushBehavior, collisionBehavior, itemBehavior]) {
        [self.animator addBehavior:animators];
    }
}

#pragma mark -
#pragma mark - Override Setters

- (void)setGameInterfaceHidden:(BOOL)isGameInterfaceHidden
{
    if (_isGameInterfaceHidden == isGameInterfaceHidden) {
        return;
    }
    
    _isGameInterfaceHidden = isGameInterfaceHidden;
    
    if (_isGameInterfaceHidden) {
        [self _showInterfaceAnimated:YES];
    } else {
        [self _hideInterfaceAnimated:YES];
    }
}

#pragma mark -
#pragma mark - Animation

- (void)_hideInterfaceAnimated:(BOOL)animated
{
    [self.view removeConstraints:_vLC];
    
    _vLC  = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[container(200)]" options:0 metrics:nil views:_dictionary];
    
    [self.view addConstraints:_vLC];
    
    dispatch_block_t closeAnimation = ^{
        [self.view layoutSubviews];
    };
    
    if (!animated) {
        closeAnimation();
    } else {
        [UIView animateWithDuration:.3f
                         animations:closeAnimation
                         completion:nil];
    }
}

- (void)_showInterfaceAnimated:(BOOL)animated
{
    [self.view removeConstraints:_vLC];
    
    _vLC  = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[map]-20-[container(200)]" options:0 metrics:nil views:_dictionary];
    
    [self.view addConstraints:_vLC];
 
    dispatch_block_t expandAnimation = ^{
        [self.view layoutSubviews];
    };
    
    if (!animated) {
        expandAnimation();
    } else {
        [UIView animateWithDuration:.3f
                         animations:expandAnimation
                         completion:nil];
    }
}

@end

@implementation UIViewController (HDMenuViewController)

- (void)setFrontViewController:(UIViewController *)controller animated:(BOOL)animated
{
    NSParameterAssert(controller);
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
