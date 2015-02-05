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

const CGFloat TILE_DIVIDEN = 3.41;
const CGFloat TILE_COUNT = 7;
const CGFloat TILE_MULTIPLIER = .845f;

#define TILE_SIZE [[UIScreen mainScreen] bounds].size.width/TILE_DIVIDEN

@interface HDAlertNode ()
@property (nonatomic, strong) SKLabelNode  *descriptionLabel;
@property (nonatomic, strong) SKSpriteNode *star;
@end

@implementation HDAlertNode {
    NSArray *_descriptionArray;
    BOOL _isLastLevel;
}

- (instancetype)initWithSize:(CGSize)size lastLevel:(BOOL)lastLevel
{
    if (self = [super initWithColor:[SKColor flatMidnightBlueColor] size:size]) {
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
    CGFloat kPositionX[7];
    kPositionX[0] = -TILE_SIZE/2;
    kPositionX[1] = TILE_SIZE/2;
    kPositionX[2] = -TILE_SIZE;
    kPositionX[3] = 0.0f;
    kPositionX[4] = TILE_SIZE;
    kPositionX[5] = -TILE_SIZE/2;;
    kPositionX[6] = TILE_SIZE/2;
    
    CGFloat kPositionY[7];
    kPositionY[0] = -(TILE_SIZE*TILE_MULTIPLIER);
    kPositionY[1] = -(TILE_SIZE*TILE_MULTIPLIER);
    kPositionY[2] = 0.0f;
    kPositionY[3] = 0.0f;
    kPositionY[4] = 0.0f;
    kPositionY[5] = (TILE_SIZE*TILE_MULTIPLIER);
    kPositionY[6] = (TILE_SIZE*TILE_MULTIPLIER);
    
    for (NSUInteger i = 0; i < TILE_COUNT; i++) {
        SKSpriteNode *tile = [SKSpriteNode spriteNodeWithImageNamed:@"Alert-Rate-220"];
        tile.position = CGPointMake(kPositionX[i], kPositionY[i]);
        tile.scale    = CGRectGetWidth([[UIScreen mainScreen] bounds])/375.0f;
        tile.texture  = [SKTexture textureWithImageNamed:[self _textureForIndex:i]];
        tile.name     = [self _spriteNameForIndex:i];
        [self addChild:tile];
        
        if (i == 5) {
            [self _addLevelLabelToSuperView:tile];
        }
    }
    
    CGPoint descriptionCenter = CGPointMake(0.0f, -CGRectGetHeight(self.frame)/3);
    self.descriptionLabel = [SKLabelNode labelNodeWithText:[_descriptionArray objectAtIndex:arc4random() % _descriptionArray.count]];
    self.descriptionLabel.fontName  = @"GillSans";
    self.descriptionLabel.fontSize  = 26.0f;
    self.descriptionLabel.position  = descriptionCenter;
    self.descriptionLabel.fontColor = [SKColor whiteColor];
    self.descriptionLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    self.descriptionLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    self.descriptionLabel.scale = CGRectGetWidth([[UIScreen mainScreen] bounds])/375.0f;
    [self addChild:self.descriptionLabel];
    
    self.star = [SKSpriteNode spriteNodeWithImageNamed:@"CompletionStars"];
    self.star.position  = CGPointMake(0.0f, CGRectGetHeight(self.frame)/2.65f);
    self.star.scale     = 0.0f;
    [self addChild:self.star];
    
    self.scale = 0.0f;
}

- (void)_addLevelLabelToSuperView:(SKNode *)node
{
    self.levelLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans"];
    self.levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    self.levelLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    self.levelLabel.fontColor = [UIColor whiteColor];
    self.levelLabel.fontSize = TILE_SIZE/2.25f;
    self.levelLabel.scale = CGRectGetWidth([[UIScreen mainScreen] bounds])/375.0f;
    [node addChild:self.levelLabel];
}

- (NSString *)_textureForIndex:(NSUInteger)index
{
    NSArray *paths = @[@"Alert-Restart-220",
                       @"Alert-Next-220",
                       @"Alert-Leaderboard-220",
                       @"END-MIDDLE",
                       @"Alert-Rate-220",
                       @"Alert-Blank-220",
                       @"Alert-Share-220"];
    return paths[index];
}

- (NSString *)_spriteNameForIndex:(NSUInteger)index
{
    NSArray *paths = @[HDRestartLevelKey,
                       HDNextLevelKey,
                       HDGCLeaderboardKey,
                       @"blank",
                       HDRateKey,
                       @"title",
                       HDShareKey];
    return paths[index];
}

#pragma mark - Public

- (void)dismissWithCompletion:(dispatch_block_t)completion
{
    [self runAction:[SKAction scaleTo:0.0f duration:.3f] completion:^{
        [self removeFromParent];
        if (completion) {
            completion();
        }
    }];
}

- (void)show
{
    CGFloat scale = CGRectGetWidth([[UIScreen mainScreen] bounds])/375.0f;
    SKAction *scaleUpAction   = [SKAction scaleTo:scale + .4f duration:.4f];
    SKAction *scaleDownAction = [SKAction scaleTo:scale + .2f duration:.2f];
    
    [self runAction:[SKAction scaleTo:1.0f duration:.3f] completion:^{
        SKAction *sequenceAction  = [SKAction sequence:@[scaleUpAction, scaleDownAction]];
        [self.star runAction:sequenceAction];
        [[self childNodeWithName:@"blank"] runAction:sequenceAction];
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