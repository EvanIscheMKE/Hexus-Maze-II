//
//  HDAlertNode.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/22/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol HDAlertnodeDelegate;
@interface HDAlertNode : SKSpriteNode
@property (nonatomic, weak) id <HDAlertnodeDelegate> delegate;
@property (nonatomic, strong) SKLabelNode *levelLabel;

- (void)show;

@end

@protocol HDAlertnodeDelegate <NSObject>
@optional

- (void)alertNode:(HDAlertNode *)alertNode clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)alertNodeWillDismiss:(HDAlertNode *)alertNode;

@end
