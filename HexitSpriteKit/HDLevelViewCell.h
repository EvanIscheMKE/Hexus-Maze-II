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

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *indexLabel;

@end
