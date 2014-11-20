//
//  HDBackViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/13/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDContainerViewController.h"
#import "HDRearViewController.h"
#import "UIColor+FlatColors.h"
#import "HDSettingsManager.h"

@implementation HDSettingsContainer
{
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
    [buttonOne setTag:0];
    [buttonOne setBackgroundImage:[UIImage imageNamed:@"_ToggleOnButton"]  forState:UIControlStateNormal];
    [buttonOne setBackgroundImage:[UIImage imageNamed:@"_ToggleOffButton"] forState:UIControlStateSelected];
    
    UIButton *buttonTwo = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonTwo setTag:1];
    [buttonTwo setBackgroundImage:[UIImage imageNamed:@"_ToggleOnButton"]  forState:UIControlStateNormal];
    [buttonTwo setBackgroundImage:[UIImage imageNamed:@"_ToggleOffButton"] forState:UIControlStateSelected];
    
    UIButton *buttonThree = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonThree setTag:2];
    [buttonThree setBackgroundImage:[UIImage imageNamed:@"_ToggleOnButton"]  forState:UIControlStateNormal];
    [buttonThree setBackgroundImage:[UIImage imageNamed:@"_ToggleOffButton"] forState:UIControlStateSelected];
    
    UILabel *labelOne = [[UILabel alloc] init];
    [labelOne setText:@"Effects"];
    [self addSubview:labelOne];
    
    UILabel *labelTwo = [[UILabel alloc] init];
    [labelTwo setText:@"Sound"];
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
        [selectors setAdjustsImageWhenHighlighted:NO];
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

@interface HDRearViewController ()
@property (nonatomic, strong) NSMutableArray *buttonList;
@end

@implementation HDRearViewController{
    NSDictionary *_dictionary;
    NSArray *_vLC;
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setDelegate:[HDSettingsManager sharedManager]];
    [self _layoutSideMenuSelectors];
    [self.view setBackgroundColor:[UIColor flatPeterRiverColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_layoutSideMenuSelectors
{
    
    UILabel *title = [[UILabel alloc] init];
    [title setTranslatesAutoresizingMaskIntoConstraints:NO];
    [title setTextAlignment:NSTextAlignmentLeft];
    [title setText:@"HEXUS"];
    [title setFont:GILLSANS(24.0f)];
    [title setTextColor:[UIColor whiteColor]];
    [self.view addSubview:title];
    
    UIButton *retry = [UIButton buttonWithType:UIButtonTypeCustom];
    [retry setTitle:@"Retry" forState:UIControlStateNormal];
    [retry setBackgroundColor:[UIColor flatTurquoiseColor]];
    [retry addTarget:ADelegate action:@selector(restartCurrentLevel) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *map = [UIButton buttonWithType:UIButtonTypeCustom];
    [map setBackgroundColor:[UIColor flatEmeraldColor]];
    [map setTitle:@"Map" forState:UIControlStateNormal];
    [map addTarget:ADelegate action:@selector(navigateToLevelMap) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *button in @[retry, map]) {
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [[button titleLabel] setFont:GILLSANS_LIGHT(20.0f)];
        [[button titleLabel] setTextAlignment:NSTextAlignmentCenter];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.layer setCornerRadius:10.0f];
        [self.view addSubview:button];
    }
    
     self.container = [[HDSettingsContainer alloc] init];
    [self.container setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.container];
    
    _dictionary = @{ @"retry":retry, @"map":map, @"title":title, @"container":self.container };
    
    NSArray *vCt = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-130-[retry(40)]-20-[map(==retry)]"
                                                           options:0
                                                           metrics:nil
                                                             views:_dictionary];
    NSArray *titleCX      = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[title]"               options:0 metrics:nil views:_dictionary];
    NSArray *titleCY      = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[title]-|"               options:0 metrics:nil views:_dictionary];
    NSArray *hMConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[map(140)]"         options:0 metrics:nil views:_dictionary];
    NSArray *hRConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[retry(==map)]"     options:0 metrics:nil views:_dictionary];
    NSArray *hCConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[container(==map)]" options:0 metrics:nil views:_dictionary];
    
    _vLC  = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[container(200)]" options:0 metrics:nil views:_dictionary];
    
    for (NSArray *constraint in @[vCt, _vLC, hMConstraint, hRConstraint, hCConstraint, titleCX, titleCY]) {
        [self.view addConstraints:constraint];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(layoutToggleSwitchesForSettingsFromArray:)]) {
        [self.delegate layoutToggleSwitchesForSettingsFromArray:self.container.settingButtons];
    }
}

- (void)hideGameInterfaceAnimated:(BOOL)animated
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

- (void)showGameInterfaceAnimated:(BOOL)animated
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
