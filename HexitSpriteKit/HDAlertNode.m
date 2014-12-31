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

NSString * const NEXTLEVELKEY     = @"nextLevelKey";
NSString * const RESTARTKEY       = @"restartKeY";
NSString * const SHAREKEY         = @"Share";
NSString * const LEADERBOARDKEY   = @"leaderboard";
NSString * const RATEKEY          = @"heart";
NSString * const ACHIEVEMENTSKEY  = @"Achievements";

@interface HDAlertNode ()

@property (nonatomic, strong) SKShapeNode *star;
@property (nonatomic, strong) SKShapeNode *menuView;

@property (nonatomic, strong) SKSpriteNode *rightButton;
@property (nonatomic, strong) SKSpriteNode *leftButton;
@property (nonatomic, strong) SKSpriteNode *stripe;

@property (nonatomic, strong) SKLabelNode *descriptionLabel;

@end

@implementation HDAlertNode {
    NSArray *_descriptionArray;
    BOOL _isLastLevel;
}

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size lastLevel:(BOOL)lastLevel
{
    if (self = [super initWithColor:color size:size]) {
        
        self.userInteractionEnabled = YES;
        self.anchorPoint = CGPointMake(.5f, .5f);
        
        NSLog(lastLevel ? @"YES" : @"NO");
        
        _isLastLevel = lastLevel;
        _descriptionArray = @[@"Now you have it!",
                              @"You make it look easy.",
                              @"You're learning fast.",
                              @"That's the way!",
                              @"PERFECT!",
                              @"SENSATIONAL!",
                              @"You're doing beautifully.",
                              @"Good thinking!",
                              @"You've just about mastered that!",
                              @"GOOD WORK!",
                              @"Now that's what I call a fine job!"];
        
        [self _setup];
    }
    return self;
}

#pragma mark - Private

- (void)_setup
{
    CGRect containerFrame = CGRectInset(self.frame, CGRectGetWidth(self.frame)/15, CGRectGetHeight(self.frame)/6);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:containerFrame cornerRadius:15.0f];
    self.menuView = [SKShapeNode shapeNodeWithPath:[path CGPath] centered:YES];
    self.menuView.position    = CGPointMake(0.0f, CGRectGetHeight(self.frame));
    self.menuView.antialiased = YES;
    self.menuView.fillColor   = [[SKColor flatCloudsColor] colorWithAlphaComponent:1.0f];
    self.menuView.lineWidth   = 0;
    self.menuView.zPosition   = 100.0f;
    [self addChild:self.menuView];
    
    CGPoint position = CGPointZero;
    CGFloat buttonHeight = CGRectGetHeight(self.menuView.frame) / 4.25f;
    if (!_isLastLevel) {
        
        position = CGPointMake(
                               CGRectGetWidth(self.menuView.frame)/2  - CGRectGetWidth(self.menuView.frame)/1.5,
                               -(CGRectGetHeight(self.menuView.frame)/2 - buttonHeight/2)
                               );
        
        UIImage *nextLevelImage = [self _nextLevelImageTexture];
        self.rightButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:nextLevelImage]];
        self.rightButton.name        = NEXTLEVELKEY;
        self.rightButton.anchorPoint = CGPointMake(.0f, .5f);
        self.rightButton.position    = position;
        [self.menuView addChild:self.rightButton];
        
        position = CGPointMake(
                               -(CGRectGetWidth(self.menuView.frame)/2),
                               -(CGRectGetHeight(self.menuView.frame)/2 - buttonHeight/2)
                               );
        
        UIImage *menuButtonImage = [self _restartButtonTexture];
        self.leftButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:menuButtonImage]];
        self.leftButton.name        = RESTARTKEY;
        self.leftButton.anchorPoint = CGPointMake(.0f, .5f);
        self.leftButton.position    = position;
        [self.menuView addChild:self.leftButton];
        
    } else {
        
        UIImage *restartImage = [self _fullWidthRestartTexture];
        
        position = CGPointMake(0.0f, -(CGRectGetHeight(self.menuView.frame)/2 - buttonHeight));
        self.leftButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:restartImage]];
        self.leftButton.name        = RESTARTKEY;
        self.leftButton.position    = position;
        [self.menuView addChild:self.leftButton];
        
    }
    
    const CGFloat kStripeHeight = CGRectGetHeight(self.menuView.frame) / 6.5f;
    
    position = CGPointMake(0.0f, CGRectGetMaxY(self.leftButton.frame) + kStripeHeight / 2 );
    CGSize stripeSize = CGSizeMake(CGRectGetWidth(self.menuView.frame), kStripeHeight);
    self.stripe = [SKSpriteNode spriteNodeWithColor:[SKColor flatAsbestosColor] size:stripeSize];
    self.stripe.name     = RESTARTKEY;
    self.stripe.position = position;
    [self.menuView addChild:self.stripe];
    
    const CGFloat kMargin   = (CGRectGetWidth(self.stripe.frame) / 5.0);
    NSArray *imagePaths = @[SHAREKEY, LEADERBOARDKEY, ACHIEVEMENTSKEY, RATEKEY];
    for (int column = 0; column < 4; column++) {
        
        CGPoint nodePosition = CGPointMake( (-kMargin * 1.5f) + (column * kMargin), 0.0f);
        NSString *imagePath = [imagePaths objectAtIndex:column];
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:imagePath];
        node.name        = imagePath;
        node.anchorPoint = CGPointMake(.5f, .5f);
        node.position    = nodePosition;
        [self.stripe addChild:node];
    }
    
    CGPoint descriptionCenter = CGPointMake(0.0f, CGRectGetMaxY(self.stripe.frame) + 12.0f);
    self.descriptionLabel = [SKLabelNode labelNodeWithText:[_descriptionArray objectAtIndex:arc4random() % _descriptionArray.count]];
    self.descriptionLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    self.descriptionLabel.verticalAlignmentMode   = SKLabelVerticalAlignmentModeCenter;
    self.descriptionLabel.fontColor = [SKColor flatMidnightBlueColor];
    self.descriptionLabel.fontName  = @"GillSans";
    self.descriptionLabel.fontSize  = CGRectGetWidth(self.frame) / 21;
    self.descriptionLabel.position  = descriptionCenter;
    [self.menuView addChild:self.descriptionLabel];
    
    self.levelLabel = [[SKLabelNode alloc] initWithFontNamed:@"GillSans-Light"];
    self.levelLabel.position = CGPointMake(0.0f, CGRectGetHeight(self.menuView.frame) / 2.4f);
    self.levelLabel.fontSize = CGRectGetWidth(self.frame)/14;
    self.levelLabel.fontColor = [SKColor flatMidnightBlueColor];
    self.levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    self.levelLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
    [self.menuView addChild:self.levelLabel];
    
    const CGFloat kStarSize = CGRectGetHeight(self.frame)/4.5f;
    CGPathRef middleStarPath = [HDHelper starPathForBounds:CGRectMake(0.0f, 0.0, kStarSize, kStarSize)];
    self.star = [SKShapeNode shapeNodeWithPath:middleStarPath centered:YES];
    self.star.position = CGPointMake(0.0f, CGRectGetHeight(self.menuView.frame)/5.25);
    self.star.scale = 0.0f;
    self.star.fillColor = [SKColor flatEmeraldColor];
    [self.menuView addChild:self.star];
}

#pragma mark - Public

- (void)dismissWithCompletion:(dispatch_block_t)completion
{
    SKAction *upAction      = [SKAction moveToY:15.0f duration:.3f];
    SKAction *downAction    = [SKAction moveToY:-CGRectGetHeight(self.frame) duration:.3f];
    SKAction *sequeneAction = [SKAction sequence:@[upAction, downAction]];
    
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
    [self.menuView runAction:[SKAction moveToY:0.0f duration:.5f] completion:^{
        [self.star runAction:[SKAction sequence:@[[SKAction scaleTo:1.2 duration:.4f],[SKAction scaleTo:1.0f duration:.2f]]] completion:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(alertNodeFinishedIntroAnimation:)]) {
                [self.delegate alertNodeFinishedIntroAnimation:self];
            }
        }];
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
                                       CGRectGetWidth(self.menuView.frame),
                                       CGRectGetHeight(self.menuView.frame) / 4.25f
                                       );
        
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, [[UIScreen mainScreen] scale]);
        
        UIBezierPath *button = [UIBezierPath bezierPathWithRoundedRect:imageFrame
                                                     byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight
                                                           cornerRadii:CGSizeMake(15.0f, 15.0f)];
        [button addClip];
        
        [[UIColor flatEmeraldColor] setStroke];
        
        CGPoint center = CGPointMake(CGRectGetWidth(imageFrame)/2, CGRectGetHeight(imageFrame)/2);
        UIBezierPath *circle = [self _restartArrowArounndPoint:center];
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
                                       CGRectGetWidth(self.menuView.frame) / 3,
                                       CGRectGetHeight(self.menuView.frame) / 4.25f
                                       );
        
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, [[UIScreen mainScreen] scale]);
        
        UIBezierPath *button = [UIBezierPath bezierPathWithRoundedRect:imageFrame
                                                     byRoundingCorners:UIRectCornerBottomLeft
                                                           cornerRadii:CGSizeMake(15.0f, 15.0f)];
        [button addClip];
        
        [[UIColor flatEmeraldColor] setStroke];
        
        CGPoint center = CGPointMake(CGRectGetWidth(imageFrame)/2, CGRectGetHeight(imageFrame)/2);
        UIBezierPath *circle = [self _restartArrowArounndPoint:center];
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
                                       CGRectGetWidth(self.menuView.frame) / 1.5,
                                       CGRectGetHeight(self.menuView.frame) / 4.25f
                                       );
        
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, [[UIScreen mainScreen] scale]);
        
        [[UIColor flatEmeraldColor] setFill];
        UIBezierPath *button = [UIBezierPath bezierPathWithRoundedRect:imageFrame
                                                     byRoundingCorners:UIRectCornerBottomRight
                                                           cornerRadii:CGSizeMake(15.0f, 15.0f)];
        [button fill];
        [button addClip];
        
        const CGFloat startPoint = CGRectGetWidth(imageFrame)/2 - CGRectGetWidth(imageFrame)/6;
        const CGFloat endPoint   = CGRectGetWidth(imageFrame)/2 + CGRectGetWidth(imageFrame)/6;
        const CGFloat offset     = CGRectGetHeight(imageFrame)/4;
        
        [[UIColor whiteColor] setStroke];
        
        UIBezierPath *rightArrow = [UIBezierPath bezierPath];
        rightArrow.lineWidth     = 8.0f;
        rightArrow.lineCapStyle  = kCGLineCapRound;
        rightArrow.lineJoinStyle = kCGLineJoinRound;
        
        [rightArrow moveToPoint:CGPointMake(startPoint,  CGRectGetHeight(imageFrame)/2)];
        [rightArrow addLineToPoint:CGPointMake(endPoint, CGRectGetHeight(imageFrame)/2)];
        
        [rightArrow moveToPoint:   CGPointMake(endPoint - offset, offset)];
        [rightArrow addLineToPoint:CGPointMake(endPoint, CGRectGetHeight(imageFrame)/2)];
        [rightArrow addLineToPoint:CGPointMake(endPoint - offset, CGRectGetHeight(imageFrame) - offset)];
        
        [rightArrow stroke];
        
        nextLevel = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return nextLevel;
}

#pragma mark - UIBezierPath

- (UIBezierPath *)_restartArrowArounndPoint:(CGPoint)center
{
    const CGFloat offset = center.y * 2 / 4 /* Multiply the the center.y by 2 to get the height of container*/;
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:center
                                                          radius:offset
                                                      startAngle:DEGREES_RADIANS(330.0f)
                                                        endAngle:DEGREES_RADIANS(290.0f)
                                                       clockwise:YES];
    circle.lineCapStyle  = kCGLineCapRound;
    circle.lineJoinStyle = kCGLineJoinRound;
    circle.lineWidth     = 8.0f;
    
    CGPoint endPoint = circle.currentPoint;
    [circle addLineToPoint:CGPointMake(endPoint.x - offset/2, endPoint.y + offset/2.0f)];
    [circle moveToPoint:endPoint];
    [circle addLineToPoint:CGPointMake(endPoint.x - offset/2, endPoint.y - offset/1.85f)];
    
    return circle;
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch   = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKNode *node = [self nodeAtPoint:location];
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertNode:clickedButtonWithTitle:)]) {
        if ([node.name isEqualToString:NEXTLEVELKEY]||[node.name isEqualToString:RESTARTKEY]) {
            [self dismissWithCompletion:^{
                [self.delegate alertNode:self clickedButtonWithTitle:node.name];
            }];
        } else {
            [self.delegate alertNode:self clickedButtonWithTitle:node.name];
        }
    }
}

@end
