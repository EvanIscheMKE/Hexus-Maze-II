//
//  HDAlertNode.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/22/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDAlertNode.h"
#import "SKColor+HDColor.h"
#import "UIColor+FlatColors.h"

NSString * const RIGHT_BUTTON_KEY = @"RightButtonKey";
NSString * const LEFT_BUTTON_KEY  = @"LeftButtonKey";

NSString * const SHAREIMAGE        = @"Share";
NSString * const LEADERBOARDIMAGE  = @"leaderboard";
NSString * const RATEIMAGE         = @"heart";
NSString * const ACHIEVEMENTS      = @"Achievements";

@interface HDAlertNode ()

@property (nonatomic, strong) SKShapeNode *star;
@property (nonatomic, strong) SKShapeNode *container;

@property (nonatomic, strong) SKSpriteNode *rightButton;
@property (nonatomic, strong) SKSpriteNode *leftButton;
@property (nonatomic, strong) SKSpriteNode *stripe;

@property (nonatomic, strong) SKLabelNode *descriptionLabel;

@end

@implementation HDAlertNode {
    NSArray *_descriptionArray;
}

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size]) {
        
        [self setAnchorPoint:CGPointMake(.5f, .5f)];
        [self setUserInteractionEnabled:YES];
        
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
        
        CGRect containerFrame = CGRectInset(self.frame, CGRectGetWidth(self.frame)/15, CGRectGetHeight(self.frame)/6);
        self.container = [SKShapeNode shapeNodeWithPath:[[UIBezierPath bezierPathWithRoundedRect:containerFrame cornerRadius:15.0f] CGPath]
                                               centered:YES];
        [self.container setPosition:CGPointMake(CGRectGetWidth(self.frame), 0.0f)];
        [self.container setAntialiased:YES];
        [self.container setFillColor:[[SKColor flatCloudsColor] colorWithAlphaComponent:1.0f]];
        [self.container setLineWidth:0];
        [self.container setZPosition:100.0f];
        [self addChild:self.container];
        
        [self _layoutMenuButtons];
        [self _layoutDisplayBar];
        [self _layoutLabels];
        [self _layoutStarProgressNodes];
        
    }
    return self;
}

#pragma mark -
#pragma mark - < PUBLIC >

- (void)show
{
    [self.container runAction:[SKAction moveToX:0.0f duration:.3f] completion:^{
        [self.star runAction:[SKAction sequence:@[[SKAction scaleTo:1.2 duration:.4f],[SKAction scaleTo:1.0f duration:.2f]]]];
    }];
}

- (void)dismissWithCompletion:(dispatch_block_t)completion
{
    [self.container runAction:[SKAction moveToX:CGRectGetWidth(self.frame) duration:.3f] completion:^{
        [self removeFromParent];
        if (completion) {
            completion();
        }
    }];
}

#pragma mark -
#pragma mark - <PRIVATE>

- (void)_layoutStarProgressNodes
{
    const CGFloat kStarSize = CGRectGetHeight(self.frame)/4.5f;
    CGPathRef middleStarPath = [HDHelper starPathForBounds:CGRectMake(0.0f, 0.0, kStarSize, kStarSize)];
    self.star = [SKShapeNode shapeNodeWithPath:middleStarPath centered:YES];
    [self.star setPosition:CGPointMake(0.0f, CGRectGetHeight(self.container.frame)/5.25)];
    [self.star setStrokeColor:[SKColor flatEmeraldColor]];
    [self.star setScale:0.0f];
    [self.star setLineWidth:2.0f];
    [self.star setFillColor:[SKColor flatEmeraldColor]];
    [self.container addChild:self.star];
}

- (void)_layoutMenuButtons
{
    UIImage *nextLevelImage = [self _nextLevelImageTexture];
    self.rightButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:nextLevelImage]];
    [self.rightButton setName:RIGHT_BUTTON_KEY];
    [self.rightButton setAnchorPoint:CGPointMake(.0f, .5f)];
    [self.rightButton setPosition:CGPointMake(CGRectGetWidth(self.container.frame)/2  - CGRectGetWidth(self.container.frame)/1.5,
                                              -(CGRectGetHeight(self.container.frame)/2 - nextLevelImage.size.height/2))];
    [self.container addChild:self.rightButton];
    
    UIImage *menuButtonImage = [self _restartButtonTexture];
    self.leftButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:menuButtonImage]];
    [self.leftButton setName:LEFT_BUTTON_KEY];
    [self.leftButton setAnchorPoint:CGPointMake(.0f, .5f)];
    [self.leftButton setPosition:CGPointMake( -(CGRectGetWidth(self.container.frame)/2),
                                             -(CGRectGetHeight(self.container.frame)/2 - nextLevelImage.size.height/2))];
    [self.container addChild:self.leftButton];
}

- (void)_layoutDisplayBar
{
    const CGFloat kStripeHeight = CGRectGetHeight(self.container.frame) / 6.5f;
    CGPoint stripePosition = CGPointMake(0.0f, CGRectGetMaxY(self.rightButton.frame) + kStripeHeight/2);
    self.stripe = [SKSpriteNode spriteNodeWithColor:[SKColor flatAsbestosColor]
                                               size:CGSizeMake(CGRectGetWidth(self.container.frame), kStripeHeight)];
    [self.stripe setName:LEFT_BUTTON_KEY];
    [self.stripe setPosition:stripePosition];
    [self.container addChild:self.stripe];
    
    const CGFloat kMargin   = CGRectGetWidth(self.stripe.frame) / 5;
    for (int column = 0; column < 4; column++) {
        
        NSString *imagePath = [@[SHAREIMAGE, LEADERBOARDIMAGE, ACHIEVEMENTS, RATEIMAGE] objectAtIndex:column];
        
        CGPoint nodePosition = CGPointMake((-kMargin * 1.5f) + (column * kMargin), 0.0f);
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:imagePath];
        [node setName:imagePath];
        [node setAnchorPoint:CGPointMake(.5f, .5f)];
        [node setPosition:nodePosition];
        [self.stripe addChild:node];
    }
}

- (void)_layoutLabels
{
    CGPoint descriptionCenter = CGPointMake(0.0f, CGRectGetMaxY(self.stripe.frame) + 12.0f);
    self.descriptionLabel = [SKLabelNode labelNodeWithText:[_descriptionArray objectAtIndex:arc4random() % _descriptionArray.count]];
    [self.descriptionLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    [self.descriptionLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [self.descriptionLabel setFontColor:[SKColor flatMidnightBlueColor]];
    [self.descriptionLabel setFontName:@"GillSans"];
    [self.descriptionLabel setFontSize:18.0f];
    [self.descriptionLabel setPosition:descriptionCenter];
    [self.container addChild:self.descriptionLabel];
    
    self.levelLabel = [[SKLabelNode alloc] initWithFontNamed:@"GillSans-Light"];
    [self.levelLabel setPosition:CGPointMake(0.0f, CGRectGetHeight(self.container.frame) / 2.5f)];
    [self.levelLabel setFontSize:28.0f];
    [self.levelLabel setFontColor:[SKColor flatMidnightBlueColor]];
    [self.levelLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    [self.levelLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeBottom];
    [self.container addChild:self.levelLabel];
}

#pragma mark -
#pragma mark - images for textures

- (UIImage *)_restartButtonTexture
{
    static UIImage *menuButton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CGRect imageFrame = CGRectMake(
                                       0.0f,
                                       0.0f,
                                       CGRectGetWidth(self.container.frame) / 3,
                                       CGRectGetHeight(self.container.frame) / 4.25f
                                       );
        
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, [[UIScreen mainScreen] scale]);
        
        
        UIBezierPath *button = [UIBezierPath bezierPathWithRoundedRect:imageFrame
                                                     byRoundingCorners:UIRectCornerBottomLeft
                                                           cornerRadii:CGSizeMake(15.0f, 15.0f)];
        [button addClip];
        
        [[UIColor flatEmeraldColor] setStroke];
        [[UIColor flatEmeraldColor] setFill];
        
        const CGFloat lineWidth = 8.0f;
        const CGFloat offset = CGRectGetHeight(imageFrame)/4;
        
        UIBezierPath *arrow  = [UIBezierPath bezierPath];
        UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(imageFrame)/2, CGRectGetHeight(imageFrame)/2)
                                                              radius:offset
                                                          startAngle:DEGREES_RADIANS(10.0f)
                                                            endAngle:DEGREES_RADIANS(320.0f)
                                                           clockwise:YES];
        [circle setLineCapStyle:kCGLineCapRound];
        [circle setLineWidth:lineWidth];
        [arrow moveToPoint:CGPointMake(CGRectGetWidth(imageFrame) - 25.0f, 25.0f)];
        [arrow addLineToPoint:CGPointMake(CGRectGetWidth(imageFrame)/2 + 8.0f, CGRectGetHeight(imageFrame)/2 - 8.0f)];
        [arrow addLineToPoint:CGPointMake(CGRectGetWidth(imageFrame) - 25.0f, CGRectGetHeight(imageFrame)/2 - 8.0f)];
        [arrow closePath];
        [circle stroke];
        [arrow fill];
        
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
                                       CGRectGetWidth(self.container.frame) / 1.5,
                                       CGRectGetHeight(self.container.frame) / 4.25f
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
        [rightArrow setLineWidth:8.0f];
        [rightArrow setLineCapStyle:kCGLineCapRound];
        
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

#pragma mark -
#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch   = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKNode *node = [self nodeAtPoint:location];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertNode:clickedButtonAtIndex:)]) {
        if ([node.name isEqualToString:RIGHT_BUTTON_KEY]) {
            [self.delegate alertNodeWillDismiss:self];
            [self dismissWithCompletion:^{
                [self.delegate alertNode:self clickedButtonAtIndex:0];
            }];
        } else if ([node.name isEqualToString:LEFT_BUTTON_KEY]) {
            [self.delegate alertNodeWillDismiss:self];
            [self dismissWithCompletion:^{
                [self.delegate alertNode:self clickedButtonAtIndex:1];
            }];
        } else if ([node.name isEqualToString:SHAREIMAGE]) {
            [ADelegate presentShareViewController];
        } else if ([node.name isEqualToString:ACHIEVEMENTS]) {
            [ADelegate presentGameCenterControllerForState:GKGameCenterViewControllerStateAchievements];
        } else if ([node.name isEqualToString:LEADERBOARDIMAGE]) {
            [ADelegate presentGameCenterControllerForState:GKGameCenterViewControllerStateLeaderboards];
        } else if ([node.name isEqualToString:RATEIMAGE]) {
            [ADelegate rateHEXUS];
        }
    }
}

@end
