//
//  HDCollectionViewCell.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/21/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDCollectionViewCell.h"
#import "HDLevelViewCell.h"

@interface HDCollectionViewCell ()

@end

@implementation HDCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [layout setMinimumInteritemSpacing:20];
        [layout setMinimumLineSpacing:20];
        [layout setSectionInset:UIEdgeInsetsMake(30.0, 30.0f, 20.0f, 30.0f)];
        [layout setItemSize:CGSizeMake(ceilf(CGRectGetWidth(self.bounds)/4.4f), ceilf(CGRectGetWidth(self.bounds)/4.4f))];
        
         self.collectionViewGrid = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [self.collectionViewGrid registerClass:[HDLevelViewCell class] forCellWithReuseIdentifier:levelCellReuseIdentifer];
        [self.collectionViewGrid setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.collectionViewGrid];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.collectionViewGrid setFrame:self.contentView.bounds];
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    [self.collectionViewGrid setTag:tag];
}

@end
