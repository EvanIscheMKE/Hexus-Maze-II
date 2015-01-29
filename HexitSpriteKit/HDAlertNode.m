//
//  HDAlertNode.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/22/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDAlertNode.h"
#import "SKEmitterNode+EmitterAdditions.h"
#import "SKColor+HDColor.h"

NSString * const HDNextLevelKey       = @"nextLevelKey";
NSString * const HDRestartLevelKey    = @"restartKeY";
NSString * const HDShareKey           = @"Share";
NSString * const HDGCLeaderboardKey   = @"leaderboard";
NSString * const HDRateKey            = @"heart";
NSString * const HDGCAchievementsKey  = @"Achievements";

static const CGFloat cornerRadius = 15.0f;
@interface HDAlertNode ()
@property (nonatomic, strong) SKSpriteNode *star;
@property (nonatomic, strong) SKSpriteNode *menuView;
@property (nonatomic, strong) SKSpriteNode *nextButton;
@property (nonatomic, strong) SKSpriteNode *restartButton;
@property (nonatomic, strong) SKLabelNode *descriptionLabel;
@end

@implementation HDAlertNode {
    NSArray *_descriptionArray;
    BOOL _isLastLevel;
}

- (instancetype)initWithSize:(CGSize)size lastLevel:(BOOL)lastLevel
{
    if (self = [super initWithColor:[UIColor colorWithWhite:0.0f alpha:.4f] size:size]) {
        
        self.userInteractionEnabled = YES;
        self.anchorPoint = CGPointMake(.5f, .5f);
        
        _isLastLevel = lastLevel;
        _descriptionArray = @[NSLocalizedString(@"congratulation1", nil),
                              NSLocalizedString(@"congratulation2", nil),
                              NSLocalizedString(@"congratulation3", nil),
                              NSLocalizedString(@"congratulation4", nil),
                              NSLocalizedString(@"congratulation5", nil),
                              NSLocalizedString(@"congratulation6", nil),
                              NSLocalizedString(@"congratulation7", nil),
                              NSLocalizedString(@"congratulation8", nil),
                              NSLocalizedString(@"congratulation9", nil),
                              NSLocalizedString(@"congratulation10", nil),
                              NSLocalizedString(@"congratulation11", nil)];
        
        [self _setup];
    }
    return self;
}

#pragma mark - Private

- (void)_setup
{
    self.menuView = [SKSpriteNode spriteNodeWithImageNamed:@"AlertNodeTexture"];
    self.menuView.position = CGPointMake(0.0f, CGRectGetHeight(self.frame));
    self.menuView.scale = CGRectGetWidth(self.frame)/375;
    [self addChild:self.menuView];
    
//    CGPoint position = CGPointZero;
//    CGFloat buttonHeight = CGRectGetHeight(self.menuView.frame) / 5.5f;
//    if (!_isLastLevel) {
//        
//        position = CGPointMake(
//                               CGRectGetWidth(self.menuView.frame)/2  - CGRectGetWidth(self.menuView.frame)/1.5,
//                               -(CGRectGetHeight(self.menuView.frame)/2 - buttonHeight/2)
//                               );
//        
//        UIImage *nextLevelImage = [self _nextLevelImageTexture];
//        self.nextButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:nextLevelImage]];
//        self.nextButton.name        = HDNextLevelKey;
//        self.nextButton.anchorPoint = CGPointMake(.0f, .5f);
//        self.nextButton.position    = position;
//      //  [self.menuView addChild:self.nextButton];
//        
//        position = CGPointMake(
//                               -(CGRectGetWidth(self.menuView.frame)/2),
//                               -(CGRectGetHeight(self.menuView.frame)/2 - buttonHeight/2)
//                               );
//        
//        UIImage *menuButtonImage = [self _restartButtonTexture];
//        self.restartButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:menuButtonImage]];
//        self.restartButton.name        = HDRestartLevelKey;
//        self.restartButton.anchorPoint = CGPointMake(.0f, .5f);
//        self.restartButton.position    = position;
//      //  [self.menuView addChild:self.restartButton];
//        
//    } else {
//        position = CGPointMake(0.0f, -(CGRectGetHeight(self.menuView.frame)/2 - buttonHeight/2));
//        self.restartButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:restartImage]];
//        self.restartButton.name        = HDRestartLevelKey;
//        self.restartButton.position    = position;
//        [self.menuView addChild:self.restartButton];
//    }
    
    const CGFloat kSpacing = CGRectGetWidth(self.frame) / 5;
    NSArray *imagePaths = @[HDShareKey, HDGCLeaderboardKey, HDGCAchievementsKey, HDRateKey];
    for (int column = 0; column < 4; column++) {
        
        CGPoint nodePosition = CGPointMake( (-kSpacing * 1.5f) + (column * kSpacing), -105);
        NSString *imagePath = [imagePaths objectAtIndex:column];
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:imagePath];
        node.name        = imagePath;
        node.position    = nodePosition;
        [self.menuView addChild:node];
    }
    
    CGPoint descriptionCenter = CGPointMake(0.0f, 0.0f);
    self.descriptionLabel = [SKLabelNode labelNodeWithText:[_descriptionArray objectAtIndex:arc4random() % _descriptionArray.count]];
    self.descriptionLabel.fontName  = @"GillSans-Light";
    self.descriptionLabel.fontSize  = CGRectGetWidth(self.frame) / 21;
    self.descriptionLabel.position  = descriptionCenter;
    
    self.levelLabel = [[SKLabelNode alloc] initWithFontNamed:@"GillSans"];
    self.levelLabel.position = CGPointMake(0.0f, CGRectGetHeight(self.menuView.frame) / 2.2f);
    self.levelLabel.fontSize = 24.0f;
    
    for (SKLabelNode *label in @[self.descriptionLabel, self.levelLabel]) {
        label.fontColor = [SKColor flatWetAsphaltColor];
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [self.menuView addChild:label];
    }
}

#pragma mark - Public

- (void)dismissWithCompletion:(dispatch_block_t)completion
{
    SKAction *upAction      = [SKAction moveToY:15.0f duration:.3f];
    SKAction *downAction    = [SKAction moveToY:-CGRectGetHeight(self.frame) duration:upAction.duration];
    SKAction *sequeneAction = [SKAction sequence:@[upAction, downAction,]];
    
    upAction.timingMode   = SKActionTimingEaseIn;
    downAction.timingMode = upAction.timingMode;
    
    [self.menuView runAction:sequeneAction completion:^{
        [self removeFromParent];
        if (completion) {
            completion();
        }
    }];
}

- (void)show
{
    SKAction *positionAction = [SKAction moveToY:0.0f duration:.5f];
    [self.menuView runAction:positionAction completion:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(alertNodeFinishedIntroAnimation:)]) {
                [self.delegate alertNodeFinishedIntroAnimation:self];
            }
        }];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch   = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKNode *node = [self nodeAtPoint:location];
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertNode:clickedButtonWithTitle:)]) {
        if ([node.name isEqualToString:HDNextLevelKey]||[node.name isEqualToString:HDRestartLevelKey]) {
            [self dismissWithCompletion:^{
                [self.delegate alertNode:self clickedButtonWithTitle:node.name];
            }];
        } else {
            [self.delegate alertNode:self clickedButtonWithTitle:node.name];
        }
    }
}

@end
