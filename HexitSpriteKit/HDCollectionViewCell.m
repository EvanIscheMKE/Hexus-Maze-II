//
//  HDCollectionViewCell.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/21/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDCollectionViewCell.h"
#import "HDLevelViewCell.h"

@implementation HDCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [layout setMinimumInteritemSpacing:20];
        [layout setMinimumLineSpacing:20];
        [layout setSectionInset:UIEdgeInsetsMake(25.0f, 20.0f, 20.0f, 20.0f)];
        [layout setItemSize:CGSizeMake(ceilf(CGRectGetWidth(self.bounds)/4), ceilf(CGRectGetWidth(self.bounds)/4))];
        
         self.gridCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [self.gridCollectionView registerClass:[HDLevelViewCell class] forCellWithReuseIdentifier:levelCellReuseIdentifer];
        [self.gridCollectionView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.gridCollectionView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.gridCollectionView setFrame:self.contentView.bounds];
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    [self.gridCollectionView setTag:tag];
}

@end
