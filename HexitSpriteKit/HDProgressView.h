//
//  HDProgressView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/15/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDProgressView : UIView

@property (nonatomic, assign) NSInteger remainingTileCount;
@property (nonatomic, strong) UILabel *countLabel;

- (void)decreaseTileCountByUno;

@end
