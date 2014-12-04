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

@interface HDAlertNode ()
@property (nonatomic, strong) SKShapeNode *container;
@property (nonatomic, strong) SKShapeNode *topButton;
@property (nonatomic, strong) SKShapeNode *bottomButton;
@end

@implementation HDAlertNode

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size]) {
        
        [self setAnchorPoint:CGPointMake(.5f, .5f)];
        [self setUserInteractionEnabled:YES];
        
        CGRect containerFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame)-20.0f, CGRectGetWidth(self.frame)-20.0f);
         self.container = [SKShapeNode shapeNodeWithPath:[HDHelper hexagonPathForBounds:containerFrame] centered:YES];
        [self.container setPosition:CGPointMake(CGRectGetWidth(self.frame), 0.0f)];
        [self.container setFillColor:[SKColor flatAsbestosColor]];
        [self.container setLineWidth:0];
        [self.container setZPosition:100.0f];
        [self addChild:self.container];
        
        CGRect topButtonFrame = CGRectMake(0.0f, 0.0, 160.0f, 35.0f);
        CGPathRef pathRef = [[UIBezierPath bezierPathWithRoundedRect:topButtonFrame cornerRadius:CGRectGetMidY(topButtonFrame)] CGPath];
        
        /*      Subclass     */
         self.topButton = [SKShapeNode shapeNodeWithPath:pathRef centered:YES];
        [self.topButton setFillColor:[SKColor flatPeterRiverColor]];
        [self.topButton setLineWidth:0.0f];
        [self.topButton setName:@"Top"];
        [self.topButton setPosition:CGPointMake(0.0, -60.0f)];
        [self.container addChild:self.topButton];
        
        SKLabelNode *topLabel = [[SKLabelNode alloc] initWithFontNamed:@"GillSans-Light"];
        [topLabel setUserInteractionEnabled:NO];
        [topLabel setPosition:CGPointMake(0.0f, 0.0f)];
        [topLabel setFontSize:22.0f];
        [topLabel setName:@"Top"];
        [topLabel setFontColor:[SKColor whiteColor]];
        [topLabel setText:@"Restart"];
        [topLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [topLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [self.topButton addChild:topLabel];
        /*      End    */
        
        /*      Subclass     */
         self.bottomButton = [SKShapeNode shapeNodeWithPath:pathRef centered:YES];
        [self.bottomButton setFillColor:[SKColor flatEmeraldColor]];
        [self.bottomButton setLineWidth:0.0f];
        [self.bottomButton setName:@"Bottom"];
        [self.bottomButton setPosition:CGPointMake(0.0, -100.0f)];
        [self.container addChild:self.bottomButton];
        
        SKLabelNode *bottomLabel = [[SKLabelNode alloc] initWithFontNamed:@"GillSans-Light"];
        [bottomLabel setUserInteractionEnabled:NO];
        [bottomLabel setPosition:CGPointMake(0.0f, 0.0f)];
        [bottomLabel setFontSize:22.0f];
        [bottomLabel setFontColor:[SKColor whiteColor]];
        [bottomLabel setText:@"Back to Map"];
        [bottomLabel setName:@"Bottom"];
        [bottomLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [bottomLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [self.bottomButton addChild:bottomLabel];
        /*      End     */
        
        SKLabelNode *levelLabel = [[SKLabelNode alloc] initWithFontNamed:@"GillSans-Light"];
        [levelLabel setPosition:CGPointMake(0.0f, CGRectGetHeight(self.container.frame) / 2.75)];
        [levelLabel setFontSize:28.0f];
        [levelLabel setFontColor:[SKColor whiteColor]];
        [levelLabel setText:[NSString stringWithFormat:@"Level %ld", [ADelegate previousLevel]]];
        [levelLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [levelLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [self.container addChild:levelLabel];
        
    }
    return self;
}

- (void)show
{
    [self.container runAction:[SKAction moveToX:0.0f duration:.3f]];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch   = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKNode *node = [self nodeAtPoint:location];

    if (self.delegate && [self.delegate respondsToSelector:@selector(alertNode:clickedButtonAtIndex:)]) {
        if ([node.name isEqualToString:@"Top"]) {
            [self.delegate alertNode:self clickedButtonAtIndex:0];
        } else if ([node.name isEqualToString:@"Bottom"]) {
            [self.delegate alertNode:self clickedButtonAtIndex:1];
        }
    }
}


@end
