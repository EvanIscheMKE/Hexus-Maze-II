//
//  HDMapScene.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import SpriteKit;

@class HDGridManager;
@interface HDMapScene : SKScene

@property (nonatomic, strong) HDGridManager *gridManager;

- (void)layoutNodesWithGrid:(NSArray *)grid;

@end
