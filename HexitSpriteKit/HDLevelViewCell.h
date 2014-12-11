//
//  HDLevelViewCell.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/21/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const levelCellReuseIdentifer;

@interface HDLevelViewCell : UICollectionViewCell

@property (nonatomic, assign) BOOL animate;
@property (nonatomic, assign) BOOL completed;

@property (nonatomic, strong) CAShapeLayer *hexagonLayer;

@property (nonatomic, strong) UIImageView *middleStar;

@property (nonatomic, strong) UILabel *indexLabel;

@end
