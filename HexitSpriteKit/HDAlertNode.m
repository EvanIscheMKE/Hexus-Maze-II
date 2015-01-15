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
@property (nonatomic, strong) SKShapeNode  *star;
@property (nonatomic, strong) SKSpriteNode *nextButton;
@property (nonatomic, strong) SKSpriteNode *restartButton;
@property (nonatomic, strong) SKSpriteNode *stripe;
@property (nonatomic, strong) SKLabelNode  *descriptionLabel;
@end

@implementation HDAlertNode {
    NSArray *_descriptionArray;
    BOOL _isLastLevel;
}

- (instancetype)initWithSize:(CGSize)size lastLevel:(BOOL)lastLevel
{
    if (self = [super initWithColor:[UIColor colorWithWhite:0.0f alpha:.850f] size:size]) {
        
        self.userInteractionEnabled = YES;
        self.anchorPoint = CGPointMake(.5f, .5f);
        self.alpha = 0.0f;
        
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
    CGPoint position  = CGPointZero;
    if (!_isLastLevel) {
        
        position = CGPointMake(
                                CGRectGetWidth(self.frame)/4,
                               -(CGRectGetHeight(self.frame)/3.25f)
                               );
        
        UIImage *nextLevelImage = [self _nextLevelImageTexture];
        self.nextButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:nextLevelImage]];
        self.nextButton.name        = HDNextLevelKey;
        self.nextButton.anchorPoint = CGPointMake(0.5f, 0.5f);
        self.nextButton.position    = position;
        [self addChild:self.nextButton];
        
        position = CGPointMake(
                               -(CGRectGetWidth(self.frame)/4),
                               -(CGRectGetHeight(self.frame)/3.25f)
                               );
        
        UIImage *menuButtonImage = [self _restartButtonTexture];
        self.restartButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:menuButtonImage]];
        self.restartButton.name        = HDRestartLevelKey;
        self.restartButton.anchorPoint = CGPointMake(0.5f, 0.5f);
        self.restartButton.position    = position;
        [self addChild:self.restartButton];
        
    } else {
        UIImage *restartImage = [self _fullWidthRestartTexture];
        position = CGPointMake(0.0f, -(CGRectGetHeight(self.frame)/2));
        self.restartButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:restartImage]];
        self.restartButton.name        = HDRestartLevelKey;
        self.restartButton.anchorPoint = CGPointMake(0.5f, 0.5f);
        self.restartButton.position    = position;
        [self addChild:self.restartButton];
    }
    
    const CGFloat kStripeHeight = CGRectGetHeight(self.frame) / 6.5f;
    position = CGPointMake(0.0f, CGRectGetMaxY(self.restartButton.frame) + kStripeHeight/4);
    CGSize stripeSize = CGSizeMake(CGRectGetWidth(self.frame), kStripeHeight);
    self.stripe = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:stripeSize];
    self.stripe.position = position;
    [self addChild:self.stripe];
    
    const CGFloat kMargin = (CGRectGetWidth(self.stripe.frame) / 5.0f);
    NSArray *imagePaths = @[HDShareKey, HDGCLeaderboardKey, HDGCAchievementsKey, HDRateKey];
    for (int column = 0; column < 4; column++) {
        
        CGPoint nodePosition = CGPointMake( (-kMargin * 1.5f) + (column * kMargin), 0.0f);
        NSString *imagePath = [imagePaths objectAtIndex:column];
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:imagePath];
        node.name        = imagePath;
        node.anchorPoint = CGPointMake(.5f, .5f);
        node.position    = nodePosition;
        [self.stripe addChild:node];
    }
    
    const CGFloat kStarSize = CGRectGetHeight(self.frame) / 3.5f;
    CGPathRef middleStarPath = [HDHelper starPathForBounds:CGRectMake(0.0f, 0.0f, kStarSize, kStarSize)];
    self.star = [SKShapeNode shapeNodeWithPath:middleStarPath centered:YES];
    self.star.position  = CGPointMake(0.0f, 120.0f);
    self.star.scale     = 1.0f;
    self.star.strokeColor = [SKColor flatEmeraldColor];
    self.star.fillColor   = [SKColor flatEmeraldColor];
    [self addChild:self.star];
    
    CGPoint descriptionCenter = CGPointMake(0.0f, -20.0f);
    self.descriptionLabel = [SKLabelNode labelNodeWithText:[_descriptionArray objectAtIndex:arc4random() % _descriptionArray.count]];
    self.descriptionLabel.fontName  = @"GillSans";
    self.descriptionLabel.fontSize  = CGRectGetWidth(self.frame) / 14;
    self.descriptionLabel.position  = descriptionCenter;
    
    self.levelLabel = [[SKLabelNode alloc] initWithFontNamed:@"GillSans-Light"];
    self.levelLabel.position = CGPointMake(0.0f, 285.0f);
    self.levelLabel.fontSize = CGRectGetWidth(self.frame)/8;
    
    for (SKLabelNode *label in @[self.descriptionLabel, self.levelLabel]) {
        label.fontColor = [SKColor whiteColor];
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        label.verticalAlignmentMode   = SKLabelVerticalAlignmentModeCenter;
        [self addChild:label];
    }
    
}

#pragma mark - Public

- (void)dismissWithCompletion:(dispatch_block_t)completion
{
    SKAction *upAction      = [SKAction moveToY:15.0f duration:.300f];
    SKAction *downAction    = [SKAction moveToY:-CGRectGetHeight(self.frame) duration:upAction.duration];
    SKAction *sequeneAction = [SKAction sequence:@[upAction, downAction,]];
    
    upAction.timingMode   = SKActionTimingEaseIn;
    downAction.timingMode = upAction.timingMode;
    
    [self runAction:sequeneAction completion:^{
        [self removeFromParent];
        if (completion) {
            completion();
        }
    }];
}

- (void)show
{
    [self runAction:[SKAction fadeInWithDuration:.300f]];
    
    SKAction *scaleUpAction   = [SKAction scaleTo:1.2f duration:.400f];
    SKAction *scaleDownAction = [SKAction scaleTo:1.0f duration:.200f];
    SKAction *sequenceAction  = [SKAction sequence:@[scaleUpAction, scaleDownAction]];
    
    [self.star runAction:sequenceAction completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(alertNodeFinishedIntroAnimation:)]) {
            [self.delegate alertNodeFinishedIntroAnimation:self];
        }
    }];
}

#pragma mark - Images for textures

- (UIImage *)_fullWidthRestartTexture
{
    static UIImage *restartButton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CGRect imageFrame = CGRectMake(
                                       0.0f,
                                       0.0f,
                                       CGRectGetWidth(self.frame),
                                       CGRectGetHeight(self.frame) / 5.5f
                                       );
        
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, [[UIScreen mainScreen] scale]);
        
        UIBezierPath *button = [UIBezierPath bezierPathWithRoundedRect:imageFrame
                                                     byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight
                                                           cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        [button addClip];
        
        [[UIColor whiteColor] setStroke];
        
        CGPoint center = CGPointMake(CGRectGetWidth(imageFrame)/2, CGRectGetHeight(imageFrame)/2);
        UIBezierPath *circle = [HDHelper restartArrowAroundPoint:center];
        [circle stroke];
        
        restartButton = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return restartButton;
}

- (UIImage *)_restartButtonTexture
{
    static UIImage *menuButton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CGRect imageFrame = CGRectMake(
                                       0.0f,
                                       0.0f,
                                       CGRectGetWidth(self.frame)  / 2.0f,
                                       CGRectGetHeight(self.frame) / 5.5f
                                       );
        
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, [[UIScreen mainScreen] scale]);
        
        [[UIColor flatAlizarinColor] setStroke];
        
        CGPoint center = CGPointMake(CGRectGetWidth(imageFrame)/2, CGRectGetHeight(imageFrame)/2);
        UIBezierPath *circle = [HDHelper restartArrowAroundPoint:center];
        [circle stroke];
        
        menuButton = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return menuButton;
}

- (UIImage *)_nextLevelImageTexture
{
    static UIImage *nextLevel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CGRect imageFrame = CGRectMake(
                                       0.0f,
                                       0.0f,
                                       CGRectGetWidth(self.frame)  / 2.0f,
                                       CGRectGetHeight(self.frame) / 5.5f
                                       );
        
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, [[UIScreen mainScreen] scale]);
        
        const CGFloat endPoint   = CGRectGetWidth(imageFrame) - CGRectGetWidth(imageFrame)/3.0f;
        const CGFloat offset     = CGRectGetHeight(imageFrame) / 4;
        
        [[UIColor flatAlizarinColor] setStroke];
        
        UIBezierPath *rightArrow = [UIBezierPath bezierPath];
        rightArrow.lineWidth     = 8.0f;
        rightArrow.lineCapStyle  = kCGLineCapRound;
        rightArrow.lineJoinStyle = kCGLineJoinRound;
        
        [rightArrow moveToPoint:CGPointMake(5.0f, CGRectGetHeight(imageFrame)/2)];
        [rightArrow addLineToPoint:CGPointMake(endPoint, CGRectGetHeight(imageFrame)/2)];
        
        [rightArrow moveToPoint:   CGPointMake(endPoint - offset, CGRectGetHeight(imageFrame)/3.5f)];
        [rightArrow addLineToPoint:CGPointMake(endPoint, CGRectGetHeight(imageFrame)/2)];
        [rightArrow addLineToPoint:CGPointMake(endPoint - offset, CGRectGetHeight(imageFrame) - CGRectGetHeight(imageFrame)/3.5f)];
        [rightArrow stroke];
        
        nextLevel = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return nextLevel;
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
